# Omarchy Bar — Stage 29 Build Brief

Status: Build brief. Build from docs/omarchy-bar-refined-brief.md plus this brief.
Purpose: Make the frame visible, and centre the top elements in it. No geometry change.

## The problem (James, 2026-11-26)

Stage 28 built the frame technically — reserves `[30, 75, 15, 15]`, pills gone, windows refit — but visually it reads as empty. The hull fill is the old islands' dark glass (background 0.70) with accent only in a 1px edge at 0.16. That is not accent glass. Against a dark wallpaper the frame disappears.

And the top elements are not centred in the 75px space yet. The Stage 28 report claims content centres at y 37.5, but James's eye says it is not centred. Trust his eye over the report — measure it live and fix it.

## Locked decisions

1. **Frame follows the theme accent.** The fill must be accent-tinted, theme-aware — it follows the active theme's accent, no hardcoded orange, no hardcoded palette. When James switches theme, the frame follows.
2. **Raise it slightly.** Start with a light accent tint, raised slightly from Stage 28's near-invisible fill — enough that the hull reads as a frame at a glance, not so much that it becomes a solid orange bar. Tune it live by eye: try a step, screenshot, judge, adjust. Do not overshoot to solid.
3. **Top elements centred in the 75px frame.** Measure the actual live y-centre of the time / battery / weather / status row (not the container, the glyphs and text themselves). Centre that in 75px — centre should be y 37.5. If the report's 37.5 is the container and the glyphs sit high or low inside it, fix the glyphs, not the container.
4. **No geometry change.** Depths stay top 75, left 30, right 15, bottom 15. Radii stay outer 20, inner 16 unless the visibility work forces a change — say so if it does. No step, no split, no new reserves, no pill coming back.

## Build checklist (standing rules)

- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files, saved per-workspace layouts. Runtime state (clipboard history, pins, recents, pause) stays local, never in git. Checksums live before = backup = live after.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- `hyprctl reload` only. No shell restart unless the change requires it, and then on its own, never combined with a summon loop.
- Theme-aware (Afterburn default), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/bar-stage-29-report.md, commit, push, hash only.

## Details

- Find the frame fill in `jimmy.frame/Frame.qml` (Canvas hull). Report its current values first: fill colour / alpha, edge colour / alpha / width, and how it is derived from the theme.
- Change the fill to an accent tint derived from the theme accent: accent colour at a low alpha over the dark glass, or accent mixed into the glass — whichever reads as "accent glass" in the live screenshot. Start low, raise in small steps, screenshot each step, and report the values tried and which one was shipped.
- The 1px edge at 0.16 can stay, go, or thicken — judge it against the new fill. If it reads as a line, thin it or drop it. The hull boundary should read as the frame edge, not as a separate line.
- Top elements: measure live — screenshot with a ruler / geometry dump — the actual y-centre of the time text, battery %, weather glyph, and status glyphs. Compare to 37.5. Fix the vertical alignment so the *visible* elements centre in 75px, not just their container. Report the before / after y-centres.
- Left numbers: check they are still vertically centred in the left frame, and that the accent fill does not wash out the active workspace accent number. If it does, adjust the number colour / fill contrast, not the frame geometry.
- Verify live: screenshots of the full frame on a dark wallpaper and on a light / busy wallpaper if available, top row centred, left numbers centred, notch reading against the new accent fill. No disguise in this stage.
- Theme switch check: switch theme (or simulate by reading the accent token) and confirm the frame fill follows the new accent. Report the accent values used.

## Out of scope

- No geometry change: no depth, radius, reserve, or centre change.
- No notch disguise, no black top.
- No moving any element to a new home, no new elements, no pills coming back.
- No changes to the float default, Super+L, Super+T, leader keys, or the launcher / emoji / clipboard pickers.
