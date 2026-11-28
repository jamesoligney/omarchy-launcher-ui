# Top Bar v7 Brief — Three Islands, Black Centre Fading to Clear

Status: Build brief. James said go, 2026-11-27.
Build from docs/omarchy-bar-refined-brief.md plus this brief.

## The idea (James, 2026-11-27, confirmed in full)

Nothing moves. All regions stay exactly where they are now, all elements stay in the same place. This is a look change, not a layout change.

The top bar now reads as **three separate islands — left, right, and centre** — with gaps between them where wallpaper shows through. Below the line of the bar is wallpaper, as now.

## 1. Left and right islands (the ears)

- Left ear: title top, secondary icon row below, both left-justified (Top Bar v6 layout).
- Right ear: time / battery / weather, 26/28px, centred in the right ear, as now.
- Both ears are **coloured with the accent colour of the theme** — the tint we've been using (`bar.tint 0.22`, glass alpha 0.70).
- Both ears are **still see-through, still translucent glass**, as now.
- **Inner edge shape:** each ear's inner edge — the edge facing the notch — stops at the cut-out, then **curves down toward its own side**. The left island's inner edge curves down and out to the left; the right island's inner edge curves down and out to the right.
- The curve is a proper curve, not a sharp corner. **Radius about the same as the windows' radius** — roughly 16px, the same rounding the windows have.
- So the gap between the left island and the centre, and between the right island and the centre, is a curved valley scooping down and outward, not a straight vertical slot.

## 2. Centre island (under the notch, workspaces)

- The centre region is **just the workspaces**, on a black surface underneath the notch (Top Bar v6 layout: workspaces under the notch).
- **Black, solid, from the top of the screen down to the bottom of the notch.** The black runs all the way to the top edge of the screen, so you can't tell the notch is there — the whole centre part is black and the notch disappears into it.
- **Fade:** at the bottom of the notch (y 32), the black **starts to fade to transparent**, so that by the time you get to the bottom of the bar (y 75), it is fully transparent — wallpaper shows through at the bottom edge.
- The workspaces still live in that centre area, in the fading zone below the notch. They must stay readable over the fading black — report the actual ink / background at the workspace row and say whether the chips are legible on both Redline and Afterburn default.
- The centre is **opaque black at the top, not translucent like the ears**. Only the fade makes it transparent, at the bottom.

## 3. What stays

- Bar 75px deep, reserves `[0, 75, 0, 0]`, windows start y 82, notch 174×32 (provisional).
- Left island 30px padding both sides, two levels, both left-justified.
- Right island untouched.
- Float default 1100×619, centre (314, 286), float inheritance (new windows follow the workspace mode), Super+Space (oma-cast), Alt+Space (Vicinae), leader Super+D — all unchanged.
- Do not trim, reorder, or remove bottom-row icons. Do not touch `jimmy.menu`'s layout entry. Do not re-add the tray.

## Prerequisite

Top Bar v6 (workspaces under the notch, left island both levels left-justified) is the layout this look sits on. If v6 is not live when this brief is built, do the v6 layout first as part of this stage, then apply the three-island look on top of it. Say in the report whether v6 was already live or was built as part of this stage.

## Build checklist (standing rules)

- **Minimum testing only.** Open once, type once / click once, Esc once, stop. No automated test loops, no dozens of rounds, no `wtype` driving the desktop, no launching apps unattended. Standing rule from 2026-11-27 (oma-cast trial).
- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `jimmy.*` plugin, shell.json / shell.toml, theme files. Runtime state stays local, never in git.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- `hyprctl reload` only. No shell restart unless the change requires it, and then on its own, never combined with a summon loop.
- Theme-aware, no hardcoded palette except the centre black (black is black on both themes). Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/bar-topbar-v7-report.md, commit, push, hash only.

## Details

- Audit first: read live `jimmy.bar` / `Bar.qml`, `shell.json` layout, and the current workspaces implementation. State in the report how the three islands are drawn (one surface with three shapes, or three surfaces), where the curved inner edges live, and how the centre fade is done (gradient, alpha ramp, or layered shapes).
- Verify live on Afterburn Redline and on Afterburn default, then restore Redline. Report both: ears tinted / translucent on both, centre black at top on both, fade to transparent at the bottom on both, notch invisible on both, workspaces legible on both.
- Verify live, once each: click a workspace under the notch and it switches, leader keys still work, bar 75px, reserves `[0, 75, 0, 0]`, no QML errors.
- Report: actual geometry (island widths, gap widths, curve radius used, fade start / end y), what was tested once each, and screenshots or pixel notes for the centre fade and the curved inner edges.

## Out of scope

- Do not move any element. Do not change the float default, inheritance, Super+L / Super+T, leader keys, oma-cast, Vicinae, or the emoji / clipboard pickers.
- Do not build the emoji "default to last item" change (later list).
- Do not trim, reorder, or remove bottom-row icons.
- No frame, no hull, no bevel, no molding, no hard line.
