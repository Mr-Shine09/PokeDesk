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
        panelSize: CGSize(width: 48, height: 56)
    )
    #expect(origin.y == 78)
}

@Test func detectsLeftAndRightDockInsets() {
    let leftVisible = CGRect(x: 72, y: 0, width: 1368, height: 876)
    let rightVisible = CGRect(x: 0, y: 0, width: 1368, height: 876)
    #expect(DockGeometry.inferDockEdge(frame: screen, visibleFrame: leftVisible) == .left)
    #expect(DockGeometry.inferDockEdge(frame: screen, visibleFrame: rightVisible) == .right)
}

@Test func clampsPanelInsideVisibleFrame() {
    let visible = CGRect(x: 0, y: 70, width: 40, height: 40)
    let origin = DockGeometry.panelOrigin(
        screenFrame: screen,
        visibleFrame: visible,
        panelSize: CGSize(width: 48, height: 56)
    )
    #expect(origin.x == -8)
    #expect(origin.y == 54)
}
