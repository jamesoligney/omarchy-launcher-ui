# Bar Stage 24: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-24-brief.md`. I downloaded the brief from the given URL into `docs/` first and committed it with this report.

The right island is untouched (time, battery, weather, the joined status island), as are the quiet contract, sparks, glow and radius.

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261125-161632-bar-stage-24`** (mode 700, 209 files), taken before any file was edited (the Super+L diagnosis before it only ran the toggle on a scratch workspace). It covers every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, `shell.json` (changed by the dock disable), `shell.toml`, hooks, theme files, extensions, the Vicinae settings, helpers and the systemd unit, plus (local only) the saved per-workspace layouts. Runtime state stays local. Checksums: live before = backup = live after |
| Reload | `hyprctl reload` for the Lua. **One `omarchy restart shell`, on its own**, because the bar gained a new layer (the strip); that can't be hot-reloaded. Never `refresh` |
| Debug / temporary code | None. `console.log` = 0. Test windows (four Ghostty, two Helium) were closed. The `6.lua` layout file the toggle runs wrote was removed. Saved layouts are as found (1, 2, 3, 4, 8). Focus returned to Orca |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced: `Bar.qml`, `float-default.lua`, `shell.toml`, and `shell.json` (the dock disabled). It also carries `shell.json` / `border-fx.lua` colour lines from your theme switch back to the orange edition, which were not mine. Live checksums are identical before and after, and the snapshot equals live. No runtime state in git |

## 1. Super+L: the cause, and the fix

**Checked and ruled out:**
- **The bind is registered once:** `SUPER + L`, "Cycle workspace layout", running `omarchy-hyprland-workspace-layout-toggle`. There is no duplicate or conflicting L bind; the others are Super+Alt+L "back" and Super+Ctrl+L lock.
- **Hyprland is in the default submap,** not stuck in the leader.
- **No Lua errors** in Hyprland's log.
- **Vicinae** binds nothing on Super, and its input server holds no input devices.
- **The toggle works end to end:** run directly, and run through Hyprland's own `exec_cmd` exactly as the bind does, it cycles dwindle → scrolling → floating.

**The cause was a Stage 19 side effect:**
- **Since Stage 19, every new window opens floating** on its own account.
- **Omarchy's floating mode only tiles the windows it floated itself** (its `omarchy-mode-floated` claim) when a workspace leaves floating.
- **After James closed everything and reopened,** every window was default-floated, so nothing was claimed. Super+L changed the layout, but no window was in it: everything stayed floating, and nothing visibly happened. That is why it looked dead even though it fired.
- **Shown live on workspace 6:** a default-floated window stayed floating through dwindle and scrolling, while a window the mode had floated tiled.

**Fix** (`float-default.lua`, `tile_switched`, in the same wrapper around `o.workspace_mode` as the Stage 21–22 reset):
- When a workspace switches to a **tiled** layout (dwindle or scrolling), its normal app windows are **tiled**.
- **Left as they are:** dialogs and windows that floated on their own (`self-floated`), apps with their own float size, and fullscreen and pinned windows.
- The bind itself is unchanged.

**Verified, through the bind's exact path** (`exec_cmd` of the toggle) on workspace 6:

| Press | Result |
|---|---|
| → dwindle | both windows **tiled** (37/887, 834 × 1055) |
| → scrolling | **tiled**, scrolled layout |
| → floating | both at the default, **(329, 273) 1100 × 619** |
| → dwindle | **tiled** again |

A real keypress could not be sent from here (uinput is root-only), so the final check is your Super+L.

## 2. Workspaces: the left strip

- **A new layer** (`jimmy-strip`), anchored to the left edge, with a **real exclusive zone of 30 px** (new token `strip.width`).
  - **Hyprland now reports `reserved [30, 48, 0, 0]`.**
  - Tiled windows start at x 37 (30 plus the gap). Floating windows centre in the reduced area.
- **The pill:** a **vertical workspace pill, centred vertically** in the strip, in the island glass, outline and glow.
  - **Active workspace:** accent fill and accent number.
  - **Others:** quiet.
  - **Click** switches workspace.
- **30 px reads well:** a 6× zoom shows the numbers at the 18 px text size with room on both sides. There was no reason to change it.
- **Fullscreen hides it cleanly,** like the bar. Verified: in fullscreen only the invisible bar reserve layer remains; leaving fullscreen brings back the bar and the strip.
- **Leader digits:** Super+D then 1–9 still switches workspaces (the binds are unchanged). The digit letters that sat under the numbers in the top island are not drawn in the strip, because the pill's numbers are the keys.

## 3. Top left: the focused window's title

- **The left island now holds only the focused window's full title** (`ToplevelManager.activeToplevel.title`). For a browser that's the page title.
- **Long titles:** elided at the ear's width, never wrapping. The island stays centred in its ear, so it never reaches the notch or the right island.
- **No focused window:** the island hides.
- **Removed:** the old app-name mapping and its `island.app-max-width` token.
- **Verified live:** "Orca" in the left island (screenshot).

## 4. The dock: disabled

- **How:** `omarchy plugin disable omarchy.dock`. It is now in `shell.json`'s disabled list, and the `omarchy-dock` layer is gone.
- **The apps window still works** (re-verified, not assumed): summoned the way the launcher's Apps row does (`omarchy-shell shell summon jimmy.apps`), the full grid opened (screenshot), with search, icons and names.
- **Nothing else depended on the dock:** no other layer or plugin went missing.
- **Its left-edge position** would also have collided with the new strip.

## 5. Float default: re-centred for the new usable area

- **The size stays `o.float_default = { width = 1100, height = 619 }`.** Centring uses Hyprland's usable area, so the position moved by itself. Only the comment above it changed, now stating (329, 273).
- **Measured live:**

| Test | Result |
|---|---|
| Fresh Ghostty, workspace 6 | **floating, 1100 × 619 at (329, 273)** |
| **Fresh Helium** (the maximized-request case), workspace 6 | **floating, 1100 × 619 at (329, 273)** |
| Workspace switch to scrolling, then floating (four windows, Helium among them) | all **tiled** on scrolling, then all **(329, 273) 1100 × 619** |
| Super+T after moving a window to (433, 338) | tiled → back at **(433, 338)** |

- **Arithmetic agrees:** x = 30 + (1728 − 30 − 1100) / 2 = 329, and y = 48 + (1117 − 48 − 619) / 2 = 273. Zen is not open, so it was not re-measured; Floorp and NYT use the same path as Ghostty.

## Still open

- **Your keys:** Super+L on a workspace whose windows all opened floating.
- **For your eye:** the strip at 30 px, and long page titles in the left island.
- **Still pending:** cascade vs. stacked, the broken `notify-send`, and #12.
