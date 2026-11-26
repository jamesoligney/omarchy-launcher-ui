# Omarchy Bar — Stage 24 Build Brief

Status: Build brief. Build from docs/omarchy-bar-refined-brief.md plus this brief.
Purpose: Fix Super+L (bind present, not firing) + workspaces to a left strip + exploded top-left name + disable the dock + re-center the float default for the new usable area.

## Locked decisions (James, 2026-11-25)

1. **Super+L is broken and must be fixed.** The bind shows in Vicinae's binds list but does nothing at all, no layout change. It broke after closing everything, switching theme, reopening. Diagnose the cause, fix it, verify live by cycling tiling → scrolling → floating and back.
2. **Workspaces move to a left strip.** Reserve ~30px on the left edge as a real Hyprland reserve, like the top 44, so windows don't slide under it. Vertical workspace pill, centered vertically in the strip. Workspaces only, nothing else in the strip.
3. **Top-left: the focused window name, exploded.** Full window title, including the page title for web pages. Use the freed space, workspaces are gone from the top. The left top island now holds only the expanded name.
4. **Dock: disable it entirely.** James doesn't use it and doesn't care about it. Verify the apps grid still works (jimmy.apps is separate now, the old dock-disable-kills-apps-grid consequence must be re-verified, not assumed). The dock remake brief is superseded: no dock remake, the dock goes away.
5. **Re-center the float default for the new usable area.** Usable area is now screen minus top 44 minus left ~30. Float default was 1100x619 at (314, 273); new center x is about 329, y unchanged. Re-measure live, do not trust the arithmetic. Re-verify the Stage 19-23 behavior under the new geometry: float default on open, workspace-switch reset, Helium case.

## Build checklist (standing rules)

- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files, saved per-workspace layouts. Runtime state (clipboard history, pins, recents, pause) stays local, never in git. Checksums live before = backup = live after.
- `hyprctl reload` only. No shell restart unless the change requires it. Never `omarchy refresh shell`.
- Theme-aware (Afterburn default), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/bar-stage-24-report.md, commit, push, hash only.

## Details

### Super+L diagnosis (do this first)
- The bind is listed in Vicinae but fires nothing. Check: is it actually registered with Hyprland (`hyprctl binds`)? Does the handler it calls error? Did the theme switch leave the layout-cycle state stuck? Is there a duplicate or conflicting bind? Fix the cause, don't just re-bind it.
- Verify live: Super+L cycles tiling → scrolling → floating → tiling, on a workspace with a normal window, and the layout visibly changes each step.

### Left strip
- Target ~30px logical. Confirm live that the pill is readable (numbers legible, not cramped). If 30 is too much or too little, say so in the report with the measured alternative. Don't silently pick a different number.
- Vertical workspace pill, centered vertically in the strip. Active workspace highlighted per the quiet contract (only the active workspace, the active app name, and the agents dot are non-neutral at rest).
- The strip is a real reserve. Windows, tiled or floating, must not slide under it. Fullscreen hides it cleanly, like the bar.

### Exploded name (top left)
- Show the full focused-window title. For browsers, the page title. The left top island now holds only this name, using the space freed by moving workspaces off the top.
- Truncate gracefully if absurdly long: ellipsize, don't wrap, don't push the right island. The left island keeps its position relative to the notch.
- Top bar after the change: left island = expanded name only; right island unchanged (time, battery, weather, agents). The two-island split around the notch stays.

### Dock disable
- Remove / disable the dock plugin (`omarchy.dock`). Confirm the apps window (jimmy.apps) still opens via its normal method and works. Confirm nothing else depended on the stock dock. If disabling the dock breaks something unexpected, say so in the report instead of silently working around it.

### Float default re-center
- Set `o.float_default` in `float-default.lua` for the new usable area. Verify live with a fresh window (Helium, Ghostty, Zen) that it opens floating at the default.
- Verify the workspace-switch reset still works under the new geometry: switching a workspace to floating resets its windows to the default.
- Helium is the hard case: it maps tiled because its Preferences store `browser.window_placement.maximized: true`, so float rules missed it before. Verify Helium specifically opens at the default.

## Out of scope
- No dock remake (superseded by disabling the dock).
- No changes to the right island, weather, agents mission control, or the quiet contract.
- No new apps, no new plugins beyond what's needed for the strip.
