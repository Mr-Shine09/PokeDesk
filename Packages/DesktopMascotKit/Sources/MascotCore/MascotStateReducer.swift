import Foundation

/// User-driven state that no provider event may override.
public struct ManualOverrides: Equatable, Sendable {
    /// Manual pause stays authoritative until the user clears it.
    public var isPaused: Bool
    /// Version 0.1 has no documented external lifecycle signal for ordinary
    /// Claude or ChatGPT conversations, so ideating is an explicit menu-bar
    /// action rather than anything inferred from the screen or a transcript.
    public var isIdeating: Bool

    public static let none = ManualOverrides()

    public init(isPaused: Bool = false, isIdeating: Bool = false) {
        self.isPaused = isPaused
        self.isIdeating = isIdeating
    }
}

/// The nightly window in which inactivity becomes sleep instead of strolling.
public struct SleepWindow: Equatable, Sendable {
    /// Inclusive local hour at which sleep begins.
    public var startHour: Int
    /// Exclusive local hour at which sleep ends, so 06:00 is already awake.
    public var endHour: Int

    public init(startHour: Int = 23, endHour: Int = 6) {
        self.startHour = startHour
        self.endHour = endHour
    }

    public func contains(hour: Int) -> Bool {
        startHour <= endHour
            ? (hour >= startHour && hour < endHour)
            : (hour >= startHour || hour < endHour)
    }
}

/// What the animation and window controllers should show, plus the providers
/// responsible for it. Concurrent providers collapse to a single animation and
/// are surfaced only in the menu-bar detail view.
public struct MascotVisibleState: Equatable, Sendable {
    public let state: MascotState
    public let providers: [EventProvider]

    public init(state: MascotState, providers: [EventProvider] = []) {
        self.state = state
        self.providers = providers
    }
}

/// Collapses every tracked session plus the manual overrides into one visible
/// state, using the documented priority:
///
/// `paused > failure-recent > waiting > working > ideating > success-recent >
/// scheduled-sleep > idle/strolling > offline`
///
/// The reducer reads no clock of its own. Callers pass the wall clock (for the
/// local sleep window) and the monotonic instant (for reaction and expiry
/// windows) separately, because the two must not be conflated.
public struct MascotStateReducer: Sendable {
    public var sleepWindow: SleepWindow
    public var calendar: Calendar

    public init(sleepWindow: SleepWindow = SleepWindow(), calendar: Calendar = .current) {
        self.sleepWindow = sleepWindow
        self.calendar = calendar
    }

    public func reduce(
        sessions: [AgentSession],
        overrides: ManualOverrides = .none,
        now: Date,
        uptime: Uptime
    ) -> MascotVisibleState {
        // A stopped session is retained only so its reaction can finish; it is no
        // longer present, so it must not hold the mascot in idle instead of offline.
        let present = sessions.filter { $0.activity != .stopped }
        let presentProviders = Self.providers(of: present)

        if overrides.isPaused {
            return MascotVisibleState(state: .paused, providers: presentProviders)
        }

        let failing = sessions.filter { Self.hasLiveReaction($0, kind: .failure, at: uptime) }
        if !failing.isEmpty {
            return MascotVisibleState(state: .failure, providers: Self.providers(of: failing))
        }

        let awaiting = sessions.filter { $0.activity == .waiting }
        if !awaiting.isEmpty {
            return MascotVisibleState(state: .waiting, providers: Self.providers(of: awaiting))
        }

        let working = sessions.filter { $0.activity == .working }
        if !working.isEmpty {
            return MascotVisibleState(state: .working, providers: Self.providers(of: working))
        }

        if overrides.isIdeating {
            // Manual ideating has no originating session, so it surfaces no provider.
            return MascotVisibleState(state: .ideating)
        }

        let succeeding = sessions.filter { Self.hasLiveReaction($0, kind: .success, at: uptime) }
        if !succeeding.isEmpty {
            return MascotVisibleState(state: .success, providers: Self.providers(of: succeeding))
        }

        // Any work, ideating, or waiting above already interrupted sleep. Reaching
        // here inside the window means the last turn's reaction has finished, so
        // the mascot goes back to sleep.
        if sleepWindow.contains(hour: calendar.component(.hour, from: now)) {
            return MascotVisibleState(state: .sleeping, providers: presentProviders)
        }

        // A known-but-quiet session strolls; no session at all is offline.
        return MascotVisibleState(
            state: present.isEmpty ? .offline : .idle,
            providers: presentProviders
        )
    }

    /// Convenience overload so callers hold a registry rather than a snapshot.
    public func reduce(
        registry: SessionRegistry,
        overrides: ManualOverrides = .none,
        now: Date,
        uptime: Uptime
    ) -> MascotVisibleState {
        reduce(
            sessions: registry.sessions(at: uptime),
            overrides: overrides,
            now: now,
            uptime: uptime
        )
    }

    private static func hasLiveReaction(
        _ session: AgentSession,
        kind: SessionReaction.Kind,
        at uptime: Uptime
    ) -> Bool {
        guard let reaction = session.reaction else { return false }
        return reaction.kind == kind && uptime <= reaction.expiresAt
    }

    private static func providers(of sessions: [AgentSession]) -> [EventProvider] {
        Array(Set(sessions.map(\.provider))).sorted { $0.rawValue < $1.rawValue }
    }
}
