# Bar Stage 21: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-21-brief.md`. I downloaded the brief from the given URL into `docs/` first and committed it with this report.

The bar and the default size are untouched: `o.float_default = { width = 1100, height = 619 }`, centred at (314, 273), `~/.config/hypr/float-default.lua` line 5. This stage resets windows when a workspace switches to floating.

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261125-153736-bar-stage-21`** (mode 700, 208 files), taken before any edit. It covers every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, `shell.json`, `shell.toml`, hooks, theme files, extensions, the Vicinae settings, helpers and the systemd unit, plus (local only) the saved per-workspace layouts. Checksums: live before = backup = live after |
| Reload | `hyprctl reload` only (`configerrors` empty each time). **A reload moved no open window:** I compared every client's geometry before and after |
| Debug / temporary code | None. All three test windows were closed. The `7.lua` layout file the real Super+L test wrote was removed, so workspace 7 is back to the default, and the saved layouts are exactly as found (1, 2, 3, 4, 8). Focus was returned to Orca on workspace 1 |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced: `config/hypr/float-default.lua`. Live checksums are identical before and after, and the snapshot equals live. No runtime state in git |

## Mechanism

- **How a workspace becomes floating:** Omarchy's floating mode is entered through two calls, both in the stock module `workspace-modes.lua`.
  - **`o.workspace_mode()`:** used by Super+L, the layout toggle (`hyprctl eval`), and the saved layouts on load.
  - **The module's `apply()`:** run on every reload. A changed default (`workspace layout default floating`) takes effect here.
- **How a just-switched window is recognised:** the mode marks every window on a floating workspace with the tag `omarchy-floating-workspace`, and that tag survives reloads.
- **What I did:**
  - In `float-default.lua` (lines 70–105) both calls are wrapped. Each records which windows carry that tag, runs the stock call, and then sets **the windows that just gained it** to the default size, centred.
  - That diff is what separates a real switch into floating from a reload that only restores saved modes, which resets nothing.
  - **It runs after the stock placement** (stock size 1100 × 726 plus a 24 px cascade), so **the default wins**, as the Stage 19 hook does for new windows.
- **Which windows are reset:** windows the mode has just floated from tiled (its own `omarchy-mode-floated` tag), and windows the default rule sized. The latter now carry a **`float-default`** tag from the Stage 18–19 rules, so dialogs can be told apart.
- **Fixed along the way:** the Stage 18–19 rules now use plain `hl.window_rule` instead of `o.window`. `o.window` had been filing my `negative:` class pattern into Omarchy's `o.floating_apps` list, which the floating mode builds its exclusions from. That was a latent bug from Stage 19.
- **Stock files:** untouched.

## What is and is not reset

| Window | On switching its workspace to floating |
|---|---|
| Normal app windows on that workspace (tiled ones, and windows the default rule opened) | **reset to 1100 × 619, centred (314, 273)**, every time |
| Windows on other workspaces | untouched; only windows that just gained the floating-workspace tag are touched |
| Modal dialogs, and dialogs or popups Hyprland already floats | **keep their own size** (they never carry `float-default`) |
| Apps with their own stock float size (About, the calculator) | **keep theirs** (excluded from the default rule, so not tagged) |
| Fullscreen windows | unaffected (skipped) |
| Windows opened before today's tag existed and floating on their own account | not reset, because nothing marks them as default-sized. Any window opened from now on is covered |

## Verified live (`hyprctl clients`)

**Workspace 6**, driven through `o.workspace_mode` exactly as Super+L's script calls it. Window A floated by default and I moved it; window B was tiled with Super+T.

| Step | A | B |
|---|---|---|
| → **floating** | (314, 273) 1100 × 619 | was tiled → **(314, 273) 1100 × 619** |
| → scrolling; A moved to (454, 253) | float (454, 253) | tiled |
| → **floating** | **(314, 273) 1100 × 619** | **(314, 273) 1100 × 619** |
| → dwindle; A moved to (194, 323) | float (194, 323) | tiled |
| → **floating** again | **(314, 273) 1100 × 619** | **(314, 273) 1100 × 619** |

**Workspace 7, the real Super+L script** (`omarchy-hyprland-workspace-layout-toggle`, three presses): a window moved to (224, 343) went master → dwindle → scrolling → **floating: (314, 273) 1100 × 619**.

**Two windows:** both land on **exactly (314, 273), 1100 × 619, stacked**, the same as for new windows. Cascade stays out of scope.

**Super+T:** unchanged and still per-window. I moved A to (354, 293), then Super+T → tiled → Super+T → **back at (354, 293)**.
- **No conflict:** the toggle remembers a window's own float. A workspace switch to floating resets the workspace's windows to the default. For that switch the reset wins.

**Note on a window behaviour:** a window that floated by default stays floating when its workspace goes to scrolling or dwindle. The stock mode only tiles what it floated itself; Super+T tiles it. That is unchanged from before.

## The Zen window on workspace 3: found moved, left as is

- **What I found:** at build start, Zen was already at **1100 × 726, (290, 196)**, which is the stock floating mode's placement. My first snapshot, taken before any change, shows it.
- **Why:** the saved layout for workspace 3 was rewritten at **15:34:41**, before this build began. That was a Super+L cycle on workspace 3, which is exactly the bug this stage fixes.
- **What I did:** I did not move it. The next time workspace 3 switches to floating, it resets to (314, 273) 1100 × 619 like everything else.

## Limits

- **A `float = true` matcher** does not see floating that another rule sets; hence the tags.
- **Untagged older windows:** a floating window opened before this stage, by an app with no rule, is not reset; it isn't marked as default-sized. New windows are.
- **Omarchy's floating mode** still adds its titlebars and its tile-when-ended behaviour; only size and place follow the default.

## Still open

- **Your test:** Super+L on a workspace with a moved floating window.
- **Still pending:** cascade vs. stacked, the broken `notify-send`, and #12.
