# Bar Stage 27: special windows exempt from the float default (2026-11-26)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-27-brief.md`. The brief was downloaded into `docs/` first (4,727 bytes) and is committed with this report.

**Not touched:** the float default size/centre (`o.float_default = { width = 1100, height = 619 }`, measured at `(330, 273)`), the top bar, the left strip, the exploded name, the dock, Super+L, toast centring. **No new binds, no new specials.**

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261126-092732-bar-stage-27`** — mode **700**, **2,386 files**, **564 MB**, local only, taken before any edit. Covers every `~/.config/hypr/*.lua` (excluding old `.bak*`), every `jimmy.*` plugin, `shell.json`, `shell.toml`, hooks, themes, extensions, tweaks, systemd, Vicinae settings, helpers and the saved per-workspace layouts. Checksums: **live before = backup = live after**. Stock qconsole hash recorded separately: **`f2adbfea3720f268b13e99246c051f91dc052acb4f2e346d0eeec4b160fed5e0`** |
| Reload | `hyprctl reload` only. No shell restart, never `omarchy refresh shell`. `hyprctl configerrors` empty every time |
| Debug / temporary code | Temporary `io.open` logging in the open and move hooks while tracing the share-window path; **removed** and verified with `grep`. `luac -p` clean. All test windows closed. Five windows remain (Helium, Muse Ghostty, Orca, Muse Chromium, the quake agent). Focus returned to Orca |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced: `config/hypr/float-default.lua`. Its checksum equals live (`9dc8f333f6ef6315d7dbfe3a1573fa5b81e08868798ed91e82c5d22a35cd06db`). No runtime state in git |

## What was wrong

The default's second float rule matched every `float = false` window on **every** workspace. A special workspace's window is not exempt just because Stage 23's open hook skips `id < 1`: the **rule** fires first, floats the window at 1100×619, centres it, and tags it `float-default`. The hook then skipped it, leaving the damage in place. The first rule (Omarchy's `floating-window` tag) had the same workspace gap.

Baseline, live:

| | Quake console, before |
|---|---|
| Window | `org.omarchy.agent`, `✳ Claude Code`, `0xaaaafaf32d80` |
| Workspace | `special:qconsole`, id **−98** |
| State | **floating**, **1100 × 619**, at **(330, 273)** |
| Tags | `float-default*`, `terminal*`, `transparent-window*` |

Stock qconsole expects a **tiled** window sized by its own gaps. The 1100×619 came from the default, not from qconsole.

## The fix: exempt specials as a class

All in `~/.config/hypr/float-default.lua` (**79 insertions, 3 deletions** against the backup):

- **`workspace = "s[false]"` on both float rules.** `s[false]` selects every ordinary workspace and no special one, so the default never reaches a special however the window opens. This is the class-wide exemption — no per-window list.
- **Open hook:** a stock rule can move a window onto a special *after* the float rules have run (the share window, `special silent`). The hook now sees the final special workspace, gives back the default's float, and classes a window that floated there on its own as `self-floated`.
- **Move hook:** a default-floated window carried onto a special (`Super+Shift+Grave`, `Super+Alt+S`) is tiled by that workspace. A manual `Super+T` float, a dialog, a pinned window or a fullscreen window keeps the state it arrived with.
- **`o.float_toggle()`:** tags a user float `user-floated`. On a special it floats the window in place and never applies the default.
- **One-time catch-up:** a window already on a special with the old `float-default` tag (the quake agent) is tiled on load. New windows never get the tag there.
- **PiP overlays:** the main rule excludes them by a marker tag (`pip-meet`). Stock's `pip` tag and stock's Meet PiP (`chromium-based-browser` + `Meet - ...` title) both get the marker, so one exact tag excludes both. This keeps their stock size, pin and corner.

## Special windows audited

| Window / workspace | Stock behaviour | Before this stage | After |
|---|---|---|---|
| **Quake console** — `special:qconsole`, `Super+Grave` | Half-height panel over the current workspace, dimmed, tiled by its gaps; one window = centred panel, two = full width | **1100×619 floating at (330, 273)**, tagged `float-default` | **Tiled 530×530 at (615, 50)**; drops from the top, dim **0.6**, agent session intact. Two windows fill the width: 929×530 + 759×530 |
| **Scratchpad** — `special:scratchpad`, `Super+S` | Full-screen special workspace | A default-floated window moved there stayed 1100×619 | **Tiled 1055×1055 at (353, 55)**; full screen, dimmed. Moved back to workspace 3: **1100×619 at (330, 273)** |
| **Screensaver** — `special:screensaver`, `org.omarchy.screensaver` | Fullscreen, floating, on a hidden special (`silent`) | The default could reach it as a floating window | **Fullscreen 1728×1117, no `float-default` tag.** Tested with a window carrying the same class; the real screensaver was **not** launched (it would lock the session) |
| **Screen share** — `special:special` (unnamed), title `.*is sharing.*` | Stock moves it to a hidden special | **1100×759 floating at (266, 131)** | **Tiled 1055×1055 at (353, 55)** on `special:special`; no default |
| **Picture-in-picture** — plain `pip` + Meet | Stock 600×338, pinned, keep aspect, its own corner | **1100×620 floating at (330, 273)**, tagged `float-default` | **600×338, pinned**, stock position, **no `float-default`**; tags `pip*`, `pip-meet*` |
| **Pop (`Super+O`)** | A normal floating window popped to another monitor, then centred | Normal floating window | **Not exempt, intentionally**: it is not a special workspace; it keeps the default size |
| **Launcher, bar, menus, OSD, notifications** | Quickshell layer surfaces | Never Hyprland clients | **Not affected** — the float default never applied |

No other special workspace, dropdown or overlay was found where the default still reaches it. Stock defines exactly the four special workspaces above: `qconsole`, `scratchpad`, `screensaver` and the unnamed `special`.

## The quake panel, and the one square thing

Stock qconsole (`/usr/share/omarchy/default/hypr/qconsole.lua`, hash above) uses `share = 0.5`, `box = 2`, and workspace gaps. On this screen (usable **1696×1069** after the 32 left / 48 top reserve) its single-window panel is **1068×534 at (346, 48)**; two windows get the full width back. The live console now does exactly that, **except** for the aspect:

- **Measured single window: 530×530 at (615, 50)** — centred on the usable area, half the usable height, flush with the top, dim 0.6, drop-down animation, session intact.
- **Why it is square, not 2:1:** the global **`single-window-aspect-ratio` toggle is on** (`~/.local/state/omarchy/toggles/hypr/single-window-aspect-ratio.lua`, `{ 1, 1 }`, file dated **2026-11-24 07:10**). Hyprland 0.56.2 applies it to every single tiled window. It is a **global** value; it cannot be scoped to one workspace (`layout_opts` only carries layout-specific keys such as scrolling direction and master orientation; the aspect value is read globally). I did **not** change it: that would change every single tiled window, outside this stage.
- **The one-key fix if you want the 2:1 panel:** turn the toggle off with **`Super + Ctrl + Backspace`**. Stock qconsole then takes **1068×534 at (346, 48)**. With it on, the same stock panel is square. The console is still the stock drop-down, centred and half-height either way.
- **Two windows:** **929×530 at (34, 50)** and **759×530 at (967, 50)** — tiled side by side across the full usable width. A fresh window added to the console gets **no `float-default` tag**; only the pre-existing agent still carries the old tag.

## Verified live

| Check | Result |
|---|---|
| Quake open → close → reopen | Hidden (`specialWorkspace` empty) and shown again; tiled panel **530×530 at (615, 50)**; agent `✳ Claude Code` and its session intact |
| Quake two windows | Full width, side by side, **929×530 + 759×530**; fresh window tiled with no default tag |
| Quake dim | `decoration:dim_special` = **0.6**, screenshot confirms the dimmed workspace behind |
| Scratchpad | Window moved there is **1055×1055 tiled**; shown full screen; moved back to workspace 3 returns **1100×619 at (330, 273)** |
| Screen share | Foot titled `stage27 is sharing` lands on `special:special`, **1055×1055 tiled** |
| Screensaver | Simulated class `org.omarchy.screensaver`: `special:screensaver`, **fullscreen 1728×1117**, no `float-default` |
| PiP | Alacritty titled `Picture-in-Picture`: **600×338, pinned**, stock position, **no `float-default`**; marker tag present |
| Normal app default | Fresh Ghostty and a fresh foot both open **1100×619 at (330, 273)** — unchanged |
| Binds | Unchanged: `Super+grave` (64) Toggle Quake console, `Super+Shift+grave` (65) Move to console, `Super+S` (64) Toggle scratchpad, `Super+Alt+S` (72) Move to scratchpad |
| Reload health | `hyprctl configerrors` empty; `luac -p` clean; no debug code; all test windows closed |

## Files changed

- `~/.config/hypr/float-default.lua` — the class-wide exemption, hooks and PiP marker (79 insertions, 3 deletions).
- `config/hypr/float-default.lua` — snapshot resynced, checksum identical to live.
- `docs/omarchy-bar-stage-27-brief.md` — brief, downloaded.
- `docs/reports/bar-stage-27-report.md` — this report.
- No runtime state, no clipboard/emoji/pins/recents in git.

## Still open / for your eye

- **The 1:1 aspect toggle vs. the 2:1 stock quake panel.** This is the only visible deviation from stock qconsole. It is your global preference, not the float default. Turn it off with `Super+Ctrl+Backspace` for the 1068×534 panel; if you would rather keep the square everywhere else but have a 2:1 console, that needs a console-specific follow-up (there is no clean per-workspace aspect setting in Hyprland 0.56.2).
- **PiP:** the plain `pip` path is live-tested. The Meet variant is marked from stock's own `chromium-based-browser` + `Meet - ...` condition; no live Meet call was made, so the Meet path is rule-verified only. A Chromium app window titled `Meet - stage27` was **not** a valid test: its class (`chrome-__tmp…-Default`) does not carry the stock browser tag, so stock would not treat it as the Meet PiP either.
- **The quake agent** keeps its old `float-default` tag from the bug. It is tiled now; if it is ever floated again, `Super+T` marks it `user-floated` and the workspace keeps that float. A reload no longer re-floats it.
- No other special-window problem was found. The other “messed up” things mentioned in the brief were not identified as special windows; nothing unrelated was changed.
