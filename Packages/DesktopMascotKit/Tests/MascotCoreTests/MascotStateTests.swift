import MascotCore
import Testing

@Test func versionZeroOneStatesRemainStable() {
    #expect(MascotState.allCases.map(\.rawValue) == [
        "offline", "idle", "working", "ideating", "waiting",
        "success", "failure", "sleeping", "paused",
    ])
}

@Test func ambientAnimationsIncludeCornerSitting() {
    #expect(AmbientAnimation.allCases.contains(.sitShakeRight))
    #expect(AmbientAnimation.allCases.contains(.sitShakeLeft))
}
