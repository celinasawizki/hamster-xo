# Security

This document explains what Philly Hamsters does, what it can access, how it's distributed, and the results of a manual source-level security review. It is accurate as of the review date noted at the bottom and should be re-checked after significant code changes — it is not auto-generated or continuously verified.

## What the app does

Philly Hamsters is a native macOS menu-bar/desktop-pet app. It shows two animated hamster characters anchored to the desktop and a countdown to a fixed date (November 6, 2026), with a different short message each day. That's the entire feature set — there is no account system, no cloud sync, no analytics, and no ads.

## Network behavior

**The app makes no network requests of any kind.** This was verified by searching every Swift source file for networking APIs (`URLSession`, `URLRequest`, `WKWebView`, raw socket APIs, hardcoded URLs) — there are none. The countdown date, daily messages, and all character art are bundled into the app at build time; nothing is fetched at runtime. The app can run with Wi-Fi/network fully disabled with no loss of functionality.

## Data and permissions

- **Files:** The app does not read or write any files outside its own sandboxed preferences. There is no file-picker UI, no access to Documents/Desktop/Downloads, no reading of other apps' data.
- **Camera, microphone, location, contacts, photos:** Not used. No corresponding frameworks are imported, and the app's `Info.plist` contains no usage-description keys for any of these (which would be required by macOS if the app tried to use them).
- **What *is* stored:** Two small preference values in `UserDefaults` (standard macOS app preferences storage, scoped to this app): your Settings toggles (launch at login, animations on/off, sound effects, countdown visibility) and the saved screen position of the mascot panel. Neither contains personal information beyond "where you dragged a widget" and "which checkboxes you clicked."
- **Login item registration:** If you enable "Launch at Login," the app registers itself via `SMAppService`, Apple's current supported API for this — no helper tool, no elevated privileges, and it's fully reversible from the same Settings toggle or System Settings → General → Login Items.
- **App Sandbox is currently disabled** in the app's entitlements. The code itself does not exercise any sensitive capability (confirmed by source review), but with the sandbox off, macOS is not technically enforcing a boundary against it doing so in a future version. This is a hardening recommendation for a future update, not evidence of current misbehavior.

## Can it run fully offline?

Yes. There is no feature that depends on network access — the countdown, messages, and animations are all computed and rendered locally.

## Third-party dependencies

There are none. No Swift Package Manager packages, no CocoaPods, no Carthage — checked by searching for `Package.swift`, `Package.resolved`, `Podfile`, `Cartfile`, and any package references in the Xcode project file. The only external tools involved are build-time/CI-time developer tooling (XcodeGen, Apple's own `codesign`/`notarytool`/`pkgbuild`), none of which are included in or run by the shipped app.

## Installation safety

- **The official way to get this app** is the `.dmg` or `.pkg` attached to a [GitHub Release](../../releases) on this repository. Don't run it from any other source.
- **Current builds are unsigned/ad-hoc and not notarized** (no Apple Developer certificate has been configured for this project yet). This means:
  - macOS Gatekeeper will warn you the first time you open it — that's Apple saying it can't verify who built it, not a sign of a trojan or an actual detected threat.
  - On current macOS, the override requires going to **System Settings → Privacy & Security → Open Anyway** (see the README's Gatekeeper section for the exact steps).
  - Until a real signing certificate + notarization is set up (see README → "Signing & notarization"), do not advertise this app as "warning-free" to anyone you send it to.
- **Build scripts** (`scripts/*.sh`) are reviewed developer tooling that run locally or in this repo's own CI — they are not reachable by untrusted/external input and don't fetch or execute remote code.

## CI/CD security notes

- The release workflow (`.github/workflows/release.yml`) only runs on pushed version tags or a manual trigger — never on pull requests — so repository secrets (signing certificate, notarization credentials) are never exposed to external/fork-submitted code.
- Signing credentials, when configured, are imported into a temporary keychain that exists only for the lifetime of that one CI job and is destroyed with the runner afterward.

## Review scope and limitations

This review covered: all Swift application source, all shell scripts in `scripts/`, both GitHub Actions workflows, the Xcode project configuration, and entitlements/Info.plist. It did **not** and cannot cover: the integrity of Apple's or GitHub's own infrastructure, the security of the maintainer's GitHub account, or behavior of any future code changes made after this review. Re-review after any change that adds a new dependency, new entitlement, or any networking code.

**Last reviewed:** 2026-10-23, against commit `372a29d`. Re-checked after the
pixel-art integration and a SwiftUI layout-crash fix — both changes only
touched views, assets, and the menu bar icon; no new imports, network code,
or dependencies were introduced.
