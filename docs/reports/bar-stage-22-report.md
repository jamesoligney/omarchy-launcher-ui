# Bar Stage 22: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-22-brief.md`. I downloaded the brief from the given URL into `docs/` first and committed it with this report.

The bar and the default size are untouched: `o.float_default = { width = 1100, height = 619 }`, centred at (314, 273), `~/.config/hypr/float-default.lua` line 5.

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261125-154824-bar-stage-22`** (mode 700, 208 files), taken before any file was edited. It covers every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, `shell.json`, `shell.toml`, hooks, theme files, extensions, the Vicinae settings, helpers and the systemd unit, plus (local only) the saved per-workspace layouts. Checksums: live before = backup = live after. One reproduction ran before it: a live, unsaved workspace-3 switch to diagnose the bug, which changed no file |
| Reload | `hyprctl reload` only (`configerrors` empty). **A reload moved no open window** |
| Debug / temporary code | None. Four test windows (three Ghostty, one calculator) were closed. Workspace 6's test-only mode was dropped by a reload (it was never saved). The saved layouts are as found (1, 2, 3, 4, 8; workspaces 2 and 3 still floating). Focus was returned to Orca |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced: `config/hypr/float-default.lua`. Live checksums are identical before and after, and the snapshot equals live. No runtime state in git |

**The screenshot** (`image-f577d910.png`) was not on this machine; the brief links only the markdown. The live state matched it: Ghostty on workspace 3 at 1100 × 619, (314, 273), and **Helium behind it at 1100 × 726, (290, 196)**.

## Why Helium was wrong

- **Not the tag gap alone.** Helium carried the tags Stage 21 checked, and a workspace switch done through `o.workspace_mode` did reset it.
- **The miss:** Omarchy's floating mode has **two more ways** to float and place a window, and Stage 21 hooked neither:
  - a tiled window **moved onto** a floating workspace (`window.move_to_workspace`);
  - a window **leaving fullscreen** there.
- **The tell:** both use the stock placement, 1100 × 726 with a 24 px cascade. Helium's (290, 196) is exactly that, one cascade step off centre.
- **The tag was also unreliable,** which the brief asked about:
  - `float-default` is a rule tag, and Hyprland re-evaluates rule tags live. Tiled windows on workspace 1 carried it.
  - The old Helium on workspace 2 didn't, though it is a normal app window.
  - So "has the tag" meant neither "was sized by the default" nor "is an app window".

## Fix (`float-default.lua`, lines 60–150)

### 1. No tag needed to qualify

- **The reset now covers every normal app window on the workspace,** whatever floated it, whether or not it was opened before Stage 21.
- **The only windows that keep their own size:**
  - fullscreen windows;
  - windows that floated **on their own account**;
  - apps with their own stock float size.
- **The `float-default` requirement is gone.**

### 2. Dialogs are told apart as they open

- **No runtime dialog check exists:** Hyprland's Lua cannot ask a window whether it is a dialog. The window object has no modal or parent field, and window queries ignore a `modal` filter; I tested both.
- **So the moment of opening is used instead,** right after the rules fire:
  - A window that opens **floating** without the default rule or Omarchy's floating-window tag has floated on its own account: a dialog or popup Hyprland floated, a modal, or an app with its own float rule.
  - It gets a static **`self-floated`** tag, for good.
- **Older windows:** apps with their own stock float size are recognised through `o.floating_apps` (Omarchy's list, read with window queries).
- **No per-app exceptions for normal apps:** I checked `o.floating_apps`, and it holds only Omarchy's own floaters and stock-sized apps. There are **no browsers** in it: About, the calculator, Steam, LocalSend, the webcam overlay, Meet windows and pip.

### 3. Every route into a floating workspace now ends at the default

| Route | Hook |
|---|---|
| Workspace switched to floating (Super+L, layout toggle, changed default on reload) | wraps `o.workspace_mode` and the mode's `apply` (Stage 21), now without the tag requirement |
| New window opened there | `window.open` (Stage 19) |
| **Tiled window moved onto it** | **new:** `window.move_to_workspace`. 30 ms after the move (after the stock placement), a window that came in tiled and is now floating there is set to the default |
| **Window leaving fullscreen there** | **new:** the same, on `window.fullscreen` |

## Verified live (`hyprctl clients`)

| Test | Result |
|---|---|
| **Helium on workspace 3**, knocked to 1220 × 709 at (324, 188), then **real Super+L** ×3 (→ dwindle → scrolling → floating) | **1100 × 619 at (314, 273)** |
| Ghostty on workspace 3, the same switch | **1100 × 619 at (314, 273)** |
| **The older Helium on workspace 2** (open since before Stage 18, no default tag), moved to (214, 331), real Super+L ×3 | **1100 × 619 at (314, 273)** |
| A window that stayed **floating while its workspace was scrolling**, moved to (404, 323), workspace → floating | **(314, 273) 1100 × 619** |
| A **tiled window moved onto** floating workspace 3 | **(314, 273) 1100 × 619** (stock would give 1100 × 726, cascaded) |
| A **new window** on workspace 3 | **(314, 273) 1100 × 619** |
| **Calculator** (own stock float size) opened on workspace 3, then workspace 3 → dwindle → floating | **kept 400 × 568 at (664, 299)**, tagged `self-floated` |
| **Super+T** after moving a window to (344, 303): tiled, then floating again | **back at (344, 303)**: per-window memory unchanged, no conflict |
| Other workspaces during each switch | untouched (workspace 1's tiled Orca and Muse never moved) |
| Reload | moved nothing |

**Two windows on a workspace switched to floating:** they stack **exactly** at (314, 273), 1100 × 619 (workspace 3: Helium and Ghostty, then three Ghostty windows). Cascade is out of scope; unchanged.

## Limits, stated rather than hidden

- **Older dialogs are not recognised.** A dialog that was already open before this config loaded carries no `self-floated` mark. It would be treated as an app window if its workspace switched to floating while it was open. Every dialog that opens from now on is marked as it opens.
- **The open-time classification trusts Hyprland's own floating:** a secondary window an app opens floating, such as some "preferences" windows, keeps its own size, exactly like a dialog. Say if any such window should take the default instead.
- **Fullscreen** windows are never touched; one leaving fullscreen on a floating workspace takes the default.

## Still open

- **Your check:** Super+L on any workspace, a window carried onto a floating workspace, and windows leaving fullscreen.
- **Still pending:** cascade vs. stacked, the broken `notify-send`, and #12.
