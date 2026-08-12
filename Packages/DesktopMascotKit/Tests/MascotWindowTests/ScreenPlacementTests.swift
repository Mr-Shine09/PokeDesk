import CoreGraphics
import MascotWindow
import Testing

// The arrangement this project's failure was first seen on: a built-in Retina
// display as the primary, and a Sidecar display butted against its right edge
// two points lower. Using real numbers keeps the regression legible.
private let builtIn = CGRect(x: 0, y: 0, width: 1280, height: 832)
private let sidecar = CGRect(x: 1280, y: -2, width: 1194, height: 834)
private let panelSize = CGSize(width: 96, height: 112)

private func panel(_ x: CGFloat, _ y: CGFloat) -> CGRect {
    CGRect(origin: CGPoint(x: x, y: y), size: panelSize)
}

@Test func aPanelOverOneDisplayResolvesToThatDisplay() {
    #expect(ScreenPlacement.screenIndex(forPanelFrame: panel(600, 56), in: [builtIn, sidecar]) == 0)
    #expect(ScreenPlacement.screenIndex(forPanelFrame: panel(1684, 300), in: [builtIn, sidecar]) == 1)
}

@Test func aStraddlingPanelResolvesToTheDisplayItCoversMost() {
    // 30 points wide on the built-in, 66 on the Sidecar.
    #expect(ScreenPlacement.screenIndex(forPanelFrame: panel(1250, 300), in: [builtIn, sidecar]) == 1)
    // 60 points on the built-in, 36 on the Sidecar.
    #expect(ScreenPlacement.screenIndex(forPanelFrame: panel(1220, 300), in: [builtIn, sidecar]) == 0)
}

@Test func aPanelPastEveryEdgeResolvesToTheNearestDisplay() {
    // The exact position that made `aDropPastAnEdgeIsClampedBackIntoView` fail:
    // 500 points past the built-in's upper bounds on both axes, which puts it
    // over no display at all but directly above the Sidecar. `NSScreen.main`
    // answered "built-in" or "Sidecar" depending on which one held the key
    // window; geometry answers "Sidecar" every time.
    #expect(ScreenPlacement.screenIndex(forPanelFrame: panel(1684, 1190), in: [builtIn, sidecar]) == 1)
    // Past the left edge of the primary, nowhere near the Sidecar.
    #expect(ScreenPlacement.screenIndex(forPanelFrame: panel(-400, 300), in: [builtIn, sidecar]) == 0)
    // Below both, but well to the right.
    #expect(ScreenPlacement.screenIndex(forPanelFrame: panel(2000, -900), in: [builtIn, sidecar]) == 1)
}

@Test func aPanelStrandedInAGapResolvesToTheNearerDisplay() {
    // A stacked arrangement with a 200-point dead band between the two, which
    // the panel can be left in when the cursor is near an edge: the panel hangs
    // 108 points below the pointer, so the pointer stays on a display while the
    // body does not.
    let upper = CGRect(x: 0, y: 300, width: 1280, height: 800)
    let lower = CGRect(x: 0, y: -700, width: 1280, height: 800)

    // Both sit wholly inside the dead band; only which edge they are closer to
    // differs.
    #expect(ScreenPlacement.screenIndex(forPanelFrame: panel(400, 170), in: [upper, lower]) == 0)
    #expect(ScreenPlacement.screenIndex(forPanelFrame: panel(400, 110), in: [upper, lower]) == 1)
}

@Test func displaysTouchingAlongAnEdgeDoNotCountAsOverlap() {
    let left = CGRect(x: 0, y: 0, width: 1000, height: 800)
    let right = CGRect(x: 1000, y: 0, width: 1000, height: 800)

    // Flush against the shared edge: the zero-width intersection with `left` is
    // two displays meeting, not the panel being on `left`.
    #expect(ScreenPlacement.screenIndex(forPanelFrame: panel(1000, 100), in: [left, right]) == 1)
}

@Test func anExactTieResolvesTheSameWayEveryTime() {
    let left = CGRect(x: 0, y: 0, width: 1000, height: 800)
    let right = CGRect(x: 1000, y: 0, width: 1000, height: 800)
    // 48 points on each display.
    let straddling = panel(952, 100)

    #expect(ScreenPlacement.screenIndex(forPanelFrame: straddling, in: [left, right]) == 0)
    #expect(ScreenPlacement.screenIndex(forPanelFrame: straddling, in: [left, right]) == 0)

    // Equidistant from both while overlapping neither, so the nearest-display
    // fallback has to break the tie too.
    let above = panel(952, 900)
    #expect(ScreenPlacement.screenIndex(forPanelFrame: above, in: [left, right]) == 0)
}

@Test func placementIsIndependentOfHowManyTimesItIsAsked() {
    // The property the fix exists for: the answer is a function of the panel
    // frame and the arrangement, so nothing about focus, call order, or the
    // panel's visibility can change it between two callers.
    let arrangement = [builtIn, sidecar]
    for frame in [panel(600, 56), panel(1684, 1190), panel(1250, 300), panel(-400, -400)] {
        let first = ScreenPlacement.screenIndex(forPanelFrame: frame, in: arrangement)
        #expect(first == ScreenPlacement.screenIndex(forPanelFrame: frame, in: arrangement))
    }
}

@Test func noDisplaysMeansNoPlacement() {
    #expect(ScreenPlacement.screenIndex(forPanelFrame: panel(0, 0), in: []) == nil)
}

@Test func aSingleDisplayIsAlwaysTheAnswer() {
    #expect(ScreenPlacement.screenIndex(forPanelFrame: panel(600, 56), in: [builtIn]) == 0)
    #expect(ScreenPlacement.screenIndex(forPanelFrame: panel(9_000, 9_000), in: [builtIn]) == 0)
}
