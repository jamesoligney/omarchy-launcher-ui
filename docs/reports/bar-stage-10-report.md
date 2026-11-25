# Bar Stage 10: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-10-brief.md`. I downloaded the brief from the given URL into `docs/` first and committed it with this report.

These locks are untouched: SF Compact Display Medium with no bold, `toast.gap` 0, the battery as a number only, C for the calendar leader, the quick strip outside the island, `Super+D` showing hints only, the letters dissecting the outline, `leader.hints`, and the sparks (no change to `Sparks.qml` or its tokens).

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261125-131101-bar-stage-10`** (mode 700, 195 files), taken before any edit. It covers the full behaviour set: every `jimmy.*` plugin, `hypr/*.lua`, `shell.json`, `shell.toml`, hooks, theme files, extensions, the Vicinae settings, the paste and backlight helpers, and the systemd unit. Checksums: live before = backup = live after. Excluded: runtime state, because nothing here touches it |
| Reload | `omarchy restart shell` once, on its own; never `refresh`, never combined with a summon. Token edits after that reloaded live from `shell.toml` |
| Debug / temporary code | None. `console.log` = 0 in `jimmy.bar` and `jimmy.shared`. The shell log shows no errors from the bar or `IslandGlow` |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced; live checksums are identical before and after, and the snapshot equals live. No runtime state in git |

**Not this build's change, but in the snapshot:**
- **What changed:** your theme is now the **green** edition (accent green).
- **`shell.json`:** border-fx's colours were rewritten at 13:06, before this build started.
- **`hypr/border-fx.lua`:** the border-fx plugin regenerated it to match when I restarted the shell (13:11).
- **Both are the theme switch,** not a Stage 10 change. They are committed because the snapshot must equal live.
- **All Stage 10 surfaces follow the new accent,** because everything is theme-aware.

## 1. Corner radius: 11

- **`island.radius` 9 → 11.** That one token already drives every surface in the island language, so all of these changed together and the system keeps one radius:
  - **the two islands** (`jimmy.bar`);
  - **toasts** (`jimmy.osd`);
  - **notifications** (`jimmy.notifications`, `Toast.qml`);
  - **the reminder card** (`jimmy.reminders`, `ReminderFlow.qml`);
  - **`PanelShell`** cards (`jimmy.shared`);
  - **adopted stock panels**, i.e. calendar, weather, power, agents and the rest, restyled by `PanelAdopter`.
- **Verified live:** the islands, a toast and the adopted calendar all show the softer corner (screenshots). It reads as a rounded square, not a pill.

## 2. Opened up vertically: both values tried

| | Try A: inside 44 | **Try B: shipped** |
|---|---|---|
| `bar.height` (reserve) | 44 | **48** |
| `island.gap` | 1 | **2** |
| Island height | 42 | **44** |
| `island.font-size` | 20 | **21** |

- **Try A:** this filled the 44 almost edge to edge (1 px above and below) and gained only 2 px of island. It still read pinched (screenshot).
- **Try B:** the reserve goes **44 → 48**, the island to 44 and the text and icons to 21 px. The island has room around its content again, and the 2 px gap keeps it clear of the screen edge (screenshot).
- **The reserve change is explicit:** `hyprctl monitors` now shows **`reserved [0, 48, 0, 0]`**, so windows start 4 px lower.
  - **To go back:** `bar.height = 44`, `island.gap = 1`, `font-size = 20` (that is Try A), or the Stage 9 values (44 / 2 / 19).
- **Text and icons scale together:** every island glyph is the same `Label` size. That covers weather, lights, the AI mark, the quick icons and the cup. Workspace chips are sized from the island height.
- **Leader letters:** unchanged at 12 px with a −1 nudge. Measured at the new 46 px edge, the outline crosses the C at the middle of its height. The other letters sit on the same line (screenshot).
- **Rest of the UI:** toasts, notifications, the reminder card and `PanelShell` all compute the island's bottom edge from `bar.height − island.gap`. A toast was verified attached at the new edge (`osd show`, screenshot).

## 3. The faintest accent glow

- **New `jimmy.shared/IslandGlow.qml`:** a `RectangularShadow` (Qt Quick Effects, an SDF rounded-rect glow, not a blur pass). It is accent at **14 %**, blur **10 px**, no spread, static.
- **One component, one token pair** (`island.glow-alpha`, `island.glow-blur`).
- **Drawn behind its surface:** it is a z:−1 child of the surface it lights. It takes that surface's radius and follows its motion and fade with no extra code.
- **Applied to:** both islands, toasts, notifications, the reminder card, `PanelShell`, and adopted panels (`PanelAdopter` adds one per card, once). It glows the same everywhere.
- **Off switch:** `island.glow-alpha = 0`.
- **Bar layer:** it is now `bar.height + max(letter overhang, glow blur)` tall, so the glow under the islands is never cut off. The input region stays the bar itself, so the extra band is click-through. The blur rule's `ignore_alpha` 0.2 leaves the faint glow unblurred.
- **Verified live:** a soft halo, visible against the dark wallpaper only when you look for it, on the islands, the toast and the calendar card (screenshots). It is not an outline or a pulse.

## Sparks

- Untouched. Sparks were seen firing in the Try B and calendar screenshots.

## Token changes (`shell.toml`)

| Token | Was | Now |
|---|---|---|
| `bar.height` | 44 | **48** (explicit reserve change) |
| `island.gap` | 2 | 2 (via 1 in Try A) |
| `island.radius` | 9 | **11** |
| `island.font-size` | 19 | **21** |
| `island.glow-alpha` / `glow-blur` | — | **0.14 / 10** (new) |

## Still open

- **For your eye:**
  - reserve 48 against 44 (Try A values above);
  - the glow strength (`glow-alpha`, 0.10–0.18 is the sensible band);
  - text at 21 px.
- **Real mouse:** hover and clicks on the quick icons (no uinput tool here).
- **Still pending:** `notch.width` (ruler), the broken `notify-send`, and #12.
