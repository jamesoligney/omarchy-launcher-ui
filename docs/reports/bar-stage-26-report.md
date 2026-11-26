# Bar Stage 26: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-26-brief.md`. I downloaded the brief from the given URL into `docs/` first and committed it with this report.

**Not touched:** the top bar, the window title, the dock, the float default, Super+L and toast centring. **No right-side frame.**

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261125-172945-bar-stage-26`** (mode 700, 210 files), taken before any edit. It covers every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, `shell.json`, `shell.toml`, hooks, theme files, extensions, the Vicinae settings, helpers and the systemd unit, plus (local only) the saved per-workspace layouts. Checksums: live before = backup = live after |
| Reload | `omarchy restart shell` twice, each on its own: once for the new bar geometry, once for the workspace-list fix. QML layer changes can't be hot-reloaded. Never `refresh`. Token changes reloaded live |
| Debug / temporary code | None. The minimum-height token was set to 0.1 for one screenshot to show the grow path, then restored to 0.5 (verified in the file). All test terminals were closed. Saved layouts unchanged. Focus returned to Orca |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced: `Bar.qml`, `shell.toml`. Live checksums are identical before and after, and the snapshot equals live. No runtime state in git |

## Before

These are from the Stage 24 code geometry. A pixel scan against the wallpaper was unreliable, so I'm quoting the code.

| | Before |
|---|---|
| Hyprland left reserve | **30** (`reserved [30, 48, 0, 0]`) |
| Visible pill | **24 px wide**, at x 3; **as tall as its numbers**, e.g. **≈ 52 px** for two workspaces |
| Number chips | 18 × 22 px |
| Number size | 18 px (`island.text-size`) |
| Tiled windows | start at x 37 |

## After: a real bar on the left

- **Width: 30 px visible** (`strip.width`).
  - **Position:** one `island.gap` (2 px) off the screen edge, like the top islands sit off the top.
  - **Reserve:** Hyprland's reserve is kept in sync as **gap + width = 32**, now **`reserved [32, 48, 0, 0]`**.
  - **Window gap:** tiled windows start at **x 39** (32 + Hyprland's 7 px gap), so the gap between the bar and the windows is the same 7 px gap windows use everywhere.
- **Height: at least half the screen** (new token `strip.min-height = 0.5`, so 559 px on the 1117 px screen; measured ≈ 555 including the outline).
  - Centred vertically in the space below the top bar.
  - Taller only if the numbers need it (it never drops below the minimum), and never taller than the strip.
- **Numbers:** centred in the bar.
  - **Chips:** widened to **24 × 28 px**, more room than before.
  - **Active workspace:** accent fill and accent number. Others quiet.
  - **Click** still switches workspace; **Super+D then 1–9** is unchanged (the binds weren't touched).
- **Same look as the top bar:** the same `Island` tokens, i.e. glass (`islandColor`), the 1 px outline, `IslandGlow` (masked, outside only) and radius (`island.radius`, capped at half the width).
- **Fullscreen** still hides it. Verified: in fullscreen only the invisible top reserve remains, and after fullscreen the bar, strip and reserve all return. The window came back at its exact place.

## Fixed along the way: workspaces reached by a moved window

- **The bug:** with windows on workspaces 1–6, the bar showed only **1–5**. Workspace 6 held a window that had been **moved** there.
- **Cause:** Quickshell doesn't update a workspace's window list when a window moves between workspaces. The strip lists only workspaces with windows, so a workspace reached only by moving a window never appeared. Stage 24's strip had the same bug.
- **Fix:** the bar re-reads Hyprland's windows on `movewindowv2` events, as it already did for `fullscreen`.
- **Verified:** after the fix, moving a window onto a brand-new workspace 7 showed **7 immediately**, and the now-empty 6 went away.

## Verified live

| Case | Result |
|---|---|
| **2 workspaces** (1, 2) | bar ≈ 559 px tall, centred; **1 and 2 float in its middle** (screenshot) |
| **6 workspaces** (1, 2, 3, 4, 5, 7) | same **minimum height, still centred**, six numbers in the middle (screenshot) |
| **Growing**, with the minimum temporarily lowered to 0.1 (112 px) | the bar **grows to fit its six numbers** and stays centred |
| Fullscreen | strip hidden, then back |

**When it would grow for real:** each number takes 30 px. It takes about **18 workspaces** to outgrow half the screen, so at normal counts it stays at the minimum. The grow path is there and verified.

## Still open

- **For your eye:** the bar at 30 × half-screen. Both are tokens (`strip.width`, `strip.min-height`).
- **Float default:** with the reserve now 32, new floating windows centre one px right of Stage 24's 329. **Measured: a fresh Ghostty opened at 1100 × 619, (330, 273).** Windows already open keep their place.
- **Next, not this stage:** the two-sided frame.
- **Still pending:** cascade vs. stacked, the broken `notify-send`, and #12.
