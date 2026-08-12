import AppKit
import MascotWindow
import Testing

@MainActor
@Test func panelRemainsNonActivatingAndInteractive() {
    let coordinator = WindowCoordinator(contentView: NSView())

    #expect(coordinator.panel.canBecomeKey == false)
    #expect(coordinator.panel.canBecomeMain == false)
    #expect(coordinator.panel.ignoresMouseEvents == false)
    #expect(coordinator.panel.isMovableByWindowBackground == false)
}

@MainActor
@Test func visibilityControlsPanelOrdering() {
    let coordinator = WindowCoordinator(contentView: NSView())
    defer { coordinator.setVisible(false) }

    coordinator.setVisible(true)
    #expect(coordinator.panel.isVisible)

    coordinator.setVisible(false)
    #expect(coordinator.panel.isVisible == false)
}

@MainActor
@Test func repositioningFalsePreservesAManuallyDraggedPosition() {
    let coordinator = WindowCoordinator(contentView: NSView())
    defer { coordinator.setVisible(false) }

    let manualOrigin = NSPoint(x: 200, y: 400)
    coordinator.panel.setFrameOrigin(manualOrigin)

    coordinator.setVisible(false)
    coordinator.setVisible(true, repositioning: false)

    #expect(coordinator.panel.frame.origin == manualOrigin)
}

@MainActor
@Test func repositioningTrueRestoresTheDefaultLane() {
    let coordinator = WindowCoordinator(contentView: NSView())
    defer { coordinator.setVisible(false) }
    let defaultOrigin = coordinator.panel.frame.origin

    coordinator.panel.setFrameOrigin(NSPoint(x: 200, y: 400))
    coordinator.setVisible(false)
    coordinator.setVisible(true, repositioning: true)

    #expect(coordinator.panel.frame.origin == defaultOrigin)
}

@MainActor
@Test func panelRoutesAPlainClickToMascotOptions() throws {
    let coordinator = WindowCoordinator(contentView: NSView())
    var clickCount = 0
    coordinator.panel.onClick = { clickCount += 1 }
    let down = try #require(NSEvent.mouseEvent(
        with: .leftMouseDown,
        location: .zero,
        modifierFlags: [],
        timestamp: 0,
        windowNumber: coordinator.panel.windowNumber,
        context: nil,
        eventNumber: 1,
        clickCount: 1,
        pressure: 1
    ))
    let up = try #require(NSEvent.mouseEvent(
        with: .leftMouseUp,
        location: .zero,
        modifierFlags: [],
        timestamp: 0.01,
        windowNumber: coordinator.panel.windowNumber,
        context: nil,
        eventNumber: 2,
        clickCount: 1,
        pressure: 0
    ))

    coordinator.panel.sendEvent(down)
    coordinator.panel.sendEvent(up)

    #expect(clickCount == 1)
}

@MainActor
@Test func panelRoutesDragBeginAndEndWithoutClicking() throws {
    let coordinator = WindowCoordinator(contentView: NSView())
    var dragBeganCount = 0
    var dragEndedCount = 0
    var clickCount = 0
    coordinator.panel.onDragBegan = { dragBeganCount += 1 }
    coordinator.panel.onDragEnded = { dragEndedCount += 1 }
    coordinator.panel.onClick = { clickCount += 1 }
    let initialOrigin = coordinator.panel.frame.origin

    let down = try #require(mouseEvent(type: .leftMouseDown, location: .zero, panel: coordinator.panel))
    let dragged = try #require(mouseEvent(type: .leftMouseDragged, location: NSPoint(x: 12, y: 8), panel: coordinator.panel))
    let up = try #require(mouseEvent(type: .leftMouseUp, location: NSPoint(x: 12, y: 8), panel: coordinator.panel))
    coordinator.panel.sendEvent(down)
    coordinator.panel.sendEvent(dragged)
    coordinator.panel.sendEvent(up)

    #expect(dragBeganCount == 1)
    #expect(dragEndedCount == 1)
    #expect(clickCount == 0)
    let cursorScreenPoint = NSPoint(x: initialOrigin.x + 12, y: initialOrigin.y + 8)
    #expect(coordinator.panel.frame.origin == NSPoint(
        x: cursorScreenPoint.x - MascotPanel.hangingCursorAttachment.x,
        y: cursorScreenPoint.y - MascotPanel.hangingCursorAttachment.y
    ))
}

@MainActor
@Test func aDropKeepsBothTheColumnAndTheHeightItLandedAt() {
    let coordinator = WindowCoordinator(contentView: NSView())
    defer { coordinator.setVisible(false) }

    coordinator.reposition()
    let laneY = coordinator.panel.frame.minY
    let dropped = NSPoint(x: (coordinator.horizontalMovementBounds()?.upperBound ?? 400) - 30, y: laneY + 260)

    coordinator.panel.setFrameOrigin(dropped)
    coordinator.settleAfterDrop()

    // The owner's requirement: roam from wherever it was dropped, not from the
    // bottom lane.
    #expect(coordinator.panel.frame.origin == dropped)
    #expect(coordinator.hasManualPlacement)
}

/// The invariant a settle must leave behind, whatever the display arrangement:
/// the mascot sits inside the bounds of the display it settled against, and
/// that display can actually show it.
///
/// This is deliberately checked against bounds read *after* the settle. The
/// earlier version of this test compared against bounds sampled before the
/// panel was moved, which only holds on a single display: with a second one
/// attached, a panel shoved past the primary's edge lands over — or nearest to
/// — the other display, and the bounds that apply are that display's. That made
/// the assertion depend on which display held the key window, because
/// `NSScreen.main` was picking the display. See `ScreenPlacementTests` for the
/// arrangement-independent coverage of which display gets chosen.
@MainActor
private func expectSettledIntoView(_ coordinator: WindowCoordinator) throws {
    let horizontal = try #require(coordinator.horizontalMovementBounds())
    let vertical = try #require(coordinator.verticalPlacementBounds())

    #expect(horizontal.contains(coordinator.panel.frame.minX))
    #expect(vertical.contains(coordinator.panel.frame.minY))
    // Otherwise a pet dropped off the edge would roam somewhere it cannot be
    // seen or grabbed back.
    #expect(NSScreen.screens.contains { $0.frame.intersects(coordinator.panel.frame) })
}

@MainActor
@Test func aDropPastAnEdgeIsClampedBackIntoView() throws {
    let coordinator = WindowCoordinator(contentView: NSView())
    defer { coordinator.setVisible(false) }

    let desktop = NSScreen.screens.reduce(CGRect.null) { $0.union($1.frame) }
    guard !desktop.isNull else { return }

    // Past every corner of the whole desktop, so no display can contain it
    // however the displays are arranged.
    for stranded in [
        NSPoint(x: desktop.maxX + 500, y: desktop.maxY + 500),
        NSPoint(x: desktop.minX - 500, y: desktop.minY - 500),
        NSPoint(x: desktop.maxX + 500, y: desktop.minY - 500),
        NSPoint(x: desktop.minX - 500, y: desktop.maxY + 500)
    ] {
        coordinator.panel.setFrameOrigin(stranded)
        coordinator.settleAfterDrop()

        #expect(coordinator.panel.frame.origin != stranded)
        try expectSettledIntoView(coordinator)
    }
}

@MainActor
@Test func aDropPastEachAttachedDisplaysEdgeIsClampedBackIntoView() throws {
    let coordinator = WindowCoordinator(contentView: NSView())
    defer { coordinator.setVisible(false) }

    // Exercises the second display when one is attached, which is the case the
    // clamp was getting wrong. On a single display it repeats the case above.
    for screen in NSScreen.screens {
        for stranded in [
            NSPoint(x: screen.frame.maxX + 40, y: screen.frame.maxY + 40),
            NSPoint(x: screen.frame.minX - 140, y: screen.frame.minY - 140)
        ] {
            coordinator.panel.setFrameOrigin(stranded)
            coordinator.settleAfterDrop()

            try expectSettledIntoView(coordinator)
        }
    }
}

@MainActor
@Test func aSettledPlacementDoesNotDriftWhenSettledAgain() throws {
    let coordinator = WindowCoordinator(contentView: NSView())
    defer { coordinator.setVisible(false) }

    // `screenParametersChanged` re-settles a dropped mascot on every display
    // change and every wake, so a settle that moved an already-settled panel
    // would walk it across the screen over a working day.
    coordinator.panel.setFrameOrigin(NSPoint(x: 9_000, y: 9_000))
    coordinator.settleAfterDrop()
    let settled = coordinator.panel.frame.origin

    coordinator.settleAfterDrop()
    coordinator.settleAfterDrop()

    #expect(coordinator.panel.frame.origin == settled)
    try expectSettledIntoView(coordinator)
}

@MainActor
@Test func horizontalRoamingPreservesADroppedHeight() {
    let coordinator = WindowCoordinator(contentView: NSView())
    defer { coordinator.setVisible(false) }

    coordinator.reposition()
    let droppedY = coordinator.panel.frame.minY + 200
    coordinator.panel.setFrameOrigin(NSPoint(x: coordinator.panel.frame.minX, y: droppedY))
    coordinator.settleAfterDrop()

    coordinator.setHorizontalPosition(coordinator.panel.frame.minX + 40)

    #expect(coordinator.panel.frame.minY == droppedY)
}

@MainActor
@Test func repositioningIsTheWayBackToTheDefaultLane() {
    let coordinator = WindowCoordinator(contentView: NSView())
    defer { coordinator.setVisible(false) }

    coordinator.reposition()
    let laneOrigin = coordinator.panel.frame.origin

    coordinator.panel.setFrameOrigin(NSPoint(x: laneOrigin.x + 60, y: laneOrigin.y + 220))
    coordinator.settleAfterDrop()
    #expect(coordinator.hasManualPlacement)

    coordinator.reposition()

    #expect(coordinator.hasManualPlacement == false)
    #expect(coordinator.panel.frame.origin == laneOrigin)
}

@MainActor
private func mouseEvent(type: NSEvent.EventType, location: NSPoint, panel: NSPanel) -> NSEvent? {
    NSEvent.mouseEvent(
        with: type,
        location: location,
        modifierFlags: [],
        timestamp: 0,
        windowNumber: panel.windowNumber,
        context: nil,
        eventNumber: 1,
        clickCount: 1,
        pressure: type == .leftMouseUp ? 0 : 1
    )
}
