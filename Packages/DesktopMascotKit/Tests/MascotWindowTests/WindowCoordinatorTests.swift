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
