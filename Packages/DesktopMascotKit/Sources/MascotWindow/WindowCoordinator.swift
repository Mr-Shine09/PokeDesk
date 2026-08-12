import AppKit

@MainActor
public final class WindowCoordinator: NSObject {
    public let panel: MascotPanel
    private let contentSize: NSSize
    /// The height the user last dropped the mascot at, or `nil` while it is
    /// still on the default bottom lane.
    private var manualLaneY: CGFloat?

    public init(contentView: NSView, contentSize: NSSize = MascotPanel.defaultContentSize) {
        self.contentSize = contentSize
        panel = MascotPanel(contentView: contentView, contentSize: contentSize)
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
        reposition()
    }

    /// `repositioning` defaults to `true` for the common case (launch, Show
    /// with no prior manual placement). Pass `false` to preserve wherever the
    /// user last dragged the panel — otherwise every Hide/Show or reopen
    /// would silently discard a manual position by snapping back to the
    /// default lane.
    public func setVisible(_ visible: Bool, repositioning: Bool = true) {
        if visible {
            if repositioning { reposition() }
            panel.orderFrontRegardless()
        } else {
            panel.orderOut(nil)
        }
    }

    /// The display the panel is placed against, chosen from the panel's own
    /// frame rather than from `NSScreen.main`.
    ///
    /// `NSScreen.main` follows keyboard focus, so with two displays attached it
    /// made every bound below depend on which window the user had last clicked
    /// — see `ScreenPlacement` for the failure it caused. `NSWindow.screen`
    /// answers correctly whenever the panel overlaps a display (including while
    /// ordered out), but returns `nil` for a panel dropped past an outer edge,
    /// which is exactly the case `settleAfterDrop` exists to repair.
    /// `ScreenPlacement` answers both cases from geometry alone.
    private func placementScreen() -> NSScreen? {
        let screens = NSScreen.screens
        guard let index = ScreenPlacement.screenIndex(forPanelFrame: panel.frame, in: screens.map(\.frame)) else {
            return nil
        }
        return screens[index]
    }

    public func horizontalMovementBounds() -> ClosedRange<CGFloat>? {
        placementScreen().map(horizontalBounds(on:))
    }

    private func horizontalBounds(on screen: NSScreen) -> ClosedRange<CGFloat> {
        let minimum = screen.visibleFrame.minX
        let maximum = max(minimum, screen.visibleFrame.maxX - contentSize.width)
        return minimum ... maximum
    }

    /// The backing scale of the display the panel is placed against, for
    /// callers that round a position to whole device pixels. It resolves the
    /// same display the movement bounds do, so a walk cannot round against one
    /// display while being clamped against another. Falls back to Retina when
    /// there is no display to ask.
    public var placementBackingScaleFactor: CGFloat {
        placementScreen()?.backingScaleFactor ?? 2
    }

    public func setHorizontalPosition(_ x: CGFloat) {
        guard let bounds = horizontalMovementBounds() else { return }
        panel.setFrameOrigin(NSPoint(x: min(max(x, bounds.lowerBound), bounds.upperBound), y: panel.frame.minY))
    }

    /// Whether the user has dropped the mascot at a height of their own.
    ///
    /// Read by callers that would otherwise reposition on Hide/Show, so a
    /// deliberate placement survives being dismissed and summoned again.
    public var hasManualPlacement: Bool { manualLaneY != nil }

    public func verticalPlacementBounds() -> ClosedRange<CGFloat>? {
        placementScreen().map(verticalBounds(on:))
    }

    private func verticalBounds(on screen: NSScreen) -> ClosedRange<CGFloat> {
        let minimum = screen.frame.minY - MascotPanel.defaultDockVisualInset
        let maximum = max(minimum, screen.visibleFrame.maxY - contentSize.height)
        return minimum ... maximum
    }

    /// Adopts wherever the user dropped the mascot as its new roaming height.
    ///
    /// Owner decision, 2026-07-30: the pet roams from wherever it is dropped,
    /// rather than falling back to the bottom lane. The walk cycle only moves
    /// along X, so this makes the mascot walk left and right at the height it
    /// was released — including through open air above the Dock, which the owner
    /// asked for explicitly after seeing the lane-snapping version. The bottom
    /// lane remains the *default* placement and the destination of the
    /// Reposition menu action; it is no longer the only legal height.
    ///
    /// Both axes are clamped to the screen, because a pet dropped past an edge
    /// would otherwise roam somewhere it cannot be seen or grabbed back. One
    /// screen decides both axes — resolving per axis could clamp X against one
    /// display and Y against another, which is a position on neither.
    public func settleAfterDrop() {
        guard let screen = placementScreen() else {
            // No displays at all: keep the drop rather than inventing bounds.
            manualLaneY = panel.frame.minY
            return
        }
        let horizontal = horizontalBounds(on: screen)
        let vertical = verticalBounds(on: screen)
        let x = min(max(panel.frame.minX, horizontal.lowerBound), horizontal.upperBound)
        let y = min(max(panel.frame.minY, vertical.lowerBound), vertical.upperBound)
        manualLaneY = y
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    /// Returns the mascot to the default bottom lane, discarding a dropped
    /// height. This is what the Reposition menu action is for: once the pet can
    /// roam at any height, the user needs one deliberate way to get it back.
    public func reposition(on screen: NSScreen? = nil) {
        // An explicit screen wins; otherwise the panel's own display decides,
        // never the focused one. Before, a mascot dismissed on one display and
        // summoned back could reappear on whichever display the user had since
        // clicked into — a teleport across unrelated displays that nothing had
        // asked for.
        guard let screen = screen ?? placementScreen() else { return }
        manualLaneY = nil
        let origin = DockGeometry.panelOrigin(
            screenFrame: screen.frame,
            visibleFrame: screen.visibleFrame,
            panelSize: contentSize,
            visualInset: MascotPanel.defaultDockVisualInset
        )
        panel.setFrameOrigin(origin)
    }

    /// A display change must not silently discard a dropped height, but it can
    /// leave one stranded off the new screen, so the placement is re-clamped
    /// rather than reset.
    @objc private func screenParametersChanged() {
        guard manualLaneY != nil else {
            reposition()
            return
        }
        settleAfterDrop()
    }

}
