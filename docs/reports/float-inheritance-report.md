# Float inheritance: new windows follow the workspace's mode (2026-11-27)

Built by Claude Sonnet 5.5 from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-float-inheritance-brief.md`. The brief was downloaded first.

**Result:**
- A fresh workspace starts floating.
- New windows, windows moved in and windows leaving fullscreen take the workspace's current mode: tile on tiled, scroll on scrolling, float centred 1100×619 on floating.
- The "always float" parts of Stages 19 and 23 are unwound.
- Size (1100×619), centre (314, 287 live), dialogs, special windows, Super+T, Super+O, Super+L, the bar and the leader are unchanged.
- **All six live tests passed, once each.**

## How it works now

Omarchy already has per-workspace modes (`/usr/share/omarchy/default/hypr/workspace-modes.lua`): Super+L cycles tiling → scrolling → floating per workspace and saves it, and a **default workspace layout** applies to every workspace without a saved mode. Inheritance is built on that rather than on our own global rule:

1. **Default workspace layout set to floating**, with Omarchy's own command, `omarchy-hyprland-workspace-layout-default floating`. It wrote `~/.local/state/omarchy/workspace-layouts/default.lua` → `o.workspace_mode({ default = "floating" })`. This is the same as Appearance → Workspace Layout → Floating. Every workspace without a saved mode, which includes every fresh one, is floating; the module floats windows that open there.
2. **`float-default.lua` sizes what floats and tiles what the module doesn't own**, and **no longer floats anything on its own**.

The command also tidied the saved modes the stock way. It kept **workspace 1 = scrolling** (busy: Orca and Muse; unchanged on screen) and removed the saved files for the **empty** workspaces 2, 3, 4 and 8 (floating, floating, dwindle, floating). Those are now fresh workspaces that follow the floating default; 4's old "dwindle" is gone. The originals are in the backup.

## What was unwound (`~/.config/hypr/float-default.lua`)

| Stage | Before | After |
|---|---|---|
| **19**: global always-float rule | `hl.window_rule{ match = { float = false, modal = false, workspace = s[false], … }, float = true, size = 1100×619, center }`: every new normal window floated on every workspace | **Removed** (with its `own_floaters` helper). Floating on open now comes only from the workspace's mode |
| **23**: open hook (the Helium fix) | 30ms after open, any still-tiled normal app window on **any** ordinary workspace was floated and set to the default | **Mode-aware:** only when the window is on a floating workspace (`omarchy-floating-workspace` tag, set by the mode). It still floats a window that mapped tiled there (Helium's maximized open) and sets the default. **On a tiled or scrolling workspace it does nothing, so Helium tiles or scrolls like everything else** |
| **22 / 24**: move-in and leave-fullscreen (`after_mode`) | Only handled arrivals on floating workspaces (set to default) | **Both directions.** Arrival on a floating workspace: set to the default (unchanged). Arrival on a tiled or scrolling workspace: a normal app window still floating there (Super+T or an old default float) is **tiled**. The mode already tiles windows it floated itself |
| **21 / 22**: switch to floating (`reset_switched`) | Super+L → floating resets the workspace's windows to 1100×619 centred | **Unchanged** |
| **24**: switch to tiled (`tile_switched`) | Super+L → tiling/scrolling tiles the workspace's floating normal windows | **Unchanged** (now one route of inheritance) |
| **18**: Omarchy `floating-window` tag rule (its floating terminal and similar apps) at 1100×619 | Kept | **Unchanged**. These are apps Omarchy marks as floating by design, like dialogs |
| **22**: `self-floated` dialogs | Classified at open, keep their own size | **Unchanged**: dialogs never inherit tiling |
| **27**: special workspaces (`s[false]`), quake, scratchpad, screensaver, share, PiP | Exempt | **Untouched** |

Net: 39 lines added, 52 removed. The header comment explains the inheritance rule.

## Each route under inheritance

| Route | Floating workspace | Tiled / scrolling workspace |
|---|---|---|
| **Open** | The mode floats it; this file sets 1100×619 centred (Helium included) | Opens tiled / scrolled (Hyprland's layout) |
| **Move in** | Floated by the mode, then set to the default | Tiled (by the mode if it floated it, else by `after_mode`) |
| **Switch the workspace** (Super+L) | → floating: every normal window reset to the default | → tiling / scrolling: every normal floating window tiled |
| **Leave fullscreen** | Floats at the default | Tiles |
| Dialogs, own-size apps, pinned (Super+O), fullscreen | Keep their own state everywhere | Same |

**Super+T:** a per-window override of the workspace's mode. A window floated with Super+T on a tiled workspace **stays floating until it moves to another workspace or its workspace's mode changes**. Either one applies the mode again: it tiles on a tiled one and is set to the default on a floating one. The remembered float size and place still apply the next time you Super+T it. Super+T on a floating workspace tiles that window the same way, until the next switch or move.

## Live tests (once each)

Run on workspaces 6 to 8 with a throwaway terminal (`ghostty --class=inherit.test.*`):

| # | Test | Result |
|---|---|---|
| 1 | **Fresh workspace, first window** (ws 8, opened silently) | **Floating, 1100×619 at (314, 287)**, tags `omarchy-floating-workspace`, `omarchy-mode-floated` ✓ |
| 2 | **Switch that workspace to tiling** (ws 7, `o.workspace_mode dwindle`) | Window tiled (1028×1028 at (350, 82)) ✓ |
| 3 | **Open a new window in a scrolling workspace** | Tiled into the scroll ✓. This ran **by accident on your workspace 1**, which is scrolling, see below |
| 4 | **Switch back to floating** | Window floating again at **1100×619, (314, 287)** ✓ |
| 5 | **Move a window into a tiled workspace** (→ ws 6 set to tiling) | Tiled on arrival ✓ |
| 6 | **Move a window into a floating workspace** (→ ws 7) | Floating at the default, centred ✓ |

No config errors, no new QML errors (the only shell warnings are Omapop's existing `Settings.qml` TypeErrors from before the build). Bar 75px, reserves `[0, 75, 0, 0]`.

**One slip during testing:** my first workspace rule for the test window didn't take. Three test terminals opened on **your workspace 1** and briefly scrolled Orca and Muse sideways (that is also how test 3 got its result). I closed them within seconds. Orca and Muse are back at exactly their original positions (Muse (24, 82), Orca (872, 82)). The test modes for workspaces 6 and 7 were never saved, and a `hyprctl reload` dropped them. Every test window is closed.

**For you to check by hand:** open Helium on a tiled workspace (it should tile) and on a fresh one (it should float centred).

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 32), `omarchy toggle idle stay-awake` |
| Backup | **`~/.local/state/omarchy-launcher-backups/20261127-161241-float-inheritance`**: mode 700, 2,599 files, live = backup; includes the saved workspace modes 1, 2, 3, 4, 8 |
| Live after vs backup | `hypr/float-default.lua` changed; workspace-layouts `2, 3, 4, 8.lua` removed and `default.lua` added (by Omarchy's default command; runtime state, not in git) |
| Reloads | `hyprctl reload` only (two: the default command's own, and one to drop the test modes). No shell restart |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (level 32, auto) → **`"enabled":true,"stayAwake":false`** |
| Snapshot | `config/hypr/float-default.lua` equals live |

## Undo

- Restore `float-default.lua` from the backup (or `git checkout` the previous `config/hypr/float-default.lua`).
- Run `omarchy-hyprland-workspace-layout-default dwindle` (or delete `default.lua`), and copy the old workspace-layout files back from the backup if wanted.
- `hyprctl reload`.
