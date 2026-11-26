# Omarchy Bar — Stage 33 Build Brief

Status: Build brief. Build from docs/omarchy-bar-refined-brief.md plus this brief.
Purpose: Bevel the hull itself, across its full depth. The bevel IS the hull — not a stroke on its inner edge.

## The problem (James, 2026-11-26)

Stages 31–32 built a bevel as a 1–3px stroke on the inner edge of the opening. That makes no difference to the hull itself. James does not see it, and it is not what he meant.

Confirmed by James: **the bevel is the hull. The bevel is the hull, yes.**

## Locked decisions

1. **The bevel IS the hull.** Each frame band is beveled across its *full* depth, like a picture-frame molding / chamfered edge:
   - Top band, 75px deep: shaded across the full 75px — light on one side, shadow on the other.
   - Left band, 30px wide: shaded across the full 30px.
   - Right band, 15px wide, and bottom band, 15px tall: shaded across their full width / height.
   - At a glance, the frame must read as a beveled surface with depth, not a flat tinted border with a line around the hole.
   - **Bevel profile (James, 2026-11-26): the middle of the hull is higher than the inside part of the hull. The outside stays high, going off into the distance beyond the screen.** So across each band, from outside to inside: outer edge stays high, the middle is the highest point / ridge, then it slopes down toward the inner edge, which is lower. Do not shade it as a simple light-to-dark gradient across the whole band — the peak is in the middle, the inner side falls away, the outer side stays high off the screen edge.
2. **Overshoot, then pull it back.** Go big first — a strong, unmistakable bevel across the full band — screenshot it, then pull it back in big steps until it is just right. Do not creep up in small steps from Stage 32's 0.20 / 0.50. James's process: overshoot on purpose, then prune.
3. **Remove the inner-edge stroke.** Stages 31–32's bevel stroke (`bevel-light` / `bevel-dark` / `bevel-width` on the inner opening edge) is the wrong thing. Remove it, or repurpose its tokens for the hull bevel — do not leave both a hull bevel *and* an inner-edge stroke, or the frame will have two bevels fighting each other. Say in the report what happened to those tokens.
4. **Theme-aware, no hardcoded colours.** Bevel highlight / shadow come from the theme — accent / foreground for light, background for shadow — so the frame follows the theme. No literal orange in the code.
5. **No geometry change.** Depths stay top 75, left 30, right 15, bottom 15. Radii stay outer 20, inner 16. Reserves stay `[30, 75, 15, 15]`. Fill tint stays at `frame.tint = 0.22` unless the hull bevel forces a change — say so if it does.

## Build checklist (standing rules)

- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files, saved per-workspace layouts. Runtime state (clipboard history, pins, recents, pause) stays local, never in git. Checksums live before = backup = live after.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- `hyprctl reload` only. No shell restart unless the change requires it, and then on its own, never combined with a summon loop.
- Theme-aware (Afterburn default), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/bar-stage-33-report.md, commit, push, hash only.

## Details

- Visual source of truth is `docs/reference/omarchy-shell-frame-diagram.html` (diagram v6, updated for this stage) — the hull bands are shaded across their full depth, with the middle highest, the inner side sloping down, and the outside staying high. Build from that picture, not just these words. If the light/shadow direction in the diagram reads backwards live (e.g. light should be on the inner side), flip it and say so — the direction is a live judgement, the full-depth bevel with a middle ridge is not.
- Audit first: read live `jimmy.frame/Frame.qml` and state how the hull is currently drawn (Canvas path, fill, Stage 31–32 stroke) and how a full-depth bevel will be drawn instead (gradient across each band, in the Canvas, following the rounded corners). Do not break Stage 30: `ctx.fillRule = Qt.OddEvenFill` stays, opening and notch are real cut-outs, desktop pixel stays untinted.
- Overshoot step must be visibly too much — a strong bevel you can see at a glance, across the whole top band. If it is not, go bigger and say so. Then pull back in big steps, screenshot each step (full screen + close crops of top band, left band, and a corner), and ship the step that reads as a beveled hull, not a flat border and not a chrome frame.
- Verify at every step: desktop pixel untinted, notch still a hole, top row still centred in 75px, left numbers still on the 30px band, reserves `[30, 75, 15, 15]`.
- Current theme is Afterburn Redline (James set it 2026-11-26). Tune on Redline first, verify the shipped step on Afterburn default, then put Redline back. Report both.
- Report: a table of every step tried (bevel strength / gradient values, hull pixel at top / middle / inner edge of the top band, desktop pixel, judgement), plus the shipped step and why it is the right one. If no step reads as a beveled hull, say so — do not ship an invisible bevel again.

## Out of scope

- No inner-edge stroke in this stage — that was Stages 31–32, and it is removed / replaced, not kept alongside the hull bevel.
- No hard line, no tint change unless the bevel forces it, no geometry change, no reserve change.
- No notch disguise, no black top, no pills coming back.
- No moving any element, no new elements.
- No changes to the float default, Super+L, Super+T, leader keys, or the launcher / emoji / clipboard pickers.
