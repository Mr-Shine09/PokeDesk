import Foundation

public enum MascotState: String, CaseIterable, Codable, Sendable {
    case offline
    case idle
    case working
    case ideating
    case waiting
    case success
    case failure
    case sleeping
    case paused

    public var displayName: String {
        rawValue.capitalized
    }
}

public enum AmbientAnimation: String, CaseIterable, Codable, Sendable {
    case idle
    case walkRight = "walk-right"
    case walkLeft = "walk-left"
    case sitShakeRight = "sit-shake-right"
    case sitShakeLeft = "sit-shake-left"
    case hanging
}
