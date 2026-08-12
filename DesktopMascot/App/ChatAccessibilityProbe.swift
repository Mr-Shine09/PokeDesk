import AppKit
import ApplicationServices
import MascotCore

/// A one-off diagnostic that answers a single question: **does the Claude
/// desktop app expose anything through the accessibility API that marks a
/// response as being generated?**
///
/// This exists because the alternative is guessing. Adding lifecycle detection
/// for the chat interface reverses this project's standing "no accessibility
/// permissions" promise (owner decision, 2026-08-11), and it is only worth
/// reversing if a signal is actually there. Claude is an Electron app, and
/// Chromium builds its accessibility tree lazily — nothing exists to inspect
/// until a client asks — so nobody could know without asking.
///
/// **What it deliberately does not collect, and the rule that changed.** The
/// first version reported the *labels* of controls in full, on the theory that a
/// label is interface structure while static text is content. Claude disproved
/// it immediately: a summary of the owner's conversation lives in a button
/// title, and it landed in a file on the Desktop. **`AXTitle` and `AXValue` are
/// now reported as a character count for every role, not just text roles.**
///
/// `AXDescription` and `AXHelp` are still reported in full, because the marker
/// this probe exists to find lives in one of them — but only up to
/// `readableLimit` characters. A UI marker is a few words; a leaked message is
/// not. Anything longer is reported as a length, so widening the search cannot
/// quietly turn into reading the conversation.
///
/// If this probe ever needs message text to work, the answer is that the feature
/// is not possible within any boundary worth keeping.
@MainActor
enum ChatAccessibilityProbe {
    /// Attributes safe to print verbatim: structural, and short by nature.
    private static let structuralAttributes = [
        kAXSubroleAttribute, kAXIdentifierAttribute, kAXEnabledAttribute,
    ] as [CFString]

    /// Attributes that may carry the marker and may carry prose. Printed when
    /// short, reported as a length when not.
    private static let boundedAttributes = [
        kAXDescriptionAttribute, kAXHelpAttribute,
    ] as [CFString]

    /// Attributes never printed. A button title held a conversation summary in
    /// the Claude app, so there is no role for which a title is known safe.
    private static let redactedAttributes = [
        kAXTitleAttribute, kAXValueAttribute,
    ] as [CFString]

    /// Longest string printed verbatim. `Currently streaming message` is 27
    /// characters; a sentence of someone's chat is longer than this.
    private static let readableLimit = 80

    static var isTrusted: Bool { AXIsProcessTrusted() }

    /// Prompts once for Accessibility access. macOS shows its own dialog and
    /// records the answer; the app cannot grant this to itself.
    static func requestAccess() {
        // The key is spelled out rather than read from
        // `kAXTrustedCheckOptionPrompt`, which Swift 6 rejects as shared mutable
        // state. The constant's value is this string and is part of the public
        // API contract.
        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    /// Walks one chat app's window and writes a redacted report.
    ///
    /// Takes the app rather than assuming Claude, because the same question has
    /// to be asked of every provider before it can be wired: ChatGPT ships as a
    /// different kind of application and there is no reason its tree should
    /// resemble Electron's.
    ///
    /// Returns the path written, or a message explaining why nothing was.
    static func writeReport(for target: ChatApp.Descriptor) -> String {
        guard isTrusted else {
            return "Accessibility access is not granted yet — use Request Accessibility Access first."
        }
        guard
            let app = NSWorkspace.shared.runningApplications.first(where: {
                $0.bundleIdentifier == target.bundleIdentifier
            })
        else {
            return "The \(target.displayName) desktop app is not running."
        }

        let element = AXUIElementCreateApplication(app.processIdentifier)
        var lines: [String] = [
            "Dock Pet chat accessibility probe",
            "Generated: \(ISO8601DateFormatter().string(from: Date()))",
            "Target: \(target.bundleIdentifier) (pid \(app.processIdentifier))",
            "AXDescription and AXHelp are printed when under \(readableLimit) characters.",
            "AXTitle and AXValue are never printed — a button title held conversation",
            "content once already. Everything else is a role and a character count.",
            "",
        ]
        describe(element, depth: 0, into: &lines)

        // Timestamped, because a fixed name made the second report silently
        // overwrite the first: the owner captured a streaming response, captured
        // the finished one over it, and then renamed the survivor "generating".
        // The instruction that would have avoided it was "rename between the two
        // clicks", which is a footgun rather than a step. Two reports are the
        // whole point of this probe, so they must not be able to collide.
        let stamp = DateFormatter()
        stamp.dateFormat = "HHmmss"
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop/dockpet-chat-ax-\(stamp.string(from: Date())).txt")
        do {
            try lines.joined(separator: "\n").write(to: url, atomically: true, encoding: .utf8)
            return "Wrote \(lines.count) lines to \(url.path)"
        } catch {
            return "Could not write the report: \(error.localizedDescription)"
        }
    }

    /// Depth is capped only to stop a cycle, not to keep the report short.
    ///
    /// The first run capped it at 18 and produced a report that looked complete
    /// and was useless: 41 nodes sat at depth 17, so the walk stopped precisely
    /// where the conversation begins. Electron nests roughly fifteen levels of
    /// `AXGroup` before any content, which is more than a hand-picked limit is
    /// likely to guess. **A truncated tree is indistinguishable from an app that
    /// exposes nothing** — that is the failure this cap caused once already.
    private static func describe(_ element: AXUIElement, depth: Int, into lines: inout [String]) {
        guard depth < 60 else { return }

        let role = string(of: element, kAXRoleAttribute as CFString) ?? "?"

        // The menu bar was 220 of the first report's 313 lines and cannot hold a
        // streaming indicator. Skipping it is the difference between a report
        // that is mostly noise and one that is mostly window.
        if role == "AXMenuBar" { return }

        let indent = String(repeating: "  ", count: depth)
        var parts: [String] = []

        for attribute in structuralAttributes {
            if let value = string(of: element, attribute), !value.isEmpty {
                parts.append("\(attribute as String)=\(value)")
            }
        }
        for attribute in boundedAttributes {
            guard let value = string(of: element, attribute), !value.isEmpty else { continue }
            if value.count <= readableLimit {
                parts.append("\(attribute as String)=\(value)")
            } else {
                parts.append("\(attribute as String)=<redacted, \(value.count) chars>")
            }
        }
        for attribute in redactedAttributes {
            if let value = string(of: element, attribute), !value.isEmpty {
                parts.append("\(attribute as String)=<redacted, \(value.count) chars>")
            }
        }

        lines.append("\(indent)\(role)\(parts.isEmpty ? "" : " " + parts.joined(separator: " "))")

        var childrenValue: CFTypeRef?
        guard
            AXUIElementCopyAttributeValue(
                element, kAXChildrenAttribute as CFString, &childrenValue
            ) == .success,
            let children = childrenValue as? [AXUIElement]
        else { return }

        for child in children {
            describe(child, depth: depth + 1, into: &lines)
        }
    }

    private static func string(of element: AXUIElement, _ attribute: CFString) -> String? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, attribute, &value) == .success else {
            return nil
        }
        switch value {
        case let text as String: return text
        case let number as NSNumber: return number.stringValue
        default: return nil
        }
    }
}
