import Foundation

/// Counters describing what the local event path has done since launch.
///
/// Part of the same privacy boundary as `EventEnvelope`: these are counts and a
/// single coarse state, never payload text, session identifiers, or rejection
/// reasons that could echo a caller's bytes back into the interface.
public struct EventPipelineDiagnostics: Equatable, Sendable {
    public var acceptedEvents: Int = 0
    public var staleEvents: Int = 0
    public var unknownSessionEvents: Int = 0
    /// Frames the transport refused before they ever reached the registry.
    public var rejectedFrames: Int = 0
    public var trackedSessions: Int = 0
    /// Arrival of the newest accepted event, for a human-readable "last seen".
    public var lastAcceptedAt: Date?

    public init() {}

    /// True once any frame has been observed, accepted or not. Distinguishes
    /// "listening and quiet" from "listening and being talked to".
    public var hasObservedTraffic: Bool {
        acceptedEvents + staleEvents + unknownSessionEvents + rejectedFrames > 0
    }
}

/// Owns the registry, the reducer, and the diagnostic counters as one unit.
///
/// A value type with injected clocks, exactly like `SessionRegistry`, so the
/// whole app-facing path stays deterministic in fixtures. It contains no
/// transport, no timer, and no AppKit: the caller decides when events arrive and
/// when time passes.
public struct EventPipeline: Sendable {
    public private(set) var registry: SessionRegistry
    public var reducer: MascotStateReducer
    public private(set) var diagnostics = EventPipelineDiagnostics()
    /// The reduced state as of the last `ingest`, `refresh`, or `noteRejectedFrame`.
    public private(set) var visibleState = MascotVisibleState(state: .offline)

    public init(
        registry: SessionRegistry = SessionRegistry(),
        reducer: MascotStateReducer = MascotStateReducer()
    ) {
        self.registry = registry
        self.reducer = reducer
    }

    @discardableResult
    public mutating func ingest(
        _ envelope: EventEnvelope,
        overrides: ManualOverrides = .none,
        now: Date,
        uptime: Uptime
    ) -> IngestOutcome {
        let outcome = registry.ingest(envelope, at: uptime)
        switch outcome {
        case .accepted:
            diagnostics.acceptedEvents += 1
            diagnostics.lastAcceptedAt = now
        case .ignoredStale:
            diagnostics.staleEvents += 1
        case .ignoredUnknownSession:
            diagnostics.unknownSessionEvents += 1
        }
        recompute(overrides: overrides, now: now, uptime: uptime)
        return outcome
    }

    /// Records a frame the transport refused. The reason is deliberately not
    /// carried: a rejection can be provoked by arbitrary bytes, so only the count
    /// crosses into the app.
    public mutating func noteRejectedFrame(
        overrides: ManualOverrides = .none,
        now: Date,
        uptime: Uptime
    ) {
        diagnostics.rejectedFrames += 1
        recompute(overrides: overrides, now: now, uptime: uptime)
    }

    /// Recomputes visible state as time passes, so heartbeat expiry, the stopped
    /// grace period, reaction windows, the sleep window, and manual override
    /// changes all take effect without needing a new event to arrive.
    public mutating func refresh(
        overrides: ManualOverrides = .none,
        now: Date,
        uptime: Uptime
    ) {
        registry.reconcile(at: uptime)
        recompute(overrides: overrides, now: now, uptime: uptime)
    }

    private mutating func recompute(overrides: ManualOverrides, now: Date, uptime: Uptime) {
        visibleState = reducer.reduce(
            registry: registry,
            overrides: overrides,
            now: now,
            uptime: uptime
        )
        diagnostics.trackedSessions = registry.sessions(at: uptime).count
    }
}
