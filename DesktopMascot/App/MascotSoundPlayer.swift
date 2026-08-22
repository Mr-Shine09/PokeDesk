import AppKit
import MascotCore

/// Plays Dock Pet's short cues: the agent reactions, and the two transitions
/// the user asks for directly.
///
/// Scope is still deliberately narrow, and the line is about *moments* rather
/// than about states. Success and failure are the moments a turn ends and
/// `waiting` is the moment it stops and needs a human, which are the three
/// things worth hearing when you are not looking at the screen; summon and
/// dismiss are moments the user causes on purpose. Working, ideating, and idle
/// are continuous, and a cue for each would turn the mascot into a noise source.
///
/// `waiting` qualifies because *entering* it is an edge, not because the state
/// is short — it is the longest-lived of the three. `onStateAppeared` fires
/// once per entry, so a turn that stops for a permission prompt knocks once and
/// then stays silent for however long the prompt sits unanswered.
///
/// The `waiting` cue is also the only one long enough to outlive the thing it
/// announces: it runs about four and a half seconds at owner request, and a
/// prompt answered in one is common. It is therefore cut short whenever
/// anything else reaches the screen — see `stateDidAppear` and `stop(_:)`.
///
/// Nothing here observes agent data. It receives a `MascotState` the reducer
/// already produced, or a transition the user triggered, and plays a bundled
/// file — so the privacy boundary is untouched. No provider, session, or event
/// detail reaches this type.
@MainActor
final class MascotSoundPlayer {
    /// Raw values are the bundled resource names.
    enum Cue: String, CaseIterable {
        case success
        case failure
        case waiting
        case summon
        case dismiss
    }

    /// Held so a repeated cue restarts instead of overlapping, and so
    /// back-to-back turns cannot stack into a drone.
    private var sounds: [Cue: NSSound] = [:]

    var isMuted: Bool {
        didSet {
            Preferences.soundsMuted = isMuted
            if isMuted { stop() }
        }
    }

    init(bundle: Bundle = .main) {
        isMuted = Preferences.soundsMuted
        for cue in Cue.allCases {
            // A missing cue is not worth failing the launch over: the mascot is
            // a visual tool first, and it should still animate on a build where
            // the audio resource did not make it into the bundle.
            guard
                let url = bundle.url(forResource: cue.rawValue, withExtension: "wav"),
                let sound = NSSound(contentsOf: url, byReference: true)
            else { continue }
            sounds[cue] = sound
        }
    }

    /// Called when a state actually reaches the screen, not when it is reduced.
    ///
    /// The distinction matters: the animation selector holds a state back for
    /// its dwell, and a cue that fired on the reduced state would arrive before
    /// the sparkles it is supposed to accompany.
    func stateDidAppear(_ state: MascotState) {
        // The knock is four and a half seconds long, so answering a permission
        // prompt quickly would leave the pet knocking at a door already opened.
        // Every other cue is short enough that this never came up. This also
        // covers the two-mascot case: one pet reacting cuts the other's knock,
        // which matches the existing rule that one cue plays per window.
        if state != .waiting { stop(.waiting) }

        switch state {
        case .success: play(.success)
        case .failure: play(.failure)
        case .waiting: play(.waiting)
        default: break
        }
    }

    func play(_ cue: Cue) {
        guard !isMuted, let sound = sounds[cue] else { return }
        if sound.isPlaying { sound.stop() }
        sound.play()
    }

    /// Stops one cue and leaves the others alone.
    ///
    /// Only `waiting` is long enough to need this; the rest finish well before
    /// anything could want to interrupt them.
    func stop(_ cue: Cue) {
        guard let sound = sounds[cue], sound.isPlaying else { return }
        sound.stop()
    }

    func stop() {
        for sound in sounds.values where sound.isPlaying {
            sound.stop()
        }
    }
}
