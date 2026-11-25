# Bar Stage 7: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-7-brief.md`. I downloaded the brief from the given URL into `docs/` first and committed it with this report.

These locks are untouched: island height 38, radius 9, bar height 44 (and its reserve), island text 16px, SF Compact Display Medium with no bold, `toast.gap` 0, the battery as a number only, and C for the calendar leader.

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261125-124148-bar-stage-7`** (mode 700, 194 files), taken before any edit. It covers the full behaviour set: every `jimmy.*` plugin, `hypr/*.lua`, `shell.json`, `shell.toml`, hooks, theme files, extensions, the Vicinae settings, the paste and backlight helpers, and the systemd unit. Checksums: live before = backup = live after. Excluded: runtime state, because nothing here touches it |
| Reload | `omarchy restart shell` run twice, each time on its own; never `refresh`, never combined with a summon. No Hyprland bind changes this round |
| Debug / temporary code | None added. `console.log` = 0 in `jimmy.bar`. The shell log shows no errors from the bar or `Embers` |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced; 3 files changed (`Bar.qml`, `shell.toml`, new `Embers.qml`). Live checksums are identical before and after, and the snapshot equals live. No runtime state in git |

## 1. Quick icons: outside the island, which never moves

- **Cause:** the strip lived inside the right island's row, so opening it widened the island and shifted the time.
- **Fix:** the strip is now its own row **outside** the island.
  - **Position:** its right edge sits on the island's left edge. The island's width and position no longer depend on it.
  - **Slide:** opening grows each icon from zero width over 160 ms (`quick.slide-ms`), with a fade, so the icons slide out leftward from the island's edge.
  - **Order:** reminder, night light, silence, stay awake; stay awake is nearest the island.
- **Icons:**
  - Grey (quiet, 45 %) when off, accent when on.
  - A lit item stays in the bar beside the island after the strip closes, until it is clicked off or turned off another way (for example the idle keybind).
  - Stay awake, when on, sits lit to the left of the time.
- **Hover:** the time and the strip each have a hover handler, and either one keeps the strip open. The strip's zone also reaches over the island's left padding up to the time, so the pointer never crosses a gap.
  - It opens after 180 ms.
  - It closes 300 ms after the pointer leaves both.
- **Q** (`Super+Ctrl+Q`, or `Super+D` then `Q`) opens the same strip with keyboard focus: Left/Right, Enter, Esc.
- **Calendar:** it drops below the island and the strip stays in the bar row to its left, so they cannot overlap.
- **Verified live:**
  - **Island fixed:** at rest and with the strip open, the island is at the same x (screenshots). The strip appears to its left.
  - **Keyboard:** Q opened the strip with focus. Left moved to Silence and Enter turned it on (`silenced: true`). After Esc, the strip closed and the **bell stayed lit beside the island**, next to the lit stay-awake cup (screenshot). The same path turned Silence back off (`silenced: false`).
- **Not testable here: a real pointer.** Hover and clicks need your mouse. There is no uinput tool, and warped pointer motion delivers no hover events.

## 2. Super+D: hints only

- **Cause:** the strip used to show its icons while the leader was active.
- **Fix:** that rule is gone. `Super+D` now shows only the letters and opens nothing. `Q` after it opens the strip (unchanged bind: `jimmy.bar quick`).
- **Verified:** entering the submap gave `leader: true` with `quick.open: false`. Only the letters appeared, and the strip showed just the items that were already lit (screenshot).
- **Leader keys unchanged:** 1–9, W, C, B, A, Q, Esc.

## 3. Leader letters: on the bottom outline, dissected

- **Shipped: the dissecting version.** Each letter is centred horizontally under its element, and vertically on the island's bottom edge, so the 1 px outline crosses the middle of the letter.
  - All letters sit on the same line.
  - They are plain accent text at 11 px (`leader.hint-size`), with no badge.
  - **Letters:** digits under the workspace numbers, Q under stay awake, C under the time, W under weather, B under the battery number, A under the AI mark.
  - **Q** always sits at stay awake's place, so it is in the same spot whether or not stay awake is lit.
- **How it fits in QML:**
  - Islands no longer clip their content. Clipping only guarded an overflow that the 200 px app-name cap already prevents.
  - The bar layer is now 11 px taller than the bar, so the lower half of each letter can draw below it. Its **input region (`mask`) stays the 44 px bar**, so the extra band never takes a click.
  - The band is fully transparent, and the blur rule's `ignore_alpha` 0.2 leaves it unblurred.
  - The reserve is unchanged.
- **Tuned live:** the first pass put the outline through the top quarter of each capital, so the letters read as hanging. A capital's visual centre sits below its line box's centre in this font, so the nudge is up by 1 px (`leader.hint-nudge` = −1). A 6× zoom now shows the edge through the middle of each letter.
- **Letters disappear when the leader exits.** Verified: `leader: false` after the reset, and no letters were drawn.

## 4. Battery: embers while charging

- **Unchanged:** the number only. Accent when plugged in, neutral on battery, amber ≤ 20 %, red ≤ 10 %. No pill, outline or shimmer.
- **New:** `Embers.qml`, a pool of 2 small sparks (nothing created at runtime) and one timer, running only while the battery is charging.
  - **Origin:** a random point on the number: anywhere across its width, around its middle and lower half.
  - **Motion:** floats up 13–19 px with a slight sideways drift (±3 px), fades from 0.9 to 0 and shrinks to half size over 1.1 s.
  - **Size:** 3 px, round.
  - **Frequency:** a random gap of 0.75–1.5 s.
  - **Colour:** theme accent, the same as the charging number.
  - **Stops** when the battery stops charging. The number then follows the plugged-in or on-battery colour rule.
- **Tokens:** `battery.ember-size` 3, `ember-rise` 16, `ember-ms` 1100, `ember-min-ms` 750, `ember-max-ms` 1500.
- **Verified live:**
  - **Frequency:** `status.battery.embers` counted 5 sparks in about 5 s while charging at 79 %, inside the 0.75–1.5 s band.
  - **Motion:** a 12-frame burst at 120 ms caught sparks leaving the 7 and the 9 and rising above the number while fading (screenshots).
  - **Stopping when unplugged** is by construction (the timer runs on `charging`). I could not test it live because the machine stayed plugged in.
- **Subtlety:** with only one 3 px dot in the air most of the time, it read as quiet at the default values, so I made no sparser pass. If it is too much at 80 % all day, raise `ember-min-ms` / `ember-max-ms` first.

## Token changes (`shell.toml`)

| Token | Value |
|---|---|
| `battery.ember-size` / `ember-rise` / `ember-ms` | 3 / 16 / 1100 (new) |
| `battery.ember-min-ms` / `ember-max-ms` | 750 / 1500 (new) |
| `quick.slide-ms` | 160 (new) |
| `leader.hint-size` / `hint-nudge` | 11 / −1 (new) |

## Rest of the UI

- **Toasts:** they use their own `toast.padding-x` (Stage 6) and attach to the island, whose position is unchanged. No effect.
- **Hosted panels and calendar:** they still drop from the right island's centre. The bar layer's extra band is click-through, so panels and windows under it behave as before.
- **Fullscreen:** the bar still unmounts as before; the embers' timer stops with it (`window.visible`).

## Still open

- **Real mouse:** hover over the time, slide onto the icons, and click each icon.
- **On battery:** confirm the embers stop and the number turns neutral.
- **For your eye:** ember frequency and size, and letter size (all tokens above).
- **Still pending:** `notch.width` (ruler), the broken `notify-send`, and #12. The AI mark is still red because OpenCode's monthly limit is at 100 %.
