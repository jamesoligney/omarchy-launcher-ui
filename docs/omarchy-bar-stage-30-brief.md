# Omarchy Bar — Stage 30 Build Brief

Status: Build brief. Build from docs/omarchy-bar-refined-brief.md plus this brief.
Purpose: Fix Stage 29 — it tinted the entire desktop, and there is no hull anymore. Restore the hull, tint only the frame.

## The problem (James, 2026-11-26)

Stage 29 was built by DeepSeek 4.1 Flash, not Claude. Its report claims tint 0.18, frame pixel (39, 28, 17), top row all 37.5. Live, that is wrong:

- **It tinted the entire fucking desktop.** The whole screen is tinted, not just the frame.
- **There is no hull anymore.** No frame boundary, no opening, no shell — just a tinted desktop.

Do not trust the Stage 29 report. Audit live first, from what is actually on screen, then fix it. This stage is for Claude Sonnet 5.5, not DeepSeek.

## Locked decisions

1. **Tint only the frame hull, never the desktop.** The frame is a hull: top 75, left 30, right 15, bottom 15, with a rounded opening cut out. Only that hull gets the accent tint. The desktop inside the opening — wallpaper, windows, everything — is untouched, untinted, unfiltered.
2. **Restore the hull first, then tint it.** If Stage 29's fill is covering the whole screen, find why (Canvas fill covering the full surface, tint applied to `background`, `Qt.tint` on the wrong layer, whatever it is) and fix the *scope* first. A correct hull with a subtle tint beats a strong tint with no hull.
3. **Frame follows the theme accent, raised slightly.** Same as Stage 29's intent, but only on the hull: accent-tinted, theme-aware, no hardcoded orange. Start low, raise in small steps, screenshot each step. Do not overshoot to solid.
4. **Top elements centred in the 75px frame.** Measure the actual live glyph/text ink centres, not the container. Centre that in 75px (target y 37.5). Stage 29 claimed all 37.5 — verify live, do not take its word for it.
5. **No geometry change.** Depths stay top 75, left 30, right 15, bottom 15. Radii stay outer 20, inner 16. Reserves stay `[30, 75, 15, 15]`. No step, no split, no pills coming back.

## Build checklist (standing rules)

- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files, saved per-workspace layouts. Runtime state (clipboard history, pins, recents, pause) stays local, never in git. Checksums live before = backup = live after.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- `hyprctl reload` only. No shell restart unless the change requires it, and then on its own, never combined with a summon loop.
- Theme-aware (Afterburn default), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/bar-stage-30-report.md, commit, push, hash only.

## Details — audit first

- Before changing anything, read the live state: `jimmy.frame/Frame.qml` as it is now, `shell.toml` `[frame]` tokens, and a screenshot of the full screen. State in the report, in plain words: what is tinted, what is not, where the hull is (or is not), and what in the code is causing the whole-desktop tint.
- The likely cause to check first: the Canvas / fill is painting the full full-screen surface, or `Qt.tint(Commons.Color.background, …)` is tinting the background itself, not just the hull path. The hull path must be the *only* thing filled with the accent tint. The opening must be a real cut-out (evenodd / clear), not a tinted overlay.
- Restore the hull: one unified frame, outer rounded corners, inner opening rounded corners, single accent-glass hull, no line across the bottom of the top reserve, no 2px underline unless it reads as the hull edge.
- Then tint the hull only: accent tint derived from the theme accent, low alpha, raised slightly until the hull reads at a glance. Screenshot the frame pixel and the desktop pixel separately — the desktop pixel must be unchanged from its wallpaper value.
- Top row: measure live ink centres for title, time, battery %, weather glyph, status glyphs. Centre them in 75px. Report before / after, with screenshots, not just numbers.
- Left numbers: directly on the 30px left frame, vertically centred, active accent, no pill. Check the accent fill does not wash them out.
- Notch: 174 × 32 cutout through the top band, centred. Report how it reads against the corrected hull. No disguise in this stage.
- If the hull cannot be restored cleanly from Stage 29's code, restore `Frame.qml` from the Stage 28 backup / Stage 28 commit and re-apply the tint correctly on top of that. Say in the report if you did that.

## Out of scope

- No geometry change: no depth, radius, reserve, or centre change.
- No notch disguise, no black top.
- No moving any element to a new home, no new elements, no pills coming back.
- No changes to the float default, Super+L, Super+T, leader keys, or the launcher / emoji / clipboard pickers.
- Do not re-run DeepSeek's Stage 29 steps. Audit, then fix.
