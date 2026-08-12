import AppKit
import Combine
import MascotAnimation
import MascotCore
import MascotTransport
import MascotWindow
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @Published private(set) var diagnostics = "Starting"
    /// Which providers' mascots are currently summoned.
    ///
    /// Owner decision, 2026-07-30: launching the app must not put a pet on the
    /// screen. The app is a menu-bar accessory first, and the mascot is
    /// something the user calls for — so launch leaves the menu-bar item ready
    /// and nothing else. There is deliberately no launch-at-login either.
    ///
    /// Owner decision, 2026-08-01: presence is per mascot. Summoning Claude's
    /// mascot must not bring Codex's along, and neither appears on its own when
    /// a provider is detected — that would break the rule above.
    @Published private(set) var summoned: Set<EventProvider> = []

    /// True while any mascot is on screen. Menu items and diagnostics that are
    /// about the app rather than one pet read this.
    var isVisible: Bool { !summoned.isEmpty }
    @Published var isPaused = false
    @Published var isIdeating = false
    /// Whether each provider's mascot strolls, restored from preferences so a
    /// deliberate choice survives relaunch.
    ///
    /// Per mascot since 2026-08-11: the owner reported that switching one pet
    /// to Stay in One Place stopped both. Presence and placement were already
    /// per mascot, so an app-wide roaming flag was the odd one out — unlike
    /// Pause and Manual Ideating, which are aimed at the app on purpose.
    @Published var roamingByProvider: [EventProvider: Bool] = Dictionary(
        uniqueKeysWithValues: EventProvider.allCases.map { ($0, Preferences.roaming(for: $0)) }
    )

    func isRoaming(_ provider: EventProvider) -> Bool {
        roamingByProvider[provider] ?? true
    }
    /// Whether a Claude chat producing a response drives its mascot's ideating
    /// pose. Named for the frontmost-app signal it used to gate; see
    /// `Preferences.chatAppsDriveIdeating`.
    @Published private(set) var chatAppsDriveIdeating = Preferences.chatAppsDriveIdeating
    /// The nightly sleep window, or `nil` when scheduled sleep is off.
    /// Restored from preferences, like roaming.
    @Published private(set) var sleepWindow = Preferences.sleepWindow
    /// Forces one animation for inspection. Never persisted: it is a testing
    /// mode, and finding the pet stuck in a fake state after a relaunch with no
    /// memory of choosing it would be its own bug.
    @Published private(set) var previewState: MascotState?

    /// Listens for provider lifecycle events, reduces them, and is the single
    /// source of the mascot's visible state — manual pause and ideating included,
    /// since those reach the reducer as overrides.
    let eventBridge = AgentEventBridge()
    /// Reports whether a chat app is frontmost. Created at launch rather than
    /// lazily, so the very first reduction already knows the answer.
    private var chatActivityWatcher: ChatActivityWatcher?
    private var chatObservation: AnyCancellable?

    /// The menu bar item, owned here rather than created by a SwiftUI
    /// `MenuBarExtra`.
    ///
    /// `MenuBarExtra` derives its own autosave name (`CC Item-0` here) and
    /// obeys the visibility macOS has remembered for it. On 2026-08-03 that
    /// made the app unusable: the item had been dragged off the menu bar at
    /// some point, so Control Center sent `NSStatusItemChangeVisibilityAction`
    /// on every launch, and because the `MenuBarExtra` was the app's only scene
    /// SwiftUI terminated the process about a tenth of a second in. The app
    /// could not be launched, controlled, or quit, and wrote no crash report.
    /// Pinning `isInserted` to `true` kept the process alive but did not bring
    /// the icon back — Control Center's hide still won.
    ///
    /// Owning the item fixes the fatal half: the app stays alive and keeps a
    /// menu, because nothing can delete its only scene. The menu itself is
    /// still the same SwiftUI `MenuBarContent`, rendered through
    /// `NSHostingMenu`, so nothing about the menu's contents changed.
    ///
    /// It does **not** restore an icon macOS has already been told to remove.
    /// That was established on 2026-08-03 by building this exact binary twice,
    /// changing only `PRODUCT_BUNDLE_IDENTIFIER`: under a fresh identifier the
    /// pawprint appears, under `com.mrshine09.desktopmascot` it never does —
    /// with the preferences domain emptied and `isVisible` true either way. The
    /// removal is held in a system store keyed to the **bundle identifier**,
    /// outside the app's own preferences, and no `autosaveName` escapes it.
    /// Renaming the autosave, deleting the persisted keys, restarting
    /// `cfprefsd` and `ControlCenter`, dropping `NSHostingMenu` for a plain
    /// `NSMenu`, and moving off the SwiftUI entry point were all tried and all
    /// made no difference to the icon.
    ///
    /// The identifier was therefore changed to `com.mrshine09.dockpet` on
    /// 2026-08-05 (owner decision), which is the only thing proven to bring the
    /// icon back. Owning the item still matters and must stay: it is what keeps
    /// a future stray Command-drag from making the app terminate itself again.
    private var statusItem: NSStatusItem?

    /// Mirrors the player's own persisted setting so the menu can bind to it.
    @Published var isMuted = Preferences.soundsMuted

    private let sounds = MascotSoundPlayer()
    /// Set once Quit has been asked for, so the transition cannot be cancelled
    /// by a summon and the app cannot be left running after asking to stop.
    private var isQuitting = false
    /// One mascot per provider, in menu order. Empty only if resource loading
    /// failed, in which case `diagnostics` carries the reason.
    private(set) var mascots: [MascotInstance] = []
    private var visibleStateObserver: AnyCancellable?
    /// Result of the last experimental accessibility probe. Published so the
    /// menu reflects it without an alert; temporary, like the probe itself.
    @Published private(set) var lastProbeResult = ""

    /// Deliberately reports what the **watcher believes**, not merely whether
    /// the permission exists.
    ///
    /// The first version of this line said only "granted", which is exactly as
    /// useful as silence when the pose fails to appear: it cannot distinguish a
    /// marker that has been renamed by an app update, an observer that never
    /// attached, and a signal that arrived and was outranked. A UI-string match
    /// fails silently by nature, so the diagnostic has to be specific.
    /// One line per watchable app, so a second provider cannot hide behind the
    /// first. An app with no captured marker is not listed: it is not being
    /// watched, and a status line for it would imply otherwise.
    var accessibilityStatus: String {
        guard ChatAccessibilityProbe.isTrusted else { return "Accessibility: not granted" }
        if let diagnostic = chatActivityWatcher?.diagnostic { return diagnostic }
        return ChatApp.watchable
            .map { descriptor in
                let events = chatActivityWatcher?.callbackCount[descriptor.provider] ?? 0
                let state = switch chatActivityWatcher?.presence.activities[descriptor.provider] {
                case .generating: "generating"
                case .completed: "just finished"
                case .open: "open and quiet"
                case nil: "app not running"
                }
                // The event count is what tells a quiet detector apart from a
                // deaf one: a state that never leaves "open and quiet" while
                // this number climbs means the search is running and missing,
                // and a number that stops climbing means the callbacks stopped.
                return "\(descriptor.displayName) chat: \(state) · \(events) events"
            }
            .joined(separator: "\n")
    }

    func requestAccessibilityAccess() {
        ChatAccessibilityProbe.requestAccess()
    }

    func writeChatAccessibilityReport(for target: ChatApp.Descriptor) {
        lastProbeResult = ChatAccessibilityProbe.writeReport(for: target)
    }

    private func mascot(for provider: EventProvider) -> MascotInstance? {
        mascots.first { $0.provider == provider }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        // The restored schedule has to reach the reducer before the first
        // reduction. Without this the saved window lives only in the menu's
        // checkmarks while the pet keeps the built-in 23:00–06:00 — a setting
        // that appears to work until the app is relaunched.
        eventBridge.sleepWindow = sleepWindow
        // Same rule the sleep window follows: an input to the reduction has to
        // reach the bridge before `start()`, or it lives only in the menu's
        // checkmark and the pet never acts on it.
        // `ChatActivityWatcher` replaced `ChatAppObserver` on 2026-08-11: a
        // frontmost chat app turned out to be the wrong question, since it
        // cannot see a response begin or end and the pose it produced ran
        // continuously while the user was merely reading.
        let watcher = ChatActivityWatcher(isEnabled: chatAppsDriveIdeating)
        chatActivityWatcher = watcher
        chatObservation = watcher.$presence.sink { [weak self] presence in
            self?.eventBridge.chat = presence
        }
        // Started before the mascot loads so a resource failure below still
        // leaves the event path diagnosable from the menu bar.
        eventBridge.start()
        do {
            let resources = try AppResources.load()
            let contractData = try Data(contentsOf: resources.contractURL)
            let contract = try JSONDecoder().decode(AtlasContract.self, from: contractData)
            let atlas = try SpriteAtlas(imageURL: resources.atlasURL, contract: contract)
            let orangeAtlas = try SpriteAtlas(imageURL: resources.orangeAtlasURL, contract: contract)
            let atlases: [MascotFashion: SpriteAtlas] = [.classic: atlas, .orange: orangeAtlas]

            // One mascot per provider, each offset along the default lane so a
            // pair summoned together arrives side by side rather than stacked.
            for (index, provider) in EventProvider.allCases.enumerated() {
                let fashion = MascotFashion.worn(by: provider)
                guard let atlas = atlases[fashion] else { throw SpriteAtlasError.unreadableImage }
                let mascot = try MascotInstance(
                    provider: provider,
                    atlas: atlas,
                    laneOffset: CGFloat(index) * MascotPanel.defaultContentSize.width
                )
                wire(mascot)
                // The restored roaming choice has to reach the animation
                // controller, not just the menu's checkmark. Without this a pet
                // saved as Stay in One Place strolls again after a relaunch
                // while the menu insists it is stationary — the same shape of
                // bug the sleep schedule avoided by pushing its window into the
                // bridge before `start()`.
                mascot.setRoaming(isRoaming(provider))
                mascots.append(mascot)
            }

            // Each mascot animates from its own provider's reduced state.
            // Nothing else may select a row, so manual pause and ideating go
            // through the reducer's overrides rather than around it.
            visibleStateObserver = eventBridge.$visibleStates
                .sink { [weak self] states in
                    guard let self else { return }
                    for mascot in self.mascots {
                        guard let state = states[mascot.provider] else { continue }
                        mascot.animationController.setVisibleState(state)
                    }
                    self.refreshDiagnostics()
                }
            installStatusItem()
            // Deliberately no summon here: launching is not summoning. Every
            // panel stays ordered out with its animation timer stopped, so an
            // unsummoned Dock Pet costs nothing but the menu-bar item.
            refreshDiagnostics()
        } catch {
            diagnostics = error.localizedDescription
        }
    }

    /// Builds the menu bar item. See `statusItem` for why the app owns this
    /// rather than declaring a `MenuBarExtra` scene.
    private func installStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        // A name of our own choosing, so the item's visibility is a property
        // this app sets rather than one macOS restores. Note that renaming does
        // NOT escape a menu bar removal: that state is keyed to the bundle
        // identifier, not to the autosave name. See `statusItem`.
        item.autosaveName = "DockPetMenuBarItem"
        item.button?.image = NSImage(
            systemSymbolName: "pawprint.fill",
            accessibilityDescription: "Dock Pet"
        )
        item.menu = NSHostingMenu(
            rootView: MenuBarContent(appDelegate: self, eventBridge: eventBridge)
        )
        // Set last and unconditionally: this item is the app's only escape
        // hatch, so it is never allowed to stay hidden.
        item.isVisible = true
        statusItem = item
    }

    /// Connects one mascot's panel and animation callbacks back to the app.
    private func wire(_ mascot: MascotInstance) {
        mascot.windowCoordinator.panel.onClick = { [weak self, weak mascot] in
            guard let mascot else { return }
            self?.showMascotMenu(for: mascot)
        }
        mascot.windowCoordinator.panel.onDragBegan = { [weak self, weak mascot] in
            mascot?.animationController.userDidBeginDrag()
            self?.diagnostics = "Dragging \(mascot?.displayName ?? "mascot") — hanging pose"
        }
        // A drop no longer switches roaming off. Dragging places the mascot;
        // whether it walks afterwards stays the user's separate choice, made
        // in the menu. See `userDidEndDrag()` for why.
        mascot.windowCoordinator.panel.onDragEnded = { [weak self, weak mascot] in
            mascot?.animationController.userDidEndDrag()
            self?.refreshDiagnostics()
        }
        mascot.animationController.onSummonCompleted = { [weak self] in
            self?.refreshDiagnostics()
        }
        // The two transition cues. Both accompany something the user asked
        // for and can see, so neither needs the visibility gate the
        // reaction cues have. They are per mascot rather than deduped: each
        // one is the sound of a specific pet arriving or leaving, and the
        // owner summons them one menu click at a time.
        mascot.animationController.onSummonStarted = { [weak self] in
            self?.sounds.play(.summon)
        }
        mascot.animationController.onDismissBurst = { [weak self] in
            self?.sounds.play(.dismiss)
        }
        // Gated on visibility: a dismissed mascot is one the user chose not
        // to have on screen, and a chime from an invisible pet is a sound
        // with nothing to explain it.
        mascot.animationController.onStateAppeared = { [weak self, weak mascot] state in
            guard let self, let mascot, mascot.isVisible else { return }
            self.playReactionCue(state, from: mascot)
        }
    }

    /// Plays at most one reaction cue per window, however many mascots reacted.
    ///
    /// Owner decision, 2026-08-01. Both mascots share the same two WAVs, so two
    /// of them entering `success` milliseconds apart would phase against each
    /// other and read as a glitch rather than as two agents finishing.
    private var lastReactionCueAt: [MascotState: TimeInterval] = [:]
    private static let reactionCueCoalescingWindow: TimeInterval = 0.6

    private func playReactionCue(_ state: MascotState, from mascot: MascotInstance) {
        let now = ProcessInfo.processInfo.systemUptime
        if let previous = lastReactionCueAt[state],
           now - previous < Self.reactionCueCoalescingWindow {
            return
        }
        lastReactionCueAt[state] = now
        sounds.stateDidAppear(state)
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Removes the socket file, so the next launch does not have to decide
        // whether a leftover one belongs to a live instance.
        eventBridge.stop()
    }

    /// Reopening restores whatever was on screen before, or the Claude mascot if
    /// nothing was — reopening with no mascot summoned should still produce one.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if summoned.isEmpty {
            setVisible(true, for: .claudeCode)
        } else {
            for provider in summoned { setVisible(true, for: provider) }
        }
        diagnostics = "Mascot reopened"
        return true
    }

    func setVisible(_ visible: Bool, for provider: EventProvider) {
        // Quit is already under way and is not negotiable. Without this, a
        // reopen event arriving during the farewell would cancel the dismiss,
        // and the completion that terminates the app would never fire.
        guard !isQuitting, let mascot = mascot(for: provider) else { return }

        if visible {
            summoned.insert(provider)
            mascot.summon()
            diagnostics = "Opening Dock portal — \(mascot.displayName)"
            return
        }

        // The pet leaves the way it arrived, through a transition rather than by
        // blinking out: it forms a ninja hand seal and vanishes in a smoke poof.
        // The panel therefore stays on screen until the animation says it is
        // finished, so hiding is deferred into the completion below. The
        // summoned set updates immediately regardless, so the menu never offers
        // to dismiss a mascot that is already leaving.
        summoned.remove(provider)
        diagnostics = "Dismissing \(mascot.displayName) — hand sign and smoke poof"
        mascot.dismiss { [weak self] in
            self?.refreshDiagnostics()
        }
    }

    /// Dismisses every mascot that is currently on screen.
    func dismissAll() {
        for provider in summoned { setVisible(false, for: provider) }
    }

    func setPaused(_ paused: Bool) {
        isPaused = paused
        if paused { isIdeating = false }
        syncOverrides()
    }

    func setIdeating(_ ideating: Bool) {
        isIdeating = ideating
        if ideating { isPaused = false }
        syncOverrides()
    }

    /// Shows one state for inspection, so every animation is reachable without an
    /// agent. Passing `nil` returns to whatever the reducer actually believes.
    ///
    /// Mutually exclusive with pause and ideating, because the reducer places a
    /// preview above both and leaving them set would strand the user in a state
    /// they cannot see the effect of.
    func setPreview(_ state: MascotState?) {
        previewState = state
        if state != nil {
            isPaused = false
            isIdeating = false
        }
        syncOverrides()
    }

    /// Publishing the overrides is what changes the animation: the reducer folds
    /// them into `MascotVisibleState`, which the observer above feeds to the
    /// controller. Setting a row directly from here would reintroduce the second
    /// source of truth this wiring exists to remove.
    private func syncOverrides() {
        eventBridge.overrides = ManualOverrides(
            isPaused: isPaused,
            isIdeating: isIdeating,
            preview: previewState
        )
        refreshDiagnostics()
    }

    func setMuted(_ muted: Bool) {
        isMuted = muted
        sounds.isMuted = muted
    }

    /// Turns the chat-app signal on or off. Clearing the presence is the
    /// observer's job, so switching this off stops the pose immediately rather
    /// than at the next app switch.
    func setChatAppsDriveIdeating(_ enabled: Bool) {
        chatAppsDriveIdeating = enabled
        Preferences.chatAppsDriveIdeating = enabled
        chatActivityWatcher?.setEnabled(enabled)
    }

    func setRoaming(_ roaming: Bool, for provider: EventProvider) {
        roamingByProvider[provider] = roaming
        mascot(for: provider)?.setRoaming(roaming)
        Preferences.setRoaming(roaming, for: provider)
        refreshDiagnostics()
    }

    /// Sets the nightly sleep window, or turns scheduled sleep off with `nil`.
    ///
    /// The reducer is the only thing that decides whether the pet is asleep, so
    /// this changes an input to the reduction rather than the animation — the
    /// same rule every other state change here follows.
    func setSleepWindow(_ window: SleepWindow?) {
        sleepWindow = window
        Preferences.sleepWindow = window
        eventBridge.sleepWindow = window
        refreshDiagnostics()
    }

    /// Choosing an hour while sleep is off turns it back on, using the saved
    /// hours for the end the user did not touch. Picking a bedtime from a menu
    /// that then does nothing because a separate switch is off would be a small
    /// puzzle with no upside.
    func setSleepStartHour(_ hour: Int) {
        let end = sleepWindow?.endHour ?? Preferences.lastSleepHours.end
        setSleepWindow(SleepWindow(startHour: hour, endHour: end))
    }

    func setSleepEndHour(_ hour: Int) {
        let start = sleepWindow?.startHour ?? Preferences.lastSleepHours.start
        setSleepWindow(SleepWindow(startHour: start, endHour: hour))
    }

    /// The submenu's own title, so the current schedule is readable without
    /// opening it.
    var sleepScheduleSummary: String {
        guard let sleepWindow else { return "Sleep Schedule: Off" }
        let start = Self.hourLabel(sleepWindow.startHour)
        let end = Self.hourLabel(sleepWindow.endHour)
        // An empty window is reachable — both menus are free — and silently
        // never sleeping would look like a bug rather than a choice.
        guard sleepWindow.startHour != sleepWindow.endHour else {
            return "Sleep Schedule: \(start)–\(end) (never)"
        }
        return "Sleep Schedule: \(start)–\(end)"
    }

    /// Formats an hour the way the user's own locale writes clock times, so a
    /// 12-hour region sees "11 PM" rather than "23:00".
    static func hourLabel(_ hour: Int) -> String {
        let calendar = Calendar.current
        guard
            let date = calendar.date(
                from: DateComponents(year: 2000, month: 1, day: 1, hour: hour)
            )
        else {
            return String(format: "%02d:00", hour)
        }
        let formatter = DateFormatter()
        formatter.locale = .current
        // "j" is the locale's preferred hour field, which is what decides
        // between a 24-hour and a 12-hour presentation.
        formatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: "j",
            options: 0,
            locale: .current
        ) ?? "HH"
        return formatter.string(from: date)
    }

    /// Describes what the pet is actually doing, without implying that a state
    /// with no provider behind it came from an agent.
    private func refreshDiagnostics() {
        guard isVisible else {
            // Says what to do about it, since this is now the state the app
            // launches in rather than an unusual one.
            diagnostics = "Not summoned — choose Summon Mascot"
            return
        }
        // Named as a preview so a forced state is never mistaken for a real one.
        if let previewState {
            diagnostics = "Previewing \(previewState.displayName) — not a real agent state"
            return
        }
        // One clause per summoned mascot, so two pets on screen never hide
        // behind a single collapsed line that names neither of them.
        let lines = mascots
            .filter { summoned.contains($0.provider) }
            .map { mascot -> String in
                let state = eventBridge.visibleStates[mascot.provider]?.state ?? .offline
                return "\(mascot.displayName): \(describe(state, roaming: isRoaming(mascot.provider)))"
            }
        diagnostics = lines.joined(separator: " • ")
    }

    /// What one mascot is doing, without implying that a state with no provider
    /// behind it came from an agent.
    private func describe(_ state: MascotState, roaming: Bool) -> String {
        switch state {
        case .paused: "animation paused"
        case .ideating: "manual ideating"
        case .offline: roaming
            ? "ambient roaming — agent not running"
            : "resting at manual position — agent not running"
        case .idle: "strolling — idle"
        case .working, .waiting, .success, .failure, .sleeping: state.displayName.lowercased()
        }
    }

    func reposition() {
        for mascot in mascots { mascot.reposition() }
    }

    /// Puts the bundled helper's absolute path on the clipboard, so it can be
    /// pasted into a provider hook configuration. Copying is the whole action:
    /// Dock Pet does not edit anyone's hook files.
    func copyHelperPath() {
        guard let path = EventHelperLocation.path else {
            diagnostics = "Event helper is missing from this build"
            return
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(path, forType: .string)
        diagnostics = "Helper path copied"
    }

    /// Copies the exact hook configuration for a provider, so the user can read
    /// every line before it goes anywhere near their settings file.
    ///
    /// Dock Pet never writes that file. Issue #10 asks for verify/disable/
    /// uninstall actions per provider; those would all mean editing the file
    /// that runs the user's actual agent, and a mascot getting that wrong breaks
    /// the tool they work in. Preview-and-paste is the deliberate substitute.
    func copyHookSetup(for provider: EventProvider) {
        guard let path = EventHelperLocation.path else {
            diagnostics = "Event helper is missing from this build"
            return
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(
            HookConfiguration.instructions(for: provider, helperPath: path),
            forType: .string
        )
        diagnostics = "\(provider.rawValue) hook setup copied"
    }

    /// Quitting says goodbye first, when there is a mascot on screen to say it.
    ///
    /// Owner request, 2026-08-01: the same seal and poof that plays for Dismiss.
    /// It costs about a second, so the escape hatches matter more than the
    /// animation does — a second Quit terminates immediately, and an
    /// unsummoned mascot skips the farewell entirely rather than making the
    /// user watch a transition for a pet that was never there.
    func quit() {
        // Every mascot on screen says goodbye, but quitting must not depend on
        // any of them finishing: the app terminates when the last farewell
        // completes, and a second Quit skips straight past them all.
        let leaving = mascots.filter { $0.animationController.isVisible }
        guard !isQuitting, !leaving.isEmpty else {
            NSApp.terminate(nil)
            return
        }
        isQuitting = true
        summoned.removeAll()
        diagnostics = "Quitting — hand sign and smoke poof"
        var remaining = leaving.count
        for mascot in leaving {
            mascot.dismiss {
                remaining -= 1
                if remaining == 0 { NSApp.terminate(nil) }
            }
        }
    }

    private func showMascotMenu(for mascot: MascotInstance) {
        let menu = NSMenu()
        menu.addItem(withTitle: isPaused ? "Resume Animation" : "Pause Animation", action: #selector(togglePauseFromMascot), keyEquivalent: "")
        // Phrased as the action taken, matching the menu bar's "Stay in One
        // Place" mode name rather than the older roaming vocabulary.
        let roamingItem = NSMenuItem(
            title: isRoaming(mascot.provider) ? "Stay in One Place" : "Start Roaming Again",
            action: #selector(toggleRoamingFromMascot(_:)),
            keyEquivalent: ""
        )
        roamingItem.representedObject = mascot.provider.rawValue
        menu.addItem(roamingItem)
        menu.addItem(.separator())
        // Names the pet that was clicked, so with two on screen it is never
        // ambiguous which one is about to leave.
        let dismiss = NSMenuItem(
            title: "Dismiss \(mascot.displayName) Mascot",
            action: #selector(dismissClickedMascot(_:)),
            keyEquivalent: ""
        )
        dismiss.representedObject = mascot.provider.rawValue
        menu.addItem(dismiss)
        menu.addItem(withTitle: "Quit Dock Pet", action: #selector(quitFromMascotMenu), keyEquivalent: "")
        for item in menu.items { item.target = self }
        let contentView = mascot.windowCoordinator.panel.contentView
        guard let contentView else { return }
        menu.popUp(positioning: nil, at: NSPoint(x: contentView.bounds.midX, y: contentView.bounds.midY), in: contentView)
    }

    @objc private func togglePauseFromMascot() { setPaused(!isPaused) }
    /// Toggles only the pet that was clicked. The provider rides on the menu
    /// item, the same way `dismissClickedMascot` identifies its target.
    @objc private func toggleRoamingFromMascot(_ sender: NSMenuItem) {
        guard let raw = sender.representedObject as? String,
              let provider = EventProvider(rawValue: raw) else { return }
        setRoaming(!isRoaming(provider), for: provider)
    }
    @objc private func dismissClickedMascot(_ sender: NSMenuItem) {
        guard
            let raw = sender.representedObject as? String,
            let provider = EventProvider(rawValue: raw)
        else { return }
        setVisible(false, for: provider)
    }
    @objc private func quitFromMascotMenu() { quit() }
}
