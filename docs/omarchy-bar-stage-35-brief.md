# Omarchy Bar — Stage 35 Build Brief

Status: Build brief. Build from docs/omarchy-bar-refined-brief.md plus this brief.
Purpose: The bevel is out. Go back to just a tinted hull with a hard line.

## The problem (James, 2026-11-26)

Stages 31–34 tried to bevel the hull — inner-edge stroke, bigger stroke, full-depth molding, then a soft warm-glass bevel with a hard line. The bevel is out. James wants it gone.

## Locked decisions

1. **Bevel is out.** Remove all bevel code: the Stage 33 ring-painted molding, the Stage 34 soft warm-glass bevel (`shade(t)`, ridge at t 0.25, long slope), `bevel-light` / `bevel-dark` / `bevel-sides` as bevel strengths. Flat hull again — no gradient across any band, no ridge, no slope, no dome, no molding.
2. **Just a tinted hull with a hard line.** That is the whole frame:
   - Fill: flat tinted hull, as in Stage 30 — `Qt.tint(Commons.Color.background, accent @ frame.tint)`, `frame.tint = 0.22`, at the launcher glass alpha. Theme-derived, no literal orange. Desktop untinted, notch a hole.
   - Hard line: 1px accent hard line at 0.85 around the inner opening (1683 × 1027, radius 16), on the hull side, as shipped in Stage 34. Keep it exactly — same width, same alpha, same colour source — unless it needs a change to sit on a flat hull, in which case say so.
3. **No geometry change.** Depths stay top 75, left 30, right 15, bottom 15. Radii stay outer 20, inner 16. Reserves stay `[30, 75, 15, 15]`.

## Build checklist (standing rules)

- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files, saved per-workspace layouts. Runtime state (clipboard history, pins, recents, pause) stays local, never in git. Checksums live before = backup = live after.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- `hyprctl reload` only. No shell restart unless the change requires it, and then on its own, never combined with a summon loop.
- Theme-aware (Afterburn default), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/bar-stage-35-report.md, commit, push, hash only.

## Details

- Audit first: read live `jimmy.frame/Frame.qml` (Stage 34 rings / soft bevel + hard line) and state exactly what is removed (all bevel / gradient / ring shading) and what stays (flat tinted fill under `Qt.OddEvenFill`, hard line). Do not break Stage 30: `ctx.fillRule = Qt.OddEvenFill` stays, opening and notch are real cut-outs, desktop pixel stays untinted.
- Tokens: remove `bevel-light`, `bevel-dark`, `bevel-sides` from `shell.toml` and the code, or repurpose them clearly — do not leave dead bevel tokens behind. Keep `frame.tint = 0.22` and `frame.edge = 0.85` (the hard line). Say in the report what happened to each token.
- Verify live: full-screen screenshot + close crops of the top inner edge, a corner, and the left band. Hull pixel should be flat across each band (same at outer, middle and inner, apart from the hard line), desktop pixel untinted, notch still a hole, top row still centred in 75px and fully legible, left numbers still on the 30px band, reserves `[30, 75, 15, 15]`.
- Current theme is Afterburn Redline (James set it 2026-11-26). Verify the shipped step on Afterburn default as well, then put Redline back. Report both. Note the Stage 34 report's warning: the hard line sits about 7px outside each window's own active border, and on Redline both are red — report whether that reads busy on a flat hull, and if so, say so, do not change the line unasked.
- Report: what was removed, what the fill and line are now, hull / line / desktop pixels on both themes, and confirmation that no gradient / bevel remains anywhere on the frame.

## Out of scope

- No bevel, no molding, no gradient, no ridge, no slope — the bevel is out.
- No black hull, no tint change, no geometry change, no reserve change.
- No notch disguise, no pills coming back.
- No moving any element, no new elements.
- No changes to the float default, Super+L, Super+T, leader keys, or the launcher / emoji / clipboard pickers.
