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
    /// Restored from preferences, so a deliberate choice survives relaunch.
    @Published var isRoaming = Preferences.roaming
    /// Forces one animation for inspection. Never persisted: it is a testing
    /// mode, and finding the pet stuck in a fake state after a relaunch with no
    /// memory of choosing it would be its own bug.
    @Published private(set) var previewState: MascotState?

    /// Listens for provider lifecycle events, reduces them, and is the single
    /// source of the mascot's visible state — manual pause and ideating included,
    /// since those reach the reducer as overrides.
    let eventBridge = AgentEventBridge()

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
    /// Owning the item fixes both halves. `autosaveName` is ours, so this is a
    /// fresh identity with no removal remembered against it, and `isVisible` is
    /// a property we set rather than one macOS restores. The menu itself is
    /// still the same SwiftUI `MenuBarContent`, rendered through
    /// `NSHostingMenu`, so nothing about the menu's contents changed.
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

    private func mascot(for provider: EventProvider) -> MascotInstance? {
        mascots.first { $0.provider == provider }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
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
        // A name of our own choosing. The removal macOS remembers is keyed to
        // the old `MenuBarExtra`-derived name, so this identity starts clean.
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

    func setRoaming(_ roaming: Bool) {
        isRoaming = roaming
        for mascot in mascots { mascot.setRoaming(roaming) }
        Preferences.roaming = roaming
        refreshDiagnostics()
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
                return "\(mascot.displayName): \(describe(state))"
            }
        diagnostics = lines.joined(separator: " • ")
    }

    /// What one mascot is doing, without implying that a state with no provider
    /// behind it came from an agent.
    private func describe(_ state: MascotState) -> String {
        switch state {
        case .paused: "animation paused"
        case .ideating: "manual ideating"
        case .offline: isRoaming
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
        menu.addItem(withTitle: isRoaming ? "Stop Roaming" : "Resume Roaming", action: #selector(toggleRoamingFromMascot), keyEquivalent: "")
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
    @objc private func toggleRoamingFromMascot() { setRoaming(!isRoaming) }
    @objc private func dismissClickedMascot(_ sender: NSMenuItem) {
        guard
            let raw = sender.representedObject as? String,
            let provider = EventProvider(rawValue: raw)
        else { return }
        setVisible(false, for: provider)
    }
    @objc private func quitFromMascotMenu() { quit() }
}
