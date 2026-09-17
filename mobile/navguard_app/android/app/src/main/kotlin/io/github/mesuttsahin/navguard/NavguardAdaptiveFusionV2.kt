package io.github.mesuttsahin.navguard

import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.sin
import kotlin.math.sqrt

enum class AdaptiveSourceQuality {
    UNKNOWN,
    GOOD,
    USABLE,
    DEGRADED,
    UNRELIABLE,
    UNAVAILABLE,
}

enum class AdaptiveTurnState {
    STRAIGHT,
    TURNING,
    UNKNOWN,
}

data class AdaptiveGnssOriginCandidate(
    val timestampNs: Long,
    val eastM: Double,
    val northM: Double,
    val reportedAccuracyM: Double,
    val isMock: Boolean = false,
)

data class AdaptiveStableGnssOrigin(
    val eastM: Double,
    val northM: Double,
    val fixCount: Int,
    val eastSpreadM: Double,
    val northSpreadM: Double,
    val horizontalSpreadM: Double,
    val reportedAccuracyMedianM: Double,
) {
    fun toSanitizedMap(): Map<String, Any?> =
        linkedMapOf(
            "gnssStabilizationFixCount" to fixCount,
            "gnssStabilizationEastSpreadM" to eastSpreadM,
            "gnssStabilizationNorthSpreadM" to northSpreadM,
            "gnssStabilizationHorizontalSpreadM" to horizontalSpreadM,
            "gnssStabilizationReportedAccuracyMedianM" to reportedAccuracyMedianM,
        )
}

data class AdaptiveMeasurementResult(
    val accepted: Boolean,
    val sigmaM: Double,
    val innovationEastM: Double,
    val innovationNorthM: Double,
    val innovationNormM: Double,
    val nis: Double,
    val rejectionReason: String?,
)

internal data class AdaptiveHeadingObservation(
    val timestampNs: Long,
    val headingRad: Double,
)

internal data class AdaptiveArObservation(
    val timestampNs: Long,
    val eastM: Double,
    val northM: Double,
)

internal data class AdaptiveRuntimeState(
    var x: DoubleArray,
    var p: DoubleArray,
    val initialEastM: Double,
    val initialNorthM: Double,
    var strideEstimateM: Double,
    var bodyHeadingOffsetRad: Double,
    var strideCalibrationSampleCount: Long,
    var headingOffsetSampleCount: Long,
    var stepCount: Long = 0L,
    var strideMinM: Double = Double.POSITIVE_INFINITY,
    var strideMaxM: Double = Double.NEGATIVE_INFINITY,
    var strideSumM: Double = 0.0,
    var headingMeasurementCount: Long = 0L,
    var headingAcceptedCount: Long = 0L,
    var headingRejectedCount: Long = 0L,
    var headingInnovationSumRad: Double = 0.0,
    var headingInnovationMaxRad: Double = 0.0,
    var headingSigmaRad: Double = NavguardAdaptiveFusionV2.BASE_HEADING_SIGMA_RAD,
    var headingVariance: Double = 0.0,
    var latestDeviceHeadingRad: Double? = null,
    var turnState: AdaptiveTurnState = AdaptiveTurnState.UNKNOWN,
    val recentHeadings: MutableList<AdaptiveHeadingObservation> = mutableListOf(),
    var arcoreUpdateCount: Long = 0L,
    var arcoreAcceptedCount: Long = 0L,
    var arcoreAcceptedNominalCount: Long = 0L,
    var arcoreAcceptedInflatedCount: Long = 0L,
    var arcoreRejectedByQualityCount: Long = 0L,
    var arcoreRejectedByInnovationCount: Long = 0L,
    var arcoreRejectedStationaryDriftCount: Long = 0L,
    var arcoreInnovationEastM: Double = 0.0,
    var arcoreInnovationNorthM: Double = 0.0,
    var arcoreInnovationNormM: Double = 0.0,
    var arcoreNisLast: Double = 0.0,
    var arcoreNisSum: Double = 0.0,
    var arcoreNisMax: Double = 0.0,
    var arcoreNisCount: Long = 0L,
    var arcorePostRobustNisLast: Double = 0.0,
    var arcorePostRobustNisSum: Double = 0.0,
    var arcorePostRobustNisMax: Double = 0.0,
    var arcorePostRobustNisCount: Long = 0L,
    var arcoreAcceptedAfterRobustInflationCount: Long = 0L,
    var arcoreRejectedAfterMaxInflationCount: Long = 0L,
    var adaptiveArcoreSigmaM: Double = NavguardAdaptiveFusionV2.BASE_ARCORE_SIGMA_M,
    var adaptiveArcoreSigmaMinM: Double = Double.POSITIVE_INFINITY,
    var adaptiveArcoreSigmaMaxM: Double = 0.0,
    var adaptiveArcoreSigmaSumM: Double = 0.0,
    var adaptiveArcoreSigmaCount: Long = 0L,
    var arcoreRobustSigmaMaxM: Double = 0.0,
    var arcoreRobustSigmaSumM: Double = 0.0,
    var arcoreRobustSigmaCount: Long = 0L,
    var firstArEastM: Double? = null,
    var firstArNorthM: Double? = null,
    var lastArObservation: AdaptiveArObservation? = null,
    var calibrationArObservation: AdaptiveArObservation? = null,
    var stepsAtCalibrationAnchor: Long = 0L,
    var stationaryDetected: Boolean = false,
    var stationaryStartNs: Long? = null,
    var stationaryCandidateStartNs: Long? = null,
    var stationaryAccumulatedDurationNs: Long = 0L,
    var stationaryDetectedDurationMs: Long = 0L,
    var stationaryEntryCount: Long = 0L,
    var stationaryCandidateCount: Long = 0L,
    var stationaryBlockedRecentStepCount: Long = 0L,
    var stationaryBlockedHeadingMotionCount: Long = 0L,
    var stationaryBlockedArcoreMotionCount: Long = 0L,
    var stationaryBlockedOtherMotionCount: Long = 0L,
    var lastStepTimestampNs: Long = 0L,
    var sourceDisagreementM: Double = 0.0,
    var sourceDisagreementSumM: Double = 0.0,
    var sourceDisagreementMaxM: Double = 0.0,
    var sourceDisagreementCount: Long = 0L,
)

private fun AdaptiveRuntimeState.deepCopy(): AdaptiveRuntimeState =
    copy(
        x = x.copyOf(),
        p = p.copyOf(),
        recentHeadings = recentHeadings.toMutableList(),
        lastArObservation = lastArObservation?.copy(),
        calibrationArObservation = calibrationArObservation?.copy(),
    )

class NavguardAdaptiveFusionV2(
    initialEastM: Double,
    initialNorthM: Double,
    initialHeadingRad: Double,
    profile: NavguardCalibrationProfile = NavguardCalibrationProfileStore.read(),
) {
    class Snapshot internal constructor(internal val runtime: AdaptiveRuntimeState)

    private var runtime: AdaptiveRuntimeState

    init {
        require(initialEastM.isFinite() && initialNorthM.isFinite() && initialHeadingRad.isFinite())
        val safeProfile = profile.sanitized()
        runtime =
            AdaptiveRuntimeState(
                x = doubleArrayOf(initialEastM, initialNorthM, normalizeHeading(initialHeadingRad)),
                p =
                    doubleArrayOf(
                        0.01, 0.0, 0.0,
                        0.0, 0.01, 0.0,
                        0.0, 0.0, BASE_HEADING_SIGMA_RAD * BASE_HEADING_SIGMA_RAD,
                    ),
                initialEastM = initialEastM,
                initialNorthM = initialNorthM,
                strideEstimateM = safeProfile.strideEstimateM,
                bodyHeadingOffsetRad = safeProfile.bodyHeadingOffsetRad,
                strideCalibrationSampleCount = safeProfile.strideSampleCount,
                headingOffsetSampleCount = safeProfile.headingOffsetSampleCount,
            )
    }

    val eastM: Double get() = runtime.x[0]
    val northM: Double get() = runtime.x[1]
    val headingRad: Double get() = runtime.x[2]
    val horizontalCovarianceSummary: Double get() = sqrt(max(0.0, runtime.p[0] + runtime.p[4]))
    val strideEstimateM: Double get() = runtime.strideEstimateM
    val bodyHeadingOffsetRad: Double get() = runtime.bodyHeadingOffsetRad
    val turnState: AdaptiveTurnState get() = runtime.turnState
    val stationaryDetected: Boolean get() = runtime.stationaryDetected

    fun snapshot(): Snapshot = Snapshot(runtime.deepCopy())

    fun restore(snapshot: Snapshot) {
        runtime = snapshot.runtime.deepCopy()
        validateState()
    }

    fun calibrationProfile(): NavguardCalibrationProfile =
        NavguardCalibrationProfile(
            strideEstimateM = runtime.strideEstimateM,
            bodyHeadingOffsetRad = runtime.bodyHeadingOffsetRad,
            strideSampleCount = runtime.strideCalibrationSampleCount,
            headingOffsetSampleCount = runtime.headingOffsetSampleCount,
        ).sanitized()

    fun updateHeading(
        timestampNs: Long,
        measuredHeadingRad: Double,
        quality: AdaptiveSourceQuality,
        reportedAccuracyRad: Double? = null,
    ): Boolean {
        if (timestampNs <= 0L || !measuredHeadingRad.isFinite()) return false
        val measured = normalizeHeading(measuredHeadingRad)
        runtime.headingMeasurementCount += 1L
        updateHeadingWindow(timestampNs, measured)
        val innovation = circularDifference(measured, runtime.x[2])
        val absoluteInnovation = abs(innovation)
        runtime.headingInnovationSumRad += absoluteInnovation
        runtime.headingInnovationMaxRad = max(runtime.headingInnovationMaxRad, absoluteInnovation)
        val sigmaRad = adaptiveHeadingSigma(quality, reportedAccuracyRad)
        runtime.headingSigmaRad = sigmaRad
        val qualityAccepted =
            quality == AdaptiveSourceQuality.GOOD ||
                quality == AdaptiveSourceQuality.USABLE ||
                quality == AdaptiveSourceQuality.DEGRADED
        val isolatedOutlier =
            absoluteInnovation > HEADING_SINGLE_SAMPLE_HARD_GATE_RAD ||
                (
                    absoluteInnovation > HEADING_INNOVATION_GATE_RAD &&
                        runtime.turnState != AdaptiveTurnState.TURNING &&
                        runtime.headingVariance <= HEADING_STABLE_VARIANCE_GATE
                )
        if (!qualityAccepted || isolatedOutlier) {
            runtime.headingRejectedCount += 1L
            return false
        }
        updateHeadingEkf(measured, sigmaRad)
        runtime.headingAcceptedCount += 1L
        runtime.latestDeviceHeadingRad = measured
        if (runtime.turnState == AdaptiveTurnState.TURNING) {
            runtime.stationaryBlockedHeadingMotionCount += 1L
            exitStationary(timestampNs)
        }
        validateState()
        return true
    }

    fun predictStep(
        timestampNs: Long,
        quality: AdaptiveSourceQuality = AdaptiveSourceQuality.USABLE,
    ): Boolean {
        if (timestampNs <= 0L || quality == AdaptiveSourceQuality.UNRELIABLE || quality == AdaptiveSourceQuality.UNAVAILABLE) {
            return false
        }
        val stride = runtime.strideEstimateM.coerceIn(MIN_STRIDE_M, MAX_STRIDE_M)
        val walkingHeading = normalizeHeading(runtime.x[2] + runtime.bodyHeadingOffsetRad)
        val sinHeading = sin(walkingHeading)
        val cosHeading = cos(walkingHeading)
        val f =
            doubleArrayOf(
                1.0, 0.0, stride * cosHeading,
                0.0, 1.0, -stride * sinHeading,
                0.0, 0.0, 1.0,
            )
        val qualityMultiplier =
            when (quality) {
                AdaptiveSourceQuality.GOOD -> 1.0
                AdaptiveSourceQuality.USABLE -> 2.0
                AdaptiveSourceQuality.DEGRADED -> 6.0
                else -> 8.0
            }
        val sigmaLength2 = BASE_STEP_LENGTH_SIGMA_M * BASE_STEP_LENGTH_SIGMA_M * qualityMultiplier
        val sigmaHeading2 = BASE_STEP_HEADING_PROCESS_SIGMA_RAD * BASE_STEP_HEADING_PROCESS_SIGMA_RAD * qualityMultiplier
        val q =
            doubleArrayOf(
                sigmaLength2 * sinHeading * sinHeading,
                sigmaLength2 * sinHeading * cosHeading,
                0.0,
                sigmaLength2 * sinHeading * cosHeading,
                sigmaLength2 * cosHeading * cosHeading,
                0.0,
                0.0,
                0.0,
                sigmaHeading2,
            )
        runtime.p = symmetrize(addMatrices(multiplyMatrices(multiplyMatrices(f, runtime.p), transpose(f)), q))
        runtime.x[0] += stride * sinHeading
        runtime.x[1] += stride * cosHeading
        runtime.x[2] = normalizeHeading(runtime.x[2])
        runtime.stepCount += 1L
        runtime.strideMinM = minOf(runtime.strideMinM, stride)
        runtime.strideMaxM = max(runtime.strideMaxM, stride)
        runtime.strideSumM += stride
        runtime.lastStepTimestampNs = timestampNs
        exitStationary(timestampNs)
        validateState()
        return true
    }

    fun updateArcore(
        timestampNs: Long,
        measuredEastM: Double,
        measuredNorthM: Double,
        quality: AdaptiveSourceQuality,
        frameGapMs: Double? = null,
        allowCalibrationLearning: Boolean = true,
    ): AdaptiveMeasurementResult {
        runtime.arcoreUpdateCount += 1L
        if (timestampNs <= 0L || !measuredEastM.isFinite() || !measuredNorthM.isFinite()) {
            runtime.arcoreRejectedByQualityCount += 1L
            return rejectedArcore("invalid_measurement")
        }
        updateStationaryEvidence(timestampNs, measuredEastM, measuredNorthM)
        val innovationEast = measuredEastM - runtime.x[0]
        val innovationNorth = measuredNorthM - runtime.x[1]
        val innovationNorm = hypot(innovationEast, innovationNorth)
        recordDisagreement(innovationNorm)
        val adaptiveSigma = arcoreSigmaFor(quality, frameGapMs, innovationNorm)
        if (!adaptiveSigma.isFinite()) {
            runtime.arcoreRejectedByQualityCount += 1L
            return rejectedArcore("quality_rejected", innovationEast, innovationNorth, innovationNorm)
        }
        var sigma = adaptiveSigma
        var robustlyInflated = false
        if (runtime.turnState == AdaptiveTurnState.TURNING) {
            sigma = (sigma * ARCORE_TURN_SIGMA_MULTIPLIER).coerceIn(BASE_ARCORE_SIGMA_M, MAX_ARCORE_SIGMA_M)
            robustlyInflated = true
        }
        val preRobustNis = calculateNis(runtime.p, innovationEast, innovationNorth, sigma)
        recordPreRobustNis(preRobustNis)
        if (preRobustNis > ARCORE_NIS_SOFT_GATE) {
            sigma = (sigma * sqrt(preRobustNis / ARCORE_NIS_SOFT_GATE)).coerceIn(BASE_ARCORE_SIGMA_M, MAX_ARCORE_SIGMA_M)
            robustlyInflated = true
        }
        val postRobustNis = calculateNis(runtime.p, innovationEast, innovationNorth, sigma)
        recordPostRobustNis(postRobustNis)
        if (!postRobustNis.isFinite() || postRobustNis > ARCORE_NIS_HARD_GATE) {
            runtime.arcoreRejectedByInnovationCount += 1L
            if (sigma >= MAX_ARCORE_SIGMA_M - NUMERICAL_EPSILON) {
                runtime.arcoreRejectedAfterMaxInflationCount += 1L
            }
            recordArcoreSigma(sigma)
            return rejectedArcore(
                "post_robust_innovation_rejected",
                innovationEast,
                innovationNorth,
                innovationNorm,
                postRobustNis,
                sigma,
            )
        }
        if (runtime.stationaryDetected && innovationNorm <= STATIONARY_DRIFT_REJECTION_M) {
            runtime.arcoreRejectedStationaryDriftCount += 1L
            recordArcoreSigma(MAX_ARCORE_SIGMA_M)
            return rejectedArcore(
                "stationary_drift_suppressed",
                innovationEast,
                innovationNorth,
                innovationNorm,
                postRobustNis,
                MAX_ARCORE_SIGMA_M,
            )
        }
        updateArcoreEkf(measuredEastM, measuredNorthM, sigma)
        runtime.arcoreAcceptedCount += 1L
        if (robustlyInflated) {
            runtime.arcoreAcceptedInflatedCount += 1L
            runtime.arcoreAcceptedAfterRobustInflationCount += 1L
        } else {
            runtime.arcoreAcceptedNominalCount += 1L
        }
        recordArcoreSigma(sigma)
        recordAcceptedRobustSigma(sigma)
        if (allowCalibrationLearning) {
            observeCalibration(timestampNs, measuredEastM, measuredNorthM, quality, preRobustNis)
        }
        if (runtime.firstArEastM == null) {
            runtime.firstArEastM = measuredEastM
            runtime.firstArNorthM = measuredNorthM
        }
        validateState()
        return AdaptiveMeasurementResult(true, sigma, innovationEast, innovationNorth, innovationNorm, postRobustNis, null)
    }

    fun tick(timestampNs: Long) {
        if (timestampNs <= 0L) return
        val stationaryStart = runtime.stationaryStartNs
        val activeDurationNs =
            if (runtime.stationaryDetected && stationaryStart != null) {
                (timestampNs - stationaryStart).coerceAtLeast(0L)
            } else {
                0L
            }
        runtime.stationaryDetectedDurationMs =
            (runtime.stationaryAccumulatedDurationNs + activeDurationNs) / 1_000_000L
    }

    fun resetPosition(
        eastM: Double,
        northM: Double,
        accuracyM: Double,
    ) {
        require(eastM.isFinite() && northM.isFinite() && accuracyM.isFinite() && accuracyM > 0.0)
        runtime.x[0] = eastM
        runtime.x[1] = northM
        val variance = accuracyM * accuracyM
        runtime.p =
            doubleArrayOf(
                variance, 0.0, 0.0,
                0.0, variance, 0.0,
                0.0, 0.0, runtime.p[8],
            )
        validateState()
    }

    fun diagnostics(): Map<String, Any?> {
        val strideMean = if (runtime.stepCount == 0L) runtime.strideEstimateM else runtime.strideSumM / runtime.stepCount
        val headingInnovationMean =
            if (runtime.headingMeasurementCount == 0L) 0.0 else runtime.headingInnovationSumRad / runtime.headingMeasurementCount
        val arcoreNisMean = if (runtime.arcoreNisCount == 0L) 0.0 else runtime.arcoreNisSum / runtime.arcoreNisCount
        val arcorePostRobustNisMean =
            if (runtime.arcorePostRobustNisCount == 0L) 0.0 else runtime.arcorePostRobustNisSum / runtime.arcorePostRobustNisCount
        val sigmaMean =
            if (runtime.adaptiveArcoreSigmaCount == 0L) BASE_ARCORE_SIGMA_M else runtime.adaptiveArcoreSigmaSumM / runtime.adaptiveArcoreSigmaCount
        val robustSigmaMean =
            if (runtime.arcoreRobustSigmaCount == 0L) BASE_ARCORE_SIGMA_M else runtime.arcoreRobustSigmaSumM / runtime.arcoreRobustSigmaCount
        val disagreementMean =
            if (runtime.sourceDisagreementCount == 0L) 0.0 else runtime.sourceDisagreementSumM / runtime.sourceDisagreementCount
        val firstEast = runtime.firstArEastM
        val firstNorth = runtime.firstArNorthM
        return linkedMapOf(
            "configId" to CONFIG_ID,
            "stepCount" to runtime.stepCount,
            "strideEstimateM" to runtime.strideEstimateM,
            "strideMinM" to if (runtime.stepCount == 0L) runtime.strideEstimateM else runtime.strideMinM,
            "strideMeanM" to strideMean,
            "strideMaxM" to if (runtime.stepCount == 0L) runtime.strideEstimateM else runtime.strideMaxM,
            "strideCalibrationSampleCount" to runtime.strideCalibrationSampleCount,
            "walkingHeadingOffsetRad" to runtime.bodyHeadingOffsetRad,
            "walkingHeadingOffsetDeg" to Math.toDegrees(runtime.bodyHeadingOffsetRad),
            "headingMeasurementCount" to runtime.headingMeasurementCount,
            "headingAcceptedCount" to runtime.headingAcceptedCount,
            "headingRejectedCount" to runtime.headingRejectedCount,
            "headingInnovationMeanRad" to headingInnovationMean,
            "headingInnovationMaxRad" to runtime.headingInnovationMaxRad,
            "headingVariance" to runtime.headingVariance,
            "adaptiveHeadingSigmaRad" to runtime.headingSigmaRad,
            "turnState" to runtime.turnState.name,
            "arcoreUpdateCount" to runtime.arcoreUpdateCount,
            "arcoreAcceptedCount" to runtime.arcoreAcceptedCount,
            "arcoreAcceptedNominalCount" to runtime.arcoreAcceptedNominalCount,
            "arcoreAcceptedInflatedCount" to runtime.arcoreAcceptedInflatedCount,
            "arcoreRejectedByQualityCount" to runtime.arcoreRejectedByQualityCount,
            "arcoreRejectedByInnovationCount" to runtime.arcoreRejectedByInnovationCount,
            "arcoreAcceptedAfterRobustInflationCount" to runtime.arcoreAcceptedAfterRobustInflationCount,
            "arcoreRejectedAfterMaxInflationCount" to runtime.arcoreRejectedAfterMaxInflationCount,
            "arcoreRejectedStationaryDriftCount" to runtime.arcoreRejectedStationaryDriftCount,
            "arcoreInnovationEastM" to runtime.arcoreInnovationEastM,
            "arcoreInnovationNorthM" to runtime.arcoreInnovationNorthM,
            "arcoreInnovationNormM" to runtime.arcoreInnovationNormM,
            "arcoreNisLast" to runtime.arcoreNisLast,
            "arcoreNisMean" to arcoreNisMean,
            "arcoreNisMax" to runtime.arcoreNisMax,
            "arcorePreRobustNisMean" to arcoreNisMean,
            "arcorePreRobustNisMax" to runtime.arcoreNisMax,
            "arcorePostRobustNisMean" to arcorePostRobustNisMean,
            "arcorePostRobustNisMax" to runtime.arcorePostRobustNisMax,
            "arcorePostRobustNisLast" to runtime.arcorePostRobustNisLast,
            "adaptiveArcoreSigmaM" to runtime.adaptiveArcoreSigmaM,
            "adaptiveArcoreSigmaMinM" to
                if (runtime.adaptiveArcoreSigmaCount == 0L) BASE_ARCORE_SIGMA_M else runtime.adaptiveArcoreSigmaMinM,
            "adaptiveArcoreSigmaMeanM" to sigmaMean,
            "adaptiveArcoreSigmaMaxM" to runtime.adaptiveArcoreSigmaMaxM.coerceAtLeast(BASE_ARCORE_SIGMA_M),
            "arcoreRobustSigmaMeanM" to robustSigmaMean,
            "arcoreRobustSigmaMaxM" to runtime.arcoreRobustSigmaMaxM.coerceAtLeast(BASE_ARCORE_SIGMA_M),
            "arcoreRelativeDisplacementM" to
                if (firstEast == null || firstNorth == null) 0.0 else hypot((runtime.lastArObservation?.eastM ?: firstEast) - firstEast, (runtime.lastArObservation?.northM ?: firstNorth) - firstNorth),
            "pdrHorizontalDisplacementM" to hypot(runtime.x[0] - runtime.initialEastM, runtime.x[1] - runtime.initialNorthM),
            "horizontalCovarianceSummaryM" to horizontalCovarianceSummary,
            "sourceDisagreementM" to runtime.sourceDisagreementM,
            "sourceDisagreementMeanM" to disagreementMean,
            "sourceDisagreementMaxM" to runtime.sourceDisagreementMaxM,
            "stationaryDetected" to runtime.stationaryDetected,
            "stationaryDurationMs" to runtime.stationaryDetectedDurationMs,
            "stationaryEntryCount" to runtime.stationaryEntryCount,
            "stationaryCandidateCount" to runtime.stationaryCandidateCount,
            "stationaryBlockedRecentStepCount" to runtime.stationaryBlockedRecentStepCount,
            "stationaryBlockedHeadingMotionCount" to runtime.stationaryBlockedHeadingMotionCount,
            "stationaryBlockedArcoreMotionCount" to runtime.stationaryBlockedArcoreMotionCount,
            "stationaryBlockedOtherMotionCount" to runtime.stationaryBlockedOtherMotionCount,
            "stationaryArcoreSuppressedCount" to runtime.arcoreRejectedStationaryDriftCount,
            "headingOffsetSampleCount" to runtime.headingOffsetSampleCount,
            "acceptedPdrCount" to runtime.stepCount,
            "acceptedArcoreCount" to runtime.arcoreAcceptedCount,
            "rejectedArcoreCount" to
                runtime.arcoreRejectedByQualityCount + runtime.arcoreRejectedByInnovationCount + runtime.arcoreRejectedStationaryDriftCount,
            "rawEventArraysReturned" to false,
            "accuracyValidated" to false,
        )
    }

    private fun updateHeadingWindow(
        timestampNs: Long,
        headingRad: Double,
    ) {
        val previous = runtime.recentHeadings.lastOrNull()
        runtime.recentHeadings.add(AdaptiveHeadingObservation(timestampNs, headingRad))
        runtime.recentHeadings.removeAll { timestampNs - it.timestampNs > HEADING_WINDOW_NS }
        while (runtime.recentHeadings.size > MAX_HEADING_WINDOW_SAMPLES) runtime.recentHeadings.removeAt(0)
        runtime.headingVariance = circularVariance(runtime.recentHeadings.map { it.headingRad })
        runtime.turnState =
            if (previous != null && timestampNs > previous.timestampNs) {
                val delta = abs(circularDifference(headingRad, previous.headingRad))
                val rate = delta / ((timestampNs - previous.timestampNs) / 1_000_000_000.0)
                when {
                    rate >= TURN_RATE_GATE_RAD_PER_S || delta >= TURN_DELTA_GATE_RAD -> AdaptiveTurnState.TURNING
                    runtime.recentHeadings.size >= 3 && runtime.headingVariance <= HEADING_STRAIGHT_VARIANCE -> AdaptiveTurnState.STRAIGHT
                    else -> AdaptiveTurnState.UNKNOWN
                }
            } else {
                AdaptiveTurnState.UNKNOWN
            }
    }

    private fun adaptiveHeadingSigma(
        quality: AdaptiveSourceQuality,
        reportedAccuracyRad: Double?,
    ): Double {
        val multiplier =
            when (quality) {
                AdaptiveSourceQuality.GOOD -> 1.0
                AdaptiveSourceQuality.USABLE -> 1.5
                AdaptiveSourceQuality.DEGRADED -> 2.5
                else -> 4.0
            }
        var sigma = BASE_HEADING_SIGMA_RAD * multiplier
        if (reportedAccuracyRad != null && reportedAccuracyRad.isFinite() && reportedAccuracyRad >= 0.0) {
            sigma = max(sigma, reportedAccuracyRad)
        }
        sigma += sqrt((2.0 * runtime.headingVariance).coerceAtLeast(0.0))
        if (runtime.turnState == AdaptiveTurnState.TURNING) sigma *= 1.35
        return sigma.coerceIn(BASE_HEADING_SIGMA_RAD, MAX_HEADING_SIGMA_RAD)
    }

    private fun arcoreSigmaFor(
        quality: AdaptiveSourceQuality,
        frameGapMs: Double?,
        disagreementM: Double,
    ): Double {
        var sigma =
            when (quality) {
                AdaptiveSourceQuality.GOOD -> BASE_ARCORE_SIGMA_M
                AdaptiveSourceQuality.USABLE -> 0.70
                AdaptiveSourceQuality.DEGRADED -> 1.50
                else -> return Double.NaN
            }
        if (frameGapMs != null && frameGapMs.isFinite()) {
            sigma *=
                when {
                    frameGapMs <= 75.0 -> 1.0
                    frameGapMs <= 150.0 -> 1.5
                    frameGapMs <= 300.0 -> 2.5
                    else -> 4.0
                }
        }
        if (disagreementM > 2.0) sigma *= (1.0 + (disagreementM - 2.0) / 8.0).coerceAtMost(2.5)
        return sigma.coerceIn(BASE_ARCORE_SIGMA_M, MAX_ARCORE_SIGMA_M)
    }

    private fun updateStationaryEvidence(
        timestampNs: Long,
        eastM: Double,
        northM: Double,
    ) {
        val previous = runtime.lastArObservation
        runtime.lastArObservation = AdaptiveArObservation(timestampNs, eastM, northM)
        if (previous == null || timestampNs <= previous.timestampNs) return
        val delta = hypot(eastM - previous.eastM, northM - previous.northM)
        val dtSeconds = (timestampNs - previous.timestampNs) / 1_000_000_000.0
        val arRate = delta / dtSeconds.coerceAtLeast(1e-6)
        val noRecentStep = runtime.lastStepTimestampNs == 0L || timestampNs - runtime.lastStepTimestampNs >= STATIONARY_NO_STEP_NS
        val arcoreQuiet = arRate <= STATIONARY_AR_RATE_GATE_MPS
        val headingQuiet = runtime.headingVariance <= STATIONARY_HEADING_VARIANCE_GATE
        val quiet = noRecentStep && arcoreQuiet && headingQuiet
        if (quiet) {
            val candidate = runtime.stationaryCandidateStartNs
            if (candidate == null) {
                runtime.stationaryCandidateStartNs = timestampNs
                runtime.stationaryCandidateCount += 1L
            } else if (!runtime.stationaryDetected && timestampNs - candidate >= STATIONARY_CONFIRM_NS) {
                runtime.stationaryDetected = true
                runtime.stationaryStartNs = candidate
                runtime.stationaryEntryCount += 1L
            }
        } else {
            var blockerRecorded = false
            if (!noRecentStep) {
                runtime.stationaryBlockedRecentStepCount += 1L
                blockerRecorded = true
            }
            if (!arcoreQuiet) {
                runtime.stationaryBlockedArcoreMotionCount += 1L
                blockerRecorded = true
            }
            if (!headingQuiet) {
                runtime.stationaryBlockedHeadingMotionCount += 1L
                blockerRecorded = true
            }
            if (!blockerRecorded) runtime.stationaryBlockedOtherMotionCount += 1L
            runtime.stationaryCandidateStartNs = null
            if (arRate >= STATIONARY_EXIT_AR_RATE_MPS || !noRecentStep) exitStationary(timestampNs)
        }
        tick(timestampNs)
    }

    private fun exitStationary(timestampNs: Long) {
        val stationaryStart = runtime.stationaryStartNs
        if (runtime.stationaryDetected && stationaryStart != null) {
            runtime.stationaryAccumulatedDurationNs += (timestampNs - stationaryStart).coerceAtLeast(0L)
        }
        runtime.stationaryDetected = false
        runtime.stationaryCandidateStartNs = null
        runtime.stationaryStartNs = null
        runtime.stationaryDetectedDurationMs = runtime.stationaryAccumulatedDurationNs / 1_000_000L
    }

    private fun observeCalibration(
        timestampNs: Long,
        eastM: Double,
        northM: Double,
        quality: AdaptiveSourceQuality,
        nis: Double,
    ) {
        val current = AdaptiveArObservation(timestampNs, eastM, northM)
        val anchor = runtime.calibrationArObservation
        if (anchor == null) {
            runtime.calibrationArObservation = current
            runtime.stepsAtCalibrationAnchor = runtime.stepCount
            return
        }
        val steps = runtime.stepCount - runtime.stepsAtCalibrationAnchor
        val deltaEast = eastM - anchor.eastM
        val deltaNorth = northM - anchor.northM
        val displacement = hypot(deltaEast, deltaNorth)
        val eligible =
            quality == AdaptiveSourceQuality.GOOD &&
                runtime.turnState == AdaptiveTurnState.STRAIGHT &&
                !runtime.stationaryDetected &&
                steps >= MIN_CALIBRATION_STEPS &&
                displacement >= MIN_CALIBRATION_DISPLACEMENT_M &&
                nis <= ARCORE_NIS_SOFT_GATE &&
                runtime.headingVariance <= HEADING_STRAIGHT_VARIANCE
        if (!eligible) return
        val observedStride = displacement / steps
        if (observedStride.isFinite() && observedStride in MIN_STRIDE_M..MAX_STRIDE_M) {
            runtime.strideEstimateM =
                ((1.0 - STRIDE_SMOOTHING_ALPHA) * runtime.strideEstimateM + STRIDE_SMOOTHING_ALPHA * observedStride)
                    .coerceIn(MIN_STRIDE_M, MAX_STRIDE_M)
            runtime.strideCalibrationSampleCount += 1L
        }
        val deviceHeading = runtime.latestDeviceHeadingRad
        if (deviceHeading != null && displacement >= MIN_HEADING_OFFSET_DISPLACEMENT_M) {
            val motionHeading = normalizeHeading(atan2(deltaEast, deltaNorth))
            val observedOffset = circularDifference(motionHeading, deviceHeading).coerceIn(-MAX_HEADING_OFFSET_RAD, MAX_HEADING_OFFSET_RAD)
            val deltaOffset = circularDifference(observedOffset, runtime.bodyHeadingOffsetRad)
            runtime.bodyHeadingOffsetRad =
                (runtime.bodyHeadingOffsetRad + HEADING_OFFSET_SMOOTHING_ALPHA * deltaOffset)
                    .coerceIn(-MAX_HEADING_OFFSET_RAD, MAX_HEADING_OFFSET_RAD)
            runtime.headingOffsetSampleCount += 1L
        }
        runtime.calibrationArObservation = current
        runtime.stepsAtCalibrationAnchor = runtime.stepCount
    }

    private fun recordDisagreement(value: Double) {
        val safe = value.takeIf(Double::isFinite)?.coerceAtLeast(0.0) ?: 0.0
        runtime.sourceDisagreementM = safe
        runtime.sourceDisagreementSumM += safe
        runtime.sourceDisagreementMaxM = max(runtime.sourceDisagreementMaxM, safe)
        runtime.sourceDisagreementCount += 1L
    }

    private fun recordPreRobustNis(value: Double) {
        val safe = value.takeIf(Double::isFinite)?.coerceAtLeast(0.0) ?: ARCORE_NIS_UNSAFE_SENTINEL
        runtime.arcoreNisLast = safe
        runtime.arcoreNisSum += safe
        runtime.arcoreNisMax = max(runtime.arcoreNisMax, safe)
        runtime.arcoreNisCount += 1L
    }

    private fun recordPostRobustNis(value: Double) {
        val safe = value.takeIf(Double::isFinite)?.coerceAtLeast(0.0) ?: ARCORE_NIS_UNSAFE_SENTINEL
        runtime.arcorePostRobustNisLast = safe
        runtime.arcorePostRobustNisSum += safe
        runtime.arcorePostRobustNisMax = max(runtime.arcorePostRobustNisMax, safe)
        runtime.arcorePostRobustNisCount += 1L
    }

    private fun recordArcoreSigma(value: Double) {
        val safe = value.takeIf(Double::isFinite)?.coerceIn(BASE_ARCORE_SIGMA_M, MAX_ARCORE_SIGMA_M) ?: MAX_ARCORE_SIGMA_M
        runtime.adaptiveArcoreSigmaM = safe
        runtime.adaptiveArcoreSigmaMinM = minOf(runtime.adaptiveArcoreSigmaMinM, safe)
        runtime.adaptiveArcoreSigmaMaxM = max(runtime.adaptiveArcoreSigmaMaxM, safe)
        runtime.adaptiveArcoreSigmaSumM += safe
        runtime.adaptiveArcoreSigmaCount += 1L
    }

    private fun recordAcceptedRobustSigma(value: Double) {
        val safe = value.coerceIn(BASE_ARCORE_SIGMA_M, MAX_ARCORE_SIGMA_M)
        runtime.arcoreRobustSigmaMaxM = max(runtime.arcoreRobustSigmaMaxM, safe)
        runtime.arcoreRobustSigmaSumM += safe
        runtime.arcoreRobustSigmaCount += 1L
    }

    private fun rejectedArcore(
        reason: String,
        innovationEastM: Double = 0.0,
        innovationNorthM: Double = 0.0,
        innovationNormM: Double = 0.0,
        nis: Double = 0.0,
        sigma: Double = MAX_ARCORE_SIGMA_M,
    ): AdaptiveMeasurementResult {
        runtime.arcoreInnovationEastM = finiteOrZero(innovationEastM)
        runtime.arcoreInnovationNorthM = finiteOrZero(innovationNorthM)
        runtime.arcoreInnovationNormM = finiteOrZero(innovationNormM)
        return AdaptiveMeasurementResult(false, finiteOrZero(sigma).coerceIn(BASE_ARCORE_SIGMA_M, MAX_ARCORE_SIGMA_M), runtime.arcoreInnovationEastM, runtime.arcoreInnovationNorthM, runtime.arcoreInnovationNormM, finiteOrZero(nis), reason)
    }

    private fun updateHeadingEkf(
        measuredHeadingRad: Double,
        sigmaRad: Double,
    ) {
        val r = sigmaRad * sigmaRad
        val s = runtime.p[8] + r
        require(s.isFinite() && s > NUMERICAL_EPSILON)
        val k = doubleArrayOf(runtime.p[2] / s, runtime.p[5] / s, runtime.p[8] / s)
        val innovation = circularDifference(measuredHeadingRad, runtime.x[2])
        runtime.x[0] += k[0] * innovation
        runtime.x[1] += k[1] * innovation
        runtime.x[2] = normalizeHeading(runtime.x[2] + k[2] * innovation)
        val ikh = identity()
        for (row in 0..2) ikh[(row * 3) + 2] -= k[row]
        val krkt = DoubleArray(9) { index -> k[index / 3] * r * k[index % 3] }
        runtime.p = symmetrize(addMatrices(multiplyMatrices(multiplyMatrices(ikh, runtime.p), transpose(ikh)), krkt))
    }

    private fun updateArcoreEkf(
        eastM: Double,
        northM: Double,
        sigmaM: Double,
    ) {
        val r = sigmaM * sigmaM
        val s00 = runtime.p[0] + r
        val s01 = runtime.p[1]
        val s10 = runtime.p[3]
        val s11 = runtime.p[4] + r
        val determinant = s00 * s11 - s01 * s10
        require(determinant.isFinite() && determinant > NUMERICAL_EPSILON)
        val inverse = doubleArrayOf(s11 / determinant, -s01 / determinant, -s10 / determinant, s00 / determinant)
        val k = DoubleArray(6)
        for (row in 0..2) {
            k[row * 2] = runtime.p[row * 3] * inverse[0] + runtime.p[(row * 3) + 1] * inverse[2]
            k[(row * 2) + 1] = runtime.p[row * 3] * inverse[1] + runtime.p[(row * 3) + 1] * inverse[3]
        }
        val innovationEast = eastM - runtime.x[0]
        val innovationNorth = northM - runtime.x[1]
        runtime.arcoreInnovationEastM = innovationEast
        runtime.arcoreInnovationNorthM = innovationNorth
        runtime.arcoreInnovationNormM = hypot(innovationEast, innovationNorth)
        runtime.x[0] += k[0] * innovationEast + k[1] * innovationNorth
        runtime.x[1] += k[2] * innovationEast + k[3] * innovationNorth
        runtime.x[2] = normalizeHeading(runtime.x[2] + k[4] * innovationEast + k[5] * innovationNorth)
        val ikh = identity()
        for (row in 0..2) {
            ikh[row * 3] -= k[row * 2]
            ikh[(row * 3) + 1] -= k[(row * 2) + 1]
        }
        val krkt =
            DoubleArray(9) { index ->
                val row = index / 3
                val column = index % 3
                r * (k[row * 2] * k[column * 2] + k[(row * 2) + 1] * k[(column * 2) + 1])
            }
        runtime.p = symmetrize(addMatrices(multiplyMatrices(multiplyMatrices(ikh, runtime.p), transpose(ikh)), krkt))
    }

    private fun validateState() {
        require(runtime.x.all(Double::isFinite) && runtime.p.all(Double::isFinite))
        require(runtime.p[0] >= 0.0 && runtime.p[4] >= 0.0 && runtime.p[8] >= 0.0)
        require(runtime.strideEstimateM in MIN_STRIDE_M..MAX_STRIDE_M)
        require(runtime.bodyHeadingOffsetRad in -MAX_HEADING_OFFSET_RAD..MAX_HEADING_OFFSET_RAD)
        require(runtime.arcoreAcceptedCount == runtime.arcoreAcceptedNominalCount + runtime.arcoreAcceptedInflatedCount)
        require(runtime.arcoreAcceptedCount == runtime.arcoreRobustSigmaCount)
        require(runtime.arcoreAcceptedAfterRobustInflationCount == runtime.arcoreAcceptedInflatedCount)
        require(runtime.arcoreNisCount == runtime.arcorePostRobustNisCount)
        require(runtime.stationaryAccumulatedDurationNs >= 0L && runtime.stationaryDetectedDurationMs >= 0L)
    }

    companion object {
        const val CONFIG_ID = "config_d_v2_adaptive_navguard"
        const val GNSS_STABILIZATION_WINDOW_MS = 8_000L
        const val MIN_GNSS_STABILIZATION_FIXES = 5
        const val MAX_OPERATIONAL_GNSS_ACCURACY_M = 50.0
        const val MIN_STRIDE_M = 0.45
        const val MAX_STRIDE_M = 1.05
        const val DEFAULT_STRIDE_M = 0.75
        const val BASE_ARCORE_SIGMA_M = 0.35
        const val MAX_ARCORE_SIGMA_M = 5.0
        const val ARCORE_NIS_SOFT_GATE = 5.99
        const val ARCORE_NIS_HARD_GATE = 25.0
        private const val ARCORE_TURN_SIGMA_MULTIPLIER = 1.35
        val BASE_HEADING_SIGMA_RAD: Double = Math.toRadians(15.0)
        val MAX_HEADING_SIGMA_RAD: Double = Math.toRadians(60.0)
        val MAX_HEADING_OFFSET_RAD: Double = Math.toRadians(25.0)
        private val BASE_STEP_HEADING_PROCESS_SIGMA_RAD = Math.toRadians(5.0)
        private const val BASE_STEP_LENGTH_SIGMA_M = 0.20
        private const val STRIDE_SMOOTHING_ALPHA = 0.15
        private const val HEADING_OFFSET_SMOOTHING_ALPHA = 0.10
        private const val MIN_CALIBRATION_STEPS = 4L
        private const val MIN_CALIBRATION_DISPLACEMENT_M = 1.0
        private const val MIN_HEADING_OFFSET_DISPLACEMENT_M = 1.5
        private const val HEADING_WINDOW_NS = 2_000_000_000L
        private const val MAX_HEADING_WINDOW_SAMPLES = 128
        private val TURN_RATE_GATE_RAD_PER_S = Math.toRadians(35.0)
        private val TURN_DELTA_GATE_RAD = Math.toRadians(18.0)
        private val HEADING_INNOVATION_GATE_RAD = Math.toRadians(75.0)
        private val HEADING_SINGLE_SAMPLE_HARD_GATE_RAD = Math.toRadians(150.0)
        private const val HEADING_STRAIGHT_VARIANCE = 0.004
        private const val HEADING_STABLE_VARIANCE_GATE = 0.02
        private const val STATIONARY_HEADING_VARIANCE_GATE = 0.004
        private const val STATIONARY_NO_STEP_NS = 3_000_000_000L
        private const val STATIONARY_CONFIRM_NS = 3_000_000_000L
        private const val STATIONARY_AR_RATE_GATE_MPS = 0.08
        private const val STATIONARY_EXIT_AR_RATE_MPS = 0.25
        private const val STATIONARY_DRIFT_REJECTION_M = 0.75
        private const val NUMERICAL_EPSILON = 1e-12
        private const val ARCORE_NIS_UNSAFE_SENTINEL = 1e12
        private const val TWO_PI = 2.0 * PI

        fun computeStableGnssOrigin(
            candidates: List<AdaptiveGnssOriginCandidate>,
            nowNs: Long,
            windowMs: Long = GNSS_STABILIZATION_WINDOW_MS,
            minimumFixCount: Int = MIN_GNSS_STABILIZATION_FIXES,
        ): AdaptiveStableGnssOrigin? {
            if (nowNs <= 0L || windowMs <= 0L || minimumFixCount <= 0) return null
            val cutoff = nowNs - windowMs * 1_000_000L
            val valid =
                candidates.filter {
                    it.timestampNs in (cutoff + 1)..nowNs &&
                        it.eastM.isFinite() && it.northM.isFinite() &&
                        it.reportedAccuracyM.isFinite() &&
                        it.reportedAccuracyM > 0.0 &&
                        it.reportedAccuracyM <= MAX_OPERATIONAL_GNSS_ACCURACY_M &&
                        !it.isMock
                }
            if (valid.size < minimumFixCount) return null
            val eastValues = valid.map { it.eastM }.sorted()
            val northValues = valid.map { it.northM }.sorted()
            val accuracyValues = valid.map { it.reportedAccuracyM }.sorted()
            val east = median(eastValues)
            val north = median(northValues)
            val eastSpread = (eastValues.last() - eastValues.first()).coerceAtLeast(0.0)
            val northSpread = (northValues.last() - northValues.first()).coerceAtLeast(0.0)
            return AdaptiveStableGnssOrigin(
                eastM = east,
                northM = north,
                fixCount = valid.size,
                eastSpreadM = eastSpread,
                northSpreadM = northSpread,
                horizontalSpreadM = hypot(eastSpread, northSpread),
                reportedAccuracyMedianM = median(accuracyValues),
            )
        }

        fun calculateNis(
            covariance: DoubleArray,
            innovationEastM: Double,
            innovationNorthM: Double,
            sigmaM: Double,
        ): Double {
            if (covariance.size != 9 || covariance.any { !it.isFinite() } ||
                !innovationEastM.isFinite() || !innovationNorthM.isFinite() ||
                !sigmaM.isFinite() || sigmaM < BASE_ARCORE_SIGMA_M
            ) return ARCORE_NIS_UNSAFE_SENTINEL
            val r = sigmaM * sigmaM
            val s00 = covariance[0] + r
            val s01 = covariance[1]
            val s10 = covariance[3]
            val s11 = covariance[4] + r
            val determinant = s00 * s11 - s01 * s10
            if (!determinant.isFinite() || determinant <= NUMERICAL_EPSILON) return ARCORE_NIS_UNSAFE_SENTINEL
            val value =
                innovationEastM * ((s11 * innovationEastM - s01 * innovationNorthM) / determinant) +
                    innovationNorthM * ((-s10 * innovationEastM + s00 * innovationNorthM) / determinant)
            return value.takeIf { it.isFinite() && it >= 0.0 } ?: ARCORE_NIS_UNSAFE_SENTINEL
        }

        fun runDeterministicSelfTests(): Map<String, Boolean> {
            val origin =
                computeStableGnssOrigin(
                    listOf(
                        AdaptiveGnssOriginCandidate(2_000_000_000L, 1.0, 2.0, 5.0),
                        AdaptiveGnssOriginCandidate(3_000_000_000L, 1.1, 2.1, 6.0),
                        AdaptiveGnssOriginCandidate(4_000_000_000L, 0.9, 1.9, 4.0),
                        AdaptiveGnssOriginCandidate(5_000_000_000L, 1.05, 2.05, 5.0),
                        AdaptiveGnssOriginCandidate(6_000_000_000L, 100.0, -100.0, 8.0),
                    ),
                    6_000_000_000L,
                )
            val robustOrigin = origin != null && abs(origin.eastM - 1.05) < 0.2 && abs(origin.northM - 2.0) < 0.2
            val smallOriginRejected =
                computeStableGnssOrigin(
                    listOf(AdaptiveGnssOriginCandidate(1L, 0.0, 0.0, 5.0)),
                    1L,
                ) == null

            fun applyStraightCalibration(
                core: NavguardAdaptiveFusionV2,
                deviceHeadingRad: Double,
                measuredNorthM: Double,
            ) {
                for (index in 1..4) {
                    core.updateHeading(index * 100_000_000L, deviceHeadingRad, AdaptiveSourceQuality.GOOD, 0.05)
                }
                core.updateArcore(500_000_000L, 0.0, 0.0, AdaptiveSourceQuality.GOOD, 50.0)
                for (index in 1..4) {
                    val stepTimestampNs = 1_000_000_000L + (index - 1L) * 500_000_000L
                    core.updateHeading(stepTimestampNs - 100_000_000L, deviceHeadingRad, AdaptiveSourceQuality.GOOD, 0.05)
                    core.predictStep(stepTimestampNs, AdaptiveSourceQuality.GOOD)
                }
                core.updateArcore(2_700_000_000L, 0.0, measuredNorthM, AdaptiveSourceQuality.GOOD, 50.0)
            }

            val strideCore = NavguardAdaptiveFusionV2(0.0, 0.0, 0.0, NavguardCalibrationProfile())
            applyStraightCalibration(strideCore, 0.0, 3.4)
            val strideMovedGradually = strideCore.strideEstimateM > DEFAULT_STRIDE_M && strideCore.strideEstimateM < 0.85
            val strideBounds = strideCore.strideEstimateM in MIN_STRIDE_M..MAX_STRIDE_M
            val degradedBefore = strideCore.strideEstimateM
            strideCore.updateArcore(2_800_000_000L, 0.0, 4.0, AdaptiveSourceQuality.DEGRADED, 50.0)
            val degradedFreeze = strideCore.strideEstimateM == degradedBefore

            val offsetCore = NavguardAdaptiveFusionV2(0.0, 0.0, Math.toRadians(10.0), NavguardCalibrationProfile())
            applyStraightCalibration(offsetCore, Math.toRadians(10.0), 3.4)
            val offsetProfile = offsetCore.calibrationProfile()
            val headingOffsetCalibrated =
                offsetProfile.headingOffsetSampleCount > 0L && offsetProfile.bodyHeadingOffsetRad < 0.0
            val headingOffsetBounded = abs(offsetProfile.bodyHeadingOffsetRad) <= MAX_HEADING_OFFSET_RAD
            val offsetBeforeTurn = offsetCore.bodyHeadingOffsetRad
            offsetCore.updateHeading(2_800_000_000L, Math.toRadians(100.0), AdaptiveSourceQuality.GOOD, 0.05)
            repeat(4) { index -> offsetCore.predictStep(3_000_000_000L + index * 400_000_000L, AdaptiveSourceQuality.GOOD) }
            offsetCore.updateArcore(5_000_000_000L, 3.4, 3.4, AdaptiveSourceQuality.GOOD, 50.0)
            val headingOffsetTurnProtected = offsetCore.bodyHeadingOffsetRad == offsetBeforeTurn

            val headingCore = NavguardAdaptiveFusionV2(0.0, 0.0, Math.toRadians(359.0))
            val circularAccepted = headingCore.updateHeading(1L, Math.toRadians(1.0), AdaptiveSourceQuality.GOOD, 0.05)
            headingCore.updateHeading(100_000_001L, Math.toRadians(45.0), AdaptiveSourceQuality.GOOD, 0.05)
            val legitimateTurnAccepted = headingCore.turnState == AdaptiveTurnState.TURNING
            val outlierCore = NavguardAdaptiveFusionV2(0.0, 0.0, 0.0)
            repeat(4) { outlierCore.updateHeading((it + 1L) * 100_000_000L, 0.0, AdaptiveSourceQuality.GOOD, 0.02) }
            val isolatedOutlierRejected = !outlierCore.updateHeading(600_000_000L, PI, AdaptiveSourceQuality.GOOD, 0.02)

            val arCore = NavguardAdaptiveFusionV2(0.0, 0.0, 0.0)
            val consistent = arCore.updateArcore(1L, 0.05, 0.05, AdaptiveSourceQuality.GOOD, 50.0)
            val beforeEast = arCore.eastM
            val beforeNorth = arCore.northM
            val outlier = arCore.updateArcore(2L, 50.0, -50.0, AdaptiveSourceQuality.GOOD, 50.0)
            val hardRejectNoMutation = !outlier.accepted && arCore.eastM == beforeEast && arCore.northM == beforeNorth
            val moderateCore = NavguardAdaptiveFusionV2(0.0, 0.0, 0.0)
            val moderate = moderateCore.updateArcore(1L, 1.0, 0.0, AdaptiveSourceQuality.GOOD, 50.0)
            val nominalGain = 0.01 / (0.01 + BASE_ARCORE_SIGMA_M * BASE_ARCORE_SIGMA_M)
            val softInflation =
                moderate.accepted &&
                    moderate.nis in ARCORE_NIS_SOFT_GATE..ARCORE_NIS_HARD_GATE &&
                    moderate.sigmaM > BASE_ARCORE_SIGMA_M &&
                    moderateCore.eastM > 0.0 &&
                    moderateCore.eastM < nominalGain
            val robustCounters = moderateCore.diagnostics()
            val moderateCounterSeparated =
                robustCounters["arcoreAcceptedNominalCount"] == 0L &&
                    robustCounters["arcoreAcceptedInflatedCount"] == 1L

            val postRobustCore = NavguardAdaptiveFusionV2(0.0, 0.0, 0.0)
            val recoveredAfterInflation =
                postRobustCore.updateArcore(1L, 2.0, 0.0, AdaptiveSourceQuality.GOOD, 50.0)
            val postRobustDiagnostics = postRobustCore.diagnostics()
            val preAboveHardPostAccepted =
                recoveredAfterInflation.accepted &&
                    (postRobustDiagnostics["arcorePreRobustNisMax"] as? Double ?: 0.0) > ARCORE_NIS_HARD_GATE &&
                    (postRobustDiagnostics["arcorePostRobustNisMax"] as? Double ?: ARCORE_NIS_UNSAFE_SENTINEL) <=
                    ARCORE_NIS_HARD_GATE &&
                    postRobustDiagnostics["arcoreAcceptedAfterRobustInflationCount"] == 1L

            val turnAwareCore = NavguardAdaptiveFusionV2(0.0, 0.0, 0.0)
            turnAwareCore.updateHeading(1_000_000_000L, 0.0, AdaptiveSourceQuality.GOOD, 0.02)
            turnAwareCore.updateHeading(2_000_000_000L, Math.toRadians(90.0), AdaptiveSourceQuality.GOOD, 0.02)
            val turnOffsetBefore = turnAwareCore.bodyHeadingOffsetRad
            val turnArcore =
                turnAwareCore.updateArcore(2_100_000_000L, 2.5, 0.0, AdaptiveSourceQuality.GOOD, 50.0)
            val turnDiagnostics = turnAwareCore.diagnostics()
            val turnAwareRobustUpdate =
                turnAwareCore.turnState == AdaptiveTurnState.TURNING &&
                    turnArcore.accepted &&
                    turnArcore.sigmaM > BASE_ARCORE_SIGMA_M &&
                    (turnDiagnostics["arcorePreRobustNisMax"] as? Double ?: 0.0) > ARCORE_NIS_HARD_GATE &&
                    turnAwareCore.bodyHeadingOffsetRad == turnOffsetBefore
            val knownNis =
                calculateNis(
                    doubleArrayOf(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0),
                    1.0,
                    2.0,
                    1.0,
                )
            val nisFinite = knownNis.isFinite()
            val nisKnownCase = abs(knownNis - 2.5) < 1e-9
            val singularSafe = calculateNis(DoubleArray(9), 1.0, 1.0, Double.NaN).isFinite()

            val stationaryCore = NavguardAdaptiveFusionV2(0.0, 0.0, 0.0)
            repeat(4) { stationaryCore.updateHeading((it + 1L) * 100_000_000L, 0.0, AdaptiveSourceQuality.GOOD, 0.02) }
            stationaryCore.updateArcore(1_000_000_000L, 0.0, 0.0, AdaptiveSourceQuality.GOOD, 50.0)
            stationaryCore.updateArcore(2_500_000_000L, 0.01, 0.0, AdaptiveSourceQuality.GOOD, 50.0)
            stationaryCore.updateArcore(4_500_000_000L, 0.02, 0.0, AdaptiveSourceQuality.GOOD, 50.0)
            val beforeSuppressedDrift = stationaryCore.eastM to stationaryCore.northM
            val suppressedDrift = stationaryCore.updateArcore(6_000_000_000L, 0.03, 0.0, AdaptiveSourceQuality.GOOD, 50.0)
            val stationaryDetected = stationaryCore.stationaryDetected
            val stationaryDriftSuppressed =
                !suppressedDrift.accepted &&
                    stationaryCore.eastM == beforeSuppressedDrift.first &&
                    stationaryCore.northM == beforeSuppressedDrift.second
            stationaryCore.predictStep(6_100_000_000L)
            val stationaryExited = !stationaryCore.stationaryDetected
            stationaryCore.tick(6_200_000_000L)
            val stationaryReplayDiagnostics = stationaryCore.diagnostics()
            val stationaryReplayActivation =
                (stationaryReplayDiagnostics["stationaryEntryCount"] as? Long ?: 0L) > 0L &&
                    (stationaryReplayDiagnostics["stationaryDurationMs"] as? Long ?: 0L) > 0L &&
                    (stationaryReplayDiagnostics["stationaryArcoreSuppressedCount"] as? Long ?: 0L) > 0L &&
                    stationaryExited

            val delayedStepCore = NavguardAdaptiveFusionV2(0.0, 0.0, 0.0)
            delayedStepCore.updateHeading(1_000_000_000L, 0.0, AdaptiveSourceQuality.GOOD, 0.02)
            delayedStepCore.predictStep(5_000_000_000L, AdaptiveSourceQuality.GOOD)
            delayedStepCore.updateArcore(6_000_000_000L, 0.0, 0.75, AdaptiveSourceQuality.GOOD, 50.0)
            delayedStepCore.updateArcore(7_000_000_000L, 0.0, 0.75, AdaptiveSourceQuality.GOOD, 50.0)
            delayedStepCore.updateArcore(9_000_000_000L, 0.0, 0.75, AdaptiveSourceQuality.GOOD, 50.0)
            delayedStepCore.updateArcore(12_000_000_000L, 0.0, 0.75, AdaptiveSourceQuality.GOOD, 50.0)
            val delayedStationaryDiagnostics = delayedStepCore.diagnostics()
            val delayedStepEventTime =
                delayedStepCore.stationaryDetected &&
                    (delayedStationaryDiagnostics["stationaryEntryCount"] as? Long ?: 0L) == 1L &&
                    (delayedStationaryDiagnostics["stationaryCandidateCount"] as? Long ?: 0L) > 0L &&
                    (delayedStationaryDiagnostics["stationaryBlockedRecentStepCount"] as? Long ?: 0L) > 0L
            delayedStepCore.predictStep(16_000_000_000L, AdaptiveSourceQuality.GOOD)
            val delayedStationaryExit = !delayedStepCore.stationaryDetected

            val stationaryTurnCore = NavguardAdaptiveFusionV2(0.0, 0.0, 0.0)
            repeat(4) { stationaryTurnCore.updateHeading((it + 1L) * 100_000_000L, 0.0, AdaptiveSourceQuality.GOOD, 0.02) }
            stationaryTurnCore.updateArcore(1_000_000_000L, 0.0, 0.0, AdaptiveSourceQuality.GOOD, 50.0)
            stationaryTurnCore.updateArcore(2_500_000_000L, 0.01, 0.0, AdaptiveSourceQuality.GOOD, 50.0)
            stationaryTurnCore.updateArcore(4_500_000_000L, 0.02, 0.0, AdaptiveSourceQuality.GOOD, 50.0)
            stationaryTurnCore.updateArcore(6_000_000_000L, 0.03, 0.0, AdaptiveSourceQuality.GOOD, 50.0)
            val acceptedTurn =
                stationaryTurnCore.updateHeading(6_100_000_000L, Math.toRadians(45.0), AdaptiveSourceQuality.GOOD, 0.02)
            val stationaryExitedOnTurn = acceptedTurn && !stationaryTurnCore.stationaryDetected

            val agreementCore = NavguardAdaptiveFusionV2(0.0, 0.0, 0.0, NavguardCalibrationProfile())
            repeat(4) { agreementCore.predictStep((it + 1L) * 500_000_000L, AdaptiveSourceQuality.GOOD) }
            val agreementArcore = agreementCore.updateArcore(2_500_000_000L, 0.0, 3.0, AdaptiveSourceQuality.GOOD, 50.0)
            val syntheticAgreementRegression =
                agreementArcore.accepted && hypot(agreementCore.eastM, agreementCore.northM - 3.0) < 0.05

            val outlierComparisonCore = NavguardAdaptiveFusionV2(0.0, 0.0, 0.0, NavguardCalibrationProfile())
            repeat(4) { outlierComparisonCore.predictStep((it + 1L) * 500_000_000L, AdaptiveSourceQuality.GOOD) }
            val d2OutlierResult =
                outlierComparisonCore.updateArcore(2_500_000_000L, 50.0, 3.0, AdaptiveSourceQuality.GOOD, 50.0)
            val legacyUngatedGain = 1.0 / (1.0 + BASE_ARCORE_SIGMA_M * BASE_ARCORE_SIGMA_M)
            val legacyOutlierErrorM = abs(legacyUngatedGain * 50.0)
            val d2OutlierErrorM = hypot(outlierComparisonCore.eastM, outlierComparisonCore.northM - 3.0)
            val syntheticArcoreOutlierImprovement =
                !d2OutlierResult.accepted && d2OutlierErrorM < legacyOutlierErrorM

            var legacyStationaryEastM = 0.0
            var legacyStationaryVariance = 0.01
            for (measurement in listOf(0.0, 0.01, 0.02, 0.03)) {
                val gain = legacyStationaryVariance / (legacyStationaryVariance + BASE_ARCORE_SIGMA_M * BASE_ARCORE_SIGMA_M)
                legacyStationaryEastM += gain * (measurement - legacyStationaryEastM)
                legacyStationaryVariance *= (1.0 - gain)
            }
            val d2StationaryDriftM = hypot(beforeSuppressedDrift.first, beforeSuppressedDrift.second)
            val syntheticStationaryDriftSuppression = d2StationaryDriftM < abs(legacyStationaryEastM)
            val syntheticVariableStride = strideCore.strideEstimateM != DEFAULT_STRIDE_M
            val syntheticRobustV2Regression =
                consistent.accepted &&
                    softInflation &&
                    preAboveHardPostAccepted &&
                    hardRejectNoMutation &&
                    stationaryDriftSuppressed &&
                    delayedStepEventTime &&
                    delayedStationaryExit

            fun syntheticPrediction(comparatorNorthM: Double?): Pair<Pair<Double, Double>, Double?> {
                val core = NavguardAdaptiveFusionV2(0.0, 0.0, 0.0, NavguardCalibrationProfile())
                repeat(4) { core.predictStep((it + 1L) * 500_000_000L, AdaptiveSourceQuality.GOOD) }
                val prediction = core.eastM to core.northM
                val comparatorError = comparatorNorthM?.let { hypot(prediction.first, prediction.second - it) }
                return prediction to comparatorError
            }
            val originalGtComparison = syntheticPrediction(3.0)
            val mutatedGtComparison = syntheticPrediction(300.0)
            val removedGtComparison = syntheticPrediction(null)
            val gtMutationInvariant =
                originalGtComparison.first == mutatedGtComparison.first &&
                    originalGtComparison.second != mutatedGtComparison.second
            val gtRemovalInvariant =
                originalGtComparison.first == removedGtComparison.first && removedGtComparison.second == null

            return linkedMapOf(
                "robustGnssOrigin" to robustOrigin,
                "smallGnssCandidateFallback" to smallOriginRejected,
                "dynamicStride" to strideMovedGradually,
                "strideBounds" to strideBounds,
                "degradedStrideFreeze" to degradedFreeze,
                "headingOffsetCalibration" to headingOffsetCalibrated,
                "headingOffsetBounds" to headingOffsetBounded,
                "headingOffsetTurnProtection" to headingOffsetTurnProtected,
                "headingCircularInnovation" to circularAccepted,
                "headingTurnProtection" to legitimateTurnAccepted,
                "headingOutlierRejection" to isolatedOutlierRejected,
                "nisFinite" to nisFinite,
                "nisKnownCase" to nisKnownCase,
                "nisUnsafeRejectedSafely" to singularSafe,
                "arcoreConsistentAccepted" to consistent.accepted,
                "arcoreSoftInflation" to softInflation,
                "arcoreHardRejection" to hardRejectNoMutation,
                "arcoreModerateRobustUpdate" to (softInflation && moderateCounterSeparated),
                "arcoreExtremeHardRejection" to hardRejectNoMutation,
                "arcorePostRobustRecovery" to preAboveHardPostAccepted,
                "arcorePostRobustExtremeRejection" to
                    (hardRejectNoMutation && (arCore.diagnostics()["arcoreRejectedAfterMaxInflationCount"] as? Long ?: 0L) > 0L),
                "arcoreTurnAwareRobustUpdate" to turnAwareRobustUpdate,
                "stationaryDetection" to stationaryDetected,
                "stationaryDriftSuppression" to stationaryDriftSuppressed,
                "stationaryExitOnStep" to stationaryExited,
                "stationaryExitOnTurn" to stationaryExitedOnTurn,
                "stationaryReplayActivation" to stationaryReplayActivation,
                "stationaryDelayedStepEventTime" to delayedStepEventTime,
                "stationaryCandidateDiagnostics" to
                    ((delayedStationaryDiagnostics["stationaryCandidateCount"] as? Long ?: 0L) > 0L),
                "stationaryDelayedStepExit" to delayedStationaryExit,
                "syntheticAgreementRegression" to syntheticAgreementRegression,
                "syntheticArcoreOutlierImprovement" to syntheticArcoreOutlierImprovement,
                "syntheticStationaryDriftSuppression" to syntheticStationaryDriftSuppression,
                "syntheticRobustV2Regression" to syntheticRobustV2Regression,
                "syntheticVariableStride" to syntheticVariableStride,
                "gtMutationInvariant" to gtMutationInvariant,
                "gtRemovalInvariant" to gtRemovalInvariant,
            )
        }

        fun normalizeHeading(angle: Double): Double {
            var value = angle % TWO_PI
            if (value < 0.0) value += TWO_PI
            return if (value >= TWO_PI) 0.0 else value
        }

        fun circularDifference(
            measured: Double,
            predicted: Double,
        ): Double {
            var difference = (measured - predicted + PI) % TWO_PI - PI
            if (difference <= -PI) difference += TWO_PI
            return difference
        }

        private fun median(values: List<Double>): Double {
            require(values.isNotEmpty())
            val middle = values.size / 2
            return if (values.size % 2 == 1) values[middle] else (values[middle - 1] + values[middle]) / 2.0
        }

        private fun circularVariance(values: List<Double>): Double {
            if (values.isEmpty()) return 1.0
            val sinMean = values.sumOf(::sin) / values.size
            val cosMean = values.sumOf(::cos) / values.size
            return (1.0 - hypot(sinMean, cosMean)).coerceIn(0.0, 1.0)
        }

        private fun finiteOrZero(value: Double): Double = if (value.isFinite()) value else 0.0

        private fun identity(): DoubleArray = doubleArrayOf(1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0)

        private fun multiplyMatrices(
            left: DoubleArray,
            right: DoubleArray,
        ): DoubleArray =
            DoubleArray(9) { index ->
                val row = index / 3
                val column = index % 3
                var value = 0.0
                for (inner in 0..2) value += left[row * 3 + inner] * right[inner * 3 + column]
                value
            }

        private fun transpose(matrix: DoubleArray): DoubleArray =
            DoubleArray(9) { index -> matrix[(index % 3) * 3 + index / 3] }

        private fun addMatrices(
            left: DoubleArray,
            right: DoubleArray,
        ): DoubleArray = DoubleArray(9) { left[it] + right[it] }

        private fun symmetrize(matrix: DoubleArray): DoubleArray {
            val result = matrix.copyOf()
            for (row in 0..2) {
                for (column in (row + 1)..2) {
                    val average = (matrix[row * 3 + column] + matrix[column * 3 + row]) / 2.0
                    result[row * 3 + column] = average
                    result[column * 3 + row] = average
                }
            }
            for (index in intArrayOf(0, 4, 8)) {
                if (result[index] < 0.0 && result[index] > -1e-12) result[index] = 0.0
                require(result[index] >= 0.0)
            }
            require(result.all(Double::isFinite))
            return result
        }
    }
}
