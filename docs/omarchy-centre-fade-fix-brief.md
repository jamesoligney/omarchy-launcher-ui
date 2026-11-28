# Centre Fade Fix Brief — Smoother, Ends Higher

Status: Build brief. James said go, 2026-11-27.
Build from docs/omarchy-bar-refined-brief.md plus this brief.

## The problem (James, 2026-11-27, with screenshot)

The centre black-to-transparent fade in Top Bar v7 is poor. Screenshot shows a hard / banded fade from black at the top to the wallpaper below, with the workspaces sitting in it.

James: "It's a poor fade from black to transparent. It should be much smoother, and it should end higher."

## What to fix

1. **Much smoother fade.** No banding, no hard steps, no visible bands where the black meets the wallpaper. Use a proper smooth gradient — more interpolation steps, correct alpha ramp, no 8-bit banding. If the Canvas gradient is banding, fix the gradient itself (dithering, more stops, or a different gradient method), not just the endpoints. Report what caused the banding and what changed.
2. **End higher.** The fade should reach fully transparent **higher up in the bar** than it does now. Now: black to y 32 (notch bottom), clear at y 75 (bar bottom). New: black to y 32, clear well before y 75 — try **clear by about y 55**, so the bottom ~20px of the bar is already transparent wallpaper. James to judge by eye — go big on the change first (end clearly higher), then pull back if he says so. Do not creep from 75 to 70.
3. **Workspaces stay legible.** The workspaces (chips 1, 2, etc.) sit in the fading zone. With the fade ending higher, the chips will be over more wallpaper and less black. Report the actual chip / digit colours and say whether they are still legible on both Redline and Afterburn default. If legibility suffers, say so — do not silently add a chip background or outline without naming it in the report.

## Geometry (unchanged unless the fade needs it)

- Notch: real width **190px, x 769–959, centre 864** (measured 2026-11-27, 95 each edge). This brief does not change the notch width — that is the separate notch-measure-fix brief. If that fix is not live yet, build this fade fix on top of the real 190px notch, and say so in the report.
- Bar 75px deep, reserves `[0, 75, 0, 0]`, centre x 769–959.
- Ears: accent-tinted translucent glass, inner bottom corner radius 16, unchanged.
- Fade start stays at the notch bottom, y 32. Only the smoothness and the end point change.

## Build checklist (standing rules)

- **Minimum testing only.** Open once, type once / click once, Esc once, stop. No automated test loops, no dozens of rounds, no `wtype` driving the desktop, no launching apps unattended. Standing rule from 2026-11-27.
- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `jimmy.*` plugin, shell.json / shell.toml, theme files. Runtime state stays local, never in git.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- `hyprctl reload` only. No shell restart unless the change requires it, and then on its own, never combined with a summon loop.
- Theme-aware, no hardcoded palette except the centre black. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/centre-fade-fix-report.md, commit, push, hash only.

## Details

- Audit first: read live `jimmy.bar/Bar.qml` and the Canvas gradient code. State in the report how the fade is currently drawn, why it bands, and what the new gradient is (stops, alpha values, method).
- Verify live on Afterburn Redline and on Afterburn default, then restore Redline. Report both, with pixel samples down the centre column (x 864) at several y values, so the smoothness can be seen in numbers, not just claimed.
- Verify live, once each: workspaces still centred under the notch, click / leader still works, bar 75px, reserves `[0, 75, 0, 0]`, no QML errors.
- Report: old vs new fade (start / end y, gradient stops), what caused the banding, pixel samples, workspace legibility on both themes, and what James should check by eye (is the fade smooth now, does it end high enough?).

## Out of scope

- Do not change the notch width (separate brief), the ears, the curve radius, or any element position.
- Do not move the workspaces, trim the bottom row, or change the right island.
- Do not change the float default, inheritance, Super+L / Super+T, leader keys, oma-cast, Vicinae, or the pickers.
- No frame, no hull, no bevel, no molding, no hard line.
