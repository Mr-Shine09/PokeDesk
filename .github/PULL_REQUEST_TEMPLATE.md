<!--
Read CONTRIBUTING.md first if you have not. This project has hard invariants
(frozen character, privacy boundary, generated Xcode project) and a documented
preference for accurate evidence over confident claims.
-->

## What this changes

<!-- One paragraph. What behavior is different after this lands? -->

## Why

<!-- Link the issue, or explain the problem. -->

Closes #

## Evidence

<!--
What you actually ran, and what it printed. "It builds" is not evidence that a
feature works.
-->

- [ ] `swift test` from `Packages/DesktopMascotKit` — result:
- [ ] `python3 tools/validate_animation_atlas.py --contract-only` (if art or contract changed)
- [ ] `xcodebuild` Debug build succeeds, with a `-derivedDataPath` unique to this branch
- [ ] Hands-on check, if this touches window behavior, animation, or the menu bar — describe what you saw:

## Not verified

<!--
List what you did NOT test. This is the most useful section in the template.
An accurate gap is worth more than an optimistic claim.
-->

## Invariants

- [ ] No new network access, telemetry, account, or private API use
- [ ] Reads no prompt, transcript, code, tool argument, tool output, repository
      path, or screen content
- [ ] Does not change the frozen mascot character or revive a rejected variant
- [ ] Animation changes go through `MascotStateReducer`, not by setting an atlas
      row directly
- [ ] App remains non-activating, and quitting does not depend on an animation
      finishing
- [ ] `project.yml` changed and `xcodegen generate` re-run, if the project
      changed at all — or N/A
- [ ] Generated output (Xcode project, atlases, WAVs) committed alongside the
      source change that produced it — or N/A
- [ ] `DesktopMascot.md` updated with the decision, evidence, and next step

<!--
On that last box: verify the ledger edit actually landed with
`git show HEAD:DesktopMascot.md | grep '<your text>'`. A string replacement
whose target does not match fails silently, and that has produced false claims
in this repository before.
-->
