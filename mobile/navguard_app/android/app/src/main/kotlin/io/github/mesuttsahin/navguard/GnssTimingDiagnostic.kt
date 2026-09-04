package io.github.mesuttsahin.navguard

import android.location.GnssStatus
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.ceil

class GnssTimingDiagnostic(
    private val locationManager: LocationManager,
    private val resultHandler: Handler = Handler(Looper.getMainLooper()),
) {
    interface Callback {
        fun onSuccess(summary: Map<String, Any?>)

        fun onError(code: String, message: String)
    }

    private val activeSessionLock = Any()
    private var activeSession: Session? = null

    fun start(callback: Callback) {
        val session = Session(callback)

        if (!reserveSession(session)) {
            postError(
                callback,
                ERROR_TIMING_ALREADY_RUNNING,
                "A GNSS timing diagnostic is already running.",
            )
            return
        }

        session.start()
    }

    fun cancelActiveSession(
        message: String = "GNSS timing diagnostic cancelled.",
    ) {
        val session =
            synchronized(activeSessionLock) {
                activeSession
            }

        session?.cancel(message)
    }

    private fun reserveSession(session: Session): Boolean =
        synchronized(activeSessionLock) {
            if (activeSession != null) {
                false
            } else {
                activeSession = session
                true
            }
        }

    private fun releaseSession(session: Session) {
        synchronized(activeSessionLock) {
            if (activeSession === session) {
                activeSession = null
            }
        }
    }

    private fun postSuccess(
        callback: Callback,
        summary: Map<String, Any?>,
    ) {
        if (!resultHandler.post { callback.onSuccess(summary) }) {
            callback.onSuccess(summary)
        }
    }

    private fun postError(
        callback: Callback,
        code: String,
        message: String,
    ) {
        if (!resultHandler.post { callback.onError(code, message) }) {
            callback.onError(code, message)
        }
    }

    private inner class Session(
        private val callback: Callback,
    ) : LocationListener {
        private val completed = AtomicBoolean(false)
        private val stateLock = Any()
        private val handlerThread = HandlerThread(HANDLER_THREAD_NAME)

        private var sessionHandler: Handler? = null
        private var phase = SessionPhase.STARTING

        private var locationUpdatesRegistrationSucceeded = false
        private var gnssStatusRegistrationSucceeded = false

        private var locationEventCount = 0
        private var firstElapsedRealtimeNs: Long? = null
        private var previousElapsedRealtimeNs: Long? = null
        private var lastElapsedRealtimeNs: Long? = null
        private val elapsedDeltasNs = mutableListOf<Long>()
        private var nonMonotonicTimestampCount = 0
        private var mockLocationDetectedCount = 0
        private val horizontalAccuraciesM = mutableListOf<Double>()

        private var gnssStartedCount = 0
        private var gnssStoppedCount = 0
        private var firstFixCallbackCount = 0
        private var lastTtffMs: Int? = null
        private var satelliteStatusCallbackCount = 0
        private var lastSatelliteCount: Int? = null
        private var lastUsedInFixCount: Int? = null
        private var maxSatelliteCount: Int? = null
        private var maxUsedInFixCount: Int? = null

        private val firstLocationTimeoutRunnable =
            Runnable {
                finishWithSummary(
                    completionReason = COMPLETION_FIRST_LOCATION_TIMEOUT,
                    forceInvalid = true,
                )
            }

        private val collectionTimeoutRunnable =
            Runnable {
                finishWithSummary(
                    completionReason = COMPLETION_MEASUREMENT_WINDOW_COMPLETED,
                    forceInvalid = false,
                )
            }

        private val gnssStatusCallback =
            object : GnssStatus.Callback() {
                override fun onStarted() {
                    if (completed.get()) {
                        return
                    }

                    synchronized(stateLock) {
                        gnssStartedCount += 1
                    }
                }

                override fun onStopped() {
                    if (completed.get()) {
                        return
                    }

                    synchronized(stateLock) {
                        gnssStoppedCount += 1
                    }
                }

                override fun onFirstFix(ttffMillis: Int) {
                    if (completed.get()) {
                        return
                    }

                    synchronized(stateLock) {
                        firstFixCallbackCount += 1
                        lastTtffMs = ttffMillis.takeIf { it >= 0 }
                    }
                }

                override fun onSatelliteStatusChanged(status: GnssStatus) {
                    if (completed.get()) {
                        return
                    }

                    val satelliteCount = status.satelliteCount
                    var usedInFixCount = 0

                    for (index in 0 until satelliteCount) {
                        if (status.usedInFix(index)) {
                            usedInFixCount += 1
                        }
                    }

                    synchronized(stateLock) {
                        satelliteStatusCallbackCount += 1
                        lastSatelliteCount = satelliteCount
                        lastUsedInFixCount = usedInFixCount
                        maxSatelliteCount =
                            maxSatelliteCount?.let {
                                maxOf(it, satelliteCount)
                            } ?: satelliteCount
                        maxUsedInFixCount =
                            maxUsedInFixCount?.let {
                                maxOf(it, usedInFixCount)
                            } ?: usedInFixCount
                    }
                }
            }

        fun start() {
            val handler =
                try {
                    handlerThread.start()
                    Handler(handlerThread.looper)
                } catch (_: Exception) {
                    finishWithError(
                        ERROR_TIMING_START_FAILED,
                        "Unable to start the GNSS diagnostic worker thread.",
                    )
                    return
                }

            sessionHandler = handler

            if (!handler.post { initializeOnSessionThread(handler) }) {
                finishWithError(
                    ERROR_TIMING_START_FAILED,
                    "Unable to initialize the GNSS timing diagnostic.",
                )
            }
        }

        private fun initializeOnSessionThread(handler: Handler) {
            if (completed.get()) {
                return
            }

            val providerAvailable =
                try {
                    locationManager.allProviders.contains(
                        LocationManager.GPS_PROVIDER,
                    )
                } catch (_: Exception) {
                    finishWithError(
                        ERROR_PROVIDER_QUERY_FAILED,
                        "Unable to determine GPS provider availability.",
                    )
                    return
                }

            if (!providerAvailable) {
                finishWithError(
                    ERROR_PROVIDER_UNAVAILABLE,
                    "GPS_PROVIDER is unavailable on this device.",
                )
                return
            }

            val providerEnabled =
                try {
                    locationManager.isProviderEnabled(
                        LocationManager.GPS_PROVIDER,
                    )
                } catch (_: Exception) {
                    finishWithError(
                        ERROR_PROVIDER_QUERY_FAILED,
                        "Unable to determine whether GPS_PROVIDER is enabled.",
                    )
                    return
                }

            if (!providerEnabled) {
                finishWithError(
                    ERROR_PROVIDER_DISABLED,
                    "GPS_PROVIDER is disabled.",
                )
                return
            }

            val gnssStatusRegistered =
                try {
                    locationManager.registerGnssStatusCallback(
                        gnssStatusCallback,
                        handler,
                    )
                } catch (_: SecurityException) {
                    finishWithError(
                        ERROR_PRECISE_PERMISSION_REQUIRED,
                        "Precise foreground location permission is required for GNSS status diagnostics.",
                    )
                    return
                } catch (_: IllegalArgumentException) {
                    finishWithError(
                        ERROR_STATUS_REGISTRATION_FAILED,
                        "GNSS status callback registration was rejected.",
                    )
                    return
                } catch (_: Exception) {
                    finishWithError(
                        ERROR_STATUS_REGISTRATION_FAILED,
                        "Unable to register the GNSS status callback.",
                    )
                    return
                }

            if (!gnssStatusRegistered) {
                finishWithError(
                    ERROR_STATUS_REGISTRATION_FAILED,
                    "GNSS status callback registration failed.",
                )
                return
            }

            synchronized(stateLock) {
                gnssStatusRegistrationSucceeded = true
            }

            try {
                locationManager.requestLocationUpdates(
                    LocationManager.GPS_PROVIDER,
                    REQUESTED_MIN_TIME_MS,
                    REQUESTED_MIN_DISTANCE_M,
                    this,
                    handlerThread.looper,
                )
            } catch (_: SecurityException) {
                finishWithError(
                    ERROR_PRECISE_PERMISSION_REQUIRED,
                    "Precise foreground location permission is required for the GNSS timing diagnostic.",
                )
                return
            } catch (_: IllegalArgumentException) {
                finishWithError(
                    ERROR_PROVIDER_UNAVAILABLE,
                    "GPS_PROVIDER could not be registered for location updates.",
                )
                return
            } catch (_: Exception) {
                finishWithError(
                    ERROR_LOCATION_REGISTRATION_FAILED,
                    "Unable to register GPS location updates.",
                )
                return
            }

            synchronized(stateLock) {
                locationUpdatesRegistrationSucceeded = true
                phase = SessionPhase.WAITING_FOR_FIRST_LOCATION
            }

            if (!handler.postDelayed(
                    firstLocationTimeoutRunnable,
                    FIRST_LOCATION_TIMEOUT_MS,
                )
            ) {
                finishWithError(
                    ERROR_TIMING_START_FAILED,
                    "Unable to schedule the first GPS location timeout.",
                )
            }
        }

        override fun onLocationChanged(location: Location) {
            if (
                completed.get() ||
                    location.provider != LocationManager.GPS_PROVIDER
            ) {
                return
            }

            val elapsedRealtimeNs = location.elapsedRealtimeNanos
            val mockLocation = isMockLocation(location)
            val horizontalAccuracyM =
                if (location.hasAccuracy()) {
                    location.accuracy.toDouble().takeIf {
                        it.isFinite() && it >= 0.0
                    }
                } else {
                    null
                }

            var beginsCollection = false

            synchronized(stateLock) {
                if (completed.get()) {
                    return
                }

                val previousTimestamp = previousElapsedRealtimeNs

                if (previousTimestamp == null) {
                    firstElapsedRealtimeNs = elapsedRealtimeNs
                } else {
                    val deltaNs = elapsedRealtimeNs - previousTimestamp
                    elapsedDeltasNs.add(deltaNs)

                    if (deltaNs <= 0L) {
                        nonMonotonicTimestampCount += 1
                    }
                }

                previousElapsedRealtimeNs = elapsedRealtimeNs
                lastElapsedRealtimeNs = elapsedRealtimeNs
                locationEventCount += 1

                if (mockLocation) {
                    mockLocationDetectedCount += 1
                }

                if (horizontalAccuracyM != null) {
                    horizontalAccuraciesM.add(horizontalAccuracyM)
                }

                if (phase == SessionPhase.WAITING_FOR_FIRST_LOCATION) {
                    phase = SessionPhase.COLLECTING
                    beginsCollection = true
                }
            }

            if (beginsCollection) {
                val handler = sessionHandler

                handler?.removeCallbacks(firstLocationTimeoutRunnable)

                if (
                    handler == null ||
                        !handler.postDelayed(
                            collectionTimeoutRunnable,
                            COLLECTION_DURATION_TARGET_MS,
                        )
                ) {
                    finishWithError(
                        ERROR_TIMING_START_FAILED,
                        "Unable to schedule the GNSS collection timeout.",
                    )
                }
            }
        }

        override fun onProviderDisabled(provider: String) {
            if (provider == LocationManager.GPS_PROVIDER) {
                finishWithSummary(
                    completionReason = COMPLETION_PROVIDER_DISABLED,
                    forceInvalid = true,
                )
            }
        }

        override fun onProviderEnabled(provider: String) = Unit

        @Suppress("DEPRECATION")
        override fun onStatusChanged(
            provider: String?,
            status: Int,
            extras: Bundle?,
        ) = Unit

        fun cancel(message: String) {
            finishWithError(ERROR_TIMING_CANCELLED, message)
        }

        @Suppress("DEPRECATION")
        private fun isMockLocation(location: Location): Boolean =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                location.isMock
            } else {
                location.isFromMockProvider
            }

        private fun finishWithSummary(
            completionReason: String,
            forceInvalid: Boolean,
        ) {
            if (!completed.compareAndSet(false, true)) {
                return
            }

            synchronized(stateLock) {
                phase = SessionPhase.COMPLETED
            }

            cleanup()

            val summary = buildSummary(completionReason, forceInvalid)

            releaseSession(this)
            postSuccess(callback, summary)
        }

        private fun finishWithError(code: String, message: String) {
            if (!completed.compareAndSet(false, true)) {
                return
            }

            synchronized(stateLock) {
                phase = SessionPhase.COMPLETED
            }

            cleanup()
            releaseSession(this)
            postError(callback, code, message)
        }

        private fun cleanup() {
            sessionHandler?.removeCallbacks(firstLocationTimeoutRunnable)
            sessionHandler?.removeCallbacks(collectionTimeoutRunnable)

            val registrations =
                synchronized(stateLock) {
                    Pair(
                        locationUpdatesRegistrationSucceeded,
                        gnssStatusRegistrationSucceeded,
                    )
                }

            if (registrations.first) {
                try {
                    locationManager.removeUpdates(this)
                } catch (_: Exception) {
                    // Defensive cleanup: continue with the remaining resources.
                }
            }

            if (registrations.second) {
                try {
                    locationManager.unregisterGnssStatusCallback(
                        gnssStatusCallback,
                    )
                } catch (_: Exception) {
                    // Defensive cleanup: continue with the remaining resources.
                }
            }

            try {
                handlerThread.quitSafely()
            } catch (_: Exception) {
                // The exact-once completion gate has already protected the result.
            }
        }

        private fun buildSummary(
            completionReason: String,
            forceInvalid: Boolean,
        ): Map<String, Any?> {
            val snapshot =
                synchronized(stateLock) {
                    TimingSnapshot(
                        locationUpdatesRegistrationSucceeded =
                            locationUpdatesRegistrationSucceeded,
                        gnssStatusRegistrationSucceeded =
                            gnssStatusRegistrationSucceeded,
                        locationEventCount = locationEventCount,
                        firstElapsedRealtimeNs = firstElapsedRealtimeNs,
                        lastElapsedRealtimeNs = lastElapsedRealtimeNs,
                        elapsedDeltasNs = elapsedDeltasNs.toList(),
                        nonMonotonicTimestampCount =
                            nonMonotonicTimestampCount,
                        mockLocationDetectedCount = mockLocationDetectedCount,
                        horizontalAccuraciesM =
                            horizontalAccuraciesM.toList(),
                        gnssStartedCount = gnssStartedCount,
                        gnssStoppedCount = gnssStoppedCount,
                        firstFixCallbackCount = firstFixCallbackCount,
                        lastTtffMs = lastTtffMs,
                        satelliteStatusCallbackCount =
                            satelliteStatusCallbackCount,
                        lastSatelliteCount = lastSatelliteCount,
                        lastUsedInFixCount = lastUsedInFixCount,
                        maxSatelliteCount = maxSatelliteCount,
                        maxUsedInFixCount = maxUsedInFixCount,
                    )
                }

            val sortedDeltasNs = snapshot.elapsedDeltasNs.sorted()
            val deltaCount = sortedDeltasNs.size
            val durationNs =
                if (
                    snapshot.firstElapsedRealtimeNs != null &&
                        snapshot.lastElapsedRealtimeNs != null
                ) {
                    snapshot.lastElapsedRealtimeNs -
                        snapshot.firstElapsedRealtimeNs
                } else {
                    null
                }
            val minDeltaNs = sortedDeltasNs.firstOrNull()
            val maxDeltaNs = sortedDeltasNs.lastOrNull()
            val meanDeltaNs =
                if (sortedDeltasNs.isNotEmpty()) {
                    sortedDeltasNs.sumOf { it.toDouble() } /
                        sortedDeltasNs.size
                } else {
                    null
                }
            val medianDeltaNs = calculateMedianLong(sortedDeltasNs)
            val p95DeltaNs = calculateNearestRankP95(sortedDeltasNs)

            val validTimingSummary =
                !forceInvalid &&
                    completionReason ==
                    COMPLETION_MEASUREMENT_WINDOW_COMPLETED &&
                    snapshot.locationEventCount >= 2 &&
                    deltaCount == snapshot.locationEventCount - 1 &&
                    snapshot.firstElapsedRealtimeNs != null &&
                    snapshot.lastElapsedRealtimeNs != null &&
                    durationNs != null &&
                    durationNs > 0L &&
                    snapshot.nonMonotonicTimestampCount == 0 &&
                    meanDeltaNs != null &&
                    meanDeltaNs > 0.0 &&
                    medianDeltaNs != null &&
                    medianDeltaNs > 0.0 &&
                    snapshot.mockLocationDetectedCount == 0

            val meanFixRateHz =
                if (validTimingSummary) {
                    NANOSECONDS_PER_SECOND / meanDeltaNs!!
                } else {
                    null
                }
            val medianIntervalDerivedHz =
                if (validTimingSummary) {
                    NANOSECONDS_PER_SECOND / medianDeltaNs!!
                } else {
                    null
                }

            val sortedAccuraciesM = snapshot.horizontalAccuraciesM.sorted()

            return linkedMapOf(
                "schemaVersion" to SCHEMA_VERSION,
                "snapshotKind" to SNAPSHOT_KIND,
                "liveGnssTimingDiagnostic" to true,
                "status" to STATUS_COMPLETED,
                "completionReason" to completionReason,
                "validTimingSummary" to validTimingSummary,
                "provider" to PROVIDER_SUMMARY_VALUE,
                "requestedMinTimeMs" to REQUESTED_MIN_TIME_MS,
                "requestedMinDistanceM" to
                    REQUESTED_MIN_DISTANCE_M.toDouble(),
                "firstLocationTimeoutMs" to FIRST_LOCATION_TIMEOUT_MS,
                "collectionDurationTargetMs" to
                    COLLECTION_DURATION_TARGET_MS,
                "timestampSource" to TIMESTAMP_SOURCE,
                "timestampDomain" to TIMESTAMP_DOMAIN,
                "locationUpdatesRegistrationSucceeded" to
                    snapshot.locationUpdatesRegistrationSucceeded,
                "gnssStatusRegistrationSucceeded" to
                    snapshot.gnssStatusRegistrationSucceeded,
                "locationEventCount" to snapshot.locationEventCount,
                "firstElapsedRealtimeNs" to
                    snapshot.firstElapsedRealtimeNs,
                "lastElapsedRealtimeNs" to snapshot.lastElapsedRealtimeNs,
                "durationNs" to durationNs,
                "deltaCount" to deltaCount,
                "minDeltaNs" to minDeltaNs,
                "maxDeltaNs" to maxDeltaNs,
                "meanDeltaNs" to meanDeltaNs,
                "medianDeltaNs" to medianDeltaNs,
                "p95DeltaNs" to p95DeltaNs,
                "meanFixRateHz" to meanFixRateHz,
                "medianIntervalDerivedHz" to medianIntervalDerivedHz,
                "nonMonotonicTimestampCount" to
                    snapshot.nonMonotonicTimestampCount,
                "mockLocationDetectedCount" to
                    snapshot.mockLocationDetectedCount,
                "accuracyPresentCount" to sortedAccuraciesM.size,
                "minHorizontalAccuracyM" to sortedAccuraciesM.firstOrNull(),
                "medianHorizontalAccuracyM" to
                    calculateMedianDouble(sortedAccuraciesM),
                "maxHorizontalAccuracyM" to sortedAccuraciesM.lastOrNull(),
                "gnssStartedCount" to snapshot.gnssStartedCount,
                "gnssStoppedCount" to snapshot.gnssStoppedCount,
                "firstFixCallbackCount" to snapshot.firstFixCallbackCount,
                "lastTtffMs" to snapshot.lastTtffMs,
                "satelliteStatusCallbackCount" to
                    snapshot.satelliteStatusCallbackCount,
                "lastSatelliteCount" to snapshot.lastSatelliteCount,
                "lastUsedInFixCount" to snapshot.lastUsedInFixCount,
                "maxSatelliteCount" to snapshot.maxSatelliteCount,
                "maxUsedInFixCount" to snapshot.maxUsedInFixCount,
            )
        }
    }

    private enum class SessionPhase {
        STARTING,
        WAITING_FOR_FIRST_LOCATION,
        COLLECTING,
        COMPLETED,
    }

    private data class TimingSnapshot(
        val locationUpdatesRegistrationSucceeded: Boolean,
        val gnssStatusRegistrationSucceeded: Boolean,
        val locationEventCount: Int,
        val firstElapsedRealtimeNs: Long?,
        val lastElapsedRealtimeNs: Long?,
        val elapsedDeltasNs: List<Long>,
        val nonMonotonicTimestampCount: Int,
        val mockLocationDetectedCount: Int,
        val horizontalAccuraciesM: List<Double>,
        val gnssStartedCount: Int,
        val gnssStoppedCount: Int,
        val firstFixCallbackCount: Int,
        val lastTtffMs: Int?,
        val satelliteStatusCallbackCount: Int,
        val lastSatelliteCount: Int?,
        val lastUsedInFixCount: Int?,
        val maxSatelliteCount: Int?,
        val maxUsedInFixCount: Int?,
    )

    private companion object {
        const val SCHEMA_VERSION = 1
        const val SNAPSHOT_KIND = "gnss_runtime_timing_diagnostic"
        const val STATUS_COMPLETED = "completed"
        const val PROVIDER_SUMMARY_VALUE = "gps"
        const val TIMESTAMP_SOURCE = "Location.elapsedRealtimeNanos"
        const val TIMESTAMP_DOMAIN = "elapsed_realtime_nanoseconds"

        const val REQUESTED_MIN_TIME_MS = 1_000L
        const val REQUESTED_MIN_DISTANCE_M = 0.0f
        const val FIRST_LOCATION_TIMEOUT_MS = 120_000L
        const val COLLECTION_DURATION_TARGET_MS = 60_000L
        const val NANOSECONDS_PER_SECOND = 1_000_000_000.0

        const val HANDLER_THREAD_NAME = "NAVGUARD-GnssTiming"

        const val COMPLETION_MEASUREMENT_WINDOW_COMPLETED =
            "measurement_window_completed"
        const val COMPLETION_FIRST_LOCATION_TIMEOUT =
            "first_location_timeout"
        const val COMPLETION_PROVIDER_DISABLED = "provider_disabled"

        const val ERROR_TIMING_ALREADY_RUNNING =
            "gnss_timing_already_running"
        const val ERROR_TIMING_START_FAILED = "gnss_timing_start_failed"
        const val ERROR_TIMING_CANCELLED = "gnss_timing_cancelled"
        const val ERROR_PROVIDER_UNAVAILABLE = "gnss_provider_unavailable"
        const val ERROR_PROVIDER_DISABLED = "gnss_provider_disabled"
        const val ERROR_PROVIDER_QUERY_FAILED = "gnss_provider_query_failed"
        const val ERROR_PRECISE_PERMISSION_REQUIRED =
            "gnss_precise_permission_required"
        const val ERROR_STATUS_REGISTRATION_FAILED =
            "gnss_status_registration_failed"
        const val ERROR_LOCATION_REGISTRATION_FAILED =
            "gnss_location_registration_failed"

        fun calculateMedianLong(sortedValues: List<Long>): Double? {
            if (sortedValues.isEmpty()) {
                return null
            }

            val middleIndex = sortedValues.size / 2

            return if (sortedValues.size % 2 == 1) {
                sortedValues[middleIndex].toDouble()
            } else {
                (
                    sortedValues[middleIndex - 1].toDouble() +
                        sortedValues[middleIndex].toDouble()
                ) / 2.0
            }
        }

        fun calculateMedianDouble(sortedValues: List<Double>): Double? {
            if (sortedValues.isEmpty()) {
                return null
            }

            val middleIndex = sortedValues.size / 2

            return if (sortedValues.size % 2 == 1) {
                sortedValues[middleIndex]
            } else {
                (
                    sortedValues[middleIndex - 1] +
                        sortedValues[middleIndex]
                ) / 2.0
            }
        }

        fun calculateNearestRankP95(sortedValues: List<Long>): Long? {
            if (sortedValues.isEmpty()) {
                return null
            }

            val oneBasedRank = ceil(0.95 * sortedValues.size).toInt()
            val zeroBasedIndex =
                (oneBasedRank - 1).coerceIn(0, sortedValues.lastIndex)

            return sortedValues[zeroBasedIndex]
        }
    }
}