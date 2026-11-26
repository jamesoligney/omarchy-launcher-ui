# Top Bar v5: the easy trim (2026-11-26)

Built by Claude Sonnet 5.5 from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-topbar-v5-brief.md`. The brief was downloaded first. The theme stays **Afterburn Redline**.

**Built:** the six easy items are out of the bottom row, removed from `shell.json` → `bar.layout`, not hidden. The row went from **497 to 340px** (room 717). **No blank slots remain**: locus (night light) now sits directly beside audio. Nothing else was trimmed. The right island, quick tiles and geometry are untouched.

![Top bar v5, Redline](bar-topbar-v5/topbar-v5-redline.png)

![Left island with leader letters](bar-topbar-v5/left-island-leader.png)

## Audit (v4, confirmed live before the trim)

`omarchy-shell jimmy.bar status` at build start: `band {width 497, room 717}`. The inventory and widths matched the brief exactly:

| Widget | Width | Why it's out |
|---|---|---|
| `omarchy.keyboard-layout` | **30** | Blank with one layout: the space between locus and audio |
| `omarchy.power` | **54** | "86%" + battery, duplicating the right island's battery |
| `omarchy.indicators` | **0** | Invisible at rest |
| `omarchy.system-update` | **21** | Invisible at rest (no updates pending) |
| `io.github.smoothpixels.glyph-menu` | **25** | Opens a menu Super+Space already opens |
| `jimmy.menu` | **27** | Opens the launcher Super+Space already opens |

Total: 157px of widgets plus the 0-spacing between them, so 497 → **340**.

## How they were pulled out

- All six entries were deleted from **`shell.json` → `bar.layout`** (`centerBegin`, `centerEnd`, `left`, `right`, `tray`). `inventoryIds` is computed from that layout, so the bar no longer loads them into the row. No hiding, no CSS. Restoring any one is one entry back in the layout; the originals are in the build-start backup.
- **One safeguard: `omarchy.power`.** That widget also owns the **power panel the right island's battery opens** (click, and leader B). Removing it from the layout alone would have broken the battery's panel, so it is now **hosted invisibly under the right ear** again (`rightHostIds`), as it was before v2, and listed in `drawnIds` so it can never re-enter the row. It draws nothing; the battery's panel still drops from the right ear. Verified live.
- The others own nothing the bar still needs:
  - the `omarchy.indicators refresh` IPC is answered by `jimmy.bar` itself;
  - the launcher keeps its own binds;
  - updates and the keyboard layout are still reachable from the Omarchy menu.

## Bottom row now (left → right)

| # | Widget | Shows | px |
|---|---|---|---|
| 1 | `io.github.cwilliams5.locus` | Night-light arc | 27 |
| 2 | `omarchy.audio` | Speaker (directly beside locus, no gap) | 27 |
| 3 | `superwhisper.panel` | Superwhisper | 27 |
| 4 | `io.github.jondkinney.omapop` | Omapop's icon | 27 |
| 5 | `omarchy-fx` | FX pen | 27 |
| 6 | `acooper.scratchpad` | Note | 21 |
| 7 | `io.github.whiskeytangofussell.matrixscreens` | [10/01] | 27 |
| 8 | `omarchy.monitor` | Display | 27 |
| 9 | `io.github.denonmaryland.tricky-tiles` | Split | 27 |
| — | `lock-explorer` | Still configured, never loaded (raw `type: qml` entry only the stock bar resolves). It takes no space | — |
| + | Wi‑Fi, Bluetooth, mic, agents | Status lights, leader N T M A | — |

**Width / room: 340 / 717.** The row's ink spans x 414.5–745.5, ending 30 from the notch. Every slot in the row now draws something. **No invisible slots remain.** The gaps are the v3 tightening: 0 between widgets (their slots' own padding) and 10 before and between the lights.

## What to trim next (your call, by eye)

1. **The settings-type widgets you open rarely:** `matrixscreens`, `omarchy-fx`, `tricky-tiles`, `omarchy.monitor`. Each is reachable from its own panel or the Omarchy menu.
2. **`lock-explorer`:** remove its dead layout entry for tidiness (it never loads in this bar).
3. Then decide the row's order, for example the things you touch most (audio, Superwhisper, Omapop) nearest the lights.

## Verified live

| Check | Result |
|---|---|
| Bottom row | Tight; 9 widgets + 4 lights all visible; no blank slot between locus and audio; no other invisible slots |
| Left island | Workspace chip at x 30 + title on top; bottom row ends at 745.5 (30 from the notch at 777) |
| Leader Super+D | **N T M A** on the lights, legible, not clipped; Q C B W unchanged |
| Panels | Audio drops from its bottom-row icon. **The battery's power panel** (`omarchy.power`, now hosted hidden) **drops from the right ear**. Calendar unchanged |
| Right island | Unchanged (time bbox 174 × 36 at y 57, as in v4); quick tiles unchanged |
| Band under the notch | Empty fill: (42, 9, 11) Redline, (46, 31, 19) Afterburn |
| Notch | Clean cut-out: (0, 1, 0) / (7, 11, 10) |
| Desktop / geometry | (88, 0, 0) / (9, 14, 7) untinted; bar 75; **`[0, 75, 0, 0]`**; windows **y 82**; float rule unchanged (314, 286); tint 0.22 |
| Themes | Afterburn verified, **Redline restored** |
| Health | `hyprctl configerrors` empty; no `jimmy.bar` errors |

**Not exercised live:** Super+L / Super+T, a fullscreen toggle, and opening a new floating window. Those code paths are unchanged.

![Afterburn](bar-topbar-v5/topbar-v5-afterburn.png)

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold`, `omarchy toggle idle stay-awake` |
| Backup | **`~/.local/state/omarchy-launcher-backups/20261126-141019-bar-topbar-v5`**: mode 700, **2,401 files**, live = backup. Excluded (named): `*.bak*`, `__pycache__`, symlinks, runtime state. No runtime state in git |
| Live after vs backup | Exactly `shell.json` (six layout entries) and `jimmy.bar/Bar.qml` (`omarchy.power` hosted hidden) |
| Reloads | One `omarchy restart shell`, on its own |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` → **`"enabled":true,"stayAwake":false`** |
| Snapshot | `plugins/jimmy.bar/Bar.qml`, `config/omarchy/shell.{json,toml}`, `config/hypr/border-fx.lua` equal live |
