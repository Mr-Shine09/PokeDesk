import Foundation
import MascotCore
import MascotTransport

/// Runs the local event socket inside the app and keeps the pipeline current.
///
/// This is the app's only owner of `EventSocketServer`, and `visibleState` is the
/// only input to animation selection — `AppDelegate` observes it and feeds it to
/// `AmbientAnimationController`. Manual pause and ideating arrive here as
/// `overrides` and come back out folded into the reduced state, so there is
/// exactly one path from any cause to what the pet is doing.
@MainActor
final class AgentEventBridge: ObservableObject {
    enum Status: Equatable {
        case stopped
        case listening
        /// Already-explained failure text. Never contains a path or payload byte.
        case failed(String)
    }

    @Published private(set) var status: Status = .stopped
    @Published private(set) var visibleState = MascotVisibleState(state: .offline)
    @Published private(set) var diagnostics = EventPipelineDiagnostics()

    /// Kept in sync by `AppDelegate` so a manual pause or ideating choice
    /// outranks provider events exactly as the reducer specifies.
    var overrides: ManualOverrides = .none {
        didSet {
            guard overrides != oldValue else { return }
            refresh()
        }
    }

    /// Cadence while sessions are tracked: reaction windows are seconds long, so
    /// a second of latency is invisible.
    private static let activeRefreshInterval: TimeInterval = 1
    /// Cadence while nothing is tracked. Nothing can change without an event
    /// arriving, and an event refreshes immediately, so this only exists to
    /// re-evaluate the nightly sleep window.
    private static let idleRefreshInterval: TimeInterval = 15

    private var pipeline = EventPipeline()
    private var server: EventSocketServer?
    private var refreshTimer: Timer?

    /// Monotonic and unaffected by time-zone changes or NTP corrections. It also
    /// does not advance while the machine sleeps, so a closed lid cannot retire a
    /// live session; `EventPipeline.refresh` still reconciles after wake.
    private var uptime: Uptime {
        Uptime(seconds: ProcessInfo.processInfo.systemUptime)
    }

    func start() {
        guard server == nil else { return }
        do {
            let socketURL = try EventSocketLocation.socketURL()
            let server = EventSocketServer(
                configuration: EventSocketServer.Configuration(socketURL: socketURL),
                onEvent: { [weak self] envelope in
                    Task { @MainActor in self?.receive(envelope) }
                },
                onRejection: { [weak self] _ in
                    // The reason is discarded on purpose: it is derived from
                    // bytes a caller controls, so only the count crosses over.
                    Task { @MainActor in self?.receiveRejectedFrame() }
                }
            )
            try server.start()
            self.server = server
            status = .listening
            refresh()
        } catch {
            status = .failed(Self.describe(error))
        }
    }

    /// Idempotent, and safe to call during termination. Removes the socket file
    /// so the next launch does not have to reclaim a stale one.
    func stop() {
        refreshTimer?.invalidate()
        refreshTimer = nil
        server?.stop()
        server = nil
        status = .stopped
    }

    /// One line for the menu bar. States plainly that nothing drives the mascot
    /// yet, so the diagnostics cannot be read as a claim of live agent tracking.
    var summary: String {
        switch status {
        case .stopped:
            return "Event socket: not running"
        case .failed(let reason):
            return "Event socket: \(reason)"
        case .listening:
            let counts = [
                "\(diagnostics.acceptedEvents) accepted",
                "\(diagnostics.trackedSessions) session\(diagnostics.trackedSessions == 1 ? "" : "s")",
            ]
            let rejected = diagnostics.rejectedFrames + diagnostics.staleEvents
                + diagnostics.unknownSessionEvents
            let tail = rejected > 0 ? counts + ["\(rejected) ignored"] : counts
            return "Event socket: listening • " + tail.joined(separator: " • ")
        }
    }

    /// The reduced state and where it came from. `no provider` is the honest
    /// label for a state no agent asserted — including the offline default that
    /// every machine shows until a hook is installed.
    var reducedStateSummary: String {
        let providers = visibleState.providers.map(\.rawValue).joined(separator: ", ")
        let source = providers.isEmpty ? "no provider" : providers
        return "Reduced state: \(visibleState.state.displayName) (\(source))"
    }

    // MARK: - Private

    private func receive(_ envelope: EventEnvelope) {
        pipeline.ingest(envelope, overrides: overrides, now: Date(), uptime: uptime)
        publish()
    }

    private func receiveRejectedFrame() {
        pipeline.noteRejectedFrame(overrides: overrides, now: Date(), uptime: uptime)
        publish()
    }

    private func refresh() {
        pipeline.refresh(overrides: overrides, now: Date(), uptime: uptime)
        publish()
    }

    private func publish() {
        visibleState = pipeline.visibleState
        diagnostics = pipeline.diagnostics
        rescheduleRefresh()
    }

    /// Slows to the idle cadence whenever nothing is tracked, so a quiet machine
    /// is not woken once a second for a reduction that cannot change.
    private func rescheduleRefresh() {
        guard server != nil else { return }
        let interval = diagnostics.trackedSessions > 0
            ? Self.activeRefreshInterval
            : Self.idleRefreshInterval
        if let refreshTimer, refreshTimer.isValid, refreshTimer.timeInterval == interval {
            return
        }
        refreshTimer?.invalidate()
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
        timer.tolerance = interval / 2
        refreshTimer = timer
    }

    private static func describe(_ error: Error) -> String {
        guard let error = error as? EventSocketServerError else {
            return "unavailable"
        }
        switch error {
        case .addressInUse:
            return "another Dock Pet is already listening"
        case .alreadyRunning:
            return "already running"
        case .socketPathTooLong:
            return "socket path too long for this account"
        case .directoryUnavailable:
            return "support directory unavailable"
        case .socketCreationFailed, .bindFailed, .listenFailed:
            return "could not open the local socket"
        }
    }
}
