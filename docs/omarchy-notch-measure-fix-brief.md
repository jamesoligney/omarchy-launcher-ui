# Notch Measurement Fix Brief — Real Notch Width 190px

Status: Build brief. James said go, 2026-11-27.
Build from docs/omarchy-bar-refined-brief.md plus this brief.

## The measurement (James, 2026-11-27, by eye with jimmy.notch-ruler)

- **95 for each edge.** Half-width is 95px each side of centre.
- **Real notch width is 190px**, not the provisional 174px used in v1–v7.
- Centre is 864 (screen 1728 wide). So the real notch is **x 769–959**, not 777–951.
- The old 174px number was provisional and unmeasured. James's eye is final: in v7 both ears were pushing into the notch area, so you could actually see where the notch sits.

## What to fix

1. **Set `notch.width` to 190** (was 174). Set the notch edges to **769 and 959**. Update every place that used 777 / 951 / 174: the bar Canvas ears, the centre shape, the workspace centring, and any token or geometry that derived from the old width.
2. **Re-cut the ears** so they stop at the real notch edges: left ear x 0 → 769, right ear x 959 → 1728. Their inner bottom corners keep the 16px curve back toward their own sides (v7).
3. **Re-cut the centre** to the real notch width: x 769–959, 190 wide. Solid black from the top of the screen to the notch bottom (y 32), fading to transparent by the bar bottom (y 75), as v7. Workspaces stay centred in it — re-centre them on 864, and report the actual chip positions.
4. **Verify the notch is actually hidden now.** The v7 report claimed the notch was invisible at (0,0,0) while James could see it — do not repeat that claim without checking the edges. Check the pixels at and just outside the new edges (769 and 959), and at the top edge, on both themes. Report the actual measurements. James's eye is the final check.

## Build checklist (standing rules)

- **Minimum testing only.** Open once, type once / click once, Esc once, stop. No automated test loops, no dozens of rounds, no `wtype` driving the desktop, no launching apps unattended. Standing rule from 2026-11-27.
- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `jimmy.*` plugin, shell.json / shell.toml, theme files. Runtime state stays local, never in git.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- `hyprctl reload` only. No shell restart unless the change requires it, and then on its own, never combined with a summon loop.
- Theme-aware, no hardcoded palette except the centre black. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/notch-measure-fix-report.md, commit, push, hash only.

## Details

- Audit first: read live `jimmy.bar/Bar.qml` and `shell.toml`, and list every place the old 174 / 777 / 951 appears. State in the report each place changed.
- Do not move any element. Do not change the bar height (75px), reserves `[0, 75, 0, 0]`, the fade (black to y 32, clear at 75), the curve radius (16), the float default, inheritance, Super+L / Super+T, leader Super+D, Super+Space (oma-cast), Alt+Space (Vicinae), or the pickers.
- Verify live on Afterburn Redline and on Afterburn default, then restore Redline. Report both.
- Report: old vs new notch geometry, actual pixel checks at the new edges, workspace chip positions, and what James should check by eye (can he still see where the notch sits?).

## Out of scope

- Do not change the three-island look, the fade, or the curve.
- Do not move any element, trim the bottom row, or change the right island.
- No frame, no hull, no bevel, no molding, no hard line.
