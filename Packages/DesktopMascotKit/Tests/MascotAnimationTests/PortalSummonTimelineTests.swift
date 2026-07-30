import MascotAnimation
import Testing

@Test func portalOpensBeforeThePetEmerges() {
    let timeline = PortalSummonTimeline(duration: 1)

    let opening = timeline.frame(at: 0.12)
    #expect(opening.portalOpenness > 0)
    #expect(opening.petReveal == 0)

    let emerging = timeline.frame(at: 0.45)
    #expect(emerging.portalOpenness == 1)
    #expect(emerging.petReveal > 0)
    #expect(emerging.petReveal < 1)
}

@Test func petIsFullyVisibleBeforeThePortalCloses() {
    let timeline = PortalSummonTimeline(duration: 1)
    let frame = timeline.frame(at: 0.77)

    #expect(frame.petReveal == 1)
    #expect(frame.portalOpenness == 1)
    #expect(frame.isComplete == false)
}

@Test func summonTimelineClampsAndCompletes() {
    let timeline = PortalSummonTimeline(duration: 1)

    #expect(timeline.frame(at: -1).progress == 0)
    #expect(timeline.frame(at: 2) == .resting)
}
