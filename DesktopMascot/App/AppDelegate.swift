import AppKit
import Combine
import MascotAnimation
import MascotWindow
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @Published private(set) var diagnostics = "Starting"
    @Published var isVisible = true
    @Published var isPaused = false
    @Published var isIdeating = false
    @Published var isRoaming = true

    private let previewModel = MascotPreviewModel()
    private var atlas: SpriteAtlas?
    private var windowCoordinator: WindowCoordinator?
    private var animationController: AmbientAnimationController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        do {
            let resources = try AppResources.load()
            let contractData = try Data(contentsOf: resources.contractURL)
            let contract = try JSONDecoder().decode(AtlasContract.self, from: contractData)
            let atlas = try SpriteAtlas(imageURL: resources.atlasURL, contract: contract)
            self.atlas = atlas
            previewModel.image = try atlas.frame(state: "idle", index: 0)

            let hostingView = NSHostingView(rootView: MascotPreviewView(model: previewModel))
            hostingView.frame = NSRect(origin: .zero, size: MascotPanel.defaultContentSize)
            let windowCoordinator = WindowCoordinator(contentView: hostingView)
            self.windowCoordinator = windowCoordinator
            windowCoordinator.panel.onClick = { [weak self] in
                self?.showMascotMenu()
            }
            windowCoordinator.panel.onDragBegan = { [weak self] in
                self?.animationController?.userDidBeginDrag()
                self?.diagnostics = "Dragging — hanging pose"
            }
            windowCoordinator.panel.onDragEnded = { [weak self] in
                self?.animationController?.userDidEndDrag()
                self?.isRoaming = false
                self?.diagnostics = "Manual position — click mascot to resume roaming"
            }
            animationController = try AmbientAnimationController(
                atlas: atlas,
                previewModel: previewModel,
                windowCoordinator: windowCoordinator
            )
            animationController?.onSummonCompleted = { [weak self] in
                guard let self else { return }
                if self.isPaused {
                    self.diagnostics = "Animation paused"
                } else if self.isIdeating {
                    self.diagnostics = "Manual ideating"
                } else if self.isRoaming {
                    self.diagnostics = "Ambient roaming — no agent signal connected"
                } else {
                    self.diagnostics = "Offline at manual position"
                }
            }
            setVisible(isVisible)
        } catch {
            diagnostics = error.localizedDescription
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        setVisible(true)
        diagnostics = "Mascot reopened"
        return true
    }

    func setVisible(_ visible: Bool) {
        isVisible = visible
        windowCoordinator?.setVisible(visible)
        animationController?.setVisible(visible)
        diagnostics = visible ? "Opening Dock portal" : "Mascot hidden"
    }

    func setPaused(_ paused: Bool) {
        isPaused = paused
        if paused { isIdeating = false }
        animationController?.setIdeating(false)
        animationController?.setPaused(paused)
        diagnostics = paused ? "Animation paused" : "Ambient roaming"
    }

    func setIdeating(_ ideating: Bool) {
        isIdeating = ideating
        if ideating { isPaused = false }
        animationController?.setPaused(false)
        animationController?.setIdeating(ideating)
        diagnostics = ideating ? "Manual ideating" : "Ambient roaming"
    }

    func setRoaming(_ roaming: Bool) {
        isRoaming = roaming
        animationController?.setRoaming(roaming)
        diagnostics = roaming ? "Ambient roaming" : "Offline at manual position"
    }

    func reposition() {
        windowCoordinator?.reposition()
    }

    func quit() {
        NSApp.terminate(nil)
    }

    private func showMascotMenu() {
        let menu = NSMenu()
        menu.addItem(withTitle: isPaused ? "Resume Animation" : "Pause Animation", action: #selector(togglePauseFromMascot), keyEquivalent: "")
        menu.addItem(withTitle: isRoaming ? "Stop Roaming" : "Resume Roaming", action: #selector(toggleRoamingFromMascot), keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Hide Mascot", action: #selector(hideMascotFromMenu), keyEquivalent: "")
        menu.addItem(withTitle: "Quit Dock Pet", action: #selector(quitFromMascotMenu), keyEquivalent: "")
        for item in menu.items { item.target = self }
        guard let contentView = windowCoordinator?.panel.contentView else { return }
        menu.popUp(positioning: nil, at: NSPoint(x: contentView.bounds.midX, y: contentView.bounds.midY), in: contentView)
    }

    @objc private func togglePauseFromMascot() { setPaused(!isPaused) }
    @objc private func toggleRoamingFromMascot() { setRoaming(!isRoaming) }
    @objc private func hideMascotFromMenu() { setVisible(false) }
    @objc private func quitFromMascotMenu() { quit() }
}
