#!/bin/bash
# Packages build/"Philly Hamsters.app" into a distributable PhillyHamsters.dmg
# containing the app and an Applications shortcut (drag-to-install).
#
# Usage:
#   ./scripts/package_dmg.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
APP_PATH="$BUILD_DIR/Philly Hamsters.app"
DMG_PATH="$BUILD_DIR/PhillyHamsters.dmg"
STAGING_DIR="$BUILD_DIR/dmg-staging"

if [[ ! -d "$APP_PATH" ]]; then
  echo "error: $APP_PATH not found — run scripts/build_release.sh first" >&2
  exit 1
fi

rm -rf "$STAGING_DIR" "$DMG_PATH"
mkdir -p "$STAGING_DIR"

cp -R "$APP_PATH" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

echo "==> Creating $DMG_PATH"
hdiutil create \
  -volname "Philly Hamsters" \
  -srcfolder "$STAGING_DIR" \
  -ov -format UDZO \
  "$DMG_PATH"

rm -rf "$STAGING_DIR"
echo "==> Done: $DMG_PATH"
