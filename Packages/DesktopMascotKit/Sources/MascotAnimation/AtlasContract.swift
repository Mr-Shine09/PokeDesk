import Foundation

public struct AtlasContract: Decodable, Sendable {
    public let schemaVersion: Int
    public let scale: Int
    public let atlas: AtlasSpec
    public let rows: [Row]

    public struct AtlasSpec: Decodable, Sendable {
        public let columns: Int
        public let rows: Int
        public let pixelSize: [Int]
        public let cellPixelSize: [Int]
        public let cellPointSize: [Int]

        enum CodingKeys: String, CodingKey {
            case columns, rows
            case pixelSize = "pixel_size"
            case cellPixelSize = "cell_pixel_size"
            case cellPointSize = "cell_point_size"
        }
    }

    public struct Row: Decodable, Sendable {
        public let index: Int
        public let state: String
        public let frames: Int
        public let playback: String
        public let durationsMS: [FrameDuration]

        enum CodingKeys: String, CodingKey {
            case index, state, frames, playback
            case durationsMS = "durations_ms"
        }
    }

    public enum FrameDuration: Decodable, Equatable, Sendable {
        case milliseconds(Int)
        case hold

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let milliseconds = try? container.decode(Int.self) {
                self = .milliseconds(milliseconds)
            } else if try container.decode(String.self) == "hold" {
                self = .hold
            } else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Frame duration must be a positive integer or hold"
                )
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case scale, atlas, rows
    }

    public func row(named state: String) -> Row? {
        rows.first { $0.state == state }
    }
}
