# Omarchy Bar — Stage 31 Build Brief

Status: Build brief. Build from docs/omarchy-bar-refined-brief.md plus this brief.
Purpose: Give the frame the slightest bevel on its inner edge, so it looks like something instead of flat. No hard line, no tint change, no geometry change.

## The problem (James, 2026-11-26)

Stage 30 fixed the hull — `ctx.fillRule = Qt.OddEvenFill`, desktop untinted, tint 0.22, top row centred. But the frame looks very flat now. It needs a hard inner edge so it looks like "something", and James's idea is the slightest bevel instead of a hard line.

## Locked decisions

1. **Slightest bevel on the inner edge only.** A bevel is two 1px strokes, not one hard line: a light highlight on the top / inner-top, and a dark shadow on the bottom / inner-bottom. That light/dark pair is what reads as depth — a raised edge, light catching it — without adding a separate line drawn on the frame.
2. **Slightest is the word.** Start barely there — just enough that the inner opening stops looking flat and the hull stops blending into the wallpaper. If it is too strong it becomes a 3D chrome frame, which is not wanted. Tune live in small steps, screenshot each step.
3. **Bevel instead of a hard edge, not as well as.** Try the bevel first. If the bevel alone makes it read, no hard line is added. If it still feels flat after the bevel, say so in the report — do not add a hard edge unasked in this stage.
4. **No tint change, no geometry change.** Fill stays at `frame.tint = 0.22`, depths stay top 75, left 30, right 15, bottom 15, radii stay outer 20, inner 16, reserves stay `[30, 75, 15, 15]`. The bevel does the work of making it look like something; the fill stays warm glass.

## Build checklist (standing rules)

- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files, saved per-workspace layouts. Runtime state (clipboard history, pins, recents, pause) stays local, never in git. Checksums live before = backup = live after.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- `hyprctl reload` only. No shell restart unless the change requires it, and then on its own, never combined with a summon loop.
- Theme-aware (Afterburn default), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/bar-stage-31-report.md, commit, push, hash only.

## Details

- Build on Stage 30's fix: `ctx.fillRule = Qt.OddEvenFill` in `jimmy.frame/Frame.qml`, opening and notch are real cut-outs. Do not break that — verify the desktop pixel stays untinted at every step, and the notch stays a hole.
- Add the bevel to the inner opening edge only (the 1683 × 1027 opening, radius 16), not the outer edge, not the notch. Highlight: 1px, light, low alpha, on the top side of the inner edge. Shadow: 1px, dark, low alpha, on the bottom side of the inner edge. Report the exact colours / alphas / widths tried and which were shipped.
- Tune live: try a step, screenshot a close crop of the inner edge (top edge and bottom edge, and a corner), judge, adjust. Start low. If a step reads as a hard line, back it off. If it reads as nothing, raise it slightly.
- The bevel must follow the theme accent / background — no hardcoded colours. Light side from the accent / foreground, dark side from the background / shadow, theme-aware.
- Verify live: full-screen screenshot, plus close crops of the top inner edge, bottom inner edge, and a rounded corner, on the dark Afterburn wallpaper. Desktop pixel unchanged, notch still a hole, top row still centred, left numbers still on the frame.
- If the bevel cannot be done cleanly in the Canvas (e.g. the stroke follows the wrong path, or it draws over the opening), say so in the report and stop — do not ship a broken bevel, and do not fall back to a hard line unasked.

## Out of scope

- No hard inner edge in this stage — bevel only.
- No tint change, no geometry change, no reserve change.
- No notch disguise, no black top, no pills coming back.
- No moving any element, no new elements.
- No changes to the float default, Super+L, Super+T, leader keys, or the launcher / emoji / clipboard pickers.
