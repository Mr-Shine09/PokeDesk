import Darwin
import Foundation
import MascotCore

/// Works out whether a hook fired inside a desktop app's own interface or at a
/// command line, by walking the helper process's parent chain.
///
/// ## Why this exists
///
/// The ChatGPT desktop app **is** the Codex app — that is why it ships as
/// `com.openai.codex`. It runs its own bundled `codex` binary, which fires the
/// same `~/.codex/hooks.json` hooks as the command-line one, with byte-identical
/// payloads from the same provider. A chat turn and a terminal agent run are
/// therefore indistinguishable at the event level, and the owner wants them to
/// look different: chat thinks, the terminal types (owner rule, 2026-08-11).
///
/// ## Why in the helper
///
/// The helper is a child of the process that fired the hook, so the answer is
/// sitting in its own ancestry and needs no permission, no accessibility API, and
/// no UI string that an app update can rename. The app cannot work this out on
/// its own: by the time an event arrives over the socket, the only thing tying it
/// to an origin is a hashed session ID.
///
/// ## What leaves this file
///
/// **One of two words.** Executable paths are read from the local process table
/// and compared here; no path, argument, process name, or PID is put in the
/// envelope or sent anywhere. The envelope gains `surface` and nothing else — see
/// `EventSurface`, whose widening of the privacy boundary is a recorded owner
/// decision rather than an implementation detail.
public enum EventSurfaceDetector {
    /// Bundle directories whose processes count as a desktop chat interface.
    ///
    /// Matched as a path component, `.app/`, rather than by name anywhere in the
    /// string: a checkout at `~/src/ChatGPT.app-clone/` would otherwise read as
    /// the real thing.
    ///
    /// **`Claude.app` is deliberately absent.** It hosts Claude Code as well as
    /// its chat, and Claude Code is agent work that must keep sitting at its
    /// computer; the chat half is detected by reading the window instead. Adding
    /// it here would turn every Claude Code turn into a Thinker pose.
    ///
    /// Anything unlisted is `commandLine`, which is the safe default: an
    /// unrecognized origin keeps the behavior Dock Pet has always had rather than
    /// quietly reclassifying agent work as a conversation.
    public static let appBundleMarkers = ["/ChatGPT.app/"]

    /// How far up the parent chain to look.
    ///
    /// The ChatGPT app sits three or four levels above a hook (app → bundled
    /// `codex` → hook shell → helper), and a terminal run is a similar depth
    /// through a shell. Sixteen is far past both and bounds the walk if the
    /// process table ever hands back a cycle.
    private static let maximumAncestors = 16

    /// The surface this process is running under.
    public static func current() -> EventSurface {
        surface(
            startingAt: getpid(),
            executablePath: { executablePath(of: $0) },
            parent: { parentPID(of: $0) }
        )
    }

    /// Injectable form, so the walk is testable without a real process tree.
    ///
    /// The two closures are the only places this touches the system, and both
    /// return `nil` for a process that has gone away — which happens routinely,
    /// since an ancestor can exit while the walk is in progress.
    public static func surface(
        startingAt pid: pid_t,
        executablePath: (pid_t) -> String?,
        parent: (pid_t) -> pid_t?
    ) -> EventSurface {
        var current = pid
        var seen: Set<pid_t> = []

        for _ in 0 ..< maximumAncestors {
            guard !seen.contains(current) else { break }
            seen.insert(current)

            if let path = executablePath(current),
               appBundleMarkers.contains(where: path.contains) {
                return .desktopChat
            }

            // pid 1 is `launchd`; there is nothing above it, and a pid of 0 means
            // the process table had no answer.
            guard let next = parent(current), next > 1 else { break }
            current = next
        }
        return .commandLine
    }

    // MARK: - Process table

    private static func executablePath(of pid: pid_t) -> String? {
        var buffer = [UInt8](repeating: 0, count: Int(MAXPATHLEN))
        let length = proc_pidpath(pid, &buffer, UInt32(buffer.count))
        guard length > 0 else { return nil }
        return String(decoding: buffer[..<Int(length)], as: UTF8.self)
    }

    private static func parentPID(of pid: pid_t) -> pid_t? {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var name: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
        guard sysctl(&name, UInt32(name.count), &info, &size, nil, 0) == 0, size > 0 else {
            return nil
        }
        return info.kp_eproc.e_ppid
    }
}
