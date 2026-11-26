# Omarchy Bar — Top Bar v2 Build Brief

Status: Build brief. Build from docs/omarchy-bar-refined-brief.md plus this brief.
Purpose: Left island with 30px padding, two levels, everything in the bottom row so we can see what we have, then trim. Right island untouched. Start slowly.

## The direction (James, 2026-11-26)

Top Bar v1 is live: 75px deep bar, notch cut out, left ear in two levels, right ear with larger primaries, band below the notch empty.

James, after discussion:
- Keep two levels on the left side. Keep them left and right justified, but give a little more breathing room on the edges. Look at it as an island within the bar.
- Left "island" right and left padding **30px**.
- Throw everything in the bottom row — tray, everything, whatever. Everything including stuff that is currently hidden. I want to see what we have. The first edit after that will be an easy one.
- Leave the quick tiles where they are for now.
- Leave the right island as it is for now.
- Notch just creates its own cutout. No valley sweeping underneath it — that is probably not very practical.

## Locked decisions

1. **Left island, padding 30px left and right.** The left island sits inside the 75px bar with 30px padding on its left edge (from the bar's left edge) and 30px padding on its right edge (from the notch). More breathing room than v1's 18px / 10px. It reads as an island within the bar, not two rows crammed to the edges.
2. **Two levels on the left, left and right justified.** Top level left-justified, bottom level right-justified — the stagger stays. Top level: workspaces + focused title. Bottom level: everything secondary.
3. **Throw everything in the bottom row.** Bottom level holds everything we have — Wi-Fi, Bluetooth, mic, agents, tray, everything, whatever, including stuff that is currently hidden / not on the bar. Do not curate it in this stage. The point is to see the whole inventory at once, then trim in the next edit.
4. **Right island untouched.** Time, battery, weather at 26 / 28px, centred in the right ear, exactly as v1. Do not resize, move, or change them.
5. **Quick tiles untouched.** Leave them where they are for now. Do not move them in this stage.
6. **Notch just a cutout.** No valley under the notch, no band holding elements. The band below the notch stays as bar fill — empty, no elements. Decide what lives under the notch later, after we see everything in the bottom row.
7. **No geometry change.** Bar stays 75px deep, reserves `[0, 75, 0, 0]`, windows start y 82, float default 1100×619 centred at (314, 286). Tint stays `bar.tint = 0.22`.

## Build checklist (standing rules)

- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files, saved per-workspace layouts. Runtime state (clipboard history, pins, recents, pause) stays local, never in git. Checksums live before = backup = live after.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- `hyprctl reload` only. No shell restart unless the change requires it, and then on its own, never combined with a summon loop.
- Theme-aware (Afterburn default), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/bar-topbar-v2-report.md, commit, push, hash only.

## Details

- Audit first: read live `jimmy.bar/Bar.qml` (v1) and list everything that exists that could go in the bottom row — status lights, tray apps, agents, and anything else currently hidden / in the drawer / tray. Then put all of it in the bottom row, in one Row, right-justified within the 30px padding. Report the full inventory in the report, with what each item is and where it came from.
- If the bottom row overflows the left ear at 30px padding, say so in the report and do not shrink it to fit unasked — report the overflow and what would need to be trimmed first. Do not drop items silently to make it fit.
- Leader keys: Super+D letters must still sit on their elements in the new layout. Verify they are legible and not clipping.
- Panels: status-light / tray panels must drop from the bottom row elements. Calendar still drops from the right ear. Quick tiles stay where they are.
- Verify live: left island has 30px padding both sides, two levels, top left-justified, bottom right-justified with everything in it, right island unchanged, notch is a clean cut-out with nothing under it, bar is 75px, desktop untinted, reserves `[0, 75, 0, 0]`, float default still (314, 286), Super+L / Super+T / leader still work, fullscreen hides the bar cleanly.
- Current theme is Afterburn Redline. Verify on Afterburn default as well, then put Redline back. Report both.
- Report: the full bottom-row inventory, the padding, what was left untouched (right island, quick tiles), and what James should trim first — the easy first edit.

## Out of scope for v2

- No trimming in this stage — throw everything in, see it, trim next.
- No valley under the notch, no band holding elements.
- No frame, no hull, no bevel, no molding, no hard line.
- No changing the right island, no changing the quick tiles.
- No new elements beyond what we already have (just surface the hidden ones).
- No drawer, no agent mission control, no dock remake.
- No changes to the launcher / emoji / clipboard pickers, except that they must still work with the new bar.
