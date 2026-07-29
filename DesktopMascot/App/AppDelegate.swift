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
    @Published var isPositionUnlocked = false

    private let previewModel = MascotPreviewModel()
    private var atlas: SpriteAtlas?
    private var windowCoordinator: WindowCoordinator?

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
            hostingView.frame = NSRect(x: 0, y: 0, width: 48, height: 56)
            windowCoordinator = WindowCoordinator(contentView: hostingView)
            windowCoordinator?.setVisible(isVisible)
            diagnostics = "Atlas revision \(contract.schemaVersion) loaded"
        } catch {
            diagnostics = error.localizedDescription
        }
    }

    func setVisible(_ visible: Bool) {
        isVisible = visible
        windowCoordinator?.setVisible(visible)
    }

    func setPaused(_ paused: Bool) {
        isPaused = paused
        if paused { isIdeating = false }
        updatePreviewState()
    }

    func setIdeating(_ ideating: Bool) {
        isIdeating = ideating
        if ideating { isPaused = false }
        updatePreviewState()
    }

    func setPositionUnlocked(_ unlocked: Bool) {
        isPositionUnlocked = unlocked
        windowCoordinator?.setInteractionUnlocked(unlocked)
        if unlocked {
            diagnostics = "Position unlocked for 15 seconds"
        } else {
            diagnostics = "Position locked"
        }
    }

    func reposition() {
        windowCoordinator?.reposition()
    }

    func quit() {
        NSApp.terminate(nil)
    }

    private func updatePreviewState() {
        guard let atlas else { return }
        let state = isPaused ? "paused" : (isIdeating ? "ideating" : "idle")
        do {
            previewModel.image = try atlas.frame(state: state, index: 0)
            diagnostics = "Showing \(state) preview"
        } catch {
            diagnostics = error.localizedDescription
        }
    }
}
