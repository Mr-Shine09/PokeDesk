# Production mascot base

The production direction was frozen on 2026-07-28 after owner review.

## Live assets

- `../references/owner-selected-fallback-chibi.png` — exact owner-selected secondary-chibi concept source.
- `mascot-base-chibi-40pt-at2x-80px-final.png` — frozen 80x80-pixel `@2x` base for a 40x40-point mascot window.
- `mascot-base-chibi-40pt-at2x-final-review-8x.png` — frozen light/dark QA sheet.

The base uses the project's 12-color subject palette and binary alpha. Its SHA-256 is `954f4b19cf352808e89c2e197849c16e58409f107a4b5dfd681aa9dac432abc6`.

## Selection boundary

The owner rejected the 32x32 direction, all tall reductions, all tall-face repairs, and every pre-freeze production candidate. Those 23 rejected or duplicate production PNGs were removed from the working tree on 2026-07-28. Their filenames, results, and failure reasons remain in `../../DesktopMascot.md`; the binaries remain recoverable from Git history through commit `0f292ec`.

Only the two PNGs listed under **Live assets** in this directory may be consumed by the app or future animation-atlas work. Issue #2 is complete. Issue #3 must define atlas geometry, anchors, timing, and frame acceptance rules before new production frames are created.
