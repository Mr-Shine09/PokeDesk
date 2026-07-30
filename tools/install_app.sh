#!/bin/bash
# Builds, signs, and installs Dock Pet to a durable location.
#
# Why this exists: until now the only binary lived in DerivedData under
# /private/tmp, which macOS clears on reboot. That is fine for development, but
# a provider hook is configured with an absolute path, so every rebuild or
# restart silently broke the installed hook. This gives the app a stable home so
# a configured hook keeps working.
#
# This is a LOCAL install, not a distributable build. It signs with whatever
# identity is available (falling back to ad-hoc) and does not notarize, because
# notarization needs a "Developer ID Application" certificate from the paid
# Apple Developer Program. A notarized, distributable build remains open work.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED="${DERIVED_DATA_PATH:-/private/tmp/DesktopMascotDerivedData}"
DESTINATION="${INSTALL_DESTINATION:-$HOME/Applications}"
APP_NAME="Dock Pet.app"
BUILT_APP="$DERIVED/Build/Products/Release/$APP_NAME"
INSTALLED_APP="$DESTINATION/$APP_NAME"

say() { printf '\n==> %s\n' "$1"; }

say "Building Release"
xcodebuild \
  -project "$REPO_ROOT/DesktopMascot.xcodeproj" \
  -scheme DesktopMascot \
  -configuration Release \
  -derivedDataPath "$DERIVED" \
  CODE_SIGNING_ALLOWED=NO \
  build >/dev/null

[ -d "$BUILT_APP" ] || { echo "build produced no app at $BUILT_APP" >&2; exit 1; }

# Prefer a real identity so the install survives Gatekeeper's local checks, but
# ad-hoc is enough for a self-built app on the machine that built it.
# Selected by certificate hash rather than name: a keychain routinely holds
# several certificates with identical common names, and passing the name then
# fails as "ambiguous" instead of picking one.
IDENTITY="${CODESIGN_IDENTITY:-}"
if [ -z "$IDENTITY" ]; then
  IDENTITY="$(security find-identity -v -p codesigning 2>/dev/null \
    | awk '/Developer ID Application/ {print $2; exit}')"
fi
if [ -z "$IDENTITY" ]; then
  IDENTITY="$(security find-identity -v -p codesigning 2>/dev/null \
    | awk '/Apple Development/ {print $2; exit}')"
fi
if [ -z "$IDENTITY" ]; then
  IDENTITY="-"
  say "No signing identity found; signing ad-hoc"
else
  say "Signing with: $IDENTITY"
fi

# The nested helper must be signed BEFORE the bundle that contains it. Signing
# the outer bundle first would leave the app's seal describing a helper that is
# then modified, and the app would fail its own validation.
sign_with() {
  codesign --force --timestamp=none --sign "$1" \
    "$BUILT_APP/Contents/MacOS/dockpet-event" 2>&1 &&
  codesign --force --timestamp=none --sign "$1" "$BUILT_APP" 2>&1
}

say "Signing nested helper, then app"
if ! sign_with "$IDENTITY"; then
  # errSecInternalComponent here usually means codesign cannot reach the private
  # key without a keychain prompt, which a non-interactive shell cannot answer.
  # Ad-hoc signing needs no key and is sufficient for a self-built local app, so
  # the install proceeds rather than failing. Run this script from an interactive
  # terminal (and allow the keychain prompt) to sign with the real identity.
  say "Identity signing failed; falling back to ad-hoc"
  IDENTITY="-"
  sign_with "$IDENTITY"
fi
codesign --verify --deep --strict "$BUILT_APP"

say "Installing to $DESTINATION"
mkdir -p "$DESTINATION"
# Quit a running copy first: replacing a bundle out from under a live process
# leaves it running stale code, and the socket would stay bound.
osascript -e 'quit app id "com.mrshine09.desktopmascot"' 2>/dev/null || true
sleep 1
rm -rf "$INSTALLED_APP"
cp -R "$BUILT_APP" "$INSTALLED_APP"

HELPER="$INSTALLED_APP/Contents/MacOS/dockpet-event"
[ -x "$HELPER" ] || { echo "helper missing from installed bundle" >&2; exit 1; }

say "Installed"
echo "App:    $INSTALLED_APP"
echo "Helper: $HELPER"
echo
echo "This path is durable across reboots. Configure provider hooks with:"
echo "  \"$HELPER\" --print-hooks --provider claude-code"
echo
echo "Launch with:"
echo "  open -g \"$INSTALLED_APP\""
