import CoreGraphics
import MascotWindow
import Testing

private let screen = CGRect(x: 0, y: 0, width: 1440, height: 900)

@Test func placesThePanelAboveTheVisibleFrameBottom() {
    let visible = CGRect(x: 0, y: 70, width: 1440, height: 806)
    let origin = DockGeometry.panelOrigin(
        screenFrame: screen,
        visibleFrame: visible,
        panelSize: CGSize(width: 96, height: 112),
        visualInset: 10
    )
    #expect(origin.x == 432)
    #expect(origin.y == 60)
}

@Test func ignoresVisibleFrameInsetsFromASideDock() {
    // A left/right Dock narrows visibleFrame.minX/maxX but must not change
    // vertical placement: the panel still anchors to the screen bottom.
    let leftVisible = CGRect(x: 72, y: 0, width: 1368, height: 876)
    let origin = DockGeometry.panelOrigin(
        screenFrame: screen,
        visibleFrame: leftVisible,
        panelSize: CGSize(width: 96, height: 112),
        visualInset: 10
    )
    #expect(origin.y == 0)
}

@Test func clampsPanelInsideAVisibleFrameSmallerThanThePanel() {
    let visible = CGRect(x: 0, y: 70, width: 40, height: 40)
    let origin = DockGeometry.panelOrigin(
        screenFrame: screen,
        visibleFrame: visible,
        panelSize: CGSize(width: 96, height: 112),
        visualInset: 10
    )
    #expect(origin.x == 0)
    #expect(origin.y == 0)
}
