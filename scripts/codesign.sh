#!/bin/bash
# Codesigns the built .app with a Developer ID Application certificate.
#
# Requires:
#   - An Apple Developer Program membership ($99/yr).
#   - A "Developer ID Application" certificate installed in your login
#     keychain (create one at https://developer.apple.com/account/resources/certificates/list,
#     then double-click the downloaded .cer to install it).
#   - CODESIGN_IDENTITY set to that certificate's name, e.g.
#       "Developer ID Application: Celina Sawizki (ABCDE12345)"
#     (run `security find-identity -v -p codesigning` to list installed identities).
#
# Usage:
#   CODESIGN_IDENTITY="Developer ID Application: Celina Sawizki (ABCDE12345)" \
#     ./scripts/codesign.sh build/"Philly Hamsters.app"
set -euo pipefail

if [[ -z "${CODESIGN_IDENTITY:-}" ]]; then
  echo "error: CODESIGN_IDENTITY is not set." >&2
  echo "List available identities with: security find-identity -v -p codesigning" >&2
  exit 1
fi

APP_PATH="${1:-}"
if [[ -z "$APP_PATH" || ! -d "$APP_PATH" ]]; then
  echo "usage: $0 <path to .app>" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENTITLEMENTS="$ROOT_DIR/PhillyHamsters/App/PhillyHamsters.entitlements"

echo "==> Signing $APP_PATH with identity: $CODESIGN_IDENTITY"

# Sign from the inside out: frameworks/dylibs before the outer bundle.
find "$APP_PATH" \( -name "*.framework" -o -name "*.dylib" \) -print0 \
  | xargs -0 -I{} codesign --force --timestamp --options runtime \
      --sign "$CODESIGN_IDENTITY" "{}" 2>/dev/null || true

codesign --force --deep --timestamp --options runtime \
  --entitlements "$ENTITLEMENTS" \
  --sign "$CODESIGN_IDENTITY" \
  "$APP_PATH"

echo "==> Verifying signature"
codesign --verify --deep --strict --verbose=2 "$APP_PATH"
spctl --assess --type execute --verbose=4 "$APP_PATH" || \
  echo "note: spctl will report 'rejected' until the app is also notarized (see scripts/notarize.sh)"

echo "==> Signed OK: $APP_PATH"
