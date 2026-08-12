import Foundation

/// User-driven state that no provider event may override.
public struct ManualOverrides: Equatable, Sendable {
    /// Manual pause stays authoritative until the user clears it.
    public var isPaused: Bool
    /// Version 0.1 has no documented external lifecycle signal for ordinary
    /// Claude or ChatGPT conversations, so ideating is an explicit menu-bar
    /// action rather than anything inferred from the screen or a transcript.
    public var isIdeating: Bool

    /// Forces one state so every animation can be inspected without an agent.
    ///
    /// This exists because the alternative is worse: previewing by injecting
    /// synthetic events would put fabricated sessions in the registry, and a
    /// fabricated session is indistinguishable from a real one after the fact.
    /// A preview is therefore an override — it changes what is *shown* and
    /// never what is *believed*, so the registry stays a record of real events
    /// only.
    ///
    /// It outranks everything, including pause, because a preview that silently
    /// showed something else would be useless for its one purpose. The caller is
    /// expected to keep it mutually exclusive with the other overrides.
    public var preview: MascotState?

    public static let none = ManualOverrides()

    public init(
        isPaused: Bool = false,
        isIdeating: Bool = false,
        preview: MascotState? = nil
    ) {
        self.isPaused = isPaused
        self.isIdeating = isIdeating
        self.preview = preview
    }
}

/// The nightly window in which inactivity becomes sleep instead of strolling.
public struct SleepWindow: Equatable, Sendable {
    /// Inclusive local hour at which sleep begins.
    public var startHour: Int
    /// Exclusive local hour at which sleep ends, so 06:00 is already awake.
    public var endHour: Int

    /// Hours outside `0 ... 23` are clamped rather than rejected.
    ///
    /// The values reach here from persisted preferences, which any process can
    /// write and which survive an app downgrade. A nonsense hour must produce a
    /// usable window, not a crash and not a silently dead sleep schedule.
    public init(startHour: Int = 23, endHour: Int = 6) {
        self.startHour = min(max(startHour, 0), 23)
        self.endHour = min(max(endHour, 0), 23)
    }

    /// Equal hours mean the window is empty, not that it covers the whole day.
    ///
    /// This falls out of the half-open comparison below, and it is the reason
    /// "never sleep" is expressed as a `nil` window rather than as `0 ... 0`:
    /// an empty window and a disabled schedule should not be the same value by
    /// coincidence.
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
/// `paused > failure-recent > waiting > manual-ideating > working >
/// success-recent > chat-ideating > scheduled-sleep > idle/strolling > offline`
///
/// Chat-ideating additionally applies only to a provider with **no live
/// session at all**; see the comment at its rung.
///
/// Manual ideating moved above `working` on 2026-08-09 (owner decision). It is
/// an explicit user action, and below `working` it was unreachable in practice:
/// any live agent session outranked it, so the menu toggle did nothing at
/// exactly the moment someone was most likely to be watching the pet. It stays
/// below `waiting` and `failure` on purpose — both of those need the user, and a
/// standing preference must not hide something that is asking for attention.
///
/// **Chat-ideating is a second, weaker ideating rung, added 2026-08-11.** A
/// frontmost chat app is evidence that the user is thinking, but far weaker
/// evidence than the menu toggle: it cannot tell composing a prompt from
/// re-reading last week's conversation. So it sits *below* `working`, where
/// manual ideating deliberately does not — switching to the Claude app while an
/// agent is grinding must keep showing the real work rather than a guess about
/// the user. It sits below the success reaction so a completed turn still gets
/// its fist pump, and above scheduled sleep because someone actively using a
/// chat app at 02:00 is awake, and the documented rule is that ideating
/// interrupts sleep.
///
/// The reducer reads no clock of its own. Callers pass the wall clock (for the
/// local sleep window) and the monotonic instant (for reaction and expiry
/// windows) separately, because the two must not be conflated.
public struct MascotStateReducer: Sendable {
    /// `nil` disables scheduled sleep entirely: the mascot then strolls at 03:00
    /// exactly as it does at noon.
    ///
    /// Optional rather than a `Bool` beside the hours, so "no schedule" cannot
    /// be confused with "a schedule that happens to be empty", and so a disabled
    /// schedule has no stale hours to misread.
    public var sleepWindow: SleepWindow?
    public var calendar: Calendar

    public init(sleepWindow: SleepWindow? = SleepWindow(), calendar: Calendar = .current) {
        self.sleepWindow = sleepWindow
        self.calendar = calendar
    }

    public func reduce(
        sessions: [AgentSession],
        overrides: ManualOverrides = .none,
        chat: ChatPresence = .none,
        now: Date,
        uptime: Uptime
    ) -> MascotVisibleState {
        // A stopped session is retained only so its reaction can finish; it is no
        // longer present, so it must not hold the mascot in idle instead of offline.
        let present = sessions.filter { $0.activity != .stopped }
        let presentProviders = Self.providers(of: present)

        // Above pause on purpose; see `ManualOverrides.preview`. No provider is
        // reported, because none asserted this state.
        if let preview = overrides.preview {
            return MascotVisibleState(state: preview)
        }

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

        if overrides.isIdeating {
            // Manual ideating has no originating session, so it surfaces no provider.
            return MascotVisibleState(state: .ideating)
        }

        // Sitting at a computer means an agent is doing work at a command line.
        // A turn driven from a desktop app's chat interface is a conversation,
        // and it drops to the chat-ideating rung below — owner rule, 2026-08-11:
        // "ChatGPT's chat interface thinks like Claude chat; Codex and the
        // terminal type."
        //
        // This distinction exists only because the ChatGPT desktop app *is* the
        // Codex app, so both arrive as the same hook events from the same
        // provider. `EventSurface` is what tells them apart, decided in the hook
        // helper from its own process ancestry.
        let working = sessions.filter { $0.activity == .working && $0.surface != .desktopChat }
        if !working.isEmpty {
            return MascotVisibleState(state: .working, providers: Self.providers(of: working))
        }

        let succeeding = sessions.filter { Self.hasLiveReaction($0, kind: .success, at: uptime) }
        if !succeeding.isEmpty {
            return MascotVisibleState(state: .success, providers: Self.providers(of: succeeding))
        }

        // Weaker than every signal above, including the success reaction: a
        // frontmost chat app says the user is probably thinking, not that any
        // agent reported anything. It reports the provider it came from, because
        // unlike manual ideating it is attributable — the Claude app drives the
        // Claude mascot.
        //
        // **A provider with any live session ignores this signal entirely**, not
        // merely ranks it lower. The Claude desktop app hosts both the chat and
        // Claude Code behind one bundle identifier, so being frontmost cannot
        // distinguish "asking a question" from "watching an agent between
        // turns" — and no signal inside this project's privacy line can, since
        // telling them apart means reading window contents. When hooks are
        // reporting sessions for a provider, that provider's agent is the
        // authority and the guess stands down; the pet strolls or idles as it
        // did before this feature existed. Sessions expire on the ordinary
        // timeout, so quitting the agent restores the chat behavior by itself.
        //
        // Owner clarification, 2026-08-11. Ranking alone was not enough: it
        // covered a *running* turn and left the quiet gaps between turns showing
        // a Thinker pose at someone who was not chatting.
        // **No blanket suppression by live session, deliberately, and this
        // reversed once.** While the signal was "a chat app is frontmost", a
        // provider with any session had to ignore it: the Claude desktop app
        // hosts the chat and Claude Code behind one bundle identifier, so
        // frontmost could not tell "asking a question" from "watching an agent
        // between turns". Since 2026-08-11 the signal is the chat window's own
        // streaming marker, which is a fact rather than an inference — there is
        // nothing left to be ambiguous about, and suppressing it made the
        // feature unreachable for anyone who uses Claude Code at all, which is
        // everyone this app is for. Ordering alone now does the work: a
        // *working* agent still outranks a generating chat, an idle session no
        // longer blocks it.
        let finishedChat = chat.providers(doing: .completed)
        if !finishedChat.isEmpty {
            return MascotVisibleState(
                state: .success,
                providers: finishedChat.sorted { $0.rawValue < $1.rawValue }
            )
        }

        // An agent turn driven from a desktop app's chat joins this rung rather
        // than the working one above. It is a stronger signal than a read window
        // — a hook actually fired — but it describes the same activity the chat
        // rung is for, and sharing the rung is what makes a terminal Codex run
        // win when both are happening at once.
        let chattingInApp = Set(
            sessions.filter { $0.activity == .working && $0.surface == .desktopChat }.map(\.provider)
        )
        let generatingChat = chat.providers(doing: .generating).union(chattingInApp)
        if !generatingChat.isEmpty {
            return MascotVisibleState(
                state: .ideating,
                providers: generatingChat.sorted { $0.rawValue < $1.rawValue }
            )
        }

        // `.open` intentionally falls through to whatever comes next — sleep,
        // strolling, or offline. A chat app merely being in front is not an
        // animation; see `ChatPresence.Activity`.

        // Any work, ideating, or waiting above already interrupted sleep. Reaching
        // here inside the window means the last turn's reaction has finished, so
        // the mascot goes back to sleep.
        if let sleepWindow, sleepWindow.contains(hour: calendar.component(.hour, from: now)) {
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
        chat: ChatPresence = .none,
        now: Date,
        uptime: Uptime
    ) -> MascotVisibleState {
        reduce(
            sessions: registry.sessions(at: uptime),
            overrides: overrides,
            chat: chat,
            now: now,
            uptime: uptime
        )
    }

    /// Reduces the state of one provider's mascot, ignoring every other
    /// provider's sessions.
    ///
    /// Since 2026-08-01 the owner can summon one mascot per provider, so a
    /// second reduction exists alongside the collapsed one above. This is
    /// deliberately the *same* priority ladder applied to a narrower session
    /// list rather than a parallel implementation: a provider-specific ordering
    /// would be a second source of truth about what the pet is doing.
    ///
    /// A provider with no sessions reduces to `offline`, which strolls. That is
    /// the intended "normal" look for the mascot whose agent is not running —
    /// it stays on screen and ambient rather than freezing or vanishing.
    ///
    /// Manual overrides are not per provider. Pause, ideating, and preview are
    /// owner actions aimed at the app as a whole, so they reach both mascots.
    public func reduce(
        sessions: [AgentSession],
        attributedTo provider: EventProvider,
        overrides: ManualOverrides = .none,
        chat: ChatPresence = .none,
        now: Date,
        uptime: Uptime
    ) -> MascotVisibleState {
        // The chat signal is narrowed the same way the sessions are: the Claude
        // app must not make the Codex mascot think. Manual overrides stay
        // app-wide, which is the documented split, not an oversight here.
        reduce(
            sessions: sessions.filter { $0.provider == provider },
            overrides: overrides,
            chat: ChatPresence(activities: chat.activities.filter { $0.key == provider }),
            now: now,
            uptime: uptime
        )
    }

    /// Convenience overload so callers hold a registry rather than a snapshot.
    public func reduce(
        registry: SessionRegistry,
        attributedTo provider: EventProvider,
        overrides: ManualOverrides = .none,
        chat: ChatPresence = .none,
        now: Date,
        uptime: Uptime
    ) -> MascotVisibleState {
        reduce(
            sessions: registry.sessions(at: uptime),
            attributedTo: provider,
            overrides: overrides,
            chat: chat,
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
