import CoreGraphics
import MascotWindow
import Testing

private let screen = CGRect(x: 0, y: 0, width: 1440, height: 900)

@Test func detectsBottomDockAndPlacesAboveVisibleFrame() {
    let visible = CGRect(x: 0, y: 70, width: 1440, height: 806)
    #expect(DockGeometry.inferDockEdge(frame: screen, visibleFrame: visible) == .bottom)
    let origin = DockGeometry.panelOrigin(
        screenFrame: screen,
        visibleFrame: visible,
        panelSize: CGSize(width: 96, height: 112),
        visualInset: 10
    )
    #expect(origin.x == 432)
    #expect(origin.y == 60)
}

@Test func detectsLeftAndRightDockInsets() {
    let leftVisible = CGRect(x: 72, y: 0, width: 1368, height: 876)
    let rightVisible = CGRect(x: 0, y: 0, width: 1368, height: 876)
    #expect(DockGeometry.inferDockEdge(frame: screen, visibleFrame: leftVisible) == .left)
    #expect(DockGeometry.inferDockEdge(frame: screen, visibleFrame: rightVisible) == .right)

    let panelSize = CGSize(width: 96, height: 112)
    let leftOrigin = DockGeometry.panelOrigin(
        screenFrame: screen,
        visibleFrame: leftVisible,
        panelSize: panelSize,
        visualInset: 10
    )
    let rightOrigin = DockGeometry.panelOrigin(
        screenFrame: screen,
        visibleFrame: rightVisible,
        panelSize: panelSize,
        visualInset: 10
    )
    #expect(leftOrigin.x + 10 == leftVisible.minX)
    #expect(rightOrigin.x + panelSize.width - 10 == rightVisible.maxX)
}

@Test func clampsPanelInsideVisibleFrame() {
    let visible = CGRect(x: 0, y: 70, width: 40, height: 40)
    let origin = DockGeometry.panelOrigin(
        screenFrame: screen,
        visibleFrame: visible,
        panelSize: CGSize(width: 96, height: 112),
        visualInset: 10
    )
    #expect(origin.x == 0)
    #expect(origin.y == -2)
}
