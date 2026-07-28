#!/usr/bin/env swift

import AppKit
import Foundation

enum CheckerboardError: Error {
    case usage
    case unreadableInput
    case unwritableOutput
}

func writePNG(_ image: CGImage, to path: String) throws {
    let representation = NSBitmapImageRep(cgImage: image)
    guard let data = representation.representation(using: .png, properties: [:]) else {
        throw CheckerboardError.unwritableOutput
    }
    try data.write(to: URL(fileURLWithPath: path), options: .atomic)
}

do {
    guard CommandLine.arguments.count == 3 else {
        throw CheckerboardError.usage
    }

    let input = CommandLine.arguments[1]
    let output = CommandLine.arguments[2]
    guard
        let data = try? Data(contentsOf: URL(fileURLWithPath: input)),
        let representation = NSBitmapImageRep(data: data),
        let source = representation.cgImage
    else {
        throw CheckerboardError.unreadableInput
    }

    let width = source.width
    let height = source.height
    let bytesPerRow = width * 4
    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    guard let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        throw CheckerboardError.unreadableInput
    }
    context.draw(source, in: CGRect(x: 0, y: 0, width: width, height: height))
    guard let rawData = context.data else {
        throw CheckerboardError.unreadableInput
    }
    let pixels = rawData.assumingMemoryBound(to: UInt8.self)
    let count = width * height

    func isNeutralCheckerPixel(_ index: Int) -> Bool {
        let offset = index * 4
        let r = Int(pixels[offset])
        let g = Int(pixels[offset + 1])
        let b = Int(pixels[offset + 2])
        return min(r, g, b) >= 225 && max(r, g, b) - min(r, g, b) <= 4
    }

    var background = [Bool](repeating: false, count: count)
    var queue: [Int] = []
    queue.reserveCapacity(count)

    func enqueue(_ index: Int) {
        guard !background[index], isNeutralCheckerPixel(index) else { return }
        background[index] = true
        queue.append(index)
    }

    for x in 0..<width {
        enqueue(x)
        enqueue((height - 1) * width + x)
    }
    for y in 0..<height {
        enqueue(y * width)
        enqueue(y * width + width - 1)
    }

    var cursor = 0
    while cursor < queue.count {
        let index = queue[cursor]
        cursor += 1
        let x = index % width
        let y = index / width
        if x > 0 { enqueue(index - 1) }
        if x + 1 < width { enqueue(index + 1) }
        if y > 0 { enqueue(index - width) }
        if y + 1 < height { enqueue(index + width) }
    }

    for index in 0..<count where background[index] {
        let offset = index * 4
        pixels[offset] = 0
        pixels[offset + 1] = 0
        pixels[offset + 2] = 0
        pixels[offset + 3] = 0
    }

    guard let cleaned = context.makeImage() else {
        throw CheckerboardError.unreadableInput
    }
    try writePNG(cleaned, to: output)
    print("Removed \(queue.count) connected checkerboard pixels from \(output)")
} catch CheckerboardError.usage {
    fputs("Usage: remove_checkerboard_background.swift <input.png> <output.png>\n", stderr)
    exit(2)
} catch {
    fputs("Failed to remove checkerboard background: \(error)\n", stderr)
    exit(1)
}
