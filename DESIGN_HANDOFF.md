# Design Handoff — Philly Hamsters

This is the contract between the engineering side (window management,
countdown logic, animation *playback*) and the design side (character art,
animation *frames*). Engineering has already built the full app against
placeholder vector drawings (see `PhillyHamsters/Views/PlaceholderHamsterView.swift`),
so **nothing blocks on this handoff** — the app already compiles and runs.
Dropping in correctly-named PNGs listed below is the entire integration step.

**Style direction, updated: cute pixel art, matching
[`design-reference/style-mockup.png`](design-reference/style-mockup.png)
exactly.** This supersedes an earlier note in this doc that said "not pixel
art" — that's reversed now. The reference image is the authoritative visual
target; match it, don't reinterpret it. If anything below conflicts with
the image, the image wins.

What the reference shows, specifically:

- **Chibi pixel-art style** — soft/rounded pixelation, not harsh 8-bit.
  Blocky-but-smooth edges, limited palette per sprite, antialiased enough
  to read as "cute," not retro-arcade.
- **Proportions:** big round head, small round body, no visible neck —
  classic chibi blob shape. Tiny stub arms/paws.
- **Fur:** warm golden-tan all over, with a lighter cream/white patch on
  the belly, cheeks, and muzzle.
- **Face:** simple black dot eyes (no visible white/sclera), small black
  nose dot, tiny mouth. Bright pink circular blush on both cheeks — this
  is a strong, consistent identifying feature across every state.
- **Girl hamster:** pink bow on top of her head, every frame. **Boy
  hamster:** no bow, otherwise same fur/face treatment.
- **Hearts:** small pink pixel hearts are a recurring decorative motif —
  floating above the pair, held between their paws, or scattered around
  during excited/celebration states.
- **Speech bubble:** rounded-rectangle, cream/off-white fill, thin dark
  outline, small pointer tail aimed at the hamsters, bold dark text
  (countdown message), small pink heart icon next to the text.
- **Menu bar icon:** a tiny flattened/simplified version of the pair
  (just heads mostly) reads fine at 16–22pt — see the mockup's top-right
  menu bar example.

### States shown in the reference (use these as the target list)

| Reference label | Maps to engine state | Bubble text example |
|---|---|---|
| Counting down | `.idle` | "30 days until Philly!" |
| Excited | `.excited` | "7 days until Philly!" |
| Sleeping | `.sleeping` | (no text — "Z Z Z" above them) |
| Eating together | *new, not yet in engine* | "Eating together" |
| Almost there | `.excited` / `.idle` near date | "1 day until Philly!" |
| You're here! | `.celebration` | "It's today!" + party hats + confetti |
| Hover/click | `.excited` or a dedicated reaction | "I can't wait to see you again! Philly is waiting for you!" |

The reference's "Animations (examples)" row also shows standalone poses:
**Hug** (→ `pair_hugging`), **Blink** (→ `celina_blink`/`kivanc_blink`),
**Wave**, **Happy jump** (→ `celina_excited`/`kivanc_excited`), **Back
view**, **Little kiss**, **Heart**. `Wave`, `Back view`, `Little kiss`, and
a standalone `Heart` pose aren't wired into the engine yet (only the 7
states in the table below exist in Swift today) — ship art for the 7
engine states first; treat the others as nice-to-have extra frames engineering
can wire up later if you deliver them. Same for `Eating together` — it's in
the reference but has no engine state yet, so it's optional/bonus, not
blocking.

Don't touch the countdown badge/menu styling shown in the mockup
(skyline wallpaper, app window chrome, dropdown menu text) — that's
illustrative mockup context, not something to literally recreate; just the
hamster characters, speech bubble style, and hearts are the deliverable.

## How the fallback works

Every sprite lookup goes through `NSImage(named:)` against the asset
catalog (`PhillyHamsters/Assets/Assets.xcassets`). If an image with the
expected name isn't found, the view silently falls back to the vector
placeholder — per-sprite, not all-or-nothing. You can deliver art
incrementally (e.g. just `pair_hugging` first) and the rest keeps using
placeholders.

To add an asset: create an Image Set inside `Assets.xcassets` with the
exact name below (e.g. `celina_idle`), and put the sprite sheet PNG in its
1x/2x/3x slots (or just 2x if that's all you render — missing scales are
fine, AppKit will scale).

## Canvas & sizing

- Each **character frame** (solo sheets) is square, rendered at **80×80 pt**
  on screen. Author at 256×256 px per frame (@2x-equivalent detail) so it's
  crisp on Retina; the engine scales to fit.
- Each **pair frame** (both hamsters sharing a sprite sheet) renders at
  **180×90 pt**. Author pair frames at roughly 2:1 aspect, e.g. 512×256 px.
- All sheets are **horizontal strips**: N equal-width frames side by side
  in one PNG, left to right, frame 0 first. Transparent background
  (alpha PNG) — no backing rectangle.

## Required assets

### Solo sheets (one character, independent of the other)

| Asset name | Frames | Used for | Notes |
|---|---|---|---|
| `celina_idle` | 1 | Idle | Single still frame is fine |
| `celina_blink` | 4 | Blink overlay during idle | Eyes open → closing → closed → opening |
| `celina_excited` | 6 | Click/ambient excited, jump cycle | Loops at ~10fps |
| `kivanc_idle` | 1 | Idle | Single still frame is fine |
| `kivanc_blink` | 4 | Blink overlay during idle | Eyes open → closing → closed → opening |
| `kivanc_excited` | 6 | Click/ambient excited, jump cycle | Loops at ~10fps |

### Pair sheets (both hamsters together, one sprite sheet)

| Asset name | Frames | Used for | Notes |
|---|---|---|---|
| `pair_hugging` | 8 | The centerpiece hug animation | See sequence below |
| `pair_missing_you` | 6 | Girl hamster sad, boy hamster comforts her | Loops at ~8fps while active |
| `pair_sleeping` | 2 | Cuddled, eyes closed | Slow "breathing" loop, ~1fps |
| `pair_celebration` | 8 | Arrival-day / countdown-excitement jump | Hearts can be baked into the frames or left for the engine's heart overlay — your call, see below |

Total: **6 solo sheets + 4 pair sheets = 10 PNGs** (plus the app icon, see below).

## The hug sequence (centerpiece — prioritize this one)

Map the 8 `pair_hugging` frames to the narrative from the design brief:

1. Sitting apart, the girl hamster glancing at the boy hamster
2. Girl hamster wiggling excitedly
3. Girl hamster moving closer
4. Boy hamster opening his paws
5. Contact — arms around each other
6. Cheeks squished together
7. Hold (this is the frame most likely to get frozen/held visually if the engine needs to pad timing)
8. Tiny pink heart visible, starting to separate back toward idle

The engine plays all 8 frames once at 10fps (~0.8s) then holds on the last
rendered pose for the remainder of a 2.4s total playback before returning
to idle — so frame 8 is the one the user's eye rests on; make it count.

## Hearts & decorative elements

Hearts are optional to bake into `pair_hugging` / `pair_celebration` frames.
If you don't bake them in, the engine already draws a simple pink "♡"
overlay above the pair for those two states (see `PairSpriteView.swift`) —
so bare sprite sheets without hearts still look correct, just simpler.
If you do bake hearts into your frames, there's nothing to turn off on the
engine side for celebration/hugging — just make sure your baked hearts
read clearly over the existing text overlay above (the countdown badge
sits above the scene, not on top of it).

## Typography / countdown UI

The countdown text ("14 days ♡", daily message, "YOU'RE HERE!!!") is
currently system rounded SF font, white, with a soft drop shadow for
legibility on any wallpaper (`CountdownBadgeView.swift`). If you want a
custom rounded display font instead:

1. Add the font file to `PhillyHamsters/Assets/` and register it in
   `Info.plist` under `ATSApplicationFontsPath` / as a bundled font.
2. Swap `.system(size:weight:design: .rounded)` in `CountdownBadgeView.swift`
   for `.custom("YourFontName", size:)`.

No background plate — keep it to text + shadow/outline per the brief.

## App icon

Current icon is a placeholder (two overlapping circles) generated by
`scripts/generate_placeholder_icon.swift`. To replace it, regenerate the
PNGs in `PhillyHamsters/Assets/Assets.xcassets/AppIcon.appiconset/` at the
same filenames (`icon_16.png` … `icon_1024.png`) listed in that folder's
`Contents.json`.

## What design should NOT touch

Per the project split, don't modify: `Models/CountdownModel.swift`,
`Models/DailyMessages.swift`, anything in `Services/`, the GitHub Actions
workflow, or the packaging scripts in `scripts/`. If a design change needs
new engine hooks (e.g. a new animation state), open that as a request to
engineering rather than editing the Swift architecture directly.

Work on a branch named `design/hamster-artwork` and open a PR back to
`main` — engineering will merge, run `xcodegen generate` if the asset
catalog needs regenerating, build, and test before cutting a release.
