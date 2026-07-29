import Foundation
@testable import MascotTransport
import Testing

private func bytes(_ string: String) -> Data {
    Data(string.utf8)
}

private func frames(_ outputs: [EventFrameReader.Output]) -> [String] {
    outputs.compactMap {
        guard case .frame(let data) = $0 else { return nil }
        return String(decoding: data, as: UTF8.self)
    }
}

@Test func readsOneFrameFromOneWrite() {
    var reader = EventFrameReader()

    #expect(frames(reader.append(bytes("{\"a\":1}\n"))) == ["{\"a\":1}"])
}

@Test func readsSeveralFramesFromOneWrite() {
    var reader = EventFrameReader()

    #expect(frames(reader.append(bytes("one\ntwo\nthree\n"))) == ["one", "two", "three"])
}

@Test func joinsAFrameSplitAcrossWrites() {
    var reader = EventFrameReader()

    #expect(reader.append(bytes("{\"par")).isEmpty)
    #expect(reader.append(bytes("tial\":true}")).isEmpty)
    #expect(frames(reader.append(bytes("\n"))) == ["{\"partial\":true}"])
}

@Test func byteAtATimeDeliveryProducesTheSameFrame() {
    var reader = EventFrameReader()
    var outputs: [EventFrameReader.Output] = []

    for byte in bytes("hello\n") {
        outputs += reader.append(Data([byte]))
    }

    #expect(frames(outputs) == ["hello"])
}

@Test func emptyLinesAreIgnoredRatherThanTreatedAsFrames() {
    var reader = EventFrameReader()

    #expect(frames(reader.append(bytes("\n\n\nreal\n\n"))) == ["real"])
}

@Test func trailingCarriageReturnIsTrimmed() {
    var reader = EventFrameReader()

    #expect(frames(reader.append(bytes("windows\r\n"))) == ["windows"])
}

@Test func aTerminatedFrameOverTheCeilingIsDiscarded() {
    var reader = EventFrameReader(maximumFrameBytes: 8)

    let outputs = reader.append(bytes("123456789012\n"))

    #expect(outputs == [.discardedOversizedFrame(bytes: 12)])
}

@Test func aFloodWithNoNewlineIsDiscardedInsteadOfBufferedForever() {
    var reader = EventFrameReader(maximumFrameBytes: 8)

    // Three writes well past the ceiling, none of them terminated.
    for _ in 0 ..< 3 {
        #expect(reader.append(Data(repeating: 0x41, count: 1_000)).isEmpty)
    }
    // The terminator finally arrives and reports one discard, not thousands.
    let outputs = reader.append(bytes("\n"))

    #expect(outputs == [.discardedOversizedFrame(bytes: 3_000)])
}

@Test func anOversizedFrameDoesNotCorruptTheFollowingFrame() {
    var reader = EventFrameReader(maximumFrameBytes: 8)

    let outputs = reader.append(bytes("123456789012\ngood\n"))

    #expect(outputs.count == 2)
    #expect(outputs.first == .discardedOversizedFrame(bytes: 12))
    #expect(frames(outputs) == ["good"])
}

@Test func recoveryWorksWhenTheOversizedFrameSpansWrites() {
    var reader = EventFrameReader(maximumFrameBytes: 8)

    #expect(reader.append(Data(repeating: 0x41, count: 20)).isEmpty)
    let outputs = reader.append(bytes("tail\ngood\n"))

    #expect(outputs.first == .discardedOversizedFrame(bytes: 24))
    #expect(frames(outputs) == ["good"])
}

@Test func theDefaultCeilingMatchesTheDecoderPayloadLimit() {
    #expect(EventFrameReader().maximumFrameBytes == 4_096)
}
