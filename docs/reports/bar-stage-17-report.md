# Bar Stage 17: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-17-brief.md`. I downloaded the brief from the given URL into `docs/` first and committed it with this report.

These locks are untouched: island height 44, radius 13 (joint 2, gap 4), bar 48, SF Compact Display Medium with no bold, text 18 px, glyphs 20 px, `toast.gap` 0, the battery as a number only, C for the calendar leader, the quick strip outside the island, `Super+D` showing hints only, the letters on the outline, `leader.hints`, the sparks, the glow and glass, the main island order and spacing (36 / 38), the weather icons, and the AI mark.

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261125-143947-bar-stage-17`** (mode 700, 202 files), taken before any edit. It covers the full behaviour set: every `jimmy.*` plugin, `hypr/*.lua`, `shell.json`, `shell.toml`, hooks, theme files, extensions, the Vicinae settings, the paste and backlight helpers, and the systemd unit. Checksums: live before = backup = live after. Excluded: runtime state, because nothing here touches it |
| Reload | `omarchy restart shell` once, on its own; never `refresh`, never combined with a summon |
| Debug / temporary code | None in the live plugins (`console.log` = 0 in `jimmy.bar`). A throwaway format check in scratch was deleted. The shell log shows no errors |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced: `Bar.qml`, `shell.toml`. Live checksums are identical before and after, and the snapshot equals live. No runtime state in git |

## 1. Status island: its own tighter spacing

- **How:** `Island` now takes its row spacing as a property (`gap`, defaulting to `island.spacing`) as well as its `padding`. The status island sets both from its own tokens. The main islands are unchanged.

| Token | Value |
|---|---|
| `status.padding-x` (new) | **18** |
| `status.spacing` (new) | **20** |
| `island.padding-x` / `island.spacing` (main islands) | 36 / 38, unchanged |

- **Only spacing:** the glyphs stay at the shared `island.glyph-size` (20 px), in a row, centred.
- **Verified live:** the status island is now about **160 px** wide against the main right island's **260 px**, clearly the secondary one. It still reads as the same system: same glyph size, same glass, joint and glow (screenshots).
- **Leader letters:** N T M A still sit on the outline under their lights (leader screenshot).

## 2. Clock: AM / PM back

- **Token:** `clock.format` is now **`h:mm AP`**, which reverses Q4. Its comment says so.
- **Why it is true 12-hour:** Qt treats `h` as 12-hour only when the format contains `AP`, and the bar's `clockText()` passes such a format through as written (Stage 9).
- **No seconds.**
- **Size:** AM/PM sits in the **same 18 px text** as the time, one string, the quiet ink. At 18 px it does not dominate the island, so no smaller marker was needed.
- **Verified live (PM):** at 14:40 the bar showed **`2:40 PM`** (screenshot). Leader C stays on the time, and the calendar panel is unchanged.
- **AM: not observed live.** I tried to confirm `9:04 AM` through a scratch QML script. The `qml` runtime prints nothing in this environment, so that check produced no output. The morning case uses the same format and Qt's standard `AP` handling; the first morning reading is the final check.
- **Rest of the UI:** the time is wider now. The main island grows symmetrically about its ear centre. The quick strip still hangs off its left edge, and the status island still joins its right edge.

## Still open

- **For your eye:** status spacing 18 / 20, and AM/PM at full text size.
- **To check:** a morning reading of the clock.
- **Real mouse:** clicks on the status lights (no uinput tool here).
- **Still pending:** the broken `notify-send` and #12. `notch.width` stays at the provisional 174.
