import AppKit
import MascotAnimation
import MascotCore
import MascotWindow
import SwiftUI

/// One mascot: its provider, its wardrobe, its panel, and its animation.
///
/// Owner decision, 2026-08-01: Dock Pet shows one mascot per provider rather
/// than a single pet whose outfit is chosen from whichever provider happened to
/// contribute to the reduced state. Each instance is summoned and dismissed on
/// its own from the menu bar, roams and is dragged independently, and reduces
/// only its own provider's sessions.
///
/// Everything here was previously inlined in `AppDelegate` for a single mascot.
/// It is a type rather than a pair of parallel arrays so that adding a third
/// provider later cannot half-wire one of them.
@MainActor
final class MascotInstance {
    let provider: EventProvider
    let fashion: MascotFashion
    let previewModel = MascotPreviewModel()
    let windowCoordinator: WindowCoordinator
    let animationController: AmbientAnimationController

    /// Whether the owner has summoned *this* mascot. Independent per instance:
    /// summoning Claude's mascot must not put Codex's on screen.
    private(set) var isVisible = false

    /// Human-readable name for menus and diagnostics.
    var displayName: String {
        switch provider {
        case .claudeCode: "Claude"
        case .codex: "Codex"
        }
    }

    init(
        provider: EventProvider,
        atlas: SpriteAtlas,
        laneOffset: CGFloat
    ) throws {
        self.provider = provider
        fashion = MascotFashion.worn(by: provider)

        previewModel.image = try atlas.frame(state: "idle", index: 0)
        let hostingView = NSHostingView(rootView: MascotPreviewView(model: previewModel))
        hostingView.frame = NSRect(origin: .zero, size: MascotPanel.defaultContentSize)
        windowCoordinator = WindowCoordinator(contentView: hostingView, laneOffset: laneOffset)
        animationController = try AmbientAnimationController(
            fashion: fashion,
            atlas: atlas,
            previewModel: previewModel,
            windowCoordinator: windowCoordinator
        )
    }

    /// Summons this mascot through the Dock portal, preserving a dropped height.
    ///
    /// A dropped height is a deliberate placement, so Hide/Show and reopen must
    /// preserve it. Roaming does not signal this — dragging leaves roaming on —
    /// so the coordinator's own record of the drop is the only reliable answer
    /// to "did the user place this themselves?".
    func summon() {
        isVisible = true
        windowCoordinator.setVisible(true, repositioning: !windowCoordinator.hasManualPlacement)
        animationController.setVisible(true)
    }

    /// Plays the seal and poof, then orders the panel out through `completion`.
    ///
    /// The panel must not be hidden until the animation says it is finished, so
    /// hiding is deferred into the completion rather than done here.
    func dismiss(completion: @escaping () -> Void) {
        isVisible = false
        guard animationController.isVisible else {
            orderOut()
            completion()
            return
        }
        animationController.beginDismiss { [weak self] in
            self?.orderOut()
            completion()
        }
    }

    private func orderOut() {
        windowCoordinator.setVisible(false)
        animationController.setVisible(false)
    }

    func setRoaming(_ roaming: Bool) {
        animationController.setRoaming(roaming)
    }

    func reposition() {
        windowCoordinator.reposition()
    }
}
