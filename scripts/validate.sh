#!/bin/bash
# Sanity-checks a built app/DMG before calling it release-ready: structure,
# code signature (if signed), Gatekeeper assessment, and (for a DMG)
# mount/read of its contents.
#
# Usage:
#   ./scripts/validate.sh build/"Philly Hamsters.app"
#   ./scripts/validate.sh build/PhillyHamsters.dmg
set -euo pipefail

TARGET="${1:-}"
if [[ -z "$TARGET" || ! -e "$TARGET" ]]; then
  echo "usage: $0 <path to .app or .dmg>" >&2
  exit 1
fi

check() {
  echo "--- $1 ---"
}

if [[ "$TARGET" == *.dmg ]]; then
  check "Mounting DMG"
  MOUNT_POINT=$(hdiutil attach "$TARGET" -nobrowse -readonly | tail -1 | awk '{print $NF}')
  trap 'hdiutil detach "$MOUNT_POINT" >/dev/null 2>&1 || true' EXIT

  APP_IN_DMG="$MOUNT_POINT/Philly Hamsters.app"
  if [[ ! -d "$APP_IN_DMG" ]]; then
    echo "FAIL: Philly Hamsters.app not found inside DMG" >&2
    exit 1
  fi
  if [[ ! -L "$MOUNT_POINT/Applications" ]]; then
    echo "FAIL: Applications shortcut missing from DMG" >&2
    exit 1
  fi
  echo "OK: DMG contains the app + Applications shortcut"
  TARGET="$APP_IN_DMG"
fi

check "Bundle structure"
if [[ ! -f "$TARGET/Contents/Info.plist" ]]; then
  echo "FAIL: missing Contents/Info.plist" >&2
  exit 1
fi
if [[ ! -x "$TARGET/Contents/MacOS/Philly Hamsters" ]]; then
  echo "FAIL: missing or non-executable main binary" >&2
  exit 1
fi
echo "OK: bundle structure looks right"

check "Code signature"
if codesign --verify --deep --strict --verbose=2 "$TARGET" 2>&1; then
  echo "OK: signature verifies"
else
  echo "WARNING: app is unsigned or signature is invalid (expected for dev builds without DEVELOPMENT_TEAM)"
fi

check "Gatekeeper assessment"
if spctl --assess --type execute --verbose=4 "$TARGET" 2>&1; then
  echo "OK: Gatekeeper accepts this app"
else
  echo "WARNING: Gatekeeper would currently block this app on a recipient's Mac."
  echo "          This is expected until it is signed + notarized + stapled."
  echo "          Do not distribute this build as 'frictionless install' until it passes this check."
fi

check "Notarization ticket (stapled)"
if xcrun stapler validate "$TARGET" 2>&1; then
  echo "OK: notarization ticket is stapled"
else
  echo "WARNING: no stapled notarization ticket found."
fi
