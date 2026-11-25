# Bar Stage 15: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-15-brief.md`. I downloaded the brief from the given URL into `docs/` first and committed it with this report.

These locks are untouched: island height 44, radius 13 (joint 2, gap 4), bar 48, SF Compact Display Medium with no bold, `toast.gap` 0, the battery as a number only, C for the calendar leader, the quick strip outside the island, `Super+D` showing hints only, the letters on the outline, `leader.hints`, the sparks, the width (44 / 48), the glow, the glass, the main island order, the custom weather icons, and the status island row.

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261125-142804-bar-stage-15`** (mode 700, 202 files), taken before any edit. It covers the full behaviour set: every `jimmy.*` plugin (`jimmy.weather` included), `hypr/*.lua`, `shell.json`, `shell.toml`, hooks, theme files, extensions, the Vicinae settings, the paste and backlight helpers, and the systemd unit. Checksums: live before = backup = live after. Excluded: runtime state, because nothing here touches it |
| Reload | `omarchy restart shell` once, on its own; never `refresh`, never combined with a summon |
| Debug / temporary code | None. `console.log` = 0 in `jimmy.bar`. The shell log shows no errors |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced: `Bar.qml`, `shell.toml`. Live checksums are identical before and after, and the snapshot equals live. No runtime state in git |

**Not this build's change, but in the snapshot:**
- **Theme:** you switched it again, this time to a **red** accent.
- **Effect:** border-fx rewrote its colours in `shell.json` and `hypr/border-fx.lua`. Both are committed because the snapshot must equal live.
- **Bar:** everything followed the new accent.

## 1. AI mark: plain half white

- The mark is now **always quiet at 60 %**, the same as the other status lights at rest.
- **No colour of any kind:** no accent while an agent runs, no red, no over-limit colour.
- **Where activity still shows:** running state and limits stay in the agents panel and in `omarchy-shell jimmy.bar status` (`agents.state`, `agents.running`), until model activity gets its own design.
- **Verified live:** agents are running and OpenCode's monthly limit is at 100 %, and the mark is still half white (screenshot).
- **Unchanged:** click (agents panel, from the status island), leader A, 13 px in the row.
- **Not built:** the side panel.

## 2. Text 18 px, glyphs 20 px: split tokens

`island.font-size` (20) is replaced by two tokens:

| Token | Value | Drives |
|---|---|---|
| **`island.text-size`** | **18** | every letter and number in the islands: time, battery %, app name, workspace numbers |
| **`island.glyph-size`** | **20** | every glyph: weather icon, contextual lights, quick-strip icons including the stay-awake cup |

- **Status island:** its lights keep their own `status.icon-size` (13), unchanged.
- **How it works:** the shared `Label` (all text) reads the text size. `Light`, the quick icons, the stay-awake metrics and `WeatherIcon` read the glyph size. Nothing else read the old token (checked across all `jimmy.*` plugins).
- **Toast text: no change needed.** It already sits at the shell's `title` size (14 px), below 18, and toasts are otherwise locked.
- **Islands unchanged:** height, width, padding and spacing. The smaller text sits in the same islands.
- **Verified live:** with the strip open (screenshot), the time and battery are visibly lighter at 18 px, while the weather sun, the quick icons and the cup stay at 20 px. The islands read less in your face at the same size.
- **Sparks:** they read the number's own font size, so they still come off it correctly.

## Still open

- **For your eye:** 18 / 20 by eye. Either value is one token.
- **Real mouse:** clicks on the status lights (no uinput tool here).
- **Still pending:** `notch.width` (your ruler), the broken `notify-send`, and #12.
