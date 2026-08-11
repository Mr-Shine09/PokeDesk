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

    /// The accessibility description Claude gives the message it is currently
    /// producing.
    ///
    /// **This is an English UI string in an app that ships often, with no
    /// stability guarantee of any kind.** When it changes, detection stops dead
    /// and the pet goes quiet during chats — which is why `diagnostic` exists
    /// and why the marker is a single named constant rather than a literal
    /// buried in a walk. Verified against Claude on 2026-08-11.
    /// `nonisolated` because the tree walk runs outside the actor.
    nonisolated static let streamingMarker = "Currently streaming message"

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

    private var observer: AXObserver?
    private var observedPID: pid_t?
    private var workspaceObservers: [any NSObjectProtocol] = []
    private var lastSearch: Date = .distantPast
    private var pendingSearch: Task<Void, Never>?
    private var completionTask: Task<Void, Never>?
    private var recheckTimer: Timer?
    private var isEnabled: Bool
    private var isGenerating = false

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
            detach()
            presence = .none
            diagnostic = nil
        }
    }

    // MARK: - Attaching

    private var claudeApp: NSRunningApplication? {
        NSWorkspace.shared.runningApplications.first {
            $0.bundleIdentifier == "com.anthropic.claudefordesktop"
        }
    }

    private func attachIfPossible() {
        guard isEnabled else { return }
        guard AXIsProcessTrusted() else {
            diagnostic = "Accessibility access is not granted, so chat activity cannot be read."
            detach()
            presence = .none
            return
        }
        guard let app = claudeApp else {
            diagnostic = nil
            detach()
            presence = .none
            return
        }
        guard observedPID != app.processIdentifier else { return }

        detach()
        var created: AXObserver?
        let callback: AXObserverCallback = { _, _, _, context in
            guard let context else { return }
            let watcher = Unmanaged<ChatActivityWatcher>.fromOpaque(context).takeUnretainedValue()
            MainActor.assumeIsolated { watcher.scheduleSearch() }
        }
        guard
            AXObserverCreate(app.processIdentifier, callback, &created) == .success,
            let created
        else {
            diagnostic = "Could not observe the Claude app for changes."
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
        observer = created
        observedPID = app.processIdentifier
        diagnostic = nil
        scheduleSearch()
    }

    private func detach() {
        if let observer {
            CFRunLoopRemoveSource(
                CFRunLoopGetCurrent(),
                AXObserverGetRunLoopSource(observer),
                .defaultMode
            )
        }
        observer = nil
        observedPID = nil
        recheckTimer?.invalidate()
        recheckTimer = nil
        pendingSearch?.cancel()
        pendingSearch = nil
    }

    // MARK: - Searching

    private func scheduleSearch() {
        guard isEnabled, pendingSearch == nil else { return }
        let elapsed = Date().timeIntervalSince(lastSearch)
        let delay = max(0, Self.minimumSearchInterval - elapsed)
        pendingSearch = Task { [weak self] in
            if delay > 0 { try? await Task.sleep(for: .seconds(delay)) }
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self?.pendingSearch = nil
                self?.search()
            }
        }
    }

    private func search() {
        guard isEnabled, let app = claudeApp else { return }
        lastSearch = Date()

        let root = AXUIElementCreateApplication(app.processIdentifier)
        let streaming = Self.containsStreamingMarker(root, depth: 0)

        if streaming {
            completionTask?.cancel()
            completionTask = nil
            isGenerating = true
            presence = ChatPresence(activities: [.claudeCode: .generating])
            startRecheckTimer()
        } else if isGenerating {
            isGenerating = false
            recheckTimer?.invalidate()
            recheckTimer = nil
            holdCompletion()
        } else if presence.activities[.claudeCode] == nil {
            presence = ChatPresence(activities: [.claudeCode: .open])
        }
    }

    /// While a response streams the app emits layout changes constantly, but the
    /// change that *ends* the stream is the last one — nothing arrives
    /// afterwards to prompt the look that would notice. Hence a slow timer, live
    /// only during generation, which is the one window where polling is honest
    /// work rather than idle cost.
    private func startRecheckTimer() {
        guard recheckTimer == nil else { return }
        let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.scheduleSearch() }
        }
        RunLoop.main.add(timer, forMode: .common)
        recheckTimer = timer
    }

    private func holdCompletion() {
        presence = ChatPresence(activities: [.claudeCode: .completed])
        completionTask?.cancel()
        completionTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(Self.completionHold))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self?.completionTask = nil
                self?.presence = ChatPresence(activities: [.claudeCode: .open])
            }
        }
    }

    /// Depth-first, stopping at the first match.
    ///
    /// Only `AXRole`, `AXSubrole`, `AXDescription`, and `AXChildren` are ever
    /// fetched. Adding `AXTitle` or `AXValue` here would start reading the
    /// conversation; see this type's documentation for why that is not a
    /// tightening but a different program.
    private nonisolated static func containsStreamingMarker(
        _ element: AXUIElement,
        depth: Int
    ) -> Bool {
        guard depth < maximumDepth else { return false }

        if copyString(element, kAXSubroleAttribute) == "AXDocumentArticle",
           copyString(element, kAXDescriptionAttribute) == streamingMarker {
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

        for child in children where containsStreamingMarker(child, depth: depth + 1) {
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
