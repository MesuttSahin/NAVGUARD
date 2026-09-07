package io.github.mesuttsahin.navguard

import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import java.util.concurrent.atomic.AtomicBoolean

internal class GnssAnchorAcquisition(
    private val locationManager: LocationManager,
    private val resultHandler: Handler = Handler(Looper.getMainLooper()),
) {
    internal interface Callback {
        fun onSuccess(anchor: Map<String, Any?>)

        fun onError(code: String, message: String)
    }

    private val activeSessionLock = Any()
    private var activeSession: AcquisitionSession? = null

    fun isAcquisitionRunning(): Boolean =
        synchronized(activeSessionLock) {
            activeSession != null
        }

    fun start(callback: Callback) {
        val session = AcquisitionSession(callback)

        if (!reserveSession(session)) {
            postError(
                callback,
                ERROR_ALREADY_RUNNING,
                "A GNSS anchor acquisition is already running.",
            )
            return
        }

        session.start()
    }

    fun cancelActiveAcquisition(
        code: String = ERROR_ACQUISITION_CANCELLED,
        message: String = "GNSS anchor acquisition cancelled.",
    ): Boolean {
        val session =
            synchronized(activeSessionLock) {
                activeSession
            }

        session?.cancel(code, message)
        return session != null
    }

    fun cancelForActivityPause() {
        cancelActiveAcquisition(
            ERROR_ACTIVITY_PAUSED,
            "GNSS anchor acquisition cancelled because the activity paused.",
        )
    }

    fun cancelForActivityDestroy() {
        cancelActiveAcquisition(
            ERROR_ACTIVITY_DESTROYED,
            "GNSS anchor acquisition cancelled because the activity was destroyed.",
        )
    }

    private fun reserveSession(session: AcquisitionSession): Boolean =
        synchronized(activeSessionLock) {
            if (activeSession != null) {
                false
            } else {
                activeSession = session
                true
            }
        }

    private fun releaseSession(session: AcquisitionSession) {
        synchronized(activeSessionLock) {
            if (activeSession === session) {
                activeSession = null
            }
        }
    }

    private fun postSuccess(
        callback: Callback,
        anchor: Map<String, Any?>,
    ) {
        if (!resultHandler.post { callback.onSuccess(anchor) }) {
            callback.onSuccess(anchor)
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

    private inner class AcquisitionSession(
        private val callback: Callback,
    ) : LocationListener {
        private val completed = AtomicBoolean(false)
        private val stateLock = Any()
        private val handlerThread = HandlerThread(HANDLER_THREAD_NAME)
        private val candidates = mutableListOf<AnchorCandidate>()

        private var sessionHandler: Handler? = null
        private var locationUpdatesRegistered = false
        private var phase = AcquisitionPhase.STARTING
        private var candidateWindowStartElapsedRealtimeNanos: Long? = null

        private val firstValidFixTimeoutRunnable =
            Runnable {
                finishWithError(
                    ERROR_FIRST_VALID_FIX_TIMEOUT,
                    "No structurally valid GPS fix was received before the timeout.",
                )
            }

        private val candidateWindowControlTimeoutRunnable =
            Runnable {
                completeCandidateCollection()
            }

        fun start() {
            val handler =
                try {
                    handlerThread.start()
                    Handler(handlerThread.looper)
                } catch (_: Exception) {
                    finishWithError(
                        ERROR_LOCATION_MANAGER,
                        "Unable to start the GNSS anchor acquisition worker.",
                    )
                    return
                }

            sessionHandler = handler

            if (!handler.post { initializeOnSessionThread(handler) }) {
                finishWithError(
                    ERROR_LOCATION_MANAGER,
                    "Unable to initialize GNSS anchor acquisition.",
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
                        ERROR_LOCATION_MANAGER,
                        "Unable to determine GPS provider availability.",
                    )
                    return
                }

            if (!providerAvailable) {
                finishWithError(
                    ERROR_GPS_PROVIDER_UNAVAILABLE,
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
                        ERROR_LOCATION_MANAGER,
                        "Unable to determine whether GPS_PROVIDER is enabled.",
                    )
                    return
                }

            if (!providerEnabled) {
                finishWithError(
                    ERROR_GPS_PROVIDER_DISABLED,
                    "GPS_PROVIDER is disabled.",
                )
                return
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
                    ERROR_FINE_LOCATION_PERMISSION_MISSING,
                    "Precise foreground location permission is required.",
                )
                return
            } catch (_: IllegalArgumentException) {
                finishWithError(
                    ERROR_GPS_PROVIDER_UNAVAILABLE,
                    "GPS_PROVIDER could not be registered for location updates.",
                )
                return
            } catch (_: Exception) {
                finishWithError(
                    ERROR_LOCATION_MANAGER,
                    "Unable to register GPS location updates.",
                )
                return
            }

            synchronized(stateLock) {
                locationUpdatesRegistered = true
                phase = AcquisitionPhase.WAITING_FOR_FIRST_VALID_FIX
            }

            if (!handler.postDelayed(
                    firstValidFixTimeoutRunnable,
                    FIRST_VALID_FIX_TIMEOUT_MS,
                )
            ) {
                finishWithError(
                    ERROR_LOCATION_MANAGER,
                    "Unable to schedule the first valid GPS fix timeout.",
                )
            }
        }

        override fun onLocationChanged(location: Location) {
            if (completed.get()) {
                return
            }

            val candidate = createStructurallyValidCandidate(location) ?: return
            val acceptance = acceptCandidateIntoMeasurementWindow(candidate)

            if (acceptance != CandidateAcceptance.FIRST_CANDIDATE_ACCEPTED) {
                return
            }

            val handler = sessionHandler
            handler?.removeCallbacks(firstValidFixTimeoutRunnable)

            // This Handler delay controls operation termination only.
            // Candidate membership is decided separately using
            // Location.elapsedRealtimeNanos.
            if (
                handler == null ||
                    !handler.postDelayed(
                        candidateWindowControlTimeoutRunnable,
                        CANDIDATE_COLLECTION_WINDOW_MS,
                    )
            ) {
                finishWithError(
                    ERROR_LOCATION_MANAGER,
                    "Unable to schedule the GNSS anchor control timeout.",
                )
            }
        }

        override fun onProviderDisabled(provider: String) {
            if (provider == LocationManager.GPS_PROVIDER) {
                finishWithError(
                    ERROR_GPS_PROVIDER_DISABLED,
                    "GPS_PROVIDER was disabled during anchor acquisition.",
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

        fun cancel(code: String, message: String) {
            finishWithError(code, message)
        }

        private fun createStructurallyValidCandidate(
            location: Location,
        ): AnchorCandidate? {
            val provider = location.provider ?: return null

            if (provider != LocationManager.GPS_PROVIDER) {
                return null
            }

            if (isMockLocation(location)) {
                return null
            }

            val latitudeDeg = location.latitude
            val longitudeDeg = location.longitude
            val elapsedRealtimeNanos = location.elapsedRealtimeNanos

            if (
                !latitudeDeg.isFinite() ||
                    latitudeDeg !in -90.0..90.0 ||
                    !longitudeDeg.isFinite() ||
                    longitudeDeg !in -180.0..180.0 ||
                    elapsedRealtimeNanos <= 0L ||
                    !location.hasAccuracy()
            ) {
                return null
            }

            val horizontalAccuracyReportedM = location.accuracy.toDouble()

            if (
                !horizontalAccuracyReportedM.isFinite() ||
                    horizontalAccuracyReportedM <= 0.0
            ) {
                return null
            }

            val altitudeEllipsoidM =
                if (location.hasAltitude()) {
                    location.altitude.takeIf { it.isFinite() }
                } else {
                    null
                }

            val verticalAccuracyReportedM =
                if (
                    altitudeEllipsoidM != null &&
                        Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                        location.hasVerticalAccuracy()
                ) {
                    location.verticalAccuracyMeters.toDouble().takeIf {
                        it.isFinite() && it > 0.0
                    }
                } else {
                    null
                }

            return AnchorCandidate(
                latitudeDeg = latitudeDeg,
                longitudeDeg = longitudeDeg,
                altitudeEllipsoidM = altitudeEllipsoidM,
                horizontalAccuracyReportedM = horizontalAccuracyReportedM,
                verticalAccuracyReportedM = verticalAccuracyReportedM,
                elapsedRealtimeNanos = elapsedRealtimeNanos,
                provider = provider,
            )
        }

        private fun acceptCandidateIntoMeasurementWindow(
            candidate: AnchorCandidate,
        ): CandidateAcceptance {
            return synchronized(stateLock) {
                if (completed.get()) {
                    CandidateAcceptance.REJECTED
                } else {
                    when (phase) {
                        AcquisitionPhase.WAITING_FOR_FIRST_VALID_FIX -> {
                            candidateWindowStartElapsedRealtimeNanos =
                                candidate.elapsedRealtimeNanos
                            candidates.add(candidate)
                            phase = AcquisitionPhase.COLLECTING_CANDIDATES
                            CandidateAcceptance.FIRST_CANDIDATE_ACCEPTED
                        }

                        AcquisitionPhase.COLLECTING_CANDIDATES -> {
                            val windowStart =
                                candidateWindowStartElapsedRealtimeNanos

                            if (windowStart == null) {
                                CandidateAcceptance.REJECTED
                            } else {
                                val candidateTimestamp =
                                    candidate.elapsedRealtimeNanos

                                if (candidateTimestamp < windowStart) {
                                    CandidateAcceptance.REJECTED
                                } else {
                                    // Both timestamps are positive and the
                                    // candidate is known to be >= windowStart.
                                    // This subtraction cannot overflow Long.
                                    val elapsedFromWindowStart =
                                        candidateTimestamp - windowStart

                                    if (
                                        elapsedFromWindowStart >
                                        CANDIDATE_COLLECTION_WINDOW_NS
                                    ) {
                                        CandidateAcceptance.REJECTED
                                    } else {
                                        candidates.add(candidate)
                                        CandidateAcceptance.ACCEPTED
                                    }
                                }
                            }
                        }

                        AcquisitionPhase.STARTING,
                        AcquisitionPhase.COMPLETED,
                        -> CandidateAcceptance.REJECTED
                    }
                }
            }
        }

        @Suppress("DEPRECATION")
        private fun isMockLocation(location: Location): Boolean =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                location.isMock
            } else {
                location.isFromMockProvider
            }

        private fun completeCandidateCollection() {
            val validWindowCandidates =
                synchronized(stateLock) {
                    candidates.toList()
                }

            if (
                validWindowCandidates.size <
                MINIMUM_VALID_CANDIDATE_COUNT
            ) {
                finishWithError(
                    ERROR_INSUFFICIENT_VALID_CANDIDATES,
                    "Fewer than three structurally valid GPS candidates were collected.",
                )
                return
            }

            val selectedCandidate =
                validWindowCandidates.minWithOrNull(
                    compareBy<AnchorCandidate> {
                        it.horizontalAccuracyReportedM
                    }.thenByDescending {
                        it.elapsedRealtimeNanos
                    },
                )

            if (selectedCandidate == null) {
                finishWithError(
                    ERROR_UNKNOWN,
                    "Unable to select a GNSS anchor candidate.",
                )
                return
            }

            finishWithSuccess(
                selectedCandidate = selectedCandidate,
                candidateCount = validWindowCandidates.size,
            )
        }

        private fun finishWithSuccess(
            selectedCandidate: AnchorCandidate,
            candidateCount: Int,
        ) {
            if (!completed.compareAndSet(false, true)) {
                return
            }

            val result =
                linkedMapOf<String, Any?>(
                    "schemaVersion" to SCHEMA_VERSION,
                    "snapshotKind" to SNAPSHOT_KIND_ACQUISITION_RESULT,
                    "success" to true,
                    "latitudeDeg" to selectedCandidate.latitudeDeg,
                    "longitudeDeg" to selectedCandidate.longitudeDeg,
                    "altitudeEllipsoidM" to
                        selectedCandidate.altitudeEllipsoidM,
                    "horizontalAccuracyReportedM" to
                        selectedCandidate.horizontalAccuracyReportedM,
                    "verticalAccuracyReportedM" to
                        selectedCandidate.verticalAccuracyReportedM,
                    "selectedReportedHorizontalAccuracyM" to
                        selectedCandidate.horizontalAccuracyReportedM,
                    "selectedReportedVerticalAccuracyM" to
                        selectedCandidate.verticalAccuracyReportedM,
                    "elapsedRealtimeNanos" to
                        selectedCandidate.elapsedRealtimeNanos,
                    "provider" to selectedCandidate.provider,
                    "candidateCount" to candidateCount,
                    "selectionPolicy" to SELECTION_POLICY,
                    "altitudeAvailable" to
                        (selectedCandidate.altitudeEllipsoidM != null),
                    "coordinateAccuracyValidated" to false,
                    "selectedCandidateStructurallyValid" to true,
                    "selectedCandidateMock" to false,
                    "firstValidFixTimeoutMs" to FIRST_VALID_FIX_TIMEOUT_MS,
                    "candidateCollectionWindowMs" to
                        CANDIDATE_COLLECTION_WINDOW_MS,
                    "minimumValidCandidateCount" to
                        MINIMUM_VALID_CANDIDATE_COUNT,
                    "rawCandidateListReturned" to false,
                )

            synchronized(stateLock) {
                phase = AcquisitionPhase.COMPLETED
                candidateWindowStartElapsedRealtimeNanos = null
                candidates.clear()
            }

            cleanup()
            releaseSession(this)
            postSuccess(callback, result)
        }

        private fun finishWithError(code: String, message: String) {
            if (!completed.compareAndSet(false, true)) {
                return
            }

            synchronized(stateLock) {
                phase = AcquisitionPhase.COMPLETED
                candidateWindowStartElapsedRealtimeNanos = null
                candidates.clear()
            }

            cleanup()
            releaseSession(this)
            postError(callback, code, message)
        }

        private fun cleanup() {
            sessionHandler?.removeCallbacks(firstValidFixTimeoutRunnable)
            sessionHandler?.removeCallbacks(
                candidateWindowControlTimeoutRunnable,
            )

            val shouldRemoveUpdates =
                synchronized(stateLock) {
                    locationUpdatesRegistered
                }

            if (shouldRemoveUpdates) {
                try {
                    locationManager.removeUpdates(this)
                } catch (_: Exception) {
                    // Exact-once completion remains authoritative.
                }
            }

            try {
                if (handlerThread.isAlive) {
                    handlerThread.quitSafely()
                }
            } catch (_: Exception) {
                // Exact-once completion remains authoritative.
            }
        }
    }

    private enum class AcquisitionPhase {
        STARTING,
        WAITING_FOR_FIRST_VALID_FIX,
        COLLECTING_CANDIDATES,
        COMPLETED,
    }

    private enum class CandidateAcceptance {
        FIRST_CANDIDATE_ACCEPTED,
        ACCEPTED,
        REJECTED,
    }

    private data class AnchorCandidate(
        val latitudeDeg: Double,
        val longitudeDeg: Double,
        val altitudeEllipsoidM: Double?,
        val horizontalAccuracyReportedM: Double,
        val verticalAccuracyReportedM: Double?,
        val elapsedRealtimeNanos: Long,
        val provider: String,
    )

    private companion object {
        const val SCHEMA_VERSION = 1
        const val SNAPSHOT_KIND_ACQUISITION_RESULT =
            "gnss_anchor_acquisition_result"

        const val REQUESTED_MIN_TIME_MS = 1_000L
        const val REQUESTED_MIN_DISTANCE_M = 0.0f
        const val FIRST_VALID_FIX_TIMEOUT_MS = 120_000L
        const val CANDIDATE_COLLECTION_WINDOW_MS = 10_000L
        const val NANOSECONDS_PER_MILLISECOND = 1_000_000L
        const val CANDIDATE_COLLECTION_WINDOW_NS =
            CANDIDATE_COLLECTION_WINDOW_MS * NANOSECONDS_PER_MILLISECOND
        const val MINIMUM_VALID_CANDIDATE_COUNT = 3

        const val SELECTION_POLICY =
            "lowest_reported_horizontal_accuracy_then_newer_elapsed_realtime"

        const val HANDLER_THREAD_NAME = "NAVGUARD-GnssAnchorAcquisition"

        const val ERROR_ALREADY_RUNNING =
            "anchor_acquisition_already_running"
        const val ERROR_FINE_LOCATION_PERMISSION_MISSING =
            "fine_location_permission_missing"
        const val ERROR_GPS_PROVIDER_UNAVAILABLE =
            "gps_provider_unavailable"
        const val ERROR_GPS_PROVIDER_DISABLED =
            "gps_provider_disabled"
        const val ERROR_FIRST_VALID_FIX_TIMEOUT =
            "first_valid_fix_timeout"
        const val ERROR_INSUFFICIENT_VALID_CANDIDATES =
            "insufficient_valid_candidates"
        const val ERROR_ACQUISITION_CANCELLED =
            "acquisition_cancelled"
        const val ERROR_ACTIVITY_PAUSED = "activity_paused"
        const val ERROR_ACTIVITY_DESTROYED = "activity_destroyed"
        const val ERROR_LOCATION_MANAGER = "location_manager_error"
        const val ERROR_UNKNOWN = "unknown_error"
    }
}
