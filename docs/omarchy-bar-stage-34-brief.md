# Omarchy Bar — Stage 34 Build Brief (revised)

Status: Build brief. Build from docs/omarchy-bar-refined-brief.md plus this brief.
Purpose: Fix the hull. Do not go back to black. The Stage 33 molding was too much — fix it by making it softer, warmer, and less chrome, not by removing it.

## The problem (James, 2026-11-26)

Stage 33's full-depth bevel molding looks terrible live. It is getting worse. James has changed his mind: he does not want black. Figure out how to fix it — this is the agent's job, not James's to direct.

Stage 34 (black + hard edge) is cancelled. Do not build it.

## What was wrong with Stage 33 (Max's diagnosis)

1. **Too strong, too pink.** Shipped 0.40 / 0.55, ridge pixel (91, 39, 41) on Redline, (95, 73, 54) on Afterburn — a pink / bronze chrome molding. At 0.90 overshoot it was (151, 77, 80). The light colour was accent warmed with 50% foreground, so the ridge went pink/red, and accent text (battery "86%", active "1") washed out on it.
2. **Ridge in the middle made every band a dome.** Edge 0.7, ridge 1.0 mid-band, foot 0 — that is a raised dome across all four bands, all the time. It reads as chrome molding, not as a frame.
3. **All four bands the same.** Top 75, left 30, right 15, bottom 15 all got the same full-depth profile, so the whole screen is rimmed in molding. Too much surface.

## Locked decisions — the fix

1. **Keep the bevel-is-the-hull idea, but make it much softer and warmer.** The bevel is still the hull surface, across its full depth — not an inner-edge stroke, not black, not a hard line. But dial it way down from Stage 33.
2. **Light colour: warm glass, not accent pink.** The highlight must come from the *glass* / foreground at low alpha, not from the accent warmed with foreground. No pink, no red, no bronze. On Afterburn it should read as warm dark glass catching light, on Redline as dark glass catching light — never as a coloured molding.
3. **Ridge near the outer edge, long inner slope.** Move the ridge from mid-band to near the outer edge (about 25% in from the screen edge), then a long, gentle slope down to the inner opening. That reads as a frame that is high at the outside and falls away toward the desktop — the profile James described — without a dome in the middle of every band.
4. **Strength: start at Stage 33's quietest step and go down, not up.** Start at 0.15 / 0.30, then try 0.10 / 0.20. Do not start at 0.40 again. The shipped step must be clearly visible at a glance, but it must not wash out text, and it must not read as chrome. If 0.15 is still too much, go to 0.10. If 0.10 is invisible, the profile is wrong — do not just raise the alpha, say so in the report.
5. **Top band carries the bevel; the narrow bands stay quiet.** The top band (75px) is where the bevel reads. The left (30px), right (15px) and bottom (15px) bands get the same profile but at half strength, so they do not rim the whole screen in molding. The frame should read from the top, not from all four sides equally.
6. **No black, no tint increase.** Fill stays at `frame.tint = 0.22`. No black hull.
7. **And a hard line too.** James also wants a hard line — in addition to the soft bevel, not instead of it. One crisp 1px hard edge around the inner opening (1683 × 1027, radius 16), accent-coloured, theme-aware, high enough alpha to be unmistakable. The bevel gives the hull its shape; the hard line gives it its boundary, so you can see there is a hull there. If the hard line and the bevel fight each other live, the hard line wins — pull the bevel back, not the line.

## Build checklist (standing rules)

- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files, saved per-workspace layouts. Runtime state (clipboard history, pins, recents, pause) stays local, never in git. Checksums live before = backup = live after.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- `hyprctl reload` only. No shell restart unless the change requires it, and then on its own, never combined with a summon loop.
- Theme-aware (Afterburn default), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/bar-stage-34-report.md, commit, push, hash only.

## Details

- Audit first: read live `jimmy.frame/Frame.qml` (Stage 33 rings / molding, `shade(t)`, edge 0.7 / ridge mid-band / foot 0) and state exactly what changes: light colour source, ridge position, strength, narrow-band strength.
- Overshoot is not the method here — Stage 33 already found the top of the range (0.90 = pink chrome, 0.40 = too much). Start low, at 0.15 / 0.30, and judge live. Screenshot full screen + close crops of the top band, a corner, and the left band at each step.
- Verify at every step: desktop pixel untinted, notch still a hole, top row still centred in 75px and fully legible (battery %, active workspace number, time, weather — no washout), left numbers still on the 30px band, reserves `[30, 75, 15, 15]`.
- Current theme is Afterburn Redline (James set it 2026-11-26). Tune on Redline first, verify the shipped step on Afterburn default, then put Redline back. Report both — and report whether the bevel reads as warm glass on both, or goes pink on either.
- Report: a table of every step tried (strength, ridge position, light colour source, hard line width / alpha, top outer / ridge / inner pixels, desktop pixel, text legibility, judgement), plus the shipped step and why it is the right one. If no step reads as a soft beveled hull without washing out text, say so — do not ship another chrome molding, and do not fall back to black unasked.

## Out of scope

- No black hull — Stage 34 black brief is cancelled.
- No inner-edge stroke as a bevel — that was Stages 31–32, and it is not coming back. The hard line is a hard line, not a bevel stroke.
- No tint change, no geometry change, no reserve change.
- No notch disguise, no pills coming back.
- No moving any element, no new elements.
- No changes to the float default, Super+L, Super+T, leader keys, or the launcher / emoji / clipboard pickers.
