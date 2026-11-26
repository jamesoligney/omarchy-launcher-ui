# Omarchy Bar — Top Bar v5 Build Brief (the easy trim)

Status: Build brief. Build from docs/omarchy-bar-refined-brief.md plus this brief.
Purpose: Trim the easy list from the bottom row — the blank, the duplicate, and the invisible-at-rest items — so the row is tight with no weird spaces.

## The problem (James, 2026-11-26)

Top Bar v4 is live: tray out, second level back left, bottom row tight at 497px in 717px of room.

James, live: "What's the space between the night light icon and the volume icon? I said I didn't want any spaces. Why is there a space there?"

Answer, from the v4 report: that space is `omarchy.keyboard-layout` — a blank 30px slot between Locus (night light) and audio (volume). With one keyboard layout it has nothing to show, so it renders blank, with nothing to click on that does anything useful. It is a whole invisible widget occupying space, not a spacing gap.

James: yes, please — trim it.

## Locked decisions

1. **Pull out the blank keyboard-layout.** Remove `omarchy.keyboard-layout` from the bottom row. It is blank with one layout, 30px of empty slot, between Locus and audio. After it is gone, Locus and audio sit next to each other with no space.
2. **Pull out the duplicate power.** Remove `omarchy.power` from the bottom row. It is "86%" + battery, 54px, duplicating the battery % already on the right island. Widest item in the row, and a duplicate.
3. **Pull out the invisible-at-rest items.** Remove `omarchy.indicators` and `omarchy.system-update` from the bottom row. Both show nothing at rest — indicators 0px, system-update 21px with no updates pending. Keep them out; if something is up later, they can come back, but they do not earn a permanent slot while invisible.
4. **Pull out the duplicate menu openers.** Remove `io.github.smoothpixels.glyph-menu` and `jimmy.menu` from the bottom row. Both open a menu Super+Space already opens. Two menu buttons in the row, for a job the launcher already does.
5. **Nothing else in this stage.** Do not trim anything else yet — matrixscreens, omarchy-fx, tricky-tiles, monitor, and the rest stay for now. See the row after this easy trim, then decide the next cut.
6. **Right island untouched, quick tiles untouched.** Do not change time / battery / weather, do not move the quick tiles.
7. **No geometry change.** Bar stays 75px deep, reserves `[0, 75, 0, 0]`, windows start y 82, float default 1100×619 centred at (314, 286). Tint stays `bar.tint = 0.22`.

## Build checklist (standing rules)

- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files, saved per-workspace layouts. Runtime state (clipboard history, pins, recents, pause) stays local, never in git. Checksums live before = backup = live after.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- `hyprctl reload` only. No shell restart unless the change requires it, and then on its own, never combined with a summon loop.
- Theme-aware (Afterburn default), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/bar-topbar-v5-report.md, commit, push, hash only.

## Details

- Audit first: read live `jimmy.bar/Bar.qml` (v4) and confirm the inventory and widths: keyboard-layout 30px blank, power 54px duplicate, indicators 0px, system-update 21px, glyph-menu 25px, jimmy.menu 27px. Remove exactly those six entries from the bottom row — via `shell.json` → `bar.layout` / `inventoryIds` as in v4, not by hiding them with CSS.
- After removal, report the new bottom-row width / room, and confirm there is no blank slot left between Locus and audio, and no other invisible slots in the row.
- Leader keys: Super+D letters must still sit on their elements. Verify they are legible and not clipping after the trim.
- Panels: the remaining bottom-row elements' panels must still drop from them. Calendar still drops from the right ear.
- Verify live: bottom row is tight with no weird spaces, all remaining icons visible, left island 30px padding both sides, right island unchanged, band under the notch empty, notch is a clean cut-out, bar is 75px, desktop untinted, reserves `[0, 75, 0, 0]`, float default still (314, 286), Super+L / Super+T / leader still work, fullscreen hides the bar cleanly.
- Current theme is Afterburn Redline. Verify on Afterburn default as well, then put Redline back. Report both.
- Report: what was pulled out (six items, with widths), what is left in the bottom row (full inventory), new width / room, and what James should trim next.

## Out of scope for v5

- No trimming beyond the six easy items listed above.
- No keeping anything under the notch, no valley, no band holding elements.
- No frame, no hull, no bevel, no molding, no hard line.
- No changing the right island, no changing the quick tiles.
- No new elements.
- No drawer, no agent mission control, no dock remake.
- No changes to the launcher / emoji / clipboard pickers, except that they must still work with the new bar.
