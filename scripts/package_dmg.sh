#!/bin/bash
# Packages build/"Philly Hamsters.app" into a distributable PhillyHamsters.dmg
# containing the app and an Applications shortcut (drag-to-install).
#
# Sets an explicit Finder icon layout (window size, icon size, side-by-side
# positions) via AppleScript so the drag gesture is actually easy to perform
# regardless of the recipient's Finder view-mode defaults — a plain
# `hdiutil create` leaves that to chance (small window, list view, or
# overlapping icons can make "drag the app onto Applications" effectively
# impossible to do). If Finder automation isn't available (e.g. no
# permission granted, or a non-interactive environment), falls back to a
# plain DMG rather than failing the whole build.
#
# Usage:
#   ./scripts/package_dmg.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
APP_PATH="$BUILD_DIR/Philly Hamsters.app"
FINAL_DMG="$BUILD_DIR/PhillyHamsters.dmg"
STAGING_DIR="$BUILD_DIR/dmg-staging"
RW_DMG="$BUILD_DIR/PhillyHamsters-rw.dmg"
VOLUME_NAME="Philly Hamsters"

if [[ ! -d "$APP_PATH" ]]; then
  echo "error: $APP_PATH not found — run scripts/build_release.sh first" >&2
  exit 1
fi

rm -rf "$STAGING_DIR" "$FINAL_DMG" "$RW_DMG"
mkdir -p "$STAGING_DIR"

cp -R "$APP_PATH" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

echo "==> Creating writable staging DMG"
hdiutil create \
  -volname "$VOLUME_NAME" \
  -srcfolder "$STAGING_DIR" \
  -fs HFS+ \
  -format UDRW \
  -ov \
  "$RW_DMG" >/dev/null

echo "==> Mounting staging DMG to set Finder icon layout"
MOUNT_OUTPUT=$(hdiutil attach "$RW_DMG" -readwrite -noverify)
MOUNT_POINT=$(echo "$MOUNT_OUTPUT" | grep -Eo '/Volumes/.*' | tail -1)

if [[ -z "$MOUNT_POINT" ]]; then
  echo "error: could not determine mount point for staging DMG" >&2
  exit 1
fi

layout_ok=true
osascript <<APPLESCRIPT || layout_ok=false
tell application "Finder"
  tell disk "$VOLUME_NAME"
    open
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set the bounds of container window to {200, 120, 760, 480}
    set viewOptions to the icon view options of container window
    set arrangement of viewOptions to not arranged
    set icon size of viewOptions to 128
    set position of item "Philly Hamsters.app" of container window to {140, 180}
    set position of item "Applications" of container window to {420, 180}
    close
    open
    update without registering applications
    delay 1
  end tell
end tell
APPLESCRIPT

if [[ "$layout_ok" == true ]]; then
  echo "==> Finder layout applied (app + Applications shortcut side by side)"
else
  echo "warning: could not set custom Finder icon layout — continuing with the default layout." >&2
  echo "          (This needs Finder automation permission granted to whatever is running this script.)" >&2
fi

sync
hdiutil detach "$MOUNT_POINT" 2>/dev/null || hdiutil detach "$MOUNT_POINT" -force

echo "==> Compressing to final $FINAL_DMG"
hdiutil convert "$RW_DMG" -format UDZO -ov -o "$FINAL_DMG" >/dev/null

rm -rf "$STAGING_DIR" "$RW_DMG"
echo "==> Done: $FINAL_DMG"
