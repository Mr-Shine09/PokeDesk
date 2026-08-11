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
/// **What it deliberately does not collect.** Roles, subroles, identifiers, and
/// the labels of *controls* go into the report. The text of static elements
/// never does: that is the conversation, and it is the exact thing this app has
/// always refused to read. Text nodes are recorded as a role and a character
/// count so the tree's shape stays legible without its contents. If this probe
/// ever needs message text to work, the answer is that the feature is not
/// possible within any boundary worth keeping.
@MainActor
enum ChatAccessibilityProbe {
    /// Roles whose `AXValue`/`AXTitle` is user content rather than UI structure.
    private static let contentRoles: Set<String> = [
        "AXStaticText", "AXTextArea", "AXTextField", "AXHeading", "AXParagraph",
    ]

    /// Attributes worth reporting for a control. `AXValue` is included because a
    /// button's value is a state (pressed, expanded), not prose — and it is read
    /// only for elements whose role is not in `contentRoles`.
    private static let reportedAttributes = [
        kAXRoleAttribute, kAXSubroleAttribute, kAXTitleAttribute,
        kAXDescriptionAttribute, kAXHelpAttribute, kAXIdentifierAttribute,
        kAXValueAttribute, kAXEnabledAttribute,
    ] as [CFString]

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

    /// Walks the frontmost Claude window and writes a redacted report.
    ///
    /// Returns the path written, or a message explaining why nothing was.
    static func writeReport() -> String {
        guard isTrusted else {
            return "Accessibility access is not granted yet — use Request Accessibility Access first."
        }
        guard
            let app = NSWorkspace.shared.runningApplications.first(where: {
                $0.bundleIdentifier == "com.anthropic.claudefordesktop"
            })
        else {
            return "The Claude desktop app is not running."
        }

        let element = AXUIElementCreateApplication(app.processIdentifier)
        var lines: [String] = [
            "Dock Pet chat accessibility probe",
            "Generated: \(ISO8601DateFormatter().string(from: Date()))",
            "Target: com.anthropic.claudefordesktop (pid \(app.processIdentifier))",
            "Control labels and roles are reported; static text is reported as a length only.",
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

        if contentRoles.contains(role) {
            let length = (string(of: element, kAXValueAttribute as CFString)
                ?? string(of: element, kAXTitleAttribute as CFString) ?? "").count
            lines.append("\(indent)\(role) <text redacted, \(length) chars>")
        } else {
            var parts: [String] = []
            for attribute in reportedAttributes where attribute != kAXRoleAttribute as CFString {
                if let value = string(of: element, attribute), !value.isEmpty {
                    parts.append("\(attribute as String)=\(value)")
                }
            }
            lines.append("\(indent)\(role)\(parts.isEmpty ? "" : " " + parts.joined(separator: " "))")
        }

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
