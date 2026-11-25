# Bar Stage 19: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-19-brief.md`. I downloaded the brief from the given URL into `docs/` first and committed it with this report.

The bar and the Stage 18 size are untouched. The size is still `o.float_default = { width = 1100, height = 700 }`, at `~/.config/hypr/float-default.lua` line 4. This stage makes floating the default.

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261125-152803-bar-stage-19`** (mode 700, 208 files), taken before any edit. It covers every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, `shell.json`, `shell.toml`, hooks, theme files, extensions, the Vicinae settings, helpers and the systemd unit. **Plus, local only,** your saved per-workspace layouts (`~/.local/state/omarchy/workspace-layouts/*.lua`), because they decide what tiles where. Checksums: live before = backup = live after |
| Reload | `hyprctl reload` only (`configerrors` empty each time). No shell restart |
| Debug / temporary code | None. All five test windows were closed, workspace 1 and Orca refocused, and no open window was moved |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced: `config/hypr/float-default.lua`. Live checksums are identical before and after, and the snapshot equals live. No runtime state in git |

## Mechanism: a global window rule, not a workspace mode

- **Hyprland has no floating layout:** it only has tiled layouts. Omarchy fakes floating per workspace (its "floating mode", `Super+L`, the `workspace layout default` command).
- **Why I did not use Omarchy's floating mode as the default:**
  - **Wrong size and place:** its size is hard-coded at min(1100, 64 %) × min(760, 68 %), which gives 1100 × 726 here. It cascades every new window 24 px, so even the first one is not centred.
  - **Titlebars:** it puts titlebars on every window of a floating workspace.
  - **Your tiled workspaces:** switching the default would not reach your three dwindle workspaces (1, 4, 8, saved as their own). Switching those would re-float their open windows.
  - **None of this is reachable without editing stock files.**
- **Instead, one rule plus one hook in `float-default.lua`:**
  1. **The default rule** (`float-default.lua`, from line 27). Every **new** window that is not modal, not already floating, and not one of Omarchy's own floaters opens with `float = true`, the default size, `center = true`.
     - **The own-floaters exclusion:** `o.floating_apps`, Omarchy's list of class and title patterns with float rules of their own, is used as a `negative:` match, the same technique the stock floating mode uses.
     - **Where it applies:** on **every workspace**, whatever its layout.
  2. **The floating-mode hook** (line 38). On workspaces in Omarchy's floating mode (your 2 and 3), the mode registers its own open rule at runtime, after mine, so it would win with its size and cascade. A `window.open` hook gives a window that rule opened (it carries the rule's tag) the default size, centred. Your 2 and 3 now behave like every other workspace.
- **Stage 18 pieces kept:** the `floating-window` tag rule and the `Super+T` toggle.

## What is and is not floated by default

| Window | Behaviour |
|---|---|
| Normal app windows, any workspace | **float, 1100 × 700, centred** on the usable area: **(314, 233)**, under the 48 px reserve |
| Omarchy's floating-window apps (floating terminals, file pickers, previews, mpv, imv) | same default (Stage 18 tag rule) |
| **Modal dialogs**, and dialogs or popups Hyprland already floats (transient windows) | **keep the size their app asks for**; there is no 1100 × 700 "OK / Cancel" box |
| Apps with their own stock float size (About, the calculator, the screensaver) | **keep theirs**, excluded via `o.floating_apps` |
| Fullscreen | unaffected; no rule touches it |
| **Windows already open** | **never moved**: rules apply only as a window opens |
| Tiling | **opt-in with `Super+T`**, which tiles the window and later floats it back at its remembered size and place (Stage 18) |

## Verified live (`hyprctl clients`)

| Test | Result |
|---|---|
| New Ghostty on a **fresh workspace** (6) | **float, 1100 × 700 at (314, 233)** |
| New Ghostty on a **busy tiled workspace** (1: Orca and Muse tiled) | **float, 1100 × 700 at (314, 233)**; Orca and Muse **stayed tiled at their exact geometry** |
| New Ghostty on a workspace in **Omarchy floating mode** (2) | before the hook: 1100 × 759 at (266, 131) (the mode's rule won). **After: 1100 × 700 at (314, 233)**. Helium, already open there, was untouched |
| **Two new windows** on one workspace | **both at exactly (314, 233), 1100 × 700**, so they land precisely on top of each other, the newest in front |
| `Super+T` on a default-floating window, after moving it to (374, 273) | → tiled (337, 55, 1055 × 1055) → `Super+T` → **floating at (374, 273), 1100 × 700** again |

## Two windows at once: what happens, and the choice

- **What happens now:** they stack **exactly**, with the second window fully covering the first. That is the literal "absolutely centred" spec.
- **The alternative:** if you'd rather see the one underneath, Omarchy's own floating mode solves this with a **cascade** that steps each new window by 24 px. It is a few lines in the same hook (step the position per opened window, wrapping after five), with the first window still dead centre. I left it out because the brief asked for absolute centring. Say the word and it goes in.

## Limits

- **No dialog-type matcher:** Hyprland has none beyond `modal`. A non-modal secondary window that Hyprland does not float on its own (some apps' "preferences" windows) is treated as an app window, so it gets the default size.
- **Omarchy's floating mode:** your workspaces 2 and 3 keep its titlebars and its tile-when-ended behaviour. Only the size and place of new windows follow the default.
- **The Super+T memory** lasts for the Hyprland session (remembering across restarts is the future Cmd+L idea).

## Still open

- **Your tests:**
  - a fresh workspace;
  - an existing workspace;
  - two windows (stacked vs. cascade);
  - Helium for YouTube at 1100 × 700.
- **Still pending:** the broken `notify-send` and #12.
