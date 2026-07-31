import AppKit
import MascotCore

/// Plays the short cue that accompanies a success or failure reaction.
///
/// Scope is deliberately narrow. Only the two reaction states make a sound:
/// they are the moments a turn *ends*, which is the thing worth hearing when
/// you are not looking at the screen. Working, waiting, and idle are continuous
/// states, and a cue for each would turn the mascot into a noise source.
///
/// Nothing here observes agent data. It receives a `MascotState` that the
/// reducer already produced and plays a bundled file, so the privacy boundary
/// is untouched — no provider, session, or event detail reaches this type.
@MainActor
final class ReactionSoundPlayer {
    /// Held so a repeated reaction restarts the cue instead of overlapping it,
    /// and so back-to-back turns cannot stack into a drone.
    private var sounds: [MascotState: NSSound] = [:]

    var isMuted: Bool {
        didSet {
            Preferences.reactionSoundsMuted = isMuted
            if isMuted { stop() }
        }
    }

    init(bundle: Bundle = .main) {
        isMuted = Preferences.reactionSoundsMuted
        for (state, resource) in [(MascotState.success, "success"), (MascotState.failure, "failure")] {
            // A missing cue is not worth failing the launch over: the mascot is
            // a visual tool first, and it should still animate on a build where
            // the audio resource did not make it into the bundle.
            guard
                let url = bundle.url(forResource: resource, withExtension: "wav"),
                let sound = NSSound(contentsOf: url, byReference: true)
            else { continue }
            sounds[state] = sound
        }
    }

    /// Called when a state actually reaches the screen, not when it is reduced.
    ///
    /// The distinction matters: the animation selector holds a state back for
    /// its dwell, and a cue that fired on the reduced state would arrive before
    /// the sparkles it is supposed to accompany.
    func stateDidAppear(_ state: MascotState) {
        guard !isMuted, let sound = sounds[state] else { return }
        if sound.isPlaying { sound.stop() }
        sound.play()
    }

    func stop() {
        for sound in sounds.values where sound.isPlaying {
            sound.stop()
        }
    }
}
