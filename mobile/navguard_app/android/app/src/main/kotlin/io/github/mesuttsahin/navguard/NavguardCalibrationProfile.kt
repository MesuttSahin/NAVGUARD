package io.github.mesuttsahin.navguard

import android.content.Context
import android.content.SharedPreferences

data class NavguardCalibrationProfile(
    val schemaVersion: Int = SCHEMA_VERSION,
    val strideEstimateM: Double = DEFAULT_STRIDE_M,
    val bodyHeadingOffsetRad: Double = 0.0,
    val strideSampleCount: Long = 0L,
    val headingOffsetSampleCount: Long = 0L,
) {
    fun isSupportedAndValid(): Boolean =
        schemaVersion == SCHEMA_VERSION &&
            strideEstimateM.isFinite() && strideEstimateM in MIN_STRIDE_M..MAX_STRIDE_M &&
            bodyHeadingOffsetRad.isFinite() && bodyHeadingOffsetRad in -MAX_HEADING_OFFSET_RAD..MAX_HEADING_OFFSET_RAD &&
            strideSampleCount in 0L..MAX_SAMPLE_COUNT &&
            headingOffsetSampleCount in 0L..MAX_SAMPLE_COUNT

    fun sanitized(): NavguardCalibrationProfile =
        copy(
            schemaVersion = SCHEMA_VERSION,
            strideEstimateM = strideEstimateM.takeIf(Double::isFinite)?.coerceIn(MIN_STRIDE_M, MAX_STRIDE_M) ?: DEFAULT_STRIDE_M,
            bodyHeadingOffsetRad =
                bodyHeadingOffsetRad.takeIf(Double::isFinite)?.coerceIn(-MAX_HEADING_OFFSET_RAD, MAX_HEADING_OFFSET_RAD)
                    ?: 0.0,
            strideSampleCount = strideSampleCount.coerceIn(0L, MAX_SAMPLE_COUNT),
            headingOffsetSampleCount = headingOffsetSampleCount.coerceIn(0L, MAX_SAMPLE_COUNT),
        )

    fun toSanitizedMap(profilePersisted: Boolean = false): Map<String, Any?> {
        val value = sanitized()
        return linkedMapOf(
            "schemaVersion" to value.schemaVersion,
            "snapshotKind" to "navguard_accuracy_v2_calibration_profile",
            "configId" to CONFIG_ID,
            "strideEstimateM" to value.strideEstimateM,
            "bodyHeadingOffsetRad" to value.bodyHeadingOffsetRad,
            "bodyHeadingOffsetDeg" to Math.toDegrees(value.bodyHeadingOffsetRad),
            "strideSampleCount" to value.strideSampleCount,
            "headingOffsetSampleCount" to value.headingOffsetSampleCount,
            "profilePersistence" to "android_shared_preferences",
            "profilePersisted" to profilePersisted,
            "rawLocationPersisted" to false,
            "rawSensorPersisted" to false,
            "rawArcorePosePersisted" to false,
            "rawTrajectoryPersisted" to false,
            "cloudUploadEnabled" to false,
            "telemetryEnabled" to false,
        )
    }

    companion object {
        const val SCHEMA_VERSION = 1
        const val CONFIG_ID = "config_d_v2_adaptive_navguard"
        const val DEFAULT_STRIDE_M = 0.75
        const val MIN_STRIDE_M = 0.45
        const val MAX_STRIDE_M = 1.05
        const val MAX_SAMPLE_COUNT = 10_000_000L
        val MAX_HEADING_OFFSET_RAD: Double = Math.toRadians(25.0)
    }
}

private interface CalibrationProfileBackend {
    fun readValues(): Map<String, Any?>

    fun write(profile: NavguardCalibrationProfile): Boolean

    fun clear(): Boolean
}

private class SharedPreferencesCalibrationProfileBackend(
    private val preferences: SharedPreferences,
) : CalibrationProfileBackend {
    override fun readValues(): Map<String, Any?> = preferences.all

    override fun write(profile: NavguardCalibrationProfile): Boolean =
        preferences.edit()
            .clear()
            .putInt(KEY_SCHEMA_VERSION, profile.schemaVersion)
            .putLong(KEY_STRIDE_BITS, profile.strideEstimateM.toRawBits())
            .putLong(KEY_STRIDE_SAMPLE_COUNT, profile.strideSampleCount)
            .putLong(KEY_HEADING_OFFSET_BITS, profile.bodyHeadingOffsetRad.toRawBits())
            .putLong(KEY_HEADING_SAMPLE_COUNT, profile.headingOffsetSampleCount)
            .commit()

    override fun clear(): Boolean = preferences.edit().clear().commit()
}

private class MemoryCalibrationProfileBackend : CalibrationProfileBackend {
    private var values: Map<String, Any?> = emptyMap()

    override fun readValues(): Map<String, Any?> = values.toMap()

    override fun write(profile: NavguardCalibrationProfile): Boolean {
        values = encodeProfile(profile)
        return true
    }

    override fun clear(): Boolean {
        values = emptyMap()
        return true
    }

    fun replaceRaw(raw: Map<String, Any?>) {
        values = raw.toMap()
    }
}

private class CalibrationProfileRepository(
    private val backend: CalibrationProfileBackend,
) {
    private var profile: NavguardCalibrationProfile
    private var persisted: Boolean

    init {
        val raw = backend.readValues()
        val loaded = decodeProfile(raw)
        profile = loaded ?: NavguardCalibrationProfile()
        persisted = loaded != null
        if (raw.isNotEmpty() && loaded == null) backend.clear()
    }

    fun read(): NavguardCalibrationProfile = profile.copy()

    fun isPersisted(): Boolean = persisted

    fun replace(value: NavguardCalibrationProfile): NavguardCalibrationProfile {
        profile = value.sanitized()
        persisted = backend.write(profile)
        return profile.copy()
    }

    fun reset(): NavguardCalibrationProfile {
        backend.clear()
        profile = NavguardCalibrationProfile()
        persisted = false
        return profile.copy()
    }
}

object NavguardCalibrationProfileStore {
    private val lock = Any()
    private var initialized = false
    private var repository = CalibrationProfileRepository(MemoryCalibrationProfileBackend())

    fun initialize(context: Context) {
        synchronized(lock) {
            if (initialized) return
            val preferences = context.applicationContext.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
            repository = CalibrationProfileRepository(SharedPreferencesCalibrationProfileBackend(preferences))
            initialized = true
        }
    }

    fun read(): NavguardCalibrationProfile = synchronized(lock) { repository.read() }

    fun isPersisted(): Boolean = synchronized(lock) { repository.isPersisted() }

    fun readSanitizedMap(): Map<String, Any?> =
        synchronized(lock) { repository.read().toSanitizedMap(repository.isPersisted()) }

    fun replace(value: NavguardCalibrationProfile): NavguardCalibrationProfile =
        synchronized(lock) { repository.replace(value) }

    fun reset(): NavguardCalibrationProfile = synchronized(lock) { repository.reset() }

    fun runDeterministicSelfTests(): Map<String, Boolean> {
        val backend = MemoryCalibrationProfileBackend()
        val initial = CalibrationProfileRepository(backend)
        initial.replace(
            NavguardCalibrationProfile(
                strideEstimateM = 0.73,
                bodyHeadingOffsetRad = Math.toRadians(2.0),
                strideSampleCount = 7L,
                headingOffsetSampleCount = 5L,
            ),
        )
        val restarted = CalibrationProfileRepository(backend)
        val reloaded = restarted.read()
        val restartReload =
            restarted.isPersisted() && reloaded.strideEstimateM == 0.73 &&
                reloaded.bodyHeadingOffsetRad == Math.toRadians(2.0) &&
                reloaded.strideSampleCount == 7L && reloaded.headingOffsetSampleCount == 5L

        restarted.reset()
        val afterReset = CalibrationProfileRepository(backend)
        val resetProfile = afterReset.read()
        val resetClearsPersistence = !afterReset.isPersisted() && resetProfile == NavguardCalibrationProfile()

        backend.replaceRaw(
            mapOf(
                KEY_SCHEMA_VERSION to NavguardCalibrationProfile.SCHEMA_VERSION,
                KEY_STRIDE_BITS to 5.0.toRawBits(),
                KEY_STRIDE_SAMPLE_COUNT to 1L,
                KEY_HEADING_OFFSET_BITS to Double.NaN.toRawBits(),
                KEY_HEADING_SAMPLE_COUNT to 1L,
            ),
        )
        val corruptReload = CalibrationProfileRepository(backend)
        val corruptProfileSafe =
            !corruptReload.isPersisted() && corruptReload.read() == NavguardCalibrationProfile() && backend.readValues().isEmpty()

        return linkedMapOf(
            "profileRestartReload" to restartReload,
            "profileResetPersistence" to resetClearsPersistence,
            "profileCorruptionFallback" to corruptProfileSafe,
        )
    }
}

private const val PREFERENCES_NAME = "navguard_accuracy_v2_calibration_profile"
private const val KEY_SCHEMA_VERSION = "schema_version"
private const val KEY_STRIDE_BITS = "stride_estimate_bits"
private const val KEY_STRIDE_SAMPLE_COUNT = "stride_sample_count"
private const val KEY_HEADING_OFFSET_BITS = "body_heading_offset_bits"
private const val KEY_HEADING_SAMPLE_COUNT = "heading_offset_sample_count"

private fun encodeProfile(profile: NavguardCalibrationProfile): Map<String, Any?> =
    linkedMapOf(
        KEY_SCHEMA_VERSION to profile.schemaVersion,
        KEY_STRIDE_BITS to profile.strideEstimateM.toRawBits(),
        KEY_STRIDE_SAMPLE_COUNT to profile.strideSampleCount,
        KEY_HEADING_OFFSET_BITS to profile.bodyHeadingOffsetRad.toRawBits(),
        KEY_HEADING_SAMPLE_COUNT to profile.headingOffsetSampleCount,
    )

private fun decodeProfile(values: Map<String, Any?>): NavguardCalibrationProfile? {
    if (values.isEmpty()) return null
    val schemaVersion = (values[KEY_SCHEMA_VERSION] as? Number)?.toInt() ?: return null
    val strideBits = (values[KEY_STRIDE_BITS] as? Number)?.toLong() ?: return null
    val strideSampleCount = (values[KEY_STRIDE_SAMPLE_COUNT] as? Number)?.toLong() ?: return null
    val headingOffsetBits = (values[KEY_HEADING_OFFSET_BITS] as? Number)?.toLong() ?: return null
    val headingSampleCount = (values[KEY_HEADING_SAMPLE_COUNT] as? Number)?.toLong() ?: return null
    val profile =
        NavguardCalibrationProfile(
            schemaVersion = schemaVersion,
            strideEstimateM = Double.fromBits(strideBits),
            bodyHeadingOffsetRad = Double.fromBits(headingOffsetBits),
            strideSampleCount = strideSampleCount,
            headingOffsetSampleCount = headingSampleCount,
        )
    return profile.takeIf(NavguardCalibrationProfile::isSupportedAndValid)
}
