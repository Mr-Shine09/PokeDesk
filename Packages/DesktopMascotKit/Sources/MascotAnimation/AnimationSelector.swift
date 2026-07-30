import Foundation
import MascotCore

/// What the animation controller should play for one visible state.
///
/// Movement is part of the plan because the art direction ties the two together:
/// only chilling/strolling moves along the lane. Working sits at a computer,
/// waiting stops and turns toward the user, and every reaction plays in place.
public enum AnimationPlan: Equatable, Sendable {
    /// Stroll the bottom lane, resting on `restingRow` between walks.
    case ambient(restingRow: String)
    /// Hold one row in place, without moving along the lane.
    case stationary(row: String)

    /// The row shown while not walking. The walk rows are chosen by direction,
    /// so they are the controller's business rather than the plan's.
    public var restingRow: String {
        switch self {
        case .ambient(let row), .stationary(let row): row
        }
    }

    public var isAmbient: Bool {
        if case .ambient = self { return true }
        return false
    }
}

/// Turns reduced state into an animation plan, holding each state on screen long
/// enough to be seen.
///
/// A value type with an injected monotonic clock, matching the registry and the
/// reducer, so the dwell fixtures are deterministic.
public struct AnimationSelector: Sendable {
    /// A state flip faster than this is not readable as an animation; it just
    /// looks like a glitch. Sessions can legitimately flip between working and
    /// waiting several times a second while tools run.
    public static let defaultMinimumDwell: TimeInterval = 0.75

    public let minimumDwell: TimeInterval
    /// The state actually on screen, which lags the reduced state by at most
    /// `minimumDwell`.
    public private(set) var displayedState: MascotState

    /// `nil` until the first real commit. The initial state was never shown to
    /// anyone, so it has earned no dwell protection and the first change is
    /// always immediate, whenever it arrives.
    private var committedAt: Uptime?
    /// The newest reduced state, held back until the dwell elapses. Only the
    /// newest is kept: intermediate states inside one dwell window are never
    /// shown, which is the entire point.
    private var pending: MascotState?

    public init(
        initial: MascotState = .offline,
        minimumDwell: TimeInterval = AnimationSelector.defaultMinimumDwell
    ) {
        self.minimumDwell = minimumDwell
        displayedState = initial
    }

    /// Feeds the newest reduced state and returns what should be on screen.
    ///
    /// Safe to call every tick with an unchanged value; that is how a pending
    /// state gets committed once its dwell elapses.
    @discardableResult
    public mutating func update(to target: MascotState, at uptime: Uptime) -> MascotState {
        // Pause and resume are direct user actions, so they must never feel
        // delayed. Everything else is a provider signal and can wait its turn.
        if target == .paused || displayedState == .paused {
            if target != displayedState { commit(target, at: uptime) }
            return displayedState
        }

        if target == displayedState {
            pending = nil
            return displayedState
        }

        if let committedAt, uptime.seconds < committedAt.seconds + minimumDwell {
            pending = target
            return displayedState
        }
        commit(target, at: uptime)
        return displayedState
    }

    /// Advances time without a new reduced state, committing whatever is pending
    /// once its dwell has elapsed.
    @discardableResult
    public mutating func tick(at uptime: Uptime) -> MascotState {
        guard let pending else { return displayedState }
        return update(to: pending, at: uptime)
    }

    public var plan: AnimationPlan {
        Self.plan(for: displayedState)
    }

    /// The state-to-row mapping, straight from the animation inventory.
    ///
    /// Offline strolls rather than standing still, deliberately: with no adapter
    /// installed, every machine would otherwise show a motionless pet forever,
    /// and roaming is the owner-approved no-signal behavior. The offline row
    /// still supplies the rests, so the quiet bowed blink is not lost.
    public static func plan(for state: MascotState) -> AnimationPlan {
        switch state {
        case .offline:
            return .ambient(restingRow: "offline")
        case .idle:
            return .ambient(restingRow: "idle")
        case .paused:
            return .stationary(row: "paused")
        case .working:
            return .stationary(row: "working")
        case .waiting:
            return .stationary(row: "waiting")
        case .ideating:
            return .stationary(row: "ideating")
        case .success:
            return .stationary(row: "success")
        case .failure:
            return .stationary(row: "failure")
        case .sleeping:
            return .stationary(row: "sleeping")
        }
    }

    private mutating func commit(_ state: MascotState, at uptime: Uptime) {
        displayedState = state
        committedAt = uptime
        pending = nil
    }
}
