#!/bin/bash
# Staples the notarization ticket to the .app and/or .dmg so Gatekeeper can
# verify it offline (without calling Apple at install time).
#
# Usage:
#   ./scripts/staple.sh build/"Philly Hamsters.app"
#   ./scripts/staple.sh build/PhillyHamsters.dmg
set -euo pipefail

TARGET="${1:-}"
if [[ -z "$TARGET" || ! -e "$TARGET" ]]; then
  echo "usage: $0 <path to .app or .dmg>" >&2
  exit 1
fi

echo "==> Stapling $TARGET"
xcrun stapler staple "$TARGET"

echo "==> Verifying staple"
xcrun stapler validate "$TARGET"
