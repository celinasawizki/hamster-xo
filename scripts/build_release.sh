#!/bin/bash
# Builds a Release .app bundle for Philly Hamsters.
#
# Unsigned (default, no Apple Developer account needed):
#   ./scripts/build_release.sh
#
# Signed (requires an Apple Developer Team ID — see scripts/codesign.sh):
#   DEVELOPMENT_TEAM=ABCDE12345 ./scripts/build_release.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BUILD_DIR="$ROOT_DIR/build"
DERIVED_DATA="$BUILD_DIR/DerivedData"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "error: xcodegen is required (brew install xcodegen)" >&2
  exit 1
fi

echo "==> Regenerating Xcode project from project.yml"
xcodegen generate

CODE_SIGN_ARGS=(CODE_SIGNING_ALLOWED=NO)
if [[ -n "${DEVELOPMENT_TEAM:-}" ]]; then
  echo "==> Building with signing identity for team $DEVELOPMENT_TEAM"
  CODE_SIGN_ARGS=(CODE_SIGNING_REQUIRED=YES DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM" CODE_SIGN_STYLE=Automatic)
else
  echo "==> Building WITHOUT code signing (DEVELOPMENT_TEAM not set)"
  echo "    This produces an app that macOS Gatekeeper will block for recipients"
  echo "    until they right-click > Open. See DESIGN_HANDOFF.md / README for notarization steps."
fi

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

xcodebuild \
  -project PhillyHamsters.xcodeproj \
  -scheme PhillyHamsters \
  -configuration Release \
  -derivedDataPath "$DERIVED_DATA" \
  -destination "generic/platform=macOS" \
  "${CODE_SIGN_ARGS[@]}" \
  clean build

APP_PATH="$DERIVED_DATA/Build/Products/Release/Philly Hamsters.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "error: expected app bundle not found at $APP_PATH" >&2
  exit 1
fi

cp -R "$APP_PATH" "$BUILD_DIR/"
echo "==> Built: $BUILD_DIR/Philly Hamsters.app"
