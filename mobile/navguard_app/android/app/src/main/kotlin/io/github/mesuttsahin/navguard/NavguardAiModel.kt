package io.github.mesuttsahin.navguard

import android.content.Context
import android.os.SystemClock
import org.json.JSONArray
import org.json.JSONObject
import kotlin.math.exp

enum class NavguardAiRuntimeStatus {
    MODEL_NOT_AVAILABLE,
    MODEL_INVALID,
    MODEL_READY,
    WARMING_UP,
    AI_ACTIVE,
    HEURISTIC_FALLBACK,
}

enum class NavguardAiMotionState {
    STATIONARY,
    STRAIGHT_WALK,
    TURNING,
    UNSTABLE_MOTION,
}

data class NavguardAiInference(
    val motionProbabilities: Map<NavguardAiMotionState, Double>,
    val motionState: NavguardAiMotionState,
    val motionConfidence: Double,
    val arcoreReliability: Double?,
    val pdrReliability: Double?,
    val headingReliability: Double?,
    val elapsedMs: Double,
)

data class NavguardAiModelLoadResult(
    val status: NavguardAiRuntimeStatus,
    val runtime: NavguardAiModelRuntime?,
    val reason: String?,
)

class NavguardAiModelRuntime private constructor(
    private val featureSchemaVersion: String,
    private val normalizationMean: DoubleArray,
    private val normalizationStd: DoubleArray,
    private val motionModel: DenseModel,
    private val arcoreModel: DenseModel?,
    private val pdrModel: DenseModel?,
    private val headingModel: DenseModel?,
    val modelVersion: String,
) {
    private var inferenceCount = 0L
    private var inferenceFailureCount = 0L
    private var inferenceElapsedMsSum = 0.0
    private var inferenceElapsedMsMax = 0.0

    @Synchronized
    fun infer(vector: NavguardAiFeatureVector): NavguardAiInference? {
        val started = SystemClock.elapsedRealtimeNanos()
        val standardized = normalizeAndClamp(vector)
        if (standardized == null) {
            inferenceFailureCount += 1L
            return null
        }
        return try {
            val motion = softmax(motionModel.forward(standardized))
            if (motion.size != NavguardAiMotionState.entries.size || motion.any { !it.isFinite() }) {
                error("invalid motion output")
            }
            val bestIndex = motion.indices.maxBy { motion[it] }
            val elapsedMs = (SystemClock.elapsedRealtimeNanos() - started) / 1_000_000.0
            inferenceCount += 1L
            inferenceElapsedMsSum += elapsedMs
            inferenceElapsedMsMax = maxOf(inferenceElapsedMsMax, elapsedMs)
            NavguardAiInference(
                motionProbabilities =
                    NavguardAiMotionState.entries.mapIndexed { index, state -> state to motion[index] }.toMap(LinkedHashMap()),
                motionState = NavguardAiMotionState.entries[bestIndex],
                motionConfidence = motion[bestIndex],
                arcoreReliability = arcoreModel?.forward(standardized)?.singleOrNull()?.let(::sigmoid),
                pdrReliability = pdrModel?.forward(standardized)?.singleOrNull()?.let(::sigmoid),
                headingReliability = headingModel?.forward(standardized)?.singleOrNull()?.let(::sigmoid),
                elapsedMs = elapsedMs,
            )
        } catch (_: Exception) {
            inferenceFailureCount += 1L
            null
        }
    }

    internal fun normalizeAndClamp(vector: NavguardAiFeatureVector): DoubleArray? {
        if (vector.schemaVersion != featureSchemaVersion ||
            vector.values.size != normalizationMean.size ||
            vector.values.any { !it.isFinite() }
        ) {
            return null
        }
        return DoubleArray(vector.values.size) { index ->
            ((vector.values[index] - normalizationMean[index]) / normalizationStd[index])
                .coerceIn(-STANDARDIZED_CLAMP, STANDARDIZED_CLAMP)
        }
    }

    @Synchronized
    fun aggregateDiagnostics(): Map<String, Any?> =
        linkedMapOf(
            "aiInferenceCount" to inferenceCount,
            "aiInferenceFailureCount" to inferenceFailureCount,
            "aiInferenceMeanMs" to if (inferenceCount == 0L) 0.0 else inferenceElapsedMsSum / inferenceCount,
            "aiInferenceMaxMs" to inferenceElapsedMsMax,
        )

    private sealed interface DenseModel {
        fun forward(input: DoubleArray): DoubleArray
    }

    private data class LinearModel(
        val weights: Array<DoubleArray>,
        val bias: DoubleArray,
    ) : DenseModel {
        override fun forward(input: DoubleArray): DoubleArray =
            DoubleArray(weights.size) { row ->
                bias[row] + weights[row].indices.sumOf { column -> weights[row][column] * input[column] }
            }
    }

    private data class MlpModel(
        val hiddenWeights: Array<DoubleArray>,
        val hiddenBias: DoubleArray,
        val outputWeights: Array<DoubleArray>,
        val outputBias: DoubleArray,
    ) : DenseModel {
        override fun forward(input: DoubleArray): DoubleArray {
            val hidden =
                DoubleArray(hiddenWeights.size) { row ->
                    maxOf(0.0, hiddenBias[row] + hiddenWeights[row].indices.sumOf { column -> hiddenWeights[row][column] * input[column] })
                }
            return DoubleArray(outputWeights.size) { row ->
                outputBias[row] + outputWeights[row].indices.sumOf { column -> outputWeights[row][column] * hidden[column] }
            }
        }
    }

    companion object {
        const val MODEL_SCHEMA_VERSION = "navguard_ai_model_v3"
        const val MODEL_VERSION = "navguard_ai_motion_v3_frozen_development_86e"
        const val MODEL_ASSET_NAME = "navguard_ai_model_v3.json"
        private const val STANDARDIZED_CLAMP = 5.0

        fun loadFromAssets(context: Context): NavguardAiModelLoadResult {
            val assetPresent =
                runCatching { context.assets.list("")?.contains(MODEL_ASSET_NAME) == true }
                    .getOrDefault(false)
            if (!assetPresent) {
                return NavguardAiModelLoadResult(
                    NavguardAiRuntimeStatus.MODEL_NOT_AVAILABLE,
                    null,
                    "experimental_v3_model_absent",
                )
            }
            return try {
                val json = context.assets.open(MODEL_ASSET_NAME).bufferedReader().use { it.readText() }
                parse(json)
            } catch (_: Exception) {
                NavguardAiModelLoadResult(NavguardAiRuntimeStatus.MODEL_INVALID, null, "production_model_unreadable")
            }
        }

        fun parse(json: String): NavguardAiModelLoadResult =
            try {
                val root = JSONObject(json)
                require(root.getString("modelSchemaVersion") == MODEL_SCHEMA_VERSION)
                require(root.getString("modelVersion") == MODEL_VERSION)
                require(root.getString("runtimeStatus") == "EXPERIMENTAL")
                require(root.getString("datasetSchemaVersion") == "navguard_ai_dataset_v3")
                val featureSchemaVersion = root.getString("featureSchemaVersion")
                require(featureSchemaVersion == NavguardAiFeatureExtractor.FEATURE_SCHEMA_VERSION_V3)
                val expectedFeatureOrder = NavguardAiFeatureExtractor.FEATURE_ORDER_V3
                val featureOrder = root.getJSONArray("featureOrder").toStringList()
                require(featureOrder == expectedFeatureOrder)
                require(root.getInt("featureCount") == 40)
                require(root.getJSONArray("standardizedClamp").toDoubleArray().contentEquals(doubleArrayOf(-5.0, 5.0)))
                val mean = root.getJSONArray("normalizationMean").toDoubleArray()
                val std = root.getJSONArray("normalizationStd").toDoubleArray()
                require(mean.size == featureOrder.size && std.size == featureOrder.size)
                require(mean.all(Double::isFinite) && std.all { it.isFinite() && it > 0.0 })
                val classes = root.getJSONArray("motionClasses").toStringList()
                require(classes == NavguardAiMotionState.entries.map { it.name })
                val motion = parseDenseModel(root.getJSONObject("motionModel"), featureOrder.size, classes.size)
                require(motion is MlpModel)
                require(motion.hiddenWeights.size == 32 && motion.hiddenBias.size == 32)
                require(motion.outputWeights.size == 4 && motion.outputBias.size == 4)
                validateFrozenDecoderMetadata(root.getJSONObject("temporalDecoder"))
                validateExperimentalProvenance(root.getJSONObject("provenance"))
                val reliability = root.getJSONObject("reliabilityAvailability")
                require(
                    reliability.keys().asSequence().toSet() ==
                        setOf("arcore", "pdr", "heading"),
                )
                require(!reliability.getBoolean("arcore"))
                require(!reliability.getBoolean("pdr"))
                require(!reliability.getBoolean("heading"))
                require(root.keys().asSequence().none { it.endsWith("ReliabilityModel") })
                val runtime =
                    NavguardAiModelRuntime(
                        featureSchemaVersion = featureSchemaVersion,
                        normalizationMean = mean,
                        normalizationStd = std,
                        motionModel = motion,
                        arcoreModel = null,
                        pdrModel = null,
                        headingModel = null,
                        modelVersion = root.getString("modelVersion"),
                    )
                validateParityFixtures(root.getJSONArray("parityFixtures"), runtime)
                validateDecoderParityFixture(root.getJSONObject("decoderParityFixture"))
                NavguardAiModelLoadResult(NavguardAiRuntimeStatus.MODEL_READY, runtime, null)
            } catch (_: Exception) {
                NavguardAiModelLoadResult(NavguardAiRuntimeStatus.MODEL_INVALID, null, "model_schema_or_value_invalid")
            }

        fun createDeterministicMockForTests(
            motionWeight: Double = 1.0,
            featureSchemaVersion: String = NavguardAiFeatureExtractor.FEATURE_SCHEMA_VERSION,
            includeReliabilityHeads: Boolean = true,
        ): NavguardAiModelRuntime {
            val featureCount =
                NavguardAiFeatureExtractor
                    .featureOrderForSchema(featureSchemaVersion)
                    .size
            require(motionWeight.isFinite() && motionWeight > 0.0)
            val classFeatureIndexes =
                intArrayOf(
                    0, // accel_mag_mean -> STATIONARY in the deterministic live fixture
                    9, // step_count -> STRAIGHT_WALK
                    7, // heading_rate_abs_mean_rad_s -> TURNING
                    5, // gyro_mag_rms -> UNSTABLE_MOTION
                )
            val weights =
                Array(NavguardAiMotionState.entries.size) { row ->
                    DoubleArray(featureCount).also { values ->
                        values[classFeatureIndexes[row]] = motionWeight
                    }
                }
            val reliability = LinearModel(arrayOf(DoubleArray(featureCount) { if (it == 15) 0.5 else 0.0 }), doubleArrayOf(0.0))
            return NavguardAiModelRuntime(
                featureSchemaVersion = featureSchemaVersion,
                normalizationMean = DoubleArray(featureCount),
                normalizationStd = DoubleArray(featureCount) { 1.0 },
                motionModel = LinearModel(weights, DoubleArray(NavguardAiMotionState.entries.size)),
                arcoreModel = reliability.takeIf { includeReliabilityHeads },
                pdrModel = reliability.takeIf { includeReliabilityHeads },
                headingModel = reliability.takeIf { includeReliabilityHeads },
                modelVersion = "unit_test_mock_only",
            )
        }

        fun createLowConfidenceMockForTests(): NavguardAiModelRuntime =
            createDeterministicMockForTests(motionWeight = 0.25)

        fun runSelfTests(): Map<String, Boolean> {
            val missingStatus = NavguardAiRuntimeStatus.MODEL_NOT_AVAILABLE.name == "MODEL_NOT_AVAILABLE"
            val invalid = parse("{}").status == NavguardAiRuntimeStatus.MODEL_INVALID
            val mock = createDeterministicMockForTests()
            val vector = NavguardAiFeatureVector(values = DoubleArray(NavguardAiFeatureExtractor.FEATURE_ORDER.size) { it / 100.0 })
            val inference = mock.infer(vector)
            val probabilitySum = inference?.motionProbabilities?.values?.sum() ?: 0.0
            val mockValid = inference != null && kotlin.math.abs(probabilitySum - 1.0) < 1e-9
            val fallbackOnNonFinite =
                runCatching {
                    NavguardAiFeatureVector(values = DoubleArray(vector.values.size) { Double.NaN })
                }.isFailure
            val v1ModelRejected =
                parse(
                    deterministicSchemaFixtureJson(
                        NavguardAiFeatureExtractor.FEATURE_SCHEMA_VERSION_V1,
                    ),
                ).status == NavguardAiRuntimeStatus.MODEL_INVALID
            val v2ModelRejected =
                parse(
                    deterministicSchemaFixtureJson(
                        NavguardAiFeatureExtractor.FEATURE_SCHEMA_VERSION_V2,
                    ),
                ).status == NavguardAiRuntimeStatus.MODEL_INVALID
            val v3ModelAccepted =
                parse(
                    deterministicSchemaFixtureJson(
                        NavguardAiFeatureExtractor.FEATURE_SCHEMA_VERSION_V3,
                    ),
                ).status == NavguardAiRuntimeStatus.MODEL_READY
            val v2Runtime =
                createDeterministicMockForTests(
                    featureSchemaVersion = NavguardAiFeatureExtractor.FEATURE_SCHEMA_VERSION_V2,
                )
            val v3Runtime =
                createDeterministicMockForTests(
                    featureSchemaVersion = NavguardAiFeatureExtractor.FEATURE_SCHEMA_VERSION_V3,
                )
            val v2RejectsV3 =
                v2Runtime.infer(
                    NavguardAiFeatureVector(
                        schemaVersion = NavguardAiFeatureExtractor.FEATURE_SCHEMA_VERSION_V3,
                        values = DoubleArray(NavguardAiFeatureExtractor.FEATURE_ORDER_V3.size),
                    ),
                ) == null
            val v3RejectsV2 =
                v3Runtime.infer(
                    NavguardAiFeatureVector(
                        schemaVersion = NavguardAiFeatureExtractor.FEATURE_SCHEMA_VERSION_V2,
                        values = DoubleArray(NavguardAiFeatureExtractor.FEATURE_ORDER_V2.size),
                    ),
                ) == null
            val v3RejectsV1 =
                v3Runtime.infer(
                    NavguardAiFeatureVector(
                        schemaVersion = NavguardAiFeatureExtractor.FEATURE_SCHEMA_VERSION_V1,
                        values = DoubleArray(NavguardAiFeatureExtractor.FEATURE_ORDER_V1.size),
                    ),
                ) == null
            val invalidScaleRejected =
                JSONObject(
                    deterministicSchemaFixtureJson(
                        NavguardAiFeatureExtractor.FEATURE_SCHEMA_VERSION_V3,
                    ),
                ).let { root ->
                    root.getJSONArray("normalizationStd").put(0, 0.0)
                    parse(root.toString()).status == NavguardAiRuntimeStatus.MODEL_INVALID
                }
            return linkedMapOf(
                "missingModelStatus" to missingStatus,
                "invalidModelRejected" to invalid,
                "mockRuntime" to mockValid,
                "nonFiniteRejected" to fallbackOnNonFinite,
                "modelFeatureSchemaV1Rejected" to v1ModelRejected,
                "modelFeatureSchemaV2Rejected" to v2ModelRejected,
                "modelFeatureSchemaV3Accepted" to v3ModelAccepted,
                "v2ModelRejectsV3Vector" to v2RejectsV3,
                "v3ModelRejectsV2Vector" to v3RejectsV2,
                "v3ModelRejectsV1Vector" to v3RejectsV1,
                "nonPositiveScaleRejected" to invalidScaleRejected,
                "pythonKotlinParityInfrastructure" to true,
            )
        }

        private fun deterministicSchemaFixtureJson(
            featureSchemaVersion: String,
        ): String {
            val featureOrder =
                NavguardAiFeatureExtractor.featureOrderForSchema(
                    featureSchemaVersion,
                )
            val featureCount = featureOrder.size
            val bias = doubleArrayOf(1.0, 0.0, 0.0, 0.0)
            val denominator = exp(1.0) + 3.0
            val expected =
                doubleArrayOf(
                    exp(1.0) / denominator,
                    1.0 / denominator,
                    1.0 / denominator,
                    1.0 / denominator,
                )
            val motionModel =
                JSONObject()
                    .put("type", "mlp_single_hidden")
                    .put("activation", "relu")
                    .put(
                        "hiddenWeights",
                        JSONArray(
                            List(32) {
                                List(featureCount) { 0.0 }
                            },
                        ),
                    )
                    .put("hiddenBias", JSONArray(List(32) { 0.0 }))
                    .put(
                        "outputWeights",
                        JSONArray(
                            List(NavguardAiMotionState.entries.size) {
                                List(32) { 0.0 }
                            },
                        ),
                    )
                    .put("outputBias", JSONArray(bias.toList()))
            val parityFixtures =
                JSONArray().apply {
                    repeat(3) {
                        put(
                            JSONObject()
                                .put(
                                    "features",
                                    JSONArray(List(featureCount) { 0.0 }),
                                )
                                .put(
                                    "normalizedClampedFeatures",
                                    JSONArray(List(featureCount) { 0.0 }),
                                )
                                .put(
                                    "motionProbabilities",
                                    JSONArray(expected.toList()),
                                ),
                        )
                    }
                }
            return JSONObject()
                .put("modelSchemaVersion", MODEL_SCHEMA_VERSION)
                .put("modelVersion", MODEL_VERSION)
                .put("runtimeStatus", "EXPERIMENTAL")
                .put("datasetSchemaVersion", "navguard_ai_dataset_v3")
                .put("featureSchemaVersion", featureSchemaVersion)
                .put("featureCount", featureCount)
                .put("featureOrder", JSONArray(featureOrder))
                .put("normalizationMean", JSONArray(List(featureCount) { 0.0 }))
                .put("normalizationStd", JSONArray(List(featureCount) { 1.0 }))
                .put("standardizedClamp", JSONArray(listOf(-5.0, 5.0)))
                .put(
                    "motionClasses",
                    JSONArray(NavguardAiMotionState.entries.map { it.name }),
                )
                .put("motionModel", motionModel)
                .put(
                    "temporalDecoder",
                    JSONObject()
                        .put("type", "FIR3_BOUNDED_SWITCH")
                        .put("firWeights", JSONArray(listOf(0.60, 0.30, 0.10)))
                        .put("highConfidence", 0.70)
                        .put("highMargin", 0.10)
                        .put("lowConfidence", 0.50)
                        .put("lowMargin", 0.00)
                        .put("consecutiveWindows", 1)
                        .put("historyLength", 3)
                        .put("sessionStateReset", true),
                )
                .put(
                    "reliabilityAvailability",
                    JSONObject()
                        .put("arcore", false)
                        .put("pdr", false)
                        .put("heading", false),
                )
                .put(
                    "provenance",
                    JSONObject()
                        .put("trainingSchema", NavguardAiFeatureExtractor.FEATURE_SCHEMA_VERSION_V3)
                        .put("trainingDataset", "development_v3")
                        .put("developmentSessions", 20)
                        .put("developmentWindows", 480)
                        .put("developmentGate", "PASS")
                        .put("independentHoldoutGate", "FAIL")
                        .put("epochs", 86)
                        .put("alpha", 0.01)
                        .put("learningRateInit", 0.0005)
                        .put("optimizer", "adam")
                        .put("randomState", 42)
                        .put("earlyStopping", false)
                        .put("holdoutUsedForTraining", false),
                )
                .put("parityFixtures", parityFixtures)
                .put(
                    "decoderParityFixture",
                    JSONObject()
                        .put(
                            "probabilities",
                            JSONArray(
                                List(3) {
                                    listOf(0.80, 0.10, 0.05, 0.05)
                                },
                            ),
                        )
                        .put(
                            "filteredProbabilities",
                            JSONArray(
                                List(3) {
                                    listOf(0.80, 0.10, 0.05, 0.05)
                                },
                            ),
                        )
                        .put(
                            "decodedMotionClasses",
                            JSONArray(List(3) { "STATIONARY" }),
                        ),
                )
                .toString()
        }

        private fun validateFrozenDecoderMetadata(json: JSONObject) {
            require(json.getString("type") == "FIR3_BOUNDED_SWITCH")
            require(json.getJSONArray("firWeights").toDoubleArray().contentEquals(doubleArrayOf(0.60, 0.30, 0.10)))
            require(json.getDouble("highConfidence") == 0.70)
            require(json.getDouble("highMargin") == 0.10)
            require(json.getDouble("lowConfidence") == 0.50)
            require(json.getDouble("lowMargin") == 0.00)
            require(json.getInt("consecutiveWindows") == 1)
            require(json.getInt("historyLength") == 3)
            require(json.getBoolean("sessionStateReset"))
        }

        private fun validateExperimentalProvenance(json: JSONObject) {
            require(json.getString("trainingSchema") == NavguardAiFeatureExtractor.FEATURE_SCHEMA_VERSION_V3)
            require(json.getString("trainingDataset") == "development_v3")
            require(json.getInt("developmentSessions") == 20)
            require(json.getInt("developmentWindows") == 480)
            require(json.getString("developmentGate") == "PASS")
            require(json.getString("independentHoldoutGate") == "FAIL")
            require(json.getInt("epochs") == 86)
            require(json.getDouble("alpha") == 0.01)
            require(json.getDouble("learningRateInit") == 0.0005)
            require(json.getString("optimizer") == "adam")
            require(json.getInt("randomState") == 42)
            require(!json.getBoolean("earlyStopping"))
            require(!json.getBoolean("holdoutUsedForTraining"))
        }

        private fun validateDecoderParityFixture(fixture: JSONObject) {
            val probabilities = fixture.getJSONArray("probabilities").toMatrix()
            val expectedFiltered = fixture.getJSONArray("filteredProbabilities").toMatrix()
            val expectedClasses = fixture.getJSONArray("decodedMotionClasses").toStringList()
            require(probabilities.size >= 3)
            require(probabilities.size == expectedFiltered.size)
            require(probabilities.size == expectedClasses.size)
            val decoder = NavguardAiTemporalDecoder()
            probabilities.indices.forEach { index ->
                val result = decoder.decode(probabilities[index])
                require(result.filteredProbabilities.indices.all { classIndex ->
                    kotlin.math.abs(
                        result.filteredProbabilities[classIndex] -
                            expectedFiltered[index][classIndex],
                    ) <= 1e-9
                })
                require(result.motionState.name == expectedClasses[index])
            }
        }

        private fun parseDenseModel(
            json: JSONObject,
            inputCount: Int,
            outputCount: Int,
        ): DenseModel {
            return when (json.getString("type")) {
                "logistic_regression" -> {
                    val weights = json.getJSONArray("weights").toMatrix()
                    val bias = json.getJSONArray("bias").toDoubleArray()
                    require(weights.size == outputCount && bias.size == outputCount)
                    require(weights.all { it.size == inputCount && it.all(Double::isFinite) } && bias.all(Double::isFinite))
                    LinearModel(weights, bias)
                }
                "mlp_single_hidden" -> {
                    require(json.optString("activation", "relu") == "relu")
                    val hiddenWeights = json.getJSONArray("hiddenWeights").toMatrix()
                    val hiddenBias = json.getJSONArray("hiddenBias").toDoubleArray()
                    val outputWeights = json.getJSONArray("outputWeights").toMatrix()
                    val outputBias = json.getJSONArray("outputBias").toDoubleArray()
                    require(hiddenWeights.size == hiddenBias.size && hiddenWeights.all { it.size == inputCount })
                    require(outputWeights.size == outputCount && outputBias.size == outputCount)
                    require(outputWeights.all { it.size == hiddenWeights.size })
                    require(hiddenWeights.flatMap { it.asIterable() }.all(Double::isFinite))
                    require(outputWeights.flatMap { it.asIterable() }.all(Double::isFinite))
                    require(hiddenBias.all(Double::isFinite) && outputBias.all(Double::isFinite))
                    MlpModel(hiddenWeights, hiddenBias, outputWeights, outputBias)
                }
                else -> error("unsupported model")
            }
        }

        private fun validateParityFixtures(fixtures: JSONArray, runtime: NavguardAiModelRuntime) {
            require(fixtures.length() >= 3)
            for (index in 0 until fixtures.length()) {
                val fixture = fixtures.getJSONObject(index)
                val input = fixture.getJSONArray("features").toDoubleArray()
                val expectedStandardized =
                    fixture.getJSONArray("normalizedClampedFeatures").toDoubleArray()
                val expected = fixture.getJSONArray("motionProbabilities").toDoubleArray()
                val vector =
                    NavguardAiFeatureVector(
                        schemaVersion = runtime.featureSchemaVersion,
                        values = input,
                    )
                val standardized = runtime.normalizeAndClamp(vector) ?: error("fixture normalization failed")
                require(standardized.size == expectedStandardized.size)
                require(standardized.indices.all {
                    kotlin.math.abs(standardized[it] - expectedStandardized[it]) <= 1e-9
                })
                val actual =
                    runtime.infer(vector) ?: error("fixture inference failed")
                val ordered = NavguardAiMotionState.entries.map { actual.motionProbabilities.getValue(it) }
                require(ordered.size == expected.size)
                require(ordered.indices.all { kotlin.math.abs(ordered[it] - expected[it]) <= 1e-6 })
            }
        }

        private fun softmax(logits: DoubleArray): DoubleArray {
            val maximum = logits.maxOrNull() ?: return doubleArrayOf()
            val exponentials = logits.map { exp((it - maximum).coerceIn(-60.0, 60.0)) }
            val total = exponentials.sum()
            require(total.isFinite() && total > 0.0)
            return exponentials.map { it / total }.toDoubleArray()
        }

        private fun sigmoid(value: Double): Double = 1.0 / (1.0 + exp(-value.coerceIn(-60.0, 60.0)))
    }
}

private fun JSONArray.toDoubleArray(): DoubleArray = DoubleArray(length()) { getDouble(it) }

private fun JSONArray.toStringList(): List<String> = List(length()) { getString(it) }

private fun JSONArray.toMatrix(): Array<DoubleArray> = Array(length()) { getJSONArray(it).toDoubleArray() }
