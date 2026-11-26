# Omarchy Bar — Stage 26 Build Brief

Status: Build brief. Build from docs/omarchy-bar-refined-brief.md plus this brief.
Purpose: Make the left strip a real bar — wider, minimum half the screen height, same look as the top bar. The start of the frame on the left side.

## The problem (James, 2026-11-25)

The left reserve space doesn't look right. The strip is too narrow for the workspace numbers — they need more breathing room. And the pill is a small floating pill, not an actual bar.

## Locked decisions

1. **Width: 30px** for the visible bar. More breathing room for the numbers. Not the full 44px of the top bar's height — narrower than the top.
2. **Height: minimum half the screen height** by default, so there's an actual bar there. The one, two or three workspace numbers float in the middle of it.
3. **Look: the same look as the top bar** (island glass, outline, glow, radius, tokens), just a little narrower.
4. The bar **grows taller than the half-height minimum if more workspaces need the room**; it never shrinks below the minimum. Numbers stay centred vertically in the bar.
5. This is the **start of the frame on the left side**. A two-sided frame (left + right) is coming soon, but NOT in this stage.

## Build checklist (standing rules)

- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files, saved per-workspace layouts. Runtime state (clipboard history, pins, recents, pause) stays local, never in git. Checksums live before = backup = live after.
- `hyprctl reload` only. No shell restart unless the change requires it. Never `omarchy refresh shell`.
- Theme-aware (Afterburn default), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/bar-stage-26-report.md, commit, push, hash only.

## Details

- Measure the live strip first and report the before numbers: the Hyprland left reserve, the visible pill's width and height, the number size.
- Set the visible bar to **30px wide**. Keep the Hyprland left reserve in sync with the bar's width so tiled windows never underlap it. Keep the gap between the bar and the windows as it is (tiled windows start at x 37 today — 30 + 7).
- Minimum height: **half the screen height** (screen is 1117 logical, so ~558px), vertically centred. Numbers centred vertically in the bar.
- Same look as the top bar: same island glass / outline / glow / radius / tokens, vertical. The active workspace keeps its accent fill + accent number, others quiet. Click still switches workspace; Super+D then 1–9 still switches.
- Fullscreen still hides the strip cleanly.
- Verify live: screenshots showing the bar's width and height measured, numbers centred, with 1–3 workspaces open, and with more workspaces open (does it grow? does it stay centred?).

## Out of scope

- No right-side frame yet — the two-sided frame is coming soon, not now.
- No changes to the top bar, the exploded name, the dock, the float default, Super+L, or toast centering (Stage 25).
- No new workspaces, no new binds.
