#!/usr/bin/env swift

import AppKit
import Foundation

enum ComponentError: Error {
    case usage
    case unreadableInput
    case noVisiblePixels
    case unwritableOutput
}

func writePNG(_ image: CGImage, to path: String) throws {
    let representation = NSBitmapImageRep(cgImage: image)
    guard let data = representation.representation(using: .png, properties: [:]) else {
        throw ComponentError.unwritableOutput
    }
    try data.write(to: URL(fileURLWithPath: path), options: .atomic)
}

do {
    guard CommandLine.arguments.count == 3 else {
        throw ComponentError.usage
    }

    let input = CommandLine.arguments[1]
    let output = CommandLine.arguments[2]
    guard
        let data = try? Data(contentsOf: URL(fileURLWithPath: input)),
        let representation = NSBitmapImageRep(data: data),
        let source = representation.cgImage
    else {
        throw ComponentError.unreadableInput
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
        throw ComponentError.unreadableInput
    }
    context.draw(source, in: CGRect(x: 0, y: 0, width: width, height: height))
    guard let rawData = context.data else {
        throw ComponentError.unreadableInput
    }
    let pixels = rawData.assumingMemoryBound(to: UInt8.self)

    let pixelCount = width * height
    var component = [Int32](repeating: -1, count: pixelCount)
    var largestID: Int32 = -1
    var largestSize = 0
    var nextID: Int32 = 0

    for start in 0..<pixelCount where component[start] == -1 {
        if pixels[start * 4 + 3] == 0 {
            component[start] = -2
            continue
        }

        let id = nextID
        nextID += 1
        var queue = [start]
        component[start] = id
        var cursor = 0

        while cursor < queue.count {
            let index = queue[cursor]
            cursor += 1
            let x = index % width
            let y = index / width
            let neighbors = [
                x > 0 ? index - 1 : -1,
                x + 1 < width ? index + 1 : -1,
                y > 0 ? index - width : -1,
                y + 1 < height ? index + width : -1
            ]
            for neighbor in neighbors where neighbor >= 0 && component[neighbor] == -1 {
                if pixels[neighbor * 4 + 3] == 0 {
                    component[neighbor] = -2
                } else {
                    component[neighbor] = id
                    queue.append(neighbor)
                }
            }
        }

        if queue.count > largestSize {
            largestID = id
            largestSize = queue.count
        }
    }

    guard largestID >= 0 else {
        throw ComponentError.noVisiblePixels
    }

    for index in 0..<pixelCount where component[index] != largestID {
        pixels[index * 4] = 0
        pixels[index * 4 + 1] = 0
        pixels[index * 4 + 2] = 0
        pixels[index * 4 + 3] = 0
    }

    guard let cleaned = context.makeImage() else {
        throw ComponentError.unreadableInput
    }
    try writePNG(cleaned, to: output)
    print("Kept largest alpha component (\(largestSize) pixels) in \(output)")
} catch ComponentError.usage {
    fputs("Usage: keep_largest_alpha_component.swift <input.png> <output.png>\n", stderr)
    exit(2)
} catch {
    fputs("Failed to clean alpha components: \(error)\n", stderr)
    exit(1)
}
