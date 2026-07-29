# Architecture and state model

## Implemented layers

### App shell

`DesktopMascot/App/AppDelegate.swift` loads bundled resources, creates the panel/controller, owns menu state, routes clicks and drag callbacks, restores hidden windows on reopen, and exposes diagnostics.

`MenuBarContent.swift` is the reliable control surface. `MascotPreviewView.swift` renders the current `NSImage` with `.interpolation(.none)`.

`AmbientAnimationController.swift` is intentionally temporary orchestration. It caches frames, advances contract timing at 20 Hz, moves at 24 points/second, alternates walk direction, pauses randomly in `offline`, handles manual ideating/pause/roaming, and plays `hanging` during drag.

### MascotCore

`MascotState.swift` defines stable state names and ambient variants. Note that the running app does not consume it: `AmbientAnimationController` selects rows by raw atlas name, so this vocabulary is currently exercised only by tests. The reducer is expected to make it the single typed source of visible state.

`EventEnvelope.swift` defines `EventProvider`, `AgentEvent`, `EventDetail`, the validated opaque `SessionID`, and the six-field `EventEnvelope`. The envelope is the privacy boundary: it has no field for forbidden content, so retaining any requires an explicit product decision.

`EventDecoder.swift` decodes transport bytes into an envelope and fails closed. It enforces a pre-parse payload ceiling, the version/provider/event allowlists, `SessionID` validation, RFC 3339 parsing with and without fractional seconds, and skew bounds against an injected `now`. Unknown top-level keys are dropped by the fixed payload shape; an unknown `detail` is discarded rather than rejected; no error value carries payload text.

The session registry and reducer are not implemented.

### MascotAnimation

`AtlasContract.swift` decodes grid geometry, row metadata, playback, and timing. Extra art-authoring fields in the JSON are intentionally ignored by runtime decoding.

`SpriteAtlas.swift` decodes the atlas once and returns an `NSImage` crop. Contract coordinates are top-origin, matching `CGImage.cropping` behavior used here. A pixel-equality regression test protects this mapping.

### MascotWindow

`MascotPanel.swift` is a transparent, borderless, non-activating floating panel. It routes click/right-click and custom drag behavior. Once drag threshold is crossed, the cursor attaches to the hanging hand anchor.

`DockGeometry.swift` infers bottom/left/right Dock exclusion from `NSScreen.frame` and `visibleFrame`, computes a safe origin, and clamps placement.

`WindowCoordinator.swift` owns panel visibility, positioning, bottom-lane horizontal bounds, backing-pixel-aligned movement, and screen/wake repositioning.

## Runtime ownership

```text
AppDelegate
├── AppResources -> atlas PNG + JSON contract
├── MascotPreviewModel -> currently displayed NSImage
├── WindowCoordinator -> MascotPanel and geometry
└── AmbientAnimationController -> frame timing and movement
```

All AppKit/UI owners are `@MainActor`. Keep decoding/reducer models `Sendable` and isolate future socket I/O away from the main actor.

## Planned event architecture

Introduce clean boundaries rather than adding provider checks to `AmbientAnimationController`:

```text
provider hook stdin
  -> provider adapter (discard non-allowlisted fields)
  -> mascot-event helper
  -> same-user Unix socket
  -> strict EventEnvelope decoder
  -> SessionRegistry
  -> MascotStateReducer
  -> visible state/reaction command
  -> animation controller
```

Recommended package placement (`✅` implemented, `▫️` planned):

```text
MascotCore/
  EventEnvelope.swift          ✅
  EventDecoder.swift           ✅
  SessionRegistry.swift        ▫️
  MascotStateReducer.swift     ▫️
MascotTransport/             new product only when transport work begins
  LocalSocketServer.swift
  PayloadLimits.swift
mascot-event/                small executable helper when justified
```

Use injected clocks/IDs for deterministic tests. Keep transport bytes separate from semantic reduction.

## Event envelope

Target schema:

```json
{
  "version": 1,
  "provider": "claude-code",
  "session_id": "opaque-local-id",
  "event": "active",
  "occurred_at": "2026-07-29T18:00:00Z",
  "detail": "tool"
}
```

Allow only `started`, `active`, `waiting`, `completed`, `failed`, `stopped`, and `heartbeat`. Do not retain the raw provider payload after decoding.

## Reducer rules

Priority:

```text
paused > failure-recent > waiting > working > ideating > success-recent > scheduled-sleep > idle/strolling > offline
```

- Manual pause is authoritative.
- Waiting clears on active/completed/failed/stopped for that session.
- Start with a 120-second heartbeat expiry.
- Failure reaction lasts 4 seconds; success lasts 3 seconds.
- Duplicate events are idempotent and older reordered events cannot overwrite newer session state.
- Work/ideating/waiting interrupts scheduled sleep immediately.
- Multiple active providers still produce one visible working state; diagnostics may list provider counts without private identifiers.

## Interaction invariants

- Animation never activates the app.
- Menu-bar controls remain usable even when the panel is off-screen or hidden.
- Hide and Quit remain semantically distinct.
- Dragging is always available, plays hanging, and stops roaming on drop.
- Resume Roaming repositions into the current display's safe lane.
- Screen, scale, Dock orientation, and wake changes trigger placement reconciliation.
- Reduced Motion work must replace motion with stable/fade behavior, not merely speed up or shrink the same loop.

