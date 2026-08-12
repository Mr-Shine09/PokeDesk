import Darwin
import Foundation
import MascotCore
import Testing

@testable import MascotTransport

/// A stand-in process table: pid -> (executable path, parent pid).
private struct FakeTree {
    var entries: [pid_t: (path: String?, parent: pid_t?)]

    func path(_ pid: pid_t) -> String? { entries[pid]?.path ?? nil }
    func parent(_ pid: pid_t) -> pid_t? { entries[pid]?.parent ?? nil }

    func surface(from pid: pid_t) -> EventSurface {
        EventSurfaceDetector.surface(startingAt: pid, executablePath: path, parent: parent)
    }
}

private let chatGPTCodex = "/Applications/ChatGPT.app/Contents/Resources/codex"
private let chatGPTApp = "/Applications/ChatGPT.app/Contents/MacOS/ChatGPT"
private let helper = "/Users/x/Applications/Dock Pet.app/Contents/MacOS/dockpet-event"

@Test func aHookUnderTheChatGPTAppIsADesktopChat() {
    // The real shape, from the observed process tree: the app runs its own
    // bundled codex, which fires the hook, which runs the helper.
    let tree = FakeTree(entries: [
        100: (helper, 101),
        101: (chatGPTCodex, 102),
        102: (chatGPTApp, 1),
    ])
    #expect(tree.surface(from: 100) == .desktopChat)
}

@Test func aHookUnderAShellIsACommandLine() {
    let tree = FakeTree(entries: [
        100: (helper, 101),
        101: ("/opt/homebrew/bin/codex", 102),
        102: ("/bin/zsh", 103),
        103: ("/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal", 1),
    ])
    #expect(tree.surface(from: 100) == .commandLine)
}

@Test func theClaudeAppIsNotTreatedAsAChatSurface() {
    // Claude.app hosts Claude Code, which is agent work and must keep sitting at
    // its computer. Its chat half is detected by reading the window instead, so
    // adding Claude.app to the markers would turn every Claude Code turn into a
    // Thinker pose.
    let tree = FakeTree(entries: [
        100: (helper, 101),
        101: ("/Applications/Claude.app/Contents/Resources/claude", 102),
        102: ("/Applications/Claude.app/Contents/MacOS/Claude", 1),
    ])
    #expect(tree.surface(from: 100) == .commandLine)
}

@Test func aLookalikeBundleNameDoesNotMatch() {
    // Matched as a path component with its trailing slash. A directory merely
    // starting with the bundle's name is not the app.
    let tree = FakeTree(entries: [
        100: (helper, 101),
        101: ("/Users/x/src/ChatGPT.app-clone/codex", 1),
    ])
    #expect(tree.surface(from: 100) == .commandLine)
}

@Test func aProcessThatVanishedMidWalkDoesNotStopTheSearch() {
    // Ancestors exit routinely while a hook runs. A missing path must not end
    // the walk, or the app one level further up would go unseen.
    let tree = FakeTree(entries: [
        100: (helper, 101),
        101: (nil, 102),
        102: (chatGPTApp, 1),
    ])
    #expect(tree.surface(from: 100) == .desktopChat)
}

@Test func anUnknownParentFallsBackToCommandLine() {
    // The safe default: an origin nobody could determine behaves exactly as Dock
    // Pet did before surfaces existed.
    let tree = FakeTree(entries: [100: (helper, nil)])
    #expect(tree.surface(from: 100) == .commandLine)
}

@Test func aCycleInTheProcessTableTerminates() {
    // Cannot happen on a healthy system, and the walk must still return rather
    // than hang inside a user's agent session.
    let tree = FakeTree(entries: [
        100: (helper, 101),
        101: ("/bin/zsh", 100),
    ])
    #expect(tree.surface(from: 100) == .commandLine)
}

@Test func theWalkIsBoundedEvenOnADeepChain() {
    // A chain longer than the cap must not find an app sitting above the limit;
    // finding it would mean the cap is not doing its job.
    var entries: [pid_t: (path: String?, parent: pid_t?)] = [:]
    for pid in 1 ..< 40 {
        entries[pid_t(pid)] = ("/bin/zsh", pid_t(pid + 1))
    }
    entries[40] = (chatGPTApp, 1)
    #expect(FakeTree(entries: entries).surface(from: 1) == .commandLine)
}

@Test func theRealProcessTreeAnswersWithoutCrashing() {
    // Not an assertion about this test runner's ancestry — it is run from a
    // terminal or from Xcode and either is legitimate. It exercises the real
    // `proc_pidpath`/`sysctl` path, which the injected tests never touch.
    #expect(EventSurfaceDetector.appBundleMarkers.contains("/ChatGPT.app/"))
    _ = EventSurfaceDetector.current()
}
