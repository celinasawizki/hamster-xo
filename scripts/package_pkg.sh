#!/bin/bash
# Packages build/"Philly Hamsters.app" into a PhillyHamsters.pkg installer —
# an alternative to the DMG that doesn't rely on drag-and-drop at all.
# Opening the .pkg launches Apple's Installer app (Continue → Install →
# Done), which copies the app into /Applications itself.
#
# Usage:
#   ./scripts/package_pkg.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
APP_PATH="$BUILD_DIR/Philly Hamsters.app"
PKG_PATH="$BUILD_DIR/PhillyHamsters.pkg"
COMPONENT_ROOT="$BUILD_DIR/pkg-root"

if [[ ! -d "$APP_PATH" ]]; then
  echo "error: $APP_PATH not found — run scripts/build_release.sh first" >&2
  exit 1
fi

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$APP_PATH/Contents/Info.plist")
IDENTIFIER=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$APP_PATH/Contents/Info.plist")

rm -rf "$COMPONENT_ROOT" "$PKG_PATH"
mkdir -p "$COMPONENT_ROOT"
cp -R "$APP_PATH" "$COMPONENT_ROOT/"

echo "==> Building $PKG_PATH (version $VERSION, identifier $IDENTIFIER.pkg)"
pkgbuild \
  --root "$COMPONENT_ROOT" \
  --install-location /Applications \
  --identifier "$IDENTIFIER.pkg" \
  --version "$VERSION" \
  "$PKG_PATH"

rm -rf "$COMPONENT_ROOT"
echo "==> Done: $PKG_PATH"
