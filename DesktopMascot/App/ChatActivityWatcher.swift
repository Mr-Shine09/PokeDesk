import AppKit
import ApplicationServices
import Combine
import MascotCore

/// Reports whether a chat app is currently producing a response, by looking for
/// one accessibility element and reading one attribute on it.
///
/// **This crosses a line the project held from its first session** — "no
/// accessibility permissions" was a promise in `README.md` — and it is an
/// explicit owner decision of 2026-08-11, taken after the alternative was laid
/// out: the frontmost-app signal cannot see a response start or finish, so the
/// lifecycle the owner wanted was unreachable without reading the chat window.
/// It is recorded as a reversal of a founding principle rather than as a
/// feature. Two consequences follow, and both are honored below: read the
/// **minimum** that answers the question, and make the failure **visible**.
///
/// ## What is read
///
/// While walking, the only attributes fetched are `AXRole`, `AXSubrole`,
/// `AXDescription`, and `AXChildren`. **No title, no value, no text.** The
/// marker is an `AXGroup` with subrole `AXDocumentArticle` whose description is
/// exactly `Currently streaming message`; the same element reads `Message 10 of
/// 10` once the response lands. Nothing about the conversation's content, the
/// user's prompt, or the model's answer is fetched, kept, or logged.
///
/// The restraint is not theoretical. The diagnostic probe that discovered this
/// marker collected control *titles*, on the assumption that a control label is
/// interface structure rather than content — and Claude puts a summary of the
/// conversation in a button title, so a description of what the owner was
/// discussing landed in a file. **Titles are content here. Do not read them.**
///
/// ## How it is checked
///
/// An `AXObserver` on the Claude process reports layout changes, which fire
/// constantly while a response streams and almost never otherwise, so the cost
/// tracks the app's activity instead of the clock. Each notification triggers a
/// bounded search, throttled to at most one per `minimumSearchInterval`. While a
/// response is believed to be in flight, a slow timer re-checks, because the
/// *last* layout change is the one that says it finished and there is nothing
/// after it to prompt another look.
@MainActor
final class ChatActivityWatcher: ObservableObject {
    @Published private(set) var presence: ChatPresence = .none

    /// Why detection is not working, in words a person can act on, or `nil` when
    /// it is. Surfaced in the menu because the failure mode of a UI-string match
    /// is silence: the pet simply never thinks, and nothing says why.
    @Published private(set) var diagnostic: String?

    /// The apps this watcher can drive a mascot from: those whose streaming
    /// marker has actually been captured. An app with no marker is probe-only
    /// and is skipped here rather than watched with a guess.
    ///
    /// **These markers are English UI strings in apps that ship often, with no
    /// stability guarantee of any kind.** When one changes, detection stops dead
    /// and that pet goes quiet during chats — which is why `diagnostic` exists,
    /// and why a marker is a named constant on `ChatApp.Descriptor` rather than
    /// a literal buried in a walk.
    private var watched: [ChatApp.Descriptor] { ChatApp.watchable }

    /// Ceiling on how often the tree is walked. Streaming fires layout changes
    /// far faster than this, and the pose does not need sub-second accuracy.
    private static let minimumSearchInterval: TimeInterval = 0.75

    /// How long `completed` is held so the success reaction has time to play.
    /// Matches the 3 s hook-driven success window so both look the same.
    private static let completionHold: TimeInterval = 3.0

    /// Depth cap for the search. Generous because Electron nests roughly fifteen
    /// `AXGroup` levels before any content — an earlier cap of 18 truncated the
    /// tree just above the conversation and made a populated app look empty.
    nonisolated static let maximumDepth = 60

    /// Everything is keyed by provider, because two chat apps can be running and
    /// generating at once and each drives its own mascot. A single shared
    /// `isGenerating` would let ChatGPT finishing a response clear the pose
    /// Claude was still producing.
    private var observers: [EventProvider: AXObserver] = [:]
    private var observedPIDs: [EventProvider: pid_t] = [:]
    /// Which app each observer belongs to. An `AXObserver` callback reports the
    /// observer, not the application, and passing a per-app context would mean
    /// retaining a box per app; this lookup is cheaper and has no ownership.
    private var observerProviders: [ObjectIdentifier: EventProvider] = [:]
    private var lastSearch: [EventProvider: Date] = [:]
    private var pendingSearch: [EventProvider: Task<Void, Never>] = [:]
    private var completionTask: [EventProvider: Task<Void, Never>] = [:]
    private var recheckTimer: [EventProvider: Timer] = [:]
    private var generating: Set<EventProvider> = []
    private var activities: [EventProvider: ChatPresence.Activity] = [:]
    private var workspaceObservers: [any NSObjectProtocol] = []
    private var isEnabled: Bool

    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
        for name in [
            NSWorkspace.didLaunchApplicationNotification,
            NSWorkspace.didTerminateApplicationNotification,
            NSWorkspace.didActivateApplicationNotification,
        ] {
            let token = NSWorkspace.shared.notificationCenter.addObserver(
                forName: name, object: nil, queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated { self?.attachIfPossible() }
            }
            workspaceObservers.append(token)
        }
        attachIfPossible()
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if enabled {
            attachIfPossible()
        } else {
            detachAll()
            activities = [:]
            presence = .none
            diagnostic = nil
        }
    }

    // MARK: - Attaching

    private func runningApp(for descriptor: ChatApp.Descriptor) -> NSRunningApplication? {
        NSWorkspace.shared.runningApplications.first {
            $0.bundleIdentifier == descriptor.bundleIdentifier
        }
    }

    private func attachIfPossible() {
        guard isEnabled else { return }
        guard AXIsProcessTrusted() else {
            diagnostic = "Accessibility access is not granted, so chat activity cannot be read."
            detachAll()
            activities = [:]
            publish()
            return
        }
        diagnostic = nil
        for descriptor in watched {
            attach(descriptor)
        }
    }

    private func attach(_ descriptor: ChatApp.Descriptor) {
        let provider = descriptor.provider
        guard let app = runningApp(for: descriptor) else {
            detach(provider)
            activities[provider] = nil
            publish()
            return
        }
        guard observedPIDs[provider] != app.processIdentifier else { return }

        detach(provider)
        var created: AXObserver?
        let callback: AXObserverCallback = { observer, _, _, context in
            guard let context else { return }
            let watcher = Unmanaged<ChatActivityWatcher>.fromOpaque(context).takeUnretainedValue()
            MainActor.assumeIsolated {
                guard let provider = watcher.observerProviders[ObjectIdentifier(observer)] else {
                    return
                }
                watcher.scheduleSearch(for: provider)
            }
        }
        guard
            AXObserverCreate(app.processIdentifier, callback, &created) == .success,
            let created
        else {
            diagnostic = "Could not observe the \(descriptor.displayName) app for changes."
            return
        }

        let element = AXUIElementCreateApplication(app.processIdentifier)
        let context = Unmanaged.passUnretained(self).toOpaque()
        // Layout changes cover streaming text; the created/destroyed pair covers
        // the article element itself appearing and going away.
        for notification in [
            kAXLayoutChangedNotification,
            kAXCreatedNotification,
            kAXUIElementDestroyedNotification,
        ] {
            AXObserverAddNotification(created, element, notification as CFString, context)
        }
        CFRunLoopAddSource(
            CFRunLoopGetCurrent(),
            AXObserverGetRunLoopSource(created),
            .defaultMode
        )
        observers[provider] = created
        observerProviders[ObjectIdentifier(created)] = provider
        observedPIDs[provider] = app.processIdentifier
        scheduleSearch(for: provider)
    }

    private func detach(_ provider: EventProvider) {
        if let observer = observers[provider] {
            CFRunLoopRemoveSource(
                CFRunLoopGetCurrent(),
                AXObserverGetRunLoopSource(observer),
                .defaultMode
            )
            observerProviders[ObjectIdentifier(observer)] = nil
        }
        observers[provider] = nil
        observedPIDs[provider] = nil
        recheckTimer[provider]?.invalidate()
        recheckTimer[provider] = nil
        pendingSearch[provider]?.cancel()
        pendingSearch[provider] = nil
        completionTask[provider]?.cancel()
        completionTask[provider] = nil
        generating.remove(provider)
    }

    private func detachAll() {
        // Snapshotted deliberately: `detach` mutates `observers`, and iterating
        // a dictionary's keys while removing from it relies on copy-on-write
        // subtleties that should not be load-bearing.
        for provider in Array(observers.keys) { detach(provider) }
    }

    private func publish() {
        presence = ChatPresence(activities: activities)
    }

    // MARK: - Searching

    private func scheduleSearch(for provider: EventProvider) {
        guard isEnabled, pendingSearch[provider] == nil else { return }
        let elapsed = Date().timeIntervalSince(lastSearch[provider] ?? .distantPast)
        let delay = max(0, Self.minimumSearchInterval - elapsed)
        pendingSearch[provider] = Task { [weak self] in
            if delay > 0 { try? await Task.sleep(for: .seconds(delay)) }
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self?.pendingSearch[provider] = nil
                self?.search(provider)
            }
        }
    }

    private func search(_ provider: EventProvider) {
        guard
            isEnabled,
            let descriptor = watched.first(where: { $0.provider == provider }),
            let marker = descriptor.streamingMarker,
            let app = runningApp(for: descriptor)
        else { return }
        lastSearch[provider] = Date()

        let root = AXUIElementCreateApplication(app.processIdentifier)
        let streaming = Self.containsStreamingMarker(
            root, marker: marker, subrole: descriptor.streamingSubrole, depth: 0
        )

        if streaming {
            completionTask[provider]?.cancel()
            completionTask[provider] = nil
            generating.insert(provider)
            activities[provider] = .generating
            publish()
            startRecheckTimer(for: provider)
        } else if generating.contains(provider) {
            generating.remove(provider)
            recheckTimer[provider]?.invalidate()
            recheckTimer[provider] = nil
            holdCompletion(for: provider)
        } else if activities[provider] == nil {
            activities[provider] = .open
            publish()
        }
    }

    /// While a response streams the app emits layout changes constantly, but the
    /// change that *ends* the stream is the last one — nothing arrives
    /// afterwards to prompt the look that would notice. Hence a slow timer, live
    /// only during generation, which is the one window where polling is honest
    /// work rather than idle cost.
    private func startRecheckTimer(for provider: EventProvider) {
        guard recheckTimer[provider] == nil else { return }
        let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.scheduleSearch(for: provider) }
        }
        RunLoop.main.add(timer, forMode: .common)
        recheckTimer[provider] = timer
    }

    private func holdCompletion(for provider: EventProvider) {
        activities[provider] = .completed
        publish()
        completionTask[provider]?.cancel()
        completionTask[provider] = Task { [weak self] in
            try? await Task.sleep(for: .seconds(Self.completionHold))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard let self else { return }
                self.completionTask[provider] = nil
                self.activities[provider] = .open
                self.publish()
                self.refreshObserver(for: provider)
            }
        }
    }

    /// Re-registers the observer once a response has ended.
    ///
    /// **Found 2026-08-12: detection fired for a conversation's first response
    /// and never again.** Question 1 in a fresh chat posed and reported
    /// `generating`; every later question in the same chat reported `open and
    /// quiet` with no pose. The marker was *present* for those later questions —
    /// a probe run mid-stream found `Currently streaming message` on the same
    /// runs this watcher called quiet, and correctly found it absent in a
    /// settled baseline — and it sat at the same depth every time, so the cap
    /// was not truncating it. Toggling the feature off and on mid-stream
    /// restored the pose immediately, and toggling is a detach followed by an
    /// attach. **The tree was always findable; the callbacks had stopped
    /// arriving.**
    ///
    /// Re-registering at the moment a stream ends is the narrowest repair that
    /// matches that evidence: it is the exact boundary the failure appears at,
    /// and it is one registration per response rather than a timer. **Do not
    /// replace this with an idle poll.** A poll would hide the cause and restore
    /// the continuous cost this observer exists to avoid — the design's argument
    /// is that the work tracks the app's activity instead of the clock.
    ///
    /// This runs after the completion hold rather than when generation stops,
    /// because `detach` cancels `completionTask`; re-attaching any earlier would
    /// cut the hold short and take the success reaction with it.
    private func refreshObserver(for provider: EventProvider) {
        guard
            isEnabled,
            let descriptor = watched.first(where: { $0.provider == provider })
        else { return }
        detach(provider)
        attach(descriptor)
    }

    /// Depth-first, stopping at the first match.
    ///
    /// Only `AXRole`, `AXSubrole`, `AXDescription`, and `AXChildren` are ever
    /// fetched. Adding `AXTitle` or `AXValue` here would start reading the
    /// conversation; see this type's documentation for why that is not a
    /// tightening but a different program.
    private nonisolated static func containsStreamingMarker(
        _ element: AXUIElement,
        marker: String,
        subrole: String?,
        depth: Int
    ) -> Bool {
        guard depth < maximumDepth else { return false }

        if copyString(element, kAXDescriptionAttribute) == marker,
           subrole == nil || copyString(element, kAXSubroleAttribute) == subrole {
            return true
        }
        // The menu bar cannot contain a streaming message and is large.
        if depth <= 1, copyString(element, kAXRoleAttribute) == "AXMenuBar" {
            return false
        }

        var childrenValue: CFTypeRef?
        guard
            AXUIElementCopyAttributeValue(
                element, kAXChildrenAttribute as CFString, &childrenValue
            ) == .success,
            let children = childrenValue as? [AXUIElement]
        else { return false }

        for child in children
        where containsStreamingMarker(child, marker: marker, subrole: subrole, depth: depth + 1) {
            return true
        }
        return false
    }

    private nonisolated static func copyString(
        _ element: AXUIElement,
        _ attribute: String
    ) -> String? {
        var value: CFTypeRef?
        guard
            AXUIElementCopyAttributeValue(element, attribute as CFString, &value) == .success
        else { return nil }
        return value as? String
    }
}
