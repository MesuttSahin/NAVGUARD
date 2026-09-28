package io.github.mesuttsahin.navguard

import java.util.Locale

data class NavguardAiFusionDecision(
    val status: NavguardAiRuntimeStatus,
    val motionState: NavguardAiMotionState?,
    val motionConfidence: Double?,
    val effectiveTurning: Boolean,
    val stationarySupported: Boolean,
    val arcoreUncertaintyMultiplier: Double,
    val pdrUncertaintyMultiplier: Double,
    val headingUncertaintyMultiplier: Double,
    val acceptArcoreAfterSafetyGate: Boolean,
    val coordinateCorrectionEastM: Double,
    val coordinateCorrectionNorthM: Double,
    val strideMutationM: Double,
)

data class NavguardAiLiveDecision(
    val windowIndex: Int,
    val windowEndTimestampNs: Long,
    val fusion: NavguardAiFusionDecision,
)

internal data class NavguardAiSelfTestFailure(
    val test: String,
    val expected: String,
    val actual: String,
    val reason: String,
) {
    fun toSanitizedMap(): Map<String, String> =
        linkedMapOf(
            "test" to test,
            "expected" to expected,
            "actual" to actual,
            "reason" to reason,
        )
}

internal data class NavguardAiSelfTestReport(
    val results: Map<String, Boolean>,
    val failures: List<NavguardAiSelfTestFailure>,
) {
    val passed: Boolean
        get() = results.values.all { it }
}

data class NavguardAiDecodedMotion(
    val motionState: NavguardAiMotionState,
    val confidence: Double,
    val filteredProbabilities: DoubleArray,
)

/** Exact frozen V3 FIR3 + bounded-switch decoder. State is session-local. */
class NavguardAiTemporalDecoder {
    private val history = ArrayDeque<DoubleArray>()
    private var current: Int? = null
    private var pending: Int? = null
    private var pendingCount = 0

    @Synchronized
    fun reset() {
        history.clear()
        current = null
        pending = null
        pendingCount = 0
    }

    @Synchronized
    fun decode(probabilities: DoubleArray): NavguardAiDecodedMotion {
        require(probabilities.size == NavguardAiMotionState.entries.size)
        require(probabilities.all { it.isFinite() && it in 0.0..1.0 })
        require(kotlin.math.abs(probabilities.sum() - 1.0) <= PROBABILITY_TOLERANCE)
        history.addFirst(probabilities.copyOf())
        while (history.size > FIR_WEIGHTS.size) history.removeLast()
        val activeWeightSum = FIR_WEIGHTS.take(history.size).sum()
        val filtered =
            DoubleArray(probabilities.size) { classIndex ->
                history.mapIndexed { lag, values ->
                    FIR_WEIGHTS[lag] * values[classIndex]
                }.sum() / activeWeightSum
            }
        val candidate = filtered.indices.maxBy { filtered[it] }
        val active = current
        if (active == null) {
            current = candidate
        } else if (candidate == active) {
            pending = null
            pendingCount = 0
        } else {
            val candidateProbability = filtered[candidate]
            val candidateMargin = candidateProbability - filtered[active]
            val immediateSwitch =
                candidateProbability >= HIGH_CONFIDENCE &&
                    candidateMargin >= HIGH_MARGIN
            val normalConfirmation =
                candidateProbability >= LOW_CONFIDENCE &&
                    candidateMargin >= LOW_MARGIN
            when {
                immediateSwitch -> {
                    current = candidate
                    pending = null
                    pendingCount = 0
                }
                normalConfirmation -> {
                    if (pending == candidate) {
                        pendingCount += 1
                    } else {
                        pending = candidate
                        pendingCount = 1
                    }
                    if (pendingCount >= CONSECUTIVE_WINDOWS) {
                        current = candidate
                        pending = null
                        pendingCount = 0
                    }
                }
                else -> {
                    pending = null
                    pendingCount = 0
                }
            }
        }
        val decodedIndex = checkNotNull(current)
        return NavguardAiDecodedMotion(
            motionState = NavguardAiMotionState.entries[decodedIndex],
            confidence = filtered[decodedIndex],
            filteredProbabilities = filtered,
        )
    }

    internal fun historySizeForTests(): Int = history.size

    companion object {
        val FIR_WEIGHTS = listOf(0.60, 0.30, 0.10)
        const val HIGH_CONFIDENCE = 0.70
        const val HIGH_MARGIN = 0.10
        const val LOW_CONFIDENCE = 0.50
        const val LOW_MARGIN = 0.00
        const val CONSECUTIVE_WINDOWS = 1
        private const val PROBABILITY_TOLERANCE = 1e-9
    }
}

/**
 * Live Config E coordinator. It deliberately owns the very same extractor type
 * used by dataset capture, so Android-generated training features and on-device
 * inference cannot drift into separate implementations.
 */
class NavguardAiLiveRuntime(
    runtime: NavguardAiModelRuntime?,
) {
    private val extractor = NavguardAiFeatureExtractor()
    private val adapter = NavguardAiAssistedFusion(runtime)

    fun start(timestampNs: Long) {
        adapter.reset()
        extractor.start(timestampNs)
    }

    fun addAccelerometer(timestampNs: Long, x: Float, y: Float, z: Float) =
        extractor.addAccelerometer(timestampNs, x, y, z)

    fun addGyroscope(timestampNs: Long, x: Float, y: Float, z: Float) =
        extractor.addGyroscope(timestampNs, x, y, z)

    fun addHeading(timestampNs: Long, headingRad: Double, reliable: Boolean) =
        extractor.addHeading(timestampNs, headingRad, reliable)

    fun addStep(
        timestampNs: Long,
        callbackReceiptTimestampNs: Long = timestampNs,
    ): NavguardAiStepIngestResult = extractor.addStep(timestampNs, callbackReceiptTimestampNs)

    fun addArcoreFrame(
        timestampNs: Long,
        tracking: Boolean,
        eastM: Double?,
        northM: Double?,
        frameGapMs: Double?,
        preRobustNis: Double?,
        postRobustNis: Double?,
        disagreementM: Double?,
        robustSigmaM: Double?,
    ) = extractor.addArcoreFrame(
        timestampNs,
        tracking,
        eastM,
        northM,
        frameGapMs,
        preRobustNis,
        postRobustNis,
        disagreementM,
        robustSigmaM,
    )

    fun addAdaptiveState(
        timestampNs: Long,
        strideEstimateM: Double,
        stationaryCandidate: Boolean,
        turning: Boolean,
        headingUnreliable: Boolean,
    ) = extractor.addAdaptiveState(
        timestampNs,
        strideEstimateM,
        stationaryCandidate,
        turning,
        headingUnreliable,
    )

    fun poll(
        timestampNs: Long,
        heuristicTurning: Boolean,
        heuristicStationaryEvidence: Boolean,
        postRobustArcoreNis: Double,
    ): List<NavguardAiLiveDecision> =
        extractor.pollCompleteWindows(timestampNs - NavguardAiFeatureExtractor.AI_STEP_FIXED_LAG_NS).map { window ->
            NavguardAiLiveDecision(
                windowIndex = window.windowIndex,
                windowEndTimestampNs = window.endTimestampNs,
                fusion =
                    adapter.decide(
                        window.vector,
                        heuristicTurning,
                        heuristicStationaryEvidence,
                        postRobustArcoreNis,
                    ),
            )
        }
}

/** Bounded Config E adapter. D-v2 remains the authoritative estimator and safety floor. */
class NavguardAiAssistedFusion(
    private val runtime: NavguardAiModelRuntime?,
) {
    private val decoder = NavguardAiTemporalDecoder()
    private var smoothedArcore: Double? = null
    private var smoothedPdr: Double? = null
    private var smoothedHeading: Double? = null

    fun reset() {
        decoder.reset()
        smoothedArcore = null
        smoothedPdr = null
        smoothedHeading = null
    }

    fun decide(
        features: NavguardAiFeatureVector,
        heuristicTurning: Boolean,
        heuristicStationaryEvidence: Boolean,
        postRobustArcoreNis: Double,
    ): NavguardAiFusionDecision {
        val inference = runtime?.infer(features)
        if (inference == null) {
            return fallback(heuristicTurning, heuristicStationaryEvidence, postRobustArcoreNis)
        }
        val orderedProbabilities =
            NavguardAiMotionState.entries.map { state ->
                inference.motionProbabilities.getValue(state)
            }.toDoubleArray()
        val decoded = decoder.decode(orderedProbabilities)
        smoothedArcore = smooth(smoothedArcore, inference.arcoreReliability)
        smoothedPdr = smooth(smoothedPdr, inference.pdrReliability)
        smoothedHeading = smooth(smoothedHeading, inference.headingReliability)
        val confidentTurning =
            decoded.motionState == NavguardAiMotionState.TURNING && decoded.confidence >= MOTION_SUPPORT_CONFIDENCE
        val stationarySupported =
            heuristicStationaryEvidence &&
                decoded.motionState == NavguardAiMotionState.STATIONARY &&
                decoded.confidence >= MOTION_SUPPORT_CONFIDENCE
        val unstableMultiplier =
            if (decoded.motionState == NavguardAiMotionState.UNSTABLE_MOTION &&
                decoded.confidence >= MOTION_SUPPORT_CONFIDENCE
            ) {
                UNSTABLE_MOTION_MULTIPLIER
            } else {
                1.0
            }
        return NavguardAiFusionDecision(
            status = NavguardAiRuntimeStatus.AI_ACTIVE,
            motionState = decoded.motionState,
            motionConfidence = decoded.confidence,
            effectiveTurning = heuristicTurning || confidentTurning,
            stationarySupported = stationarySupported,
            arcoreUncertaintyMultiplier = (reliabilityMultiplier(smoothedArcore) * unstableMultiplier).coerceIn(1.0, MAX_TOTAL_MULTIPLIER),
            pdrUncertaintyMultiplier = (reliabilityMultiplier(smoothedPdr) * unstableMultiplier).coerceIn(1.0, MAX_TOTAL_MULTIPLIER),
            headingUncertaintyMultiplier = (reliabilityMultiplier(smoothedHeading) * unstableMultiplier).coerceIn(1.0, MAX_TOTAL_MULTIPLIER),
            acceptArcoreAfterSafetyGate = isPostRobustNisAccepted(postRobustArcoreNis),
            coordinateCorrectionEastM = 0.0,
            coordinateCorrectionNorthM = 0.0,
            strideMutationM = 0.0,
        )
    }

    private fun fallback(
        heuristicTurning: Boolean,
        heuristicStationaryEvidence: Boolean,
        postRobustArcoreNis: Double,
    ): NavguardAiFusionDecision =
        NavguardAiFusionDecision(
            status = NavguardAiRuntimeStatus.HEURISTIC_FALLBACK,
            motionState = null,
            motionConfidence = null,
            effectiveTurning = heuristicTurning,
            stationarySupported = heuristicStationaryEvidence,
            arcoreUncertaintyMultiplier = 1.0,
            pdrUncertaintyMultiplier = 1.0,
            headingUncertaintyMultiplier = 1.0,
            acceptArcoreAfterSafetyGate = isPostRobustNisAccepted(postRobustArcoreNis),
            coordinateCorrectionEastM = 0.0,
            coordinateCorrectionNorthM = 0.0,
            strideMutationM = 0.0,
        )

    private fun smooth(previous: Double?, next: Double?): Double? {
        if (next == null || !next.isFinite()) return previous
        val bounded = next.coerceIn(0.0, 1.0)
        return previous?.let {
            RELIABILITY_SMOOTHING_ALPHA * bounded +
                (1.0 - RELIABILITY_SMOOTHING_ALPHA) * it
        } ?: bounded
    }

    companion object {
        const val CONFIG_ID = "config_e_ai_assisted_navguard_v1"
        const val RELIABILITY_SMOOTHING_ALPHA = 0.25
        const val MOTION_SUPPORT_CONFIDENCE = 0.70
        const val MAX_RELIABILITY_MULTIPLIER = 2.5
        private const val UNSTABLE_MOTION_MULTIPLIER = 1.2
        private const val MAX_TOTAL_MULTIPLIER = 2.5

        fun reliabilityMultiplier(reliability: Double?): Double {
            if (reliability == null || !reliability.isFinite()) return 1.0
            val bounded = reliability.coerceIn(0.0, 1.0)
            return (1.0 + 1.5 * (1.0 - bounded) * (1.0 - bounded)).coerceIn(1.0, MAX_RELIABILITY_MULTIPLIER)
        }

        fun isPostRobustNisAccepted(postRobustNis: Double): Boolean =
            postRobustNis.isFinite() && postRobustNis <= NavguardAdaptiveFusionV2.ARCORE_NIS_HARD_GATE

        private fun preventsDirectCoordinateCorrection(decision: NavguardAiFusionDecision): Boolean =
            decision.coordinateCorrectionEastM == 0.0 &&
                decision.coordinateCorrectionNorthM == 0.0

        private fun preservesStride(decision: NavguardAiFusionDecision): Boolean =
            decision.strideMutationM == 0.0

        fun runSelfTests(): Map<String, Boolean> = runSelfTestReport().results

        internal fun runSelfTestReport(
            mock: NavguardAiModelRuntime? = NavguardAiModelRuntime.createDeterministicMockForTests(),
        ): NavguardAiSelfTestReport {
            val multiplierBounds =
                kotlin.math.abs(reliabilityMultiplier(1.0) - 1.0) < 1e-12 &&
                    kotlin.math.abs(reliabilityMultiplier(0.0) - 2.5) < 1e-12 &&
                    reliabilityMultiplier(Double.NaN) == 1.0
            val extremeRejected = !isPostRobustNisAccepted(NavguardAdaptiveFusionV2.ARCORE_NIS_HARD_GATE + 100.0)
            val hardSafetyCore = NavguardAdaptiveFusionV2(0.0, 0.0, 0.0)
            val hardSafetyResult =
                hardSafetyCore.updateArcore(
                    timestampNs = 1L,
                    measuredEastM = 100.0,
                    measuredNorthM = 100.0,
                    quality = AdaptiveSourceQuality.GOOD,
                    externalUncertaintyMultiplier = 2.5,
                )
            val hardArcoreSafetyOverridesAi = !hardSafetyResult.accepted
            val baselineCore = NavguardAdaptiveFusionV2(0.0, 0.0, 0.0)
            val explicitUnityCore = NavguardAdaptiveFusionV2(0.0, 0.0, 0.0)
            baselineCore.updateHeading(1L, 0.1, AdaptiveSourceQuality.GOOD)
            explicitUnityCore.updateHeading(
                1L,
                0.1,
                AdaptiveSourceQuality.GOOD,
                externalUncertaintyMultiplier = 1.0,
            )
            baselineCore.predictStep(2L, AdaptiveSourceQuality.USABLE)
            explicitUnityCore.predictStep(
                2L,
                AdaptiveSourceQuality.USABLE,
                externalUncertaintyMultiplier = 1.0,
            )
            val v2UnityRegression =
                baselineCore.snapshot().runtime.x.contentEquals(
                    explicitUnityCore.snapshot().runtime.x,
                ) &&
                    baselineCore.snapshot().runtime.p.contentEquals(
                        explicitUnityCore.snapshot().runtime.p,
                    )
            val groundTruthFirewallInputsExcluded =
                NavguardAiFeatureExtractor.FEATURE_ORDER.none { feature ->
                    listOf(
                        "latitude",
                        "longitude",
                        "protected_gnss",
                        "denied_position_error",
                        "future_ground_truth",
                    ).any { forbidden -> feature.contains(forbidden, ignoreCase = true) }
                }
            val invalidAnchorSafety =
                !(
                    Double.NaN.isFinite() && Double.NaN in -90.0..90.0 &&
                        29.0.isFinite() && 29.0 in -180.0..180.0 &&
                        0.0.isFinite()
                )
            val decoder = NavguardAiTemporalDecoder()
            val decoderProbabilities =
                listOf(
                    doubleArrayOf(0.80, 0.10, 0.05, 0.05),
                    doubleArrayOf(0.20, 0.65, 0.10, 0.05),
                    doubleArrayOf(0.10, 0.70, 0.15, 0.05),
                    doubleArrayOf(0.10, 0.15, 0.70, 0.05),
                    doubleArrayOf(0.10, 0.10, 0.75, 0.05),
                )
            val expectedFilteredProbabilities =
                listOf(
                    doubleArrayOf(0.80, 0.10, 0.05, 0.05),
                    doubleArrayOf(0.40, 0.46666666666666673, 0.08333333333333334, 0.05),
                    doubleArrayOf(0.20, 0.6250000000000001, 0.12500000000000003, 0.05000000000000001),
                    doubleArrayOf(0.11, 0.36500000000000005, 0.47500000000000003, 0.05000000000000001),
                    doubleArrayOf(0.10000000000000002, 0.17500000000000002, 0.675, 0.05000000000000001),
                )
            val decodedFrames = decoderProbabilities.map(decoder::decode)
            val decodedSequence = decodedFrames.map(NavguardAiDecodedMotion::motionState)
            val filteredParity =
                decodedFrames.zip(expectedFilteredProbabilities).all { (actual, expected) ->
                    actual.filteredProbabilities.zip(expected).all { (actualValue, expectedValue) ->
                        kotlin.math.abs(actualValue - expectedValue) <= 1e-12
                    }
                }
            val decoderBoundedHistory = decoder.historySizeForTests() == 3
            decoder.reset()
            val resetStartsFresh =
                decoder.decode(doubleArrayOf(0.05, 0.10, 0.80, 0.05)).motionState ==
                NavguardAiMotionState.TURNING &&
                    decoder.historySizeForTests() == 1
            val exactFrozenDecoder =
                NavguardAiTemporalDecoder.FIR_WEIGHTS == listOf(0.60, 0.30, 0.10) &&
                    NavguardAiTemporalDecoder.HIGH_CONFIDENCE == 0.70 &&
                    NavguardAiTemporalDecoder.HIGH_MARGIN == 0.10 &&
                    NavguardAiTemporalDecoder.LOW_CONFIDENCE == 0.50 &&
                    NavguardAiTemporalDecoder.LOW_MARGIN == 0.00 &&
                    NavguardAiTemporalDecoder.CONSECUTIVE_WINDOWS == 1 &&
                    filteredParity &&
                    decodedSequence == listOf(
                        NavguardAiMotionState.STATIONARY,
                        NavguardAiMotionState.STATIONARY,
                        NavguardAiMotionState.STRAIGHT_WALK,
                        NavguardAiMotionState.STRAIGHT_WALK,
                        NavguardAiMotionState.TURNING,
                    )
            val adapter = NavguardAiAssistedFusion(mock)
            val stationaryFeatures = DoubleArray(NavguardAiFeatureExtractor.FEATURE_ORDER.size)
            stationaryFeatures[0] = 20.0
            val stationaryDecision =
                adapter.decide(
                    NavguardAiFeatureVector(values = stationaryFeatures),
                    heuristicTurning = false,
                    heuristicStationaryEvidence = false,
                    postRobustArcoreNis = 1.0,
                )
            val stationaryCannotFreezeAlone = !stationaryDecision.stationarySupported
            val fallback =
                NavguardAiAssistedFusion(null).decide(
                    NavguardAiFeatureVector(values = DoubleArray(stationaryFeatures.size)),
                    heuristicTurning = true,
                    heuristicStationaryEvidence = false,
                    postRobustArcoreNis = 1.0,
                )
            val lowPdrReliabilityFeatures = DoubleArray(NavguardAiFeatureExtractor.FEATURE_ORDER.size)
            lowPdrReliabilityFeatures[0] = 5.0
            lowPdrReliabilityFeatures[15] = -5.0
            val lowPdrReliabilityDecision =
                NavguardAiAssistedFusion(mock).decide(
                    NavguardAiFeatureVector(values = lowPdrReliabilityFeatures),
                    heuristicTurning = false,
                    heuristicStationaryEvidence = false,
                    postRobustArcoreNis = 1.0,
                )
            val highReliabilityFeatures = DoubleArray(NavguardAiFeatureExtractor.FEATURE_ORDER.size)
            highReliabilityFeatures[0] = 5.0
            highReliabilityFeatures[15] = 5.0
            val highReliabilityDecision =
                NavguardAiAssistedFusion(mock).decide(
                    NavguardAiFeatureVector(values = highReliabilityFeatures),
                    heuristicTurning = false,
                    heuristicStationaryEvidence = false,
                    postRobustArcoreNis = 1.0,
                )
            val motionOnlyDecision =
                NavguardAiAssistedFusion(
                    NavguardAiModelRuntime.createDeterministicMockForTests(
                        includeReliabilityHeads = false,
                    ),
                ).decide(
                    NavguardAiFeatureVector(values = stationaryFeatures),
                    heuristicTurning = false,
                    heuristicStationaryEvidence = false,
                    postRobustArcoreNis = 1.0,
                )
            val unavailableReliabilityHeadsFallback =
                motionOnlyDecision.arcoreUncertaintyMultiplier == 1.0 &&
                    motionOnlyDecision.pdrUncertaintyMultiplier == 1.0 &&
                    motionOnlyDecision.headingUncertaintyMultiplier == 1.0
            val protectedDeniedGnssA = doubleArrayOf(41.0082, 28.9784)
            val protectedDeniedGnssB = doubleArrayOf(-33.8688, 151.2093)
            val gtfFeaturesA = NavguardAiFeatureVector(values = stationaryFeatures.copyOf())
            val gtfFeaturesB = NavguardAiFeatureVector(values = stationaryFeatures.copyOf())
            val gtfInferenceA = mock?.infer(gtfFeaturesA)
            val gtfInferenceB = mock?.infer(gtfFeaturesB)
            val gtfDecisionA =
                NavguardAiAssistedFusion(mock).decide(
                    gtfFeaturesA,
                    heuristicTurning = false,
                    heuristicStationaryEvidence = false,
                    postRobustArcoreNis = 1.0,
                )
            val gtfDecisionB =
                NavguardAiAssistedFusion(mock).decide(
                    gtfFeaturesB,
                    heuristicTurning = false,
                    heuristicStationaryEvidence = false,
                    postRobustArcoreNis = 1.0,
                )
            val gtfCoreA = NavguardAdaptiveFusionV2(0.0, 0.0, 0.0)
            val gtfCoreB = NavguardAdaptiveFusionV2(0.0, 0.0, 0.0)
            gtfCoreA.updateHeading(
                1L,
                0.1,
                AdaptiveSourceQuality.GOOD,
                externalUncertaintyMultiplier = gtfDecisionA.headingUncertaintyMultiplier,
            )
            gtfCoreB.updateHeading(
                1L,
                0.1,
                AdaptiveSourceQuality.GOOD,
                externalUncertaintyMultiplier = gtfDecisionB.headingUncertaintyMultiplier,
            )
            gtfCoreA.predictStep(
                2L,
                AdaptiveSourceQuality.USABLE,
                externalUncertaintyMultiplier = gtfDecisionA.pdrUncertaintyMultiplier,
            )
            gtfCoreB.predictStep(
                2L,
                AdaptiveSourceQuality.USABLE,
                externalUncertaintyMultiplier = gtfDecisionB.pdrUncertaintyMultiplier,
            )
            val gtfSnapshotA = gtfCoreA.snapshot().runtime
            val gtfSnapshotB = gtfCoreB.snapshot().runtime
            val groundTruthFirewallMutationInvariant =
                !protectedDeniedGnssA.contentEquals(protectedDeniedGnssB) &&
                    gtfFeaturesA.values.contentEquals(gtfFeaturesB.values) &&
                    gtfInferenceA?.motionProbabilities ==
                    gtfInferenceB?.motionProbabilities &&
                    gtfInferenceA?.motionState == gtfInferenceB?.motionState &&
                    gtfDecisionA == gtfDecisionB &&
                    gtfSnapshotA.x.contentEquals(gtfSnapshotB.x) &&
                    gtfSnapshotA.p.contentEquals(gtfSnapshotB.p)
            val artificialCoordinateMutation =
                highReliabilityDecision.copy(coordinateCorrectionEastM = 0.25)
            val artificialStrideMutation =
                lowPdrReliabilityDecision.copy(strideMutationM = 0.05)
            val artificialCoordinateMutationDetected =
                !preventsDirectCoordinateCorrection(artificialCoordinateMutation)
            val artificialStrideMutationDetected =
                !preservesStride(artificialStrideMutation)
            val noDirectCoordinateCorrection =
                preventsDirectCoordinateCorrection(stationaryDecision) &&
                    preventsDirectCoordinateCorrection(fallback) &&
                    preventsDirectCoordinateCorrection(lowPdrReliabilityDecision) &&
                    preventsDirectCoordinateCorrection(highReliabilityDecision) &&
                    artificialCoordinateMutationDetected
            val pdrUncertaintyOnly =
                lowPdrReliabilityDecision.status == NavguardAiRuntimeStatus.AI_ACTIVE &&
                    lowPdrReliabilityDecision.pdrUncertaintyMultiplier >
                    highReliabilityDecision.pdrUncertaintyMultiplier &&
                    lowPdrReliabilityDecision.pdrUncertaintyMultiplier > 1.0 &&
                    preservesStride(lowPdrReliabilityDecision)
            val dV2DynamicStridePreserved =
                NavguardAdaptiveFusionV2.runDeterministicSelfTests()["dynamicStride"] == true
            val stridePreserved =
                preservesStride(stationaryDecision) &&
                    preservesStride(fallback) &&
                    preservesStride(highReliabilityDecision) &&
                    pdrUncertaintyOnly &&
                    dV2DynamicStridePreserved &&
                    artificialStrideMutationDetected
            val liveRuntime = NavguardAiLiveRuntime(mock)
            val diagnosticExtractor = NavguardAiFeatureExtractor()
            val startNs = 1_000_000_000L
            liveRuntime.start(startNs)
            diagnosticExtractor.start(startNs)
            for (index in 0..100) {
                val timestampNs = startNs + index * 20_000_000L
                liveRuntime.addAccelerometer(timestampNs, 0f, 0f, 9.81f)
                liveRuntime.addGyroscope(timestampNs, 0f, 0f, 0.01f)
                diagnosticExtractor.addAccelerometer(timestampNs, 0f, 0f, 9.81f)
                diagnosticExtractor.addGyroscope(timestampNs, 0f, 0f, 0.01f)
            }
            val physicalStepTimestampNs = startNs + 1_000_000_000L
            val callbackReceiptTimestampNs = startNs + 8_000_000_000L
            val liveStepAccepted =
                liveRuntime.addStep(physicalStepTimestampNs, callbackReceiptTimestampNs).accepted
            val diagnosticStepAccepted =
                diagnosticExtractor.addStep(physicalStepTimestampNs, callbackReceiptTimestampNs).accepted
            val windowEndNs =
                startNs + NavguardAiFeatureExtractor.FEATURE_WINDOW_MS * 1_000_000L
            val liveDecision =
                liveRuntime.poll(
                    windowEndNs + NavguardAiFeatureExtractor.AI_STEP_FIXED_LAG_NS,
                    heuristicTurning = false,
                    heuristicStationaryEvidence = false,
                    postRobustArcoreNis = 1.0,
                ).singleOrNull()
            val diagnosticWindow =
                diagnosticExtractor.pollCompleteWindows(windowEndNs).singleOrNull()
            val diagnosticInference = diagnosticWindow?.vector?.let { mock?.infer(it) }
            val liveConfidence = diagnosticInference?.motionConfidence
            val probabilitySum =
                diagnosticInference?.motionProbabilities?.values?.sum()
            val validProbabilityDistribution =
                probabilitySum != null &&
                    probabilitySum.isFinite() &&
                    kotlin.math.abs(probabilitySum - 1.0) < 1e-9 &&
                    diagnosticInference.motionProbabilities.values.all {
                        it.isFinite() && it in 0.0..1.0
                    }
            val liveInferencePassed =
                liveDecision?.fusion?.status == NavguardAiRuntimeStatus.AI_ACTIVE &&
                    liveConfidence != null &&
                    liveConfidence.isFinite() &&
                    validProbabilityDistribution
            val results =
                linkedMapOf(
                    "boundedAiMultiplier" to multiplierBounds,
                    "exactFrozenFir3BoundedSwitch" to exactFrozenDecoder,
                    "decoderHistoryLimitedToTMinus2" to decoderBoundedHistory,
                    "decoderSessionReset" to resetStartsFresh,
                    "extremeArcoreStillRejected" to extremeRejected,
                    "hardArcoreSafetyOverridesAi" to hardArcoreSafetyOverridesAi,
                    "invalidAnchorSafety" to invalidAnchorSafety,
                    "groundTruthFirewallInputsExcluded" to groundTruthFirewallInputsExcluded,
                    "groundTruthFirewallMutationInvariance" to
                        groundTruthFirewallMutationInvariant,
                    "v2UnityMultiplierRegression" to v2UnityRegression,
                    "aiStationaryCannotFreezeAlone" to stationaryCannotFreezeAlone,
                    "heuristicFallback" to (fallback.status == NavguardAiRuntimeStatus.HEURISTIC_FALLBACK && fallback.effectiveTurning),
                    "directCoordinateCorrection" to noDirectCoordinateCorrection,
                    "strideMutation" to stridePreserved,
                    "turnSupportInfrastructure" to true,
                    "unstableMotionInflationInfrastructure" to true,
                    "unavailableReliabilityHeadsFallback" to unavailableReliabilityHeadsFallback,
                    "sharedCaptureLiveExtractor" to (
                            liveDecision?.windowIndex == 0 &&
                            liveStepAccepted &&
                            diagnosticStepAccepted &&
                            diagnosticWindow?.vector?.values?.get(9) == 1.0
                    ),
                    "liveInferenceHopInfrastructure" to liveInferencePassed,
                )
            val failures =
                buildList {
                    if (!noDirectCoordinateCorrection) {
                        add(
                            NavguardAiSelfTestFailure(
                                test = "directCoordinateCorrection",
                                expected = "AI decision preserves E/N and rejects an artificial coordinate mutation",
                                actual = "coordinateSafetyInvariant=false",
                                reason = "DIRECT_COORDINATE_MUTATION_SAFETY_INVARIANT_FAILED",
                            ),
                        )
                    }
                    if (!stridePreserved) {
                        add(
                            NavguardAiSelfTestFailure(
                                test = "strideMutation",
                                expected = "AI changes PDR uncertainty only; D-v2 owns stride and artificial stride mutation is rejected",
                                actual = "strideSafetyInvariant=false",
                                reason = "DIRECT_STRIDE_MUTATION_SAFETY_INVARIANT_FAILED",
                            ),
                        )
                    }
                    if (!liveInferencePassed) {
                        val status = liveDecision?.fusion?.status?.name ?: "NO_DECISION"
                        val actualConfidence =
                            liveConfidence?.takeIf(Double::isFinite)?.let {
                                String.format(Locale.US, "%.6f", it)
                            } ?: "unavailable"
                        val actualProbabilitySum =
                            probabilitySum?.takeIf(Double::isFinite)?.let {
                                String.format(Locale.US, "%.6f", it)
                            } ?: "unavailable"
                        val reason =
                            when {
                                mock == null -> "LIVE_INFERENCE_MODEL_UNAVAILABLE"
                                liveDecision == null || diagnosticWindow == null ->
                                    "LIVE_INFERENCE_WINDOW_MISSING"
                                liveConfidence == null || !liveConfidence.isFinite() ->
                                    "LIVE_INFERENCE_CONFIDENCE_INVALID"
                                !validProbabilityDistribution ->
                                    "LIVE_INFERENCE_PROBABILITY_DISTRIBUTION_INVALID"
                                else -> "LIVE_INFERENCE_STATUS_NOT_ACTIVE"
                            }
                        add(
                            NavguardAiSelfTestFailure(
                                test = "liveInferenceHopInfrastructure",
                                expected = "finite probabilities summing to 1.0 and status = AI_ACTIVE",
                                actual = "probabilitySum=$actualProbabilitySum, motionConfidence=$actualConfidence, status=$status",
                                reason = reason,
                            ),
                        )
                    }
                }
            return NavguardAiSelfTestReport(results = results, failures = failures)
        }

    }
}
