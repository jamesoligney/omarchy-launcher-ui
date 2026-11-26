# Omarchy Bar — Stage 32 Build Brief

Status: Build brief. Build from docs/omarchy-bar-refined-brief.md plus this brief.
Purpose: Overshoot the bevel, then pull it back. James cannot see Stage 31's bevel — go big first, then pull back to the right thing, do not incrementally creep toward it.

## The problem (James, 2026-11-26)

Stage 31 shipped a slight bevel: light 0.10 / dark 0.35, width 1px. Report claims top +20, bottom −10, "soft lip". Live, James does not see it. It is too subtle to judge.

James's process, standing rule: go big, then pull it back — overshoot on purpose so the effect is unmistakable, then dial it down until it is just right. Do not creep up in small steps from 0.10 / 0.35.

## Locked decisions

1. **Overshoot first.** Start big: bevel-width **3px**, light **0.30**, dark **0.80**. That will be too much — that is the point. Screenshot it, so James can say "oh no, that's too much, pull it down."
2. **Then pull it back in big steps.** From the overshoot, step down — e.g. 0.25 / 0.65, then 0.20 / 0.50, then 0.15 / 0.40 — screenshot each step, with close crops of the top inner edge, bottom inner edge, and a corner. Ship the step that reads as a bevel, not a line and not invisible. Report all steps tried, with pixels, and where "too much" was.
3. **Bevel only, on the inner opening edge only.** Same as Stage 31: one stroke on the hull side of the opening, highlight top, shadow bottom, theme-derived, no hardcoded colours. No hard line added in this stage.
4. **No tint change, no geometry change.** Fill stays at `frame.tint = 0.22`, depths stay top 75, left 30, right 15, bottom 15, radii stay outer 20, inner 16, reserves stay `[30, 75, 15, 15]`.

## Build checklist (standing rules)

- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files, saved per-workspace layouts. Runtime state (clipboard history, pins, recents, pause) stays local, never in git. Checksums live before = backup = live after.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- `hyprctl reload` only. No shell restart unless the change requires it, and then on its own, never combined with a summon loop.
- Theme-aware (Afterburn default), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/bar-stage-32-report.md, commit, push, hash only.

## Details

- Current live theme is Afterburn Redline (James set it 2026-11-26 11:54). Tune the overshoot and the pull-back on Redline first, then verify the shipped step on Afterburn default, then put Redline back. Report both.
- Do not break Stage 30: `ctx.fillRule = Qt.OddEvenFill` stays, opening and notch are real cut-outs, desktop pixel stays untinted at every step. Verify desktop pixel and notch hole at each step.
- Overshoot step must be visibly too much in the screenshot — if it is not, go bigger (width 4px, light 0.40, dark 1.0) and say so. The point of the overshoot is to find the top of the range.
- Pull-back steps must be big enough to see a difference between steps. Do not do 0.01 increments.
- Top row and left numbers: unchanged. Verify they are still centred / on the frame after the bevel work.
- Report: a table of every step tried (width, light, dark, top highlight pixel, bottom shadow pixel, judgement), plus close crops, plus the shipped step and why it is the right one. If no step reads as a bevel, say so — do not ship an invisible bevel again.

## Out of scope

- No hard inner edge in this stage — bevel only, overshot then pulled back.
- No tint change, no geometry change, no reserve change.
- No notch disguise, no black top, no pills coming back.
- No moving any element, no new elements.
- No changes to the float default, Super+L, Super+T, leader keys, or the launcher / emoji / clipboard pickers.
