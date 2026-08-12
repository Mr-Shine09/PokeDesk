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

@MainActor
@Test func aDropPastAnEdgeIsClampedBackIntoView() {
    let coordinator = WindowCoordinator(contentView: NSView())
    defer { coordinator.setVisible(false) }

    guard
        let horizontal = coordinator.horizontalMovementBounds(),
        let vertical = coordinator.verticalPlacementBounds()
    else { return }

    coordinator.panel.setFrameOrigin(NSPoint(x: horizontal.upperBound + 500, y: vertical.upperBound + 500))
    coordinator.settleAfterDrop()

    // Otherwise a pet dropped off the edge would roam somewhere it cannot be
    // seen or grabbed back.
    #expect(coordinator.panel.frame.minX == horizontal.upperBound)
    #expect(coordinator.panel.frame.minY == vertical.upperBound)
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

/// A display change must not adopt a relocation macOS performed for us.
///
/// This reproduces the 2026-08-10 unplug defect without needing a second
/// display: moving the panel to the bottom stands in for AppKit relocating a
/// window off a display that has just been removed, and posting the
/// notification is what the system does next. The old handler called
/// `settleAfterDrop()`, which read the *moved* frame and stored it as the
/// user's height, so the drag was lost. Note that the test only bites because
/// the panel is moved first — a screen-parameter change with no relocation
/// preserved the height even before the fix, which is exactly why the bug
/// survived: on the owner's machine a resolution change looked correct and only
/// an unplug did not.
@MainActor
@Test func aDisplayChangeKeepsTheDraggedHeightRatherThanASystemRelocation() {
    let coordinator = WindowCoordinator(contentView: NSView())
    defer { coordinator.setVisible(false) }

    coordinator.reposition()
    let laneY = coordinator.panel.frame.minY
    let droppedY = laneY + 200
    coordinator.panel.setFrameOrigin(NSPoint(x: coordinator.panel.frame.minX, y: droppedY))
    coordinator.settleAfterDrop()
    #expect(coordinator.panel.frame.minY == droppedY)

    // Stand in for AppKit moving the window when its display disappears.
    coordinator.panel.setFrameOrigin(NSPoint(x: coordinator.panel.frame.minX, y: laneY))
    NotificationCenter.default.post(
        name: NSApplication.didChangeScreenParametersNotification,
        object: NSApplication.shared
    )

    #expect(coordinator.panel.frame.minY == droppedY)
    #expect(coordinator.hasManualPlacement)
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

/// The clamp must not consult keyboard focus.
///
/// `aDropPastAnEdgeIsClampedBackIntoView` pins the arithmetic. This pins the
/// property that used to make it flaky: once the panel is dropped clear of
/// every display, `NSWindow.screen` is nil, and the old fallback was
/// `NSScreen.main` — the display with *keyboard focus*. The same drop could
/// therefore settle in two different places depending on where the user was
/// typing. Focus cannot be set from a test, so this asserts what focus
/// dependence would break: the result is a function of the panel alone, and so
/// repeating one drop lands in one place.
@MainActor
@Test func aStrandedDropSettlesDeterministicallyOnTheDisplayItCameFrom() {
    let coordinator = WindowCoordinator(contentView: NSView())
    defer { coordinator.setVisible(false) }

    guard let horizontal = coordinator.horizontalMovementBounds() else { return }
    let origin = coordinator.panel.screen ?? NSScreen.main

    // Clear of every display: far right of them all, and far above them all.
    let stranded = NSPoint(x: horizontal.upperBound + 5_000, y: 50_000)
    coordinator.panel.setFrameOrigin(stranded)
    #expect(coordinator.panel.screen == nil, "the drop must actually strand the panel for this to test anything")

    coordinator.settleAfterDrop()
    let settled = coordinator.panel.frame

    #expect(NSScreen.screens.contains { $0.frame.intersects(settled) })
    // Back on the display it started on, not moved to a different one.
    #expect(origin?.frame.intersects(settled) == true)

    // And the same drop twice lands in the same place.
    coordinator.panel.setFrameOrigin(stranded)
    coordinator.settleAfterDrop()
    #expect(coordinator.panel.frame.origin == settled.origin)
}

/// Rounding and clamping must agree about which display is in play.
///
/// The walk rounds its next x to whole device pixels, and it used to take that
/// scale from `panel.screen?.backingScaleFactor ?? 2`. `panel.screen` is nil
/// exactly when the panel lies clear of every display, which is when
/// `referenceScreen` falls back to the remembered display — so the two could
/// name different displays, and on a mixed Retina and non-Retina arrangement
/// different scales. The assertion holds on one display too; it only has teeth
/// with two of differing scale attached.
@MainActor
@Test func theRoundingScaleFollowsTheDisplayPlacementUses() {
    let coordinator = WindowCoordinator(contentView: NSView())
    defer { coordinator.setVisible(false) }

    guard let horizontal = coordinator.horizontalMovementBounds() else { return }
    let expected = (coordinator.panel.screen ?? NSScreen.main)?.backingScaleFactor

    // Strand the panel so `panel.screen` is nil and the fallback path decides.
    coordinator.panel.setFrameOrigin(NSPoint(x: horizontal.upperBound + 5_000, y: 50_000))
    #expect(coordinator.panel.screen == nil, "the drop must actually strand the panel for this to test anything")

    // The remembered display still answers, rather than an assumed Retina 2.
    #expect(coordinator.placementBackingScaleFactor == expected)

    // And after settling, it matches the display the panel actually landed on.
    coordinator.settleAfterDrop()
    let landed = NSScreen.screens.first { $0.frame.intersects(coordinator.panel.frame) }
    #expect(coordinator.placementBackingScaleFactor == landed?.backingScaleFactor)
}
