import Foundation
import MascotAnimation
import Testing

@Test func sealPlaysUndisturbedBeforeTheSmoke() {
    let timeline = PoofDismissTimeline(duration: 1)
    let frame = timeline.frame(at: 0.39)

    #expect(frame.petReveal == 1)
    #expect(frame.smokeOpacity == 0)
    #expect(frame.smokeExpansion == 0)
    #expect(frame.isComplete == false)
}

@Test func petVanishesWhileTheSmokeIsFullyOpaque() {
    let timeline = PoofDismissTimeline(duration: 1)
    let frame = timeline.frame(at: 0.6)

    // The whole point of the poof: the mascot is never seen fading in the open.
    #expect(frame.petReveal == 0)
    #expect(frame.smokeOpacity == 1)
    #expect(frame.smokeExpansion > 0)
}

@Test func smokeClearsByTheEnd() {
    let timeline = PoofDismissTimeline(duration: 1)
    let frame = timeline.frame(at: 1)

    #expect(frame.smokeOpacity == 0)
    #expect(frame.petReveal == 0)
    #expect(frame.isComplete)
}

@Test func smokeExpandsMonotonically() {
    let timeline = PoofDismissTimeline(duration: 1)
    var previous = -1.0
    for step in 0 ... 20 {
        let expansion = timeline.frame(at: Double(step) / 20).smokeExpansion
        #expect(expansion >= previous)
        previous = expansion
    }
}

@Test func reducedMotionFadesWithoutSealOrSmoke() {
    let timeline = PoofDismissTimeline.reducedMotion()

    #expect(timeline.playsSeal == false)
    let middle = timeline.frame(at: timeline.duration / 2)
    #expect(middle.smokeOpacity == 0)
    #expect(middle.smokeExpansion == 0)
    #expect(middle.petReveal > 0)
    #expect(middle.petReveal < 1)
    #expect(timeline.frame(at: timeline.duration).petReveal == 0)
}

@Test func dismissTimelineClampsAndCompletes() {
    let timeline = PoofDismissTimeline(duration: 1)

    #expect(timeline.frame(at: -1).progress == 0)
    #expect(timeline.frame(at: -1).petReveal == 1)
    #expect(timeline.frame(at: 2).progress == 1)
    #expect(timeline.frame(at: 2).isComplete)
}

/// The seal and the smoke are timed independently — the atlas row plays on its
/// own declared durations while the timeline runs the poof — so the two have to
/// be checked against each other rather than assumed to line up.
@Test func handSignRowFinishesMovingBeforeTheSmokeStarts() throws {
    let repositoryRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
    let contractData = try Data(
        contentsOf: repositoryRoot.appending(path: "art/animation/atlas-contract.json")
    )
    let contract = try JSONDecoder().decode(AtlasContract.self, from: contractData)
    let row = try #require(contract.row(named: "hand-sign"))

    #expect(row.playback == "once-hold")
    #expect(row.durationsMS.last == .hold)

    let movingDuration = row.durationsMS.reduce(0.0) { total, duration in
        switch duration {
        case let .milliseconds(value): total + Double(value) / 1_000
        case .hold: total
        }
    }

    let timeline = PoofDismissTimeline()
    let sealIsStillClear = timeline.frame(at: movingDuration)
    #expect(sealIsStillClear.smokeOpacity == 0)
    #expect(sealIsStillClear.petReveal == 1)
}
