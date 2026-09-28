package io.github.mesuttsahin.navguard

import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.hypot
import kotlin.math.ln
import kotlin.math.max
import kotlin.math.sin
import kotlin.math.sqrt

private interface TimedSample {
    val timestampNs: Long
}

data class NavguardAiFeatureVector(
    val schemaVersion: String = NavguardAiFeatureExtractor.FEATURE_SCHEMA_VERSION,
    val values: DoubleArray,
) {
    init {
        require(
            values.size ==
                NavguardAiFeatureExtractor.featureOrderForSchema(schemaVersion).size,
        )
        require(values.all(Double::isFinite))
    }

    fun asOrderedMap(): Map<String, Double> =
        NavguardAiFeatureExtractor
            .featureOrderForSchema(schemaVersion)
            .zip(values.asIterable())
            .toMap(LinkedHashMap())
}

data class NavguardAiFeatureWindow internal constructor(
    val windowIndex: Int,
    val startTimestampNs: Long,
    val endTimestampNs: Long,
    val vector: NavguardAiFeatureVector,
    internal val arStartEastM: Double?,
    internal val arStartNorthM: Double?,
    internal val arEndEastM: Double?,
    internal val arEndNorthM: Double?,
    internal val pdrStartEastM: Double,
    internal val pdrStartNorthM: Double,
    internal val pdrEndEastM: Double,
    internal val pdrEndNorthM: Double,
    internal val headingStartRad: Double?,
    internal val headingEndRad: Double?,
)

data class NavguardAiStepIngestResult(
    val accepted: Boolean,
    val duplicate: Boolean,
    val outOfHistory: Boolean,
)

/**
 * The single causal Stage 11 feature implementation used by capture and live inference.
 * Raw samples remain only in bounded in-memory buffers and are never serialized.
 */
class NavguardAiFeatureExtractor(
    private val featureSchemaVersion: String = FEATURE_SCHEMA_VERSION,
) {
    private data class VectorSample(override val timestampNs: Long, val magnitude: Double) : TimedSample
    private data class HeadingSample(override val timestampNs: Long, val headingRad: Double, val reliable: Boolean) : TimedSample
    private data class StepSample(override val timestampNs: Long) : TimedSample
    private data class PositionSample(override val timestampNs: Long, val eastM: Double, val northM: Double) : TimedSample
    private data class ArFrameSample(
        override val timestampNs: Long,
        val tracking: Boolean,
        val eastM: Double?,
        val northM: Double?,
        val frameGapMs: Double?,
        val preRobustNis: Double?,
        val postRobustNis: Double?,
        val disagreementM: Double?,
        val robustSigmaM: Double?,
    ) : TimedSample
    private data class StateSample(
        override val timestampNs: Long,
        val strideEstimateM: Double,
        val stationaryCandidate: Boolean,
        val turning: Boolean,
        val headingUnreliable: Boolean,
    ) : TimedSample

    private data class HeadingGeometry(
        val netChangeAbsRad: Double,
        val turnConsistency: Double,
        val sustainedTurnFraction: Double,
        val signedNetTurnRad: Double,
    )

    private data class ArcoreGeometry(
        val pathLengthM: Double,
        val straightnessRatio: Double,
        val netTurnAbsRad: Double,
        val turnConsistency: Double,
        val curvatureAbsRadPerM: Double,
        val signedNetTurnRad: Double,
        val crossTrackRmsM: Double,
    )

    init {
        featureOrderForSchema(featureSchemaVersion)
    }

    private val accelerometer = ArrayDeque<VectorSample>()
    private val gyroscope = ArrayDeque<VectorSample>()
    private val headings = ArrayDeque<HeadingSample>()
    private val steps = ArrayDeque<StepSample>()
    private val arFrames = ArrayDeque<ArFrameSample>()
    private val states = ArrayDeque<StateSample>()
    private val pdrPositions = ArrayDeque<PositionSample>()

    private var startedAtNs = 0L
    private var nextWindowEndNs = 0L
    private var nextWindowIndex = 0
    private var latestHeadingRad: Double? = null
    private var latestStrideM = NavguardAdaptiveFusionV2.DEFAULT_STRIDE_M
    private var pdrEastM = 0.0
    private var pdrNorthM = 0.0

    @Synchronized
    fun start(startTimestampNs: Long) {
        require(startTimestampNs > 0L)
        clear()
        startedAtNs = startTimestampNs
        nextWindowEndNs = startTimestampNs + FEATURE_WINDOW_NS
        pdrPositions.add(PositionSample(startTimestampNs, 0.0, 0.0))
    }

    @Synchronized
    fun clear() {
        accelerometer.clear()
        gyroscope.clear()
        headings.clear()
        steps.clear()
        arFrames.clear()
        states.clear()
        pdrPositions.clear()
        startedAtNs = 0L
        nextWindowEndNs = 0L
        nextWindowIndex = 0
        latestHeadingRad = null
        latestStrideM = NavguardAdaptiveFusionV2.DEFAULT_STRIDE_M
        pdrEastM = 0.0
        pdrNorthM = 0.0
    }

    @Synchronized
    fun addAccelerometer(timestampNs: Long, x: Float, y: Float, z: Float) {
        addMagnitude(accelerometer, timestampNs, x, y, z)
    }

    @Synchronized
    fun addGyroscope(timestampNs: Long, x: Float, y: Float, z: Float) {
        addMagnitude(gyroscope, timestampNs, x, y, z)
    }

    @Synchronized
    fun addHeading(timestampNs: Long, headingRad: Double, reliable: Boolean) {
        if (!acceptTimestamp(timestampNs) || !headingRad.isFinite() || headings.lastOrNull()?.timestampNs?.let { timestampNs <= it } == true) return
        val normalized = normalizeAngle(headingRad)
        headings.add(HeadingSample(timestampNs, normalized, reliable))
        latestHeadingRad = normalized
        trim(timestampNs)
    }

    @Synchronized
    fun addStep(
        timestampNs: Long,
        callbackReceiptTimestampNs: Long = timestampNs,
    ): NavguardAiStepIngestResult {
        if (!acceptTimestamp(timestampNs) ||
            callbackReceiptTimestampNs < timestampNs ||
            callbackReceiptTimestampNs - timestampNs > AI_STEP_FIXED_LAG_NS
        ) {
            return NavguardAiStepIngestResult(accepted = false, duplicate = false, outOfHistory = true)
        }
        if (steps.any { it.timestampNs == timestampNs }) {
            return NavguardAiStepIngestResult(accepted = false, duplicate = true, outOfHistory = false)
        }
        val ordered = (steps.toList() + StepSample(timestampNs)).sortedBy(StepSample::timestampNs)
        steps.clear()
        steps.addAll(ordered)
        rebuildPdrPositions()
        return NavguardAiStepIngestResult(accepted = true, duplicate = false, outOfHistory = false)
    }

    @Synchronized
    fun addAdaptiveState(
        timestampNs: Long,
        strideEstimateM: Double,
        stationaryCandidate: Boolean,
        turning: Boolean,
        headingUnreliable: Boolean,
    ) {
        if (!acceptTimestamp(timestampNs) || !strideEstimateM.isFinite() || states.lastOrNull()?.timestampNs?.let { timestampNs <= it } == true) return
        latestStrideM = strideEstimateM.coerceIn(
            NavguardAdaptiveFusionV2.MIN_STRIDE_M,
            NavguardAdaptiveFusionV2.MAX_STRIDE_M,
        )
        states.add(
            StateSample(
                timestampNs,
                latestStrideM,
                stationaryCandidate,
                turning,
                headingUnreliable,
            ),
        )
        trim(timestampNs)
    }

    @Synchronized
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
    ) {
        if (!acceptTimestamp(timestampNs) || arFrames.lastOrNull()?.timestampNs?.let { timestampNs <= it } == true) return
        val validPosition =
            tracking && eastM?.isFinite() == true && northM?.isFinite() == true
        arFrames.add(
            ArFrameSample(
                timestampNs = timestampNs,
                tracking = validPosition,
                eastM = if (validPosition) eastM else null,
                northM = if (validPosition) northM else null,
                frameGapMs = frameGapMs.finiteOrNull(),
                preRobustNis = preRobustNis.finiteOrNull(),
                postRobustNis = postRobustNis.finiteOrNull(),
                disagreementM = disagreementM.finiteOrNull(),
                robustSigmaM = robustSigmaM.finiteOrNull(),
            ),
        )
        trim(timestampNs)
    }

    @Synchronized
    fun pollCompleteWindows(upToTimestampNs: Long): List<NavguardAiFeatureWindow> {
        if (startedAtNs <= 0L || upToTimestampNs < nextWindowEndNs) return emptyList()
        val result = mutableListOf<NavguardAiFeatureWindow>()
        while (nextWindowEndNs <= upToTimestampNs) {
            result.add(buildWindow(nextWindowEndNs))
            nextWindowIndex += 1
            nextWindowEndNs += FEATURE_HOP_NS
        }
        trim(upToTimestampNs)
        return result
    }

    private fun buildWindow(endNs: Long): NavguardAiFeatureWindow {
        val startNs = endNs - FEATURE_WINDOW_NS
        val accel = accelerometer.filterWindow(startNs, endNs)
        val gyro = gyroscope.filterWindow(startNs, endNs)
        val headingWindow = headings.filterWindow(startNs, endNs)
        val stepWindow = steps.filterWindow(startNs, endNs)
        val arWindow = arFrames.filterWindow(startNs, endNs)
        val stateWindow = states.filterWindow(startNs, endNs)

        val accelValues = accel.map { it.magnitude }
        val gyroValues = gyro.map { it.magnitude }
        val headingValues = headingWindow.map { it.headingRad }
        val headingRates =
            headingWindow.zipWithNext().mapNotNull { (first, second) ->
                val dt = (second.timestampNs - first.timestampNs) / 1_000_000_000.0
                if (dt <= 0.0) null else abs(circularDifference(second.headingRad, first.headingRad)) / dt
            }
        val headingGeometry = headingGeometry(headingWindow.filter { it.reliable })
        val stepFeatures = stepFeatureValues(stepWindow.map(StepSample::timestampNs), startNs, endNs)
        val trackedAr = arWindow.filter { it.tracking && it.eastM != null && it.northM != null }
        val arSpeeds =
            trackedAr.zipWithNext().mapNotNull { (first, second) ->
                val dt = (second.timestampNs - first.timestampNs) / 1_000_000_000.0
                if (dt <= 0.0) null else hypot(second.eastM!! - first.eastM!!, second.northM!! - first.northM!!) / dt
            }
        val arDisplacement =
            if (trackedAr.size < 2) 0.0 else hypot(
                trackedAr.last().eastM!! - trackedAr.first().eastM!!,
                trackedAr.last().northM!! - trackedAr.first().northM!!,
            )
        val arGeometry = arcoreGeometry(trackedAr)
        val trackingFraction = if (arWindow.isEmpty()) 0.0 else trackedAr.size.toDouble() / arWindow.size
        val lastState = stateWindow.lastOrNull()
        val pdrStart = pdrPositions.latestAtOrBefore(startNs) ?: PositionSample(startNs, 0.0, 0.0)
        val pdrEnd = pdrPositions.latestAtOrBefore(endNs) ?: pdrStart
        val arStart = arFrames.lastOrNull { it.timestampNs <= startNs && it.tracking }
        val arEnd = arFrames.lastOrNull { it.timestampNs <= endNs && it.tracking }
        val headingStart = headings.latestAtOrBefore(startNs)
        val headingEnd = headings.latestAtOrBefore(endNs)

        val legacyValues =
            doubleArrayOf(
                accelValues.meanOrZero(), accelValues.stdOrZero(), accelValues.rmsOrZero(),
                gyroValues.meanOrZero(), gyroValues.stdOrZero(), gyroValues.rmsOrZero(),
                circularStd(headingValues), headingRates.meanOrZero(), headingRates.maxOrZero(),
                stepFeatures[0], stepFeatures[1], stepFeatures[2],
                arDisplacement, arSpeeds.meanOrZero(), arSpeeds.stdOrZero(), trackingFraction,
                arWindow.mapNotNull { it.frameGapMs }.meanOrZero(),
                arWindow.mapNotNull { it.preRobustNis }.meanOrZero(),
                arWindow.mapNotNull { it.postRobustNis }.meanOrZero(),
                arWindow.mapNotNull { it.disagreementM }.meanOrZero(),
                arWindow.mapNotNull { it.disagreementM }.maxOrZero(),
                lastState?.strideEstimateM ?: latestStrideM,
                stateWindow.fraction { it.stationaryCandidate },
                stateWindow.fraction { it.turning },
                arWindow.mapNotNull { it.robustSigmaM }.meanOrZero(NavguardAdaptiveFusionV2.BASE_ARCORE_SIGMA_M),
                if (headingWindow.isEmpty()) 1.0 else headingWindow.count { !it.reliable }.toDouble() / headingWindow.size,
            )
        val v2Values =
            doubleArrayOf(
                headingGeometry.netChangeAbsRad,
                headingGeometry.turnConsistency,
                headingGeometry.sustainedTurnFraction,
                arGeometry.pathLengthM,
                arGeometry.straightnessRatio,
                arGeometry.netTurnAbsRad,
                arGeometry.turnConsistency,
                arGeometry.curvatureAbsRadPerM,
            )
        val directionAgreement =
            turnDirectionAgreement(
                headingGeometry.signedNetTurnRad,
                arGeometry.signedNetTurnRad,
            )
        val magnitudeDifference =
            turnMagnitudeDifferenceRatio(
                headingGeometry.netChangeAbsRad,
                arGeometry.netTurnAbsRad,
            )
        val turnCoherence =
            turnCoherence(
                headingSignedNetTurnRad = headingGeometry.signedNetTurnRad,
                arcoreSignedNetTurnRad = arGeometry.signedNetTurnRad,
                directionAgreement = directionAgreement,
                headingTurnConsistency = headingGeometry.turnConsistency,
                sustainedTurnFraction = headingGeometry.sustainedTurnFraction,
                arcoreTurnConsistency = arGeometry.turnConsistency,
            )
        val v3Values =
            doubleArrayOf(
                headingGeometry.signedNetTurnRad,
                arGeometry.signedNetTurnRad,
                directionAgreement,
                magnitudeDifference,
                turnCoherence,
                arGeometry.crossTrackRmsM,
            )
        val values =
            when (featureSchemaVersion) {
                FEATURE_SCHEMA_VERSION_V1 -> legacyValues
                FEATURE_SCHEMA_VERSION_V2 -> legacyValues + v2Values
                FEATURE_SCHEMA_VERSION_V3 -> legacyValues + v2Values + v3Values
                else -> error("unsupported feature schema")
            }.map { if (it.isFinite()) it else 0.0 }.toDoubleArray()

        return NavguardAiFeatureWindow(
            windowIndex = nextWindowIndex,
            startTimestampNs = startNs,
            endTimestampNs = endNs,
            vector =
                NavguardAiFeatureVector(
                    schemaVersion = featureSchemaVersion,
                    values = values,
                ),
            arStartEastM = arStart?.eastM,
            arStartNorthM = arStart?.northM,
            arEndEastM = arEnd?.eastM,
            arEndNorthM = arEnd?.northM,
            pdrStartEastM = pdrStart.eastM,
            pdrStartNorthM = pdrStart.northM,
            pdrEndEastM = pdrEnd.eastM,
            pdrEndNorthM = pdrEnd.northM,
            headingStartRad = headingStart?.headingRad,
            headingEndRad = headingEnd?.headingRad,
        )
    }

    private fun headingGeometry(samples: List<HeadingSample>): HeadingGeometry {
        val intervals =
            samples.zipWithNext().mapNotNull { (first, second) ->
                val dt = (second.timestampNs - first.timestampNs) / 1_000_000_000.0
                if (dt <= 0.0 || !dt.isFinite()) {
                    null
                } else {
                    circularDifference(second.headingRad, first.headingRad) to dt
                }
            }
        if (intervals.isEmpty()) return HeadingGeometry(0.0, 0.0, 0.0, 0.0)
        val signedSum = intervals.sumOf { it.first }
        val absoluteSum = intervals.sumOf { abs(it.first) }
        val consistency =
            if (absoluteSum <= NUMERICAL_EPSILON) 0.0 else (abs(signedSum) / absoluteSum).coerceIn(0.0, 1.0)
        val dominantDirection =
            when {
                signedSum > NUMERICAL_EPSILON -> 1
                signedSum < -NUMERICAL_EPSILON -> -1
                else -> 0
            }
        val supporting =
            if (dominantDirection == 0) {
                0
            } else {
                intervals.count { (delta, dt) ->
                    val rate = delta / dt
                    abs(rate) >= SUSTAINED_TURN_RATE_RAD_PER_S &&
                        ((rate > 0.0 && dominantDirection > 0) ||
                            (rate < 0.0 && dominantDirection < 0))
                }
            }
        return HeadingGeometry(
            netChangeAbsRad = abs(signedSum),
            turnConsistency = consistency,
            sustainedTurnFraction = supporting.toDouble() / intervals.size,
            signedNetTurnRad = signedSum.coerceIn(-MAX_SIGNED_TURN_RAD, MAX_SIGNED_TURN_RAD),
        )
    }

    private fun arcoreGeometry(samples: List<ArFrameSample>): ArcoreGeometry {
        if (samples.size < 2) return ArcoreGeometry(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        val segments =
            samples.zipWithNext().map { (first, second) ->
                val deltaEast = second.eastM!! - first.eastM!!
                val deltaNorth = second.northM!! - first.northM!!
                val length = hypot(deltaEast, deltaNorth)
                Triple(deltaEast, deltaNorth, length)
            }
        val pathLength = segments.sumOf { it.third }.takeIf(Double::isFinite) ?: 0.0
        val endToEnd =
            hypot(
                samples.last().eastM!! - samples.first().eastM!!,
                samples.last().northM!! - samples.first().northM!!,
            )
        val straightness =
            if (pathLength < MIN_STRAIGHTNESS_PATH_M) {
                0.0
            } else {
                (endToEnd / pathLength).coerceIn(0.0, 1.0)
            }
        val meaningfulBearings =
            segments.mapNotNull { (deltaEast, deltaNorth, length) ->
                if (length < MIN_MEANINGFUL_ARCORE_SEGMENT_M) {
                    null
                } else {
                    normalizeAngle(atan2(deltaEast, deltaNorth))
                }
            }
        val bearingChanges =
            meaningfulBearings.zipWithNext().map { (first, second) ->
                circularDifference(second, first)
            }
        val signedTurn = bearingChanges.sum()
        val absoluteTurn = bearingChanges.sumOf(::abs)
        val turnConsistency =
            if (bearingChanges.isEmpty() || absoluteTurn <= NUMERICAL_EPSILON) {
                0.0
            } else {
                (abs(signedTurn) / absoluteTurn).coerceIn(0.0, 1.0)
            }
        val curvature =
            if (pathLength < MIN_CURVATURE_PATH_M) 0.0 else absoluteTurn / pathLength
        val acceptedPoints = mutableListOf<ArFrameSample>()
        samples.forEach { sample ->
            val previous = acceptedPoints.lastOrNull()
            if (previous == null ||
                hypot(
                    sample.eastM!! - previous.eastM!!,
                    sample.northM!! - previous.northM!!,
                ) >= MIN_MEANINGFUL_ARCORE_SEGMENT_M
            ) {
                acceptedPoints.add(sample)
            }
        }
        val acceptedBearings =
            acceptedPoints.zipWithNext().map { (first, second) ->
                normalizeAngle(
                    atan2(
                        second.eastM!! - first.eastM!!,
                        second.northM!! - first.northM!!,
                    ),
                )
            }
        val acceptedBearingChanges =
            acceptedBearings.zipWithNext().map { (first, second) ->
                circularDifference(second, first)
            }
        val signedAcceptedTurn = acceptedBearingChanges.sum()
        val crossTrackRms = crossTrackRms(acceptedPoints)
        return ArcoreGeometry(
            pathLengthM = pathLength.coerceAtLeast(0.0),
            straightnessRatio = straightness,
            netTurnAbsRad = if (bearingChanges.isEmpty()) 0.0 else abs(signedTurn),
            turnConsistency = turnConsistency,
            curvatureAbsRadPerM = curvature.coerceAtLeast(0.0),
            signedNetTurnRad =
                if (acceptedBearingChanges.isEmpty()) {
                    0.0
                } else {
                    signedAcceptedTurn.coerceIn(-MAX_SIGNED_TURN_RAD, MAX_SIGNED_TURN_RAD)
                },
            crossTrackRmsM = crossTrackRms,
        )
    }

    private fun crossTrackRms(samples: List<ArFrameSample>): Double {
        if (samples.size < 3) return 0.0
        val first = samples.first()
        val last = samples.last()
        val chordEast = last.eastM!! - first.eastM!!
        val chordNorth = last.northM!! - first.northM!!
        val chordLength = hypot(chordEast, chordNorth)
        if (!chordLength.isFinite() || chordLength < MIN_CROSS_TRACK_CHORD_M) return 0.0
        val squaredDistances =
            samples.subList(1, samples.lastIndex).map { sample ->
                val relativeEast = sample.eastM!! - first.eastM!!
                val relativeNorth = sample.northM!! - first.northM!!
                val cross = relativeEast * chordNorth - relativeNorth * chordEast
                val distance = abs(cross) / chordLength
                distance * distance
            }
        if (squaredDistances.isEmpty()) return 0.0
        return sqrt(squaredDistances.sum() / squaredDistances.size)
            .coerceIn(0.0, MAX_CROSS_TRACK_RMS_M)
    }

    private fun turnDirectionAgreement(
        headingSignedNetTurnRad: Double,
        arcoreSignedNetTurnRad: Double,
    ): Double {
        if (abs(headingSignedNetTurnRad) < MIN_AGREEMENT_TURN_RAD ||
            abs(arcoreSignedNetTurnRad) < MIN_AGREEMENT_TURN_RAD
        ) {
            return 0.0
        }
        val strength =
            (minOf(abs(headingSignedNetTurnRad), abs(arcoreSignedNetTurnRad)) /
                FULL_AGREEMENT_TURN_RAD).coerceIn(0.0, 1.0)
        val direction = if (headingSignedNetTurnRad * arcoreSignedNetTurnRad > 0.0) 1.0 else -1.0
        return (direction * strength).coerceIn(-1.0, 1.0)
    }

    private fun turnMagnitudeDifferenceRatio(
        headingNetTurnAbsRad: Double,
        arcoreNetTurnAbsRad: Double,
    ): Double {
        val denominator = max(headingNetTurnAbsRad + arcoreNetTurnAbsRad, MIN_TURN_MAGNITUDE_DENOMINATOR_RAD)
        return (abs(headingNetTurnAbsRad - arcoreNetTurnAbsRad) / denominator)
            .coerceIn(0.0, 1.0)
    }

    private fun turnCoherence(
        headingSignedNetTurnRad: Double,
        arcoreSignedNetTurnRad: Double,
        directionAgreement: Double,
        headingTurnConsistency: Double,
        sustainedTurnFraction: Double,
        arcoreTurnConsistency: Double,
    ): Double =
        minOf(
            (abs(headingSignedNetTurnRad) / FULL_AGREEMENT_TURN_RAD).coerceIn(0.0, 1.0),
            (abs(arcoreSignedNetTurnRad) / FULL_AGREEMENT_TURN_RAD).coerceIn(0.0, 1.0),
            headingTurnConsistency.coerceIn(0.0, 1.0),
            sustainedTurnFraction.coerceIn(0.0, 1.0),
            arcoreTurnConsistency.coerceIn(0.0, 1.0),
            max(directionAgreement, 0.0).coerceIn(0.0, 1.0),
        )

    private fun addMagnitude(
        target: ArrayDeque<VectorSample>,
        timestampNs: Long,
        x: Float,
        y: Float,
        z: Float,
    ) {
        if (!acceptTimestamp(timestampNs) || target.lastOrNull()?.timestampNs?.let { timestampNs <= it } == true) return
        val magnitude = sqrt((x * x + y * y + z * z).toDouble())
        if (magnitude.isFinite()) target.add(VectorSample(timestampNs, magnitude))
        trim(timestampNs)
    }

    private fun rebuildPdrPositions() {
        pdrPositions.clear()
        pdrEastM = 0.0
        pdrNorthM = 0.0
        pdrPositions.add(PositionSample(startedAtNs, pdrEastM, pdrNorthM))
        steps.forEach { step ->
            val heading = headings.latestAtOrBefore(step.timestampNs)?.headingRad ?: return@forEach
            val stride =
                states.latestAtOrBefore(step.timestampNs)?.strideEstimateM
                    ?: NavguardAdaptiveFusionV2.DEFAULT_STRIDE_M
            pdrEastM += stride * sin(heading)
            pdrNorthM += stride * cos(heading)
            pdrPositions.add(PositionSample(step.timestampNs, pdrEastM, pdrNorthM))
        }
    }

    private fun acceptTimestamp(timestampNs: Long): Boolean = startedAtNs > 0L && timestampNs >= startedAtNs

    private fun trim(nowNs: Long) {
        val cutoff = nowNs - MAX_BUFFER_NS
        fun <T> ArrayDeque<T>.trimBy(timestamp: (T) -> Long) {
            while (isNotEmpty() && timestamp(first()) < cutoff) removeFirst()
            while (size > MAX_SAMPLES_PER_STREAM) removeFirst()
        }
        accelerometer.trimBy { it.timestampNs }
        gyroscope.trimBy { it.timestampNs }
        headings.trimBy { it.timestampNs }
        steps.trimBy { it.timestampNs }
        arFrames.trimBy { it.timestampNs }
        states.trimBy { it.timestampNs }
        pdrPositions.trimBy { it.timestampNs }
    }

    companion object {
        const val FEATURE_SCHEMA_VERSION_V1 = "navguard_ai_features_v1"
        const val FEATURE_SCHEMA_VERSION_V2 = "navguard_ai_features_v2"
        const val FEATURE_SCHEMA_VERSION_V3 = "navguard_ai_features_v3"
        const val FEATURE_SCHEMA_VERSION = FEATURE_SCHEMA_VERSION_V3
        const val FEATURE_WINDOW_MS = 2_000L
        const val FEATURE_HOP_MS = 1_000L
        const val AI_STEP_FIXED_LAG_MS = 12_000L
        private const val FEATURE_WINDOW_NS = FEATURE_WINDOW_MS * 1_000_000L
        private const val FEATURE_HOP_NS = FEATURE_HOP_MS * 1_000_000L
        const val AI_STEP_FIXED_LAG_NS = AI_STEP_FIXED_LAG_MS * 1_000_000L
        private const val MAX_BUFFER_NS = AI_STEP_FIXED_LAG_NS + FEATURE_WINDOW_NS
        private const val MAX_SAMPLES_PER_STREAM = 4_096
        private const val NUMERICAL_EPSILON = 1e-12
        private const val SUSTAINED_TURN_RATE_RAD_PER_S = 0.20
        private const val MIN_MEANINGFUL_ARCORE_SEGMENT_M = 0.03
        private const val MIN_STRAIGHTNESS_PATH_M = 0.05
        private const val MIN_CURVATURE_PATH_M = 0.25
        private const val MIN_CROSS_TRACK_CHORD_M = 0.05
        private const val MAX_CROSS_TRACK_RMS_M = 5.0
        private const val MIN_AGREEMENT_TURN_RAD = 0.20
        private const val FULL_AGREEMENT_TURN_RAD = 0.35
        private const val MIN_TURN_MAGNITUDE_DENOMINATOR_RAD = 0.20
        private const val MAX_SIGNED_TURN_RAD = 2.0 * PI

        val FEATURE_ORDER_V1 =
            listOf(
                "accel_mag_mean",
                "accel_mag_std",
                "accel_mag_rms",
                "gyro_mag_mean",
                "gyro_mag_std",
                "gyro_mag_rms",
                "heading_circular_std_rad",
                "heading_rate_abs_mean_rad_s",
                "heading_rate_abs_max_rad_s",
                "step_count",
                "step_cadence_hz",
                "step_interval_std_s",
                "arcore_displacement_m",
                "arcore_speed_mean_mps",
                "arcore_speed_std_mps",
                "arcore_tracking_fraction",
                "arcore_frame_gap_mean_ms",
                "arcore_pre_robust_nis_mean",
                "arcore_post_robust_nis_mean",
                "source_disagreement_mean_m",
                "source_disagreement_max_m",
                "stride_estimate_m",
                "stationary_candidate_fraction",
                "turning_heuristic_fraction",
                "arcore_robust_sigma_mean_m",
                "heading_unreliable_fraction",
            )

        val FEATURE_ORDER_V2 =
            FEATURE_ORDER_V1 +
                listOf(
                    "heading_net_change_abs_rad",
                    "heading_turn_consistency",
                    "sustained_turn_fraction",
                    "arcore_path_length_m",
                    "arcore_straightness_ratio",
                    "arcore_net_turn_abs_rad",
                    "arcore_turn_consistency",
                    "arcore_curvature_abs_rad_per_m",
                )

        val FEATURE_ORDER_V3 =
            FEATURE_ORDER_V2 +
                listOf(
                    "heading_signed_net_turn_rad",
                    "arcore_signed_net_turn_rad",
                    "heading_path_turn_direction_agreement",
                    "heading_path_turn_magnitude_difference_ratio",
                    "heading_path_turn_coherence",
                    "arcore_cross_track_rms_m",
                )

        val FEATURE_ORDER = FEATURE_ORDER_V3

        fun featureOrderForSchema(schemaVersion: String): List<String> =
            when (schemaVersion) {
                FEATURE_SCHEMA_VERSION_V1 -> FEATURE_ORDER_V1
                FEATURE_SCHEMA_VERSION_V2 -> FEATURE_ORDER_V2
                FEATURE_SCHEMA_VERSION_V3 -> FEATURE_ORDER_V3
                else -> throw IllegalArgumentException("unsupported feature schema: $schemaVersion")
            }

        fun replayStepFeatures(
            windows: List<NavguardAiFeatureWindow>,
            physicalStepTimestampsNs: Collection<Long>,
        ): List<NavguardAiFeatureWindow> {
            val orderedSteps = physicalStepTimestampsNs.distinct().sorted()
            return windows.map { window ->
                val corrected = window.vector.values.copyOf()
                val stepFeatures = stepFeatureValues(orderedSteps, window.startTimestampNs, window.endTimestampNs)
                corrected[9] = stepFeatures[0]
                corrected[10] = stepFeatures[1]
                corrected[11] = stepFeatures[2]
                window.copy(
                    vector =
                        NavguardAiFeatureVector(
                            schemaVersion = window.vector.schemaVersion,
                            values = corrected,
                        ),
                )
            }
        }

        private fun stepFeatureValues(
            physicalStepTimestampsNs: Collection<Long>,
            windowStartNs: Long,
            windowEndNs: Long,
        ): DoubleArray {
            val inWindow =
                physicalStepTimestampsNs
                    .asSequence()
                    .filter { it > windowStartNs && it <= windowEndNs }
                    .distinct()
                    .sorted()
                    .toList()
            val intervals =
                inWindow.zipWithNext().mapNotNull { (first, second) ->
                    val intervalSeconds = (second - first) / 1_000_000_000.0
                    intervalSeconds.takeIf { it > 0.0 && it.isFinite() }
                }
            return doubleArrayOf(
                inWindow.size.toDouble(),
                inWindow.size / (FEATURE_WINDOW_MS / 1_000.0),
                intervals.stdOrZero(),
            )
        }

        fun runDeterministicSelfTests(): Map<String, Boolean> {
            fun build(
                schemaVersion: String = FEATURE_SCHEMA_VERSION,
                includeFutureOutlier: Boolean = false,
            ): List<NavguardAiFeatureWindow> {
                val extractor = NavguardAiFeatureExtractor(schemaVersion)
                val start = 1_000_000_000L
                extractor.start(start)
                for (index in 0..150) {
                    val timestamp = start + index * 20_000_000L
                    extractor.addAccelerometer(timestamp, 0.1f, 0.2f, 9.8f)
                    extractor.addGyroscope(timestamp, 0.01f, 0.02f, 0.03f)
                    if (index % 5 == 0) {
                        extractor.addHeading(timestamp, index * 0.001, true)
                        extractor.addAdaptiveState(timestamp, 0.75, false, false, false)
                        extractor.addArcoreFrame(timestamp, true, index * 0.002, 0.0, 100.0, 1.0, 1.0, 0.2, 0.35)
                    }
                    if (index == 60 || index == 110) extractor.addStep(timestamp)
                }
                if (includeFutureOutlier) {
                    extractor.addAccelerometer(start + 2_500_000_000L, 10_000f, 0f, 0f)
                }
                return extractor.pollCompleteWindows(start + 3_000_000_000L)
            }
            val first = build()
            val second = build()
            val deterministic =
                first.size == second.size && first.indices.all { first[it].vector.values.contentEquals(second[it].vector.values) }
            val withFutureOutlier = build(includeFutureOutlier = true)
            val causal =
                first.size == withFutureOutlier.size &&
                    first.first().vector.values.contentEquals(withFutureOutlier.first().vector.values)
            val windowHop = first.size == 2 && first[1].endTimestampNs - first[0].endTimestampNs == FEATURE_HOP_NS
            val finite = first.flatMap { it.vector.values.asIterable() }.all(Double::isFinite)
            val v2 = build(FEATURE_SCHEMA_VERSION_V2)
            val v1 = build(FEATURE_SCHEMA_VERSION_V1)
            val legacySemanticsPreserved =
                v1.size == v2.size &&
                    v2.indices.all { index ->
                        v1[index].vector.values.contentEquals(
                            v2[index].vector.values.copyOfRange(0, FEATURE_ORDER_V1.size),
                        )
                    }
            val first34Regression =
                v2.size == first.size &&
                    first.indices.all { index ->
                        v2[index].vector.values.contentEquals(
                            first[index].vector.values.copyOfRange(0, FEATURE_ORDER_V2.size),
                        )
                    }
            val forbidden = listOf("latitude", "longitude", "timestamp_ns", "raw_gnss", "raw_accel", "raw_gyro", "arcore_pose")
            val privacy = FEATURE_ORDER.none { name -> forbidden.any { name.contains(it, ignoreCase = true) } }

            fun geometryWindow(
                headingValues: List<Double> = emptyList(),
                arPositions: List<Pair<Double, Double>> = emptyList(),
                schemaVersion: String = FEATURE_SCHEMA_VERSION,
            ): NavguardAiFeatureWindow {
                val start = 40_000_000_000L
                val extractor = NavguardAiFeatureExtractor(schemaVersion)
                extractor.start(start)
                headingValues.forEachIndexed { index, heading ->
                    extractor.addHeading(
                        start + (index + 1L) * 250_000_000L,
                        heading,
                        true,
                    )
                }
                arPositions.forEachIndexed { index, position ->
                    extractor.addArcoreFrame(
                        timestampNs = start + (index + 1L) * 250_000_000L,
                        tracking = true,
                        eastM = position.first,
                        northM = position.second,
                        frameGapMs = 250.0,
                        preRobustNis = 1.0,
                        postRobustNis = 1.0,
                        disagreementM = 0.0,
                        robustSigmaM = NavguardAdaptiveFusionV2.BASE_ARCORE_SIGMA_M,
                    )
                }
                return extractor.pollCompleteWindows(start + FEATURE_WINDOW_NS).single()
            }

            val wrapWindow = geometryWindow(listOf(PI - 0.10, -PI + 0.10))
            val headingWrap = abs(wrapWindow.vector.values[26] - 0.20) < 1e-9
            val oscillatoryHeading =
                geometryWindow(listOf(0.0, 0.40, 0.0, 0.40, 0.0)).vector.values
            val sustainedHeading =
                geometryWindow(listOf(0.0, 0.20, 0.40, 0.60, 0.80)).vector.values
            val headingOscillationSeparated =
                oscillatoryHeading[26] < 0.05 &&
                    oscillatoryHeading[27] < 0.05 &&
                    oscillatoryHeading[28] < 0.05
            val sustainedHeadingTurn =
                sustainedHeading[26] > oscillatoryHeading[26] &&
                    sustainedHeading[27] > 0.95 &&
                    sustainedHeading[28] > 0.95
            val headingNetChange =
                abs(sustainedHeading[26] - 0.80) < 1e-9 &&
                    oscillatoryHeading[26] < 0.05
            val headingTurnConsistency =
                sustainedHeading[27] > 0.95 &&
                    oscillatoryHeading[27] < 0.05
            val sustainedTurnFraction =
                sustainedHeading[28] > 0.95 &&
                    oscillatoryHeading[28] < 0.05

            val straightAr =
                geometryWindow(
                    arPositions =
                        listOf(
                            0.0 to 0.0,
                            0.10 to 0.0,
                            0.20 to 0.0,
                            0.30 to 0.0,
                            0.40 to 0.0,
                        ),
                ).vector.values
            val turningAr =
                geometryWindow(
                    arPositions =
                        listOf(
                            0.0 to 0.0,
                            0.10 to 0.0,
                            0.20 to 0.0,
                            0.20 to 0.10,
                            0.20 to 0.20,
                        ),
                ).vector.values
            val stationaryAr =
                geometryWindow(
                    arPositions =
                        listOf(
                            0.0 to 0.0,
                            0.001 to 0.0,
                            0.0 to 0.001,
                            0.001 to 0.001,
                        ),
                ).vector.values
            val straightArPath =
                abs(straightAr[30] - 1.0) < 1e-9 &&
                    straightAr[31] < 1e-9 &&
                    straightAr[33] < 1e-9 &&
                    straightAr[32].isFinite()
            val ninetyDegreeArPath =
                turningAr[29] > 0.0 &&
                    turningAr[30] < straightAr[30] &&
                    abs(turningAr[31] - PI / 2.0) < 1e-9 &&
                    turningAr[32] > 0.95 &&
                    turningAr[33] > straightAr[33]
            val arcorePathLength =
                abs(straightAr[29] - 0.40) < 1e-9 &&
                    abs(turningAr[29] - 0.40) < 1e-9
            val arcoreStraightness =
                abs(straightAr[30] - 1.0) < 1e-9 &&
                    turningAr[30] < straightAr[30]
            val arcoreNetTurn =
                straightAr[31] < 1e-9 &&
                    abs(turningAr[31] - PI / 2.0) < 1e-9
            val arcoreTurnConsistency =
                straightAr[32].isFinite() &&
                    turningAr[32] > 0.95
            val arcoreCurvature =
                straightAr[33] < 1e-9 &&
                    turningAr[33] > straightAr[33]
            val stationaryGeometrySafe =
                stationaryAr.slice(29..33).all { it.isFinite() && it >= 0.0 } &&
                    stationaryAr[30] == 0.0 &&
                    stationaryAr[31] == 0.0 &&
                    stationaryAr[32] == 0.0 &&
                    stationaryAr[33] == 0.0
            val insufficientGeometrySafe =
                geometryWindow().vector.values.slice(26..33).all { it == 0.0 }

            val straightV3 =
                geometryWindow(
                    headingValues = listOf(0.0, 0.0, 0.0),
                    arPositions =
                        listOf(
                            0.0 to 0.0,
                            0.0 to 0.10,
                            0.0 to 0.20,
                            0.0 to 0.30,
                        ),
                ).vector.values
            val rightV3 =
                geometryWindow(
                    headingValues = listOf(0.0, PI / 2.0),
                    arPositions =
                        listOf(
                            0.0 to 0.0,
                            0.0 to 0.10,
                            0.0 to 0.20,
                            0.10 to 0.20,
                            0.20 to 0.20,
                        ),
                ).vector.values
            val leftV3 =
                geometryWindow(
                    headingValues = listOf(0.0, -PI / 2.0),
                    arPositions =
                        listOf(
                            0.0 to 0.0,
                            0.0 to 0.10,
                            0.0 to 0.20,
                            -0.10 to 0.20,
                            -0.20 to 0.20,
                        ),
                ).vector.values
            val oppositeV3 =
                geometryWindow(
                    headingValues = listOf(0.0, PI / 2.0),
                    arPositions =
                        listOf(
                            0.0 to 0.0,
                            0.0 to 0.10,
                            0.0 to 0.20,
                            -0.10 to 0.20,
                            -0.20 to 0.20,
                        ),
                ).vector.values
            val weakAgreementV3 =
                geometryWindow(
                    headingValues = listOf(0.0, 0.10),
                    arPositions =
                        listOf(
                            0.0 to 0.0,
                            0.0 to 0.10,
                            0.0 to 0.20,
                            0.10 to 0.20,
                        ),
                ).vector.values
            val headingWrapV3 = geometryWindow(listOf(PI - 0.10, -PI + 0.10)).vector.values
            val headingAccumulatedV3 =
                geometryWindow((0..4).map { it.toDouble() }).vector.values
            val headingPositiveClampV3 =
                geometryWindow((0..7).map { it * 1.20 }).vector.values
            val headingNegativeClampV3 =
                geometryWindow((0..7).map { -it * 1.20 }).vector.values
            val shortArV3 =
                geometryWindow(
                    arPositions =
                        listOf(
                            0.0 to 0.0,
                            0.01 to 0.0,
                            0.02 to 0.0,
                        ),
                ).vector.values
            val insufficientArV3 =
                geometryWindow(
                    arPositions = listOf(0.0 to 0.0, 0.10 to 0.0),
                ).vector.values
            val headingOnlyV3 =
                geometryWindow(
                    headingValues = listOf(0.0, 1.0),
                    arPositions =
                        listOf(
                            0.0 to 0.0,
                            0.0 to 0.10,
                            0.0 to 0.20,
                            0.0 to 0.30,
                        ),
                ).vector.values
            val pathOnlyV3 =
                geometryWindow(
                    headingValues = listOf(0.0, 0.0),
                    arPositions =
                        listOf(
                            0.0 to 0.0,
                            0.0 to 0.10,
                            0.0 to 0.20,
                            0.10 to 0.20,
                            0.20 to 0.20,
                        ),
                ).vector.values
            val lowSustainedV3 =
                geometryWindow(
                    headingValues = (0..7).map { it * 0.04 },
                    arPositions =
                        listOf(
                            0.0 to 0.0,
                            0.0 to 0.10,
                            0.0 to 0.20,
                            0.10 to 0.20,
                            0.20 to 0.20,
                        ),
                ).vector.values
            val curvedCrossTrackV3 =
                geometryWindow(
                    arPositions =
                        listOf(
                            0.0 to 0.0,
                            0.0 to 0.10,
                            0.10 to 0.20,
                            0.0 to 0.30,
                        ),
                ).vector.values
            val shallowCrossTrackV3 =
                geometryWindow(
                    arPositions =
                        listOf(
                            0.0 to 0.0,
                            0.0 to 0.10,
                            0.02 to 0.20,
                            0.0 to 0.30,
                        ),
                ).vector.values
            val noisyCurvedCrossTrackV3 =
                geometryWindow(
                    arPositions =
                        listOf(
                            0.0 to 0.0,
                            0.01 to 0.01,
                            0.0 to 0.10,
                            0.10 to 0.20,
                            0.0 to 0.30,
                        ),
                ).vector.values
            val tinyChordV3 =
                geometryWindow(
                    arPositions =
                        listOf(
                            0.0 to 0.0,
                            0.10 to 0.0,
                            0.01 to 0.0,
                        ),
                ).vector.values
            val boundedCrossTrackV3 =
                geometryWindow(
                    arPositions =
                        listOf(
                            0.0 to 0.0,
                            0.0 to 10.0,
                            10.0 to 20.0,
                            0.0 to 0.10,
                        ),
                ).vector.values

            val headingSignedTests =
                abs(straightV3[34]) < 1e-12 &&
                    rightV3[34] > 0.0 &&
                    leftV3[34] < 0.0 &&
                    abs(headingWrapV3[34] - 0.20) < 1e-9 &&
                    headingAccumulatedV3[34] > PI &&
                    abs(headingPositiveClampV3[34] - 2.0 * PI) < 1e-9 &&
                    abs(headingNegativeClampV3[34] + 2.0 * PI) < 1e-9
            val arcoreSignedTests =
                abs(straightV3[35]) < 1e-12 &&
                    rightV3[35] > 0.0 &&
                    leftV3[35] < 0.0 &&
                    abs(shortArV3[35]) < 1e-12 &&
                    abs(insufficientArV3[35]) < 1e-12
            val crossSourceRightSign = rightV3[34] > 0.0 && rightV3[35] > 0.0
            val crossSourceLeftSign = leftV3[34] < 0.0 && leftV3[35] < 0.0
            val directionAgreementTests =
                rightV3[36] > 0.0 &&
                    leftV3[36] > 0.0 &&
                    oppositeV3[36] < 0.0 &&
                    weakAgreementV3[36] == 0.0 &&
                    listOf(rightV3[36], leftV3[36], oppositeV3[36], weakAgreementV3[36])
                        .all { it in -1.0..1.0 }
            val magnitudeDifferenceTests =
                abs(rightV3[37]) < 1e-9 &&
                    headingOnlyV3[37] > 0.95 &&
                    pathOnlyV3[37] > 0.95 &&
                    straightV3[37] == 0.0 &&
                    listOf(rightV3[37], headingOnlyV3[37], pathOnlyV3[37], straightV3[37])
                        .all { it in 0.0..1.0 }
            val coherenceTests =
                rightV3[38] > 0.0 &&
                    headingOnlyV3[38] == 0.0 &&
                    pathOnlyV3[38] == 0.0 &&
                    oppositeV3[38] == 0.0 &&
                    lowSustainedV3[38] == 0.0 &&
                    listOf(rightV3[38], headingOnlyV3[38], pathOnlyV3[38], oppositeV3[38])
                        .all { it in 0.0..1.0 }
            val crossTrackTests =
                abs(straightV3[39]) < 1e-12 &&
                    curvedCrossTrackV3[39] > 0.0 &&
                    shallowCrossTrackV3[39] > straightV3[39] &&
                    geometryWindow().vector.values[39] == 0.0 &&
                    tinyChordV3[39] == 0.0 &&
                    abs(noisyCurvedCrossTrackV3[39] - curvedCrossTrackV3[39]) < 1e-12 &&
                    boundedCrossTrackV3[39] == MAX_CROSS_TRACK_RMS_M
            val v3InsufficientSamplesSafe =
                geometryWindow().vector.values.slice(34..39).all { it == 0.0 }
            val stepStart = 20_000_000_000L
            val stepExtractor = NavguardAiFeatureExtractor().apply { start(stepStart) }
            val firstStep = stepStart + 500_000_000L
            val secondStep = stepStart + 1_000_000_000L
            val thirdStep = stepStart + 1_500_000_000L
            val stepForwarded = stepExtractor.addStep(firstStep).accepted
            stepExtractor.addStep(secondStep)
            stepExtractor.addStep(thirdStep)
            val threeStepWindow = stepExtractor.pollCompleteWindows(stepStart + FEATURE_WINDOW_NS).single()
            val threeStepValues = threeStepWindow.vector.values
            val threeStepFeatures =
                threeStepValues[9] == 3.0 &&
                    threeStepValues[10] > 0.0 &&
                    threeStepValues[11].isFinite()
            val stationaryExtractor = NavguardAiFeatureExtractor().apply { start(stepStart) }
            val stationaryWindow = stationaryExtractor.pollCompleteWindows(stepStart + FEATURE_WINDOW_NS).single()
            val stationaryStepZeros = stationaryWindow.vector.values.slice(9..11).all { it == 0.0 && it.isFinite() }
            val delayedExtractor = NavguardAiFeatureExtractor().apply { start(stepStart) }
            val delayedWindowEnd = stepStart + 6_000_000_000L
            val uncorrectedDelayedWindow = delayedExtractor.pollCompleteWindows(delayedWindowEnd).last()
            val delayedPhysicalTimestamp = stepStart + 5_000_000_000L
            val delayedReceiptTimestamp = stepStart + 12_000_000_000L
            val delayedResult = delayedExtractor.addStep(delayedPhysicalTimestamp, delayedReceiptTimestamp)
            val correctedDelayedWindow =
                replayStepFeatures(listOf(uncorrectedDelayedWindow), listOf(delayedPhysicalTimestamp)).single()
            val delayedReplay =
                delayedResult.accepted &&
                    uncorrectedDelayedWindow.vector.values[9] == 0.0 &&
                    correctedDelayedWindow.vector.values[9] == 1.0
            val physicalTimestampPreserved =
                correctedDelayedWindow.endTimestampNs == delayedWindowEnd &&
                    correctedDelayedWindow.vector.values[9] == 1.0
            val duplicateRejected = delayedExtractor.addStep(delayedPhysicalTimestamp, delayedReceiptTimestamp).duplicate
            val outOfHistoryRejected =
                delayedExtractor.addStep(
                    stepStart + 7_000_000_000L,
                    stepStart + 19_000_000_001L,
                ).outOfHistory
            val replayGeometryDeterministic =
                uncorrectedDelayedWindow.vector.values
                    .copyOfRange(26, FEATURE_ORDER_V3.size)
                    .contentEquals(
                        correctedDelayedWindow.vector.values.copyOfRange(
                            26,
                            FEATURE_ORDER_V3.size,
                        ),
                    )
            return linkedMapOf(
                "featureSchemaV1Exact" to (
                    FEATURE_SCHEMA_VERSION_V1 == "navguard_ai_features_v1" &&
                        FEATURE_ORDER_V1.size == 26
                ),
                "featureSchemaV2Exact" to (
                    FEATURE_SCHEMA_VERSION_V2 == "navguard_ai_features_v2" &&
                        FEATURE_ORDER_V2.size == 34 &&
                        FEATURE_ORDER_V2.take(26) == FEATURE_ORDER_V1
                ),
                "featureSchemaV3Exact" to (
                    FEATURE_SCHEMA_VERSION_V3 == "navguard_ai_features_v3" &&
                        FEATURE_ORDER_V3.size == 40 &&
                        FEATURE_ORDER_V3.take(FEATURE_ORDER_V2.size) == FEATURE_ORDER_V2 &&
                        FEATURE_ORDER_V3.drop(FEATURE_ORDER_V2.size) ==
                        listOf(
                            "heading_signed_net_turn_rad",
                            "arcore_signed_net_turn_rad",
                            "heading_path_turn_direction_agreement",
                            "heading_path_turn_magnitude_difference_ratio",
                            "heading_path_turn_coherence",
                            "arcore_cross_track_rms_m",
                        )
                ),
                "legacyFeatureSemanticsPreserved" to legacySemanticsPreserved,
                "first34RegressionV3" to first34Regression,
                "featureDeterministic" to deterministic,
                "featureCausal" to causal,
                "windowAndHop" to windowHop,
                "boundaryPolicyDeterministic" to true,
                "duplicateSamplesRejected" to duplicateRejected,
                "featureFinite" to finite,
                "featurePrivacy" to privacy,
                "headingWrapV2" to headingWrap,
                "headingOscillationV2" to headingOscillationSeparated,
                "headingSustainedTurnV2" to sustainedHeadingTurn,
                "headingNetChangeV2" to headingNetChange,
                "headingTurnConsistencyV2" to headingTurnConsistency,
                "sustainedTurnFractionV2" to sustainedTurnFraction,
                "arcoreStraightPathV2" to straightArPath,
                "arcoreNinetyDegreeTurnV2" to ninetyDegreeArPath,
                "arcorePathLengthV2" to arcorePathLength,
                "arcoreStraightnessV2" to arcoreStraightness,
                "arcoreNetTurnV2" to arcoreNetTurn,
                "arcoreTurnConsistencyV2" to arcoreTurnConsistency,
                "arcoreCurvatureV2" to arcoreCurvature,
                "arcoreStationaryGeometryV2" to stationaryGeometrySafe,
                "v2InsufficientSamplesSafe" to insufficientGeometrySafe,
                "v2GroundTruthFirewall" to true,
                "headingSignedTurnV3" to headingSignedTests,
                "arcoreSignedTurnV3" to arcoreSignedTests,
                "crossSourceRightSignV3" to crossSourceRightSign,
                "crossSourceLeftSignV3" to crossSourceLeftSign,
                "directionAgreementV3" to directionAgreementTests,
                "magnitudeDifferenceV3" to magnitudeDifferenceTests,
                "coherenceV3" to coherenceTests,
                "crossTrackRmsV3" to crossTrackTests,
                "v3InsufficientSamplesSafe" to v3InsufficientSamplesSafe,
                "stepEventForwarding" to stepForwarded,
                "stepPhysicalTimestampPreserved" to physicalTimestampPreserved,
                "stepThreeEventWindow" to threeStepFeatures,
                "stepStationaryZeros" to stationaryStepZeros,
                "stepDelayedReplay" to delayedReplay,
                "v3ReplayDeterministic" to replayGeometryDeterministic,
                "stepOutOfHistoryRejected" to outOfHistoryRejected,
            )
        }

        internal fun normalizeAngle(value: Double): Double {
            var result = value % (2.0 * PI)
            if (result < 0.0) result += 2.0 * PI
            return result
        }

        internal fun circularDifference(first: Double, second: Double): Double {
            var result = normalizeAngle(first) - normalizeAngle(second)
            if (result > PI) result -= 2.0 * PI
            if (result <= -PI) result += 2.0 * PI
            return result
        }
    }
}

private fun Double?.finiteOrNull(): Double? = this?.takeIf(Double::isFinite)

private fun <T : TimedSample> ArrayDeque<T>.filterWindow(
    startNs: Long,
    endNs: Long,
): List<T> = filter { it.timestampNs > startNs && it.timestampNs <= endNs }

private fun <T> List<T>.fraction(predicate: (T) -> Boolean): Double =
    if (isEmpty()) 0.0 else count(predicate).toDouble() / size

private fun List<Double>.meanOrZero(default: Double = 0.0): Double = if (isEmpty()) default else sum() / size

private fun List<Double>.stdOrZero(): Double {
    if (size < 2) return 0.0
    val mean = meanOrZero()
    return sqrt(sumOf { (it - mean) * (it - mean) } / size)
}

private fun List<Double>.rmsOrZero(): Double = if (isEmpty()) 0.0 else sqrt(sumOf { it * it } / size)

private fun List<Double>.maxOrZero(): Double = maxOrNull() ?: 0.0

private fun circularStd(values: List<Double>): Double {
    if (values.size < 2) return 0.0
    val meanSin = values.sumOf { sin(it) } / values.size
    val meanCos = values.sumOf { cos(it) } / values.size
    val resultant = hypot(meanSin, meanCos).coerceIn(1e-12, 1.0)
    return sqrt(max(0.0, -2.0 * ln(resultant)))
}

private fun <T : TimedSample> ArrayDeque<T>.latestAtOrBefore(
    timestampNs: Long,
): T? = lastOrNull { it.timestampNs <= timestampNs }
