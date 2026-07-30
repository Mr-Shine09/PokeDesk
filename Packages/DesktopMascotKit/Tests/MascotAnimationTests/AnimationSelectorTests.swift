import Foundation
import MascotAnimation
import MascotCore
import Testing

private let boot = Uptime(seconds: 2_000)

// MARK: - State to plan mapping

@Test func everyReducedStateMapsToARowTheAtlasDeclares() {
    // The atlas rows this must match are offline, idle, working, ideating,
    // waiting, success, failure, sleeping, and paused.
    let declaredRows: Set<String> = [
        "offline", "idle", "working", "ideating", "waiting",
        "success", "failure", "sleeping", "paused",
    ]

    for state in MascotState.allCases {
        #expect(declaredRows.contains(AnimationSelector.plan(for: state).restingRow))
    }
}

@Test func onlyTheTwoQuietStatesStrollTheLane() {
    for state in MascotState.allCases {
        let expectedToStroll = state == .offline || state == .idle
        #expect(AnimationSelector.plan(for: state).isAmbient == expectedToStroll)
    }
}

@Test func workingAndWaitingHoldTheirOwnRowInPlace() {
    #expect(AnimationSelector.plan(for: .working) == .stationary(row: "working"))
    #expect(AnimationSelector.plan(for: .waiting) == .stationary(row: "waiting"))
}

@Test func offlineAndIdleStrollWithDifferentRests() {
    #expect(AnimationSelector.plan(for: .offline) == .ambient(restingRow: "offline"))
    #expect(AnimationSelector.plan(for: .idle) == .ambient(restingRow: "idle"))
}

// MARK: - Dwell

@Test func theFirstChangeIsShownImmediately() {
    var selector = AnimationSelector()

    #expect(selector.update(to: .working, at: boot) == .working)
}

@Test func aSecondChangeInsideTheDwellWindowIsHeldBack() {
    var selector = AnimationSelector()
    selector.update(to: .working, at: boot)

    #expect(selector.update(to: .waiting, at: boot.advanced(by: 0.2)) == .working)
    #expect(selector.displayedState == .working)
}

@Test func aHeldBackStateIsCommittedOnceTheDwellElapses() {
    var selector = AnimationSelector()
    selector.update(to: .working, at: boot)
    selector.update(to: .waiting, at: boot.advanced(by: 0.2))

    #expect(selector.tick(at: boot.advanced(by: 0.8)) == .waiting)
}

@Test func onlyTheNewestStateInsideOneWindowIsEverShown() {
    var selector = AnimationSelector()
    selector.update(to: .working, at: boot)

    // A burst of tool churn: none of these intermediate states should appear.
    selector.update(to: .waiting, at: boot.advanced(by: 0.1))
    selector.update(to: .working, at: boot.advanced(by: 0.2))
    selector.update(to: .waiting, at: boot.advanced(by: 0.3))
    selector.update(to: .success, at: boot.advanced(by: 0.4))
    #expect(selector.displayedState == .working)

    #expect(selector.tick(at: boot.advanced(by: 1.0)) == .success)
}

@Test func returningToTheDisplayedStateInsideTheWindowCancelsThePendingChange() {
    var selector = AnimationSelector()
    selector.update(to: .working, at: boot)
    selector.update(to: .waiting, at: boot.advanced(by: 0.1))

    // Flapped back before the dwell elapsed, so nothing should change later.
    selector.update(to: .working, at: boot.advanced(by: 0.2))

    #expect(selector.tick(at: boot.advanced(by: 5)) == .working)
}

@Test func tickWithoutAPendingChangeIsInert() {
    var selector = AnimationSelector()
    selector.update(to: .working, at: boot)

    #expect(selector.tick(at: boot.advanced(by: 100)) == .working)
    #expect(selector.displayedState == .working)
}

// MARK: - Manual pause bypasses the dwell

@Test func pauseIsShownImmediatelyEvenInsideTheDwellWindow() {
    var selector = AnimationSelector()
    selector.update(to: .working, at: boot)

    #expect(selector.update(to: .paused, at: boot.advanced(by: 0.05)) == .paused)
}

@Test func resumingFromPauseIsAlsoImmediate() {
    var selector = AnimationSelector()
    selector.update(to: .paused, at: boot)

    #expect(selector.update(to: .working, at: boot.advanced(by: 0.05)) == .working)
}

@Test func aSuccessReactionIsNeverCutShorterThanTheDwell() {
    var selector = AnimationSelector()
    selector.update(to: .working, at: boot)
    selector.update(to: .success, at: boot.advanced(by: 1))

    // The reducer drops back to idle the instant the reaction window closes;
    // the pet must still have shown the reaction for a readable moment.
    #expect(selector.update(to: .idle, at: boot.advanced(by: 1.1)) == .success)
    #expect(selector.tick(at: boot.advanced(by: 1.8)) == .idle)
}
