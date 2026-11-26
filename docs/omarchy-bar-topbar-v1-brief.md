# Omarchy Bar — Top Bar v1 Build Brief (Stage 37)

Status: Build brief. Build from docs/omarchy-bar-refined-brief.md plus this brief.
Purpose: Initial build of the new top-bar-only design. Deep bar across the top, 75px. Workspaces back up to the top left. See it live first, then iterate.

## The direction (James, 2026-11-26)

- Rollback to the islands is done (Stage 26 state restored, frame out, flicker gone). The frame experiments (Stages 28–35) are over — no hull, no bevel, no molding, no hard line around the whole screen.
- New direction: **top-bar only, deeper at ~75px.**
- **Right side will house larger elements** — the 3 primary elements we have there now (time, battery, weather) with room to grow.
- **Left side will be 2 levels within that same ~75px** — stacked layers, one left-justified and the other right-justified. Workspaces, plus tray and secondary elements (Wi-Fi, Bluetooth, mic, agents) moving to the left.
- **Islands notch-shaped on either side of the notch as a design nod, deeper of course.** Ideally the two islands nest on either side of the notch at the same angle, leaving space for the notch. Ideally they connect below the notch with a band wide enough to hold functional elements — the band must be functional, not only cosmetic. The test is *if* it can be functional, and it can — any number of things could go in there.
- This stage is an **initial build**: first see a deep bar across the top, 75px, with workspaces back up top left. It can be coloured so we can see where the notch sits.

## Locked decisions for v1

1. **Top-bar only, 75px deep, across the top.** One bar, top reserve 75. No left strip, no frame, no hull around the screen. Left reserve goes back to 0 (or the gutter only), right and bottom reserves 0.
2. **Workspaces back up to the top left.** Workspaces live in the top bar, left side, as in the original islands bar — not in a left strip down the side. The left strip is gone.
3. **Coloured so we can see where the notch sits.** The bar fill is tinted / coloured enough to read clearly against the wallpaper, so the notch cut-out is visible at a glance. Use the theme accent tint (`frame.tint`-style, 0.22 as a starting point, or stronger if needed to see the notch) — theme-aware, no hardcoded orange. The point of v1 is to *see* the bar and the notch, so do not make it so subtle it disappears.
4. **Right side: the 3 primary elements, larger.** Time, battery, weather — larger than the 18px / 44px islands, with room to grow. Do not add new elements in v1; just give the three primaries more size and breathing room in the 75px depth.
5. **Left side: 2 levels, stacked.** Workspaces on one level, tray / secondary (Wi-Fi, Bluetooth, mic, agents) on the other level, within the same 75px. One level left-justified, the other right-justified — staggered, not centred on top of each other. Keep it simple in v1: workspaces top, tray below, and report which justification was used.
6. **Notch-shaped islands, nested at the same angle, with a band below the notch if it is straightforward.** The two sides nest around the notch, leaving space for it. If the connecting band below the notch (about 43px tall, under the 32px notch) is straightforward in the same QML path, build it in v1 — as a functional row, even if it is empty / holding a placeholder element for now, and say what is in it. If it is not straightforward, build the two islands separate in v1 and say so — do not block v1 on the band.

## Build checklist (standing rules)

- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files, saved per-workspace layouts. Runtime state (clipboard history, pins, recents, pause) stays local, never in git. Checksums live before = backup = live after.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- `hyprctl reload` only. No shell restart unless the change requires it, and then on its own, never combined with a summon loop.
- Theme-aware (Afterburn default), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/bar-topbar-v1-report.md, commit, push, hash only.

## Details

- Start from the rollback state (Stage 26 islands, `jimmy.bar`, reserves `[32, 48, 0, 0]`, float default 1100×619 at (330, 273)). Change the bar to 75px deep, top reserve 75, left reserve 0, windows start at y ~82 (75 + gutter). Recompute the floating default centre for the new usable area and report it.
- Audit first: read live `jimmy.bar/Bar.qml` and state how the islands are currently drawn, and how the 75px bar will be drawn instead. Do not break Stage 30's lesson: `ctx.fillRule = Qt.OddEvenFill` if a Canvas path is used, opening and notch are real cut-outs, desktop pixel stays untinted.
- No bevel, no molding, no hard line around the whole screen in v1. Flat tinted fill, coloured enough to see the notch. If a hard edge is needed to see the bar, say so in the report — do not add one unasked.
- Verify live: bar is 75px, workspaces top left, time / battery / weather larger on the right, Wi-Fi / Bluetooth / mic / agents on the left second level, notch visible as a cut-out, desktop untinted, top row centred in 75px, left numbers / workspaces legible, reserves correct, float default opens centred, Super+L / Super+T / leader Super+D still work, panels drop from the right elements, fullscreen hides the bar cleanly.
- Current theme is Afterburn Redline. Verify on Afterburn default as well, then put Redline back. Report both.
- Report: what was built, what the bar looks like live, what is in the band below the notch (or why it was left out in v1), the new float centre, and what James should judge by eye next.

## Out of scope for v1

- No frame, no hull, no bevel, no molding.
- No new elements beyond the 3 primaries + workspaces + tray / secondary that already exist.
- No drawer, no agent mission control, no dock remake.
- No moving the primaries to the left, no moving workspaces anywhere else.
- No changes to the launcher / emoji / clipboard pickers, except that they must still work with the new bar.
