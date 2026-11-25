# Bar Stage 16: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-16-brief.md`. I downloaded the brief from the given URL into `docs/` first and committed it with this report.

These locks are untouched: island height 44, radius 13 (joint 2, gap 4), bar 48, SF Compact Display Medium with no bold, text 18 px, glyphs 20 px, `toast.gap` 0, the battery as a number only, C for the calendar leader, the quick strip outside the island, `Super+D` showing hints only, the letters on the outline, `leader.hints`, the sparks, the glow and glass, the main island order, the custom weather icons, and the AI mark half white.

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261125-143638-bar-stage-16`** (mode 700, 202 files), taken before any edit. It covers the full behaviour set: every `jimmy.*` plugin, `hypr/*.lua`, `shell.json`, `shell.toml`, hooks, theme files, extensions, the Vicinae settings, the paste and backlight helpers, and the systemd unit. Checksums: live before = backup = live after. Excluded: runtime state, because nothing here touches it |
| Reload | `omarchy restart shell` once, on its own; never `refresh`, never combined with a summon |
| Debug / temporary code | None. `console.log` = 0 in `jimmy.bar`. The shell log shows no errors |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced: `Bar.qml`, `shell.toml`. Live checksums are identical before and after, and the snapshot equals live. No runtime state in git |

## 1. Status island: regular glyphs, normal spacing

- **Status lights are ordinary island elements now:** Wi-Fi N, Bluetooth T, mic M and AI A.
  - **Size:** the shared **glyph size (20 px)**, centred vertically.
  - **Layout:** laid out by the island's own row, with the **same padding and spacing as every other island**.
- **Removed:** its private layout, i.e. the hand-placed slots, the step and the small icon size. The `[status]` tokens are gone too (`icon-size`, `step`, `padding-x`). If the main islands' spacing changes, the status island now follows it automatically.
- **Unchanged:**
  - **Shape:** height 44, radius 13 outside and 2 at the joint, the 4 px joint gap, the glass and the shared glow.
  - **Behaviour:**
    - Wi-Fi and Bluetooth keep their status colours, click panels and leader keys.
    - The mic is persistent and grey until in use, then accent.
    - The AI mark stays half white.
- **Leader letters:** still on the outline, centred under each light (screenshot).
- **Verified live:**
  - **System read:** the status island now reads as the same system as the main island, the same glyph weight and rhythm, with no small icons to squint at (screenshots).
  - **Fit:** it is wider than before and still sits inside the right ear, about 55 px short of the ear's corner inset.

## 2. Spacing pulled back a little, everywhere

| Token | Was (Stage 11 overshoot) | Now |
|---|---|---|
| `island.padding-x` | 44 | **36** |
| `island.spacing` | 48 | **38** |

- **Applies to all islands:** the left island, the main right island and the status island. One system.
- **Still airier than before the overshoot:** Stage 9 was 26 / 28.
- **Quick strip:** it follows `island.spacing`, as before, and still slides out left of the main island with the island fixed (screenshot with the strip open). Nothing broke.
- **No other size changed:** text 18, glyphs 20, height 44, radius 13 and bar 48.

## Still open

- **For your eye:** 36 / 38. Each is one token.
- **Real mouse:** clicks on the status lights (no uinput tool here).
- **Still pending:** the broken `notify-send` and #12. `notch.width` stays at the provisional 174, as the brief says.
