#!/bin/bash
# Submits a signed .app (zipped) or .dmg to Apple Notary Service and waits
# for the result.
#
# Requires an App Store Connect API key OR an app-specific password, stored
# once via `xcrun notarytool store-credentials`:
#
#   xcrun notarytool store-credentials "PhillyHamstersNotary" \
#     --apple-id "you@example.com" \
#     --team-id "ABCDE12345" \
#     --password "<app-specific password from appleid.apple.com>"
#
# Then just:
#   ./scripts/notarize.sh build/PhillyHamsters.dmg
set -euo pipefail

TARGET="${1:-}"
PROFILE="${NOTARY_PROFILE:-PhillyHamstersNotary}"

if [[ -z "$TARGET" || ! -e "$TARGET" ]]; then
  echo "usage: $0 <path to .dmg or .zip>" >&2
  exit 1
fi

echo "==> Submitting $TARGET to Apple Notary Service (profile: $PROFILE)"
xcrun notarytool submit "$TARGET" --keychain-profile "$PROFILE" --wait

echo "==> Notarization complete. Run scripts/staple.sh next."
