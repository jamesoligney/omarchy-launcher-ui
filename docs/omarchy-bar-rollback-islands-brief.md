# Omarchy Bar — Rollback Brief: back to the islands of this morning

Status: Rollback brief. Build from docs/omarchy-bar-refined-brief.md plus this brief.
Purpose: Something is totally messed up. Roll back to the islands of this morning — the bar before the frame. Stop the frame work entirely for now.

## The problem (James, 2026-11-26)

- Stage 35: flat tinted hull + hard line.
- Keyboard lagging behind typing, whole UI glitching, flickering and redrawing on the active window.
- Idle status is clean (`"enabled": true, "stayAwake": false`), so stay-awake is not the cause.
- James: "somethings totally messed-up here. let's roll back to the islands of this morning."

## Locked decisions

1. **Roll back to the islands, not to a flat hull, not to black, not to a new frame.** The bar as it was this morning, before the frame — Stage 26 state:
   - Top islands, not a frame: left title island, main right island (time with AM/PM, battery %, weather; time nearest notch), status island joined (Wi-Fi N, Bluetooth T, mic M, AI A, regular 20px glyphs, padding 18 / spacing 20).
   - Left strip: 30px visible, minimum half screen height (~559px), numbers centred, chips 24×28, reserve 32, windows start x 39, same island look.
   - Bar height / reserve top 48, left reserve 32, island height 44, radius 13 outer / joint 2, text 18px, glyphs 20px, SF Compact Display Medium, no bold.
   - Leader Super+D, keys 1-9, W, C, B, A, Q, N, T, M, Esc; letters dissecting bottom outline, switchable off.
   - Battery number only + hybrid sparks, charging only. Glow masked outside only, alpha 0.32, blur 20. Weather custom filled set, island + panel. Dock disabled.
   - Floating default 1100×619 centred (330, 273).
2. **Remove the frame entirely.** Disable / remove `jimmy.frame`: no hull, no tint, no hard line, no bevel, no molding, no rings. The frame plugin must not be running, and must not reserve anything. Reserves go back to the islands' reserves: `[32, 48, 0, 0]` — top 48, left 32, right 0, bottom 0 — as in Stage 26, not `[30, 75, 15, 15]`.
3. **Restore from backup, do not rebuild from scratch.** Use the pre-frame backup — Stage 26 backup `20261125-172945-bar-stage-26` (210 files), or the Stage 28 pre-frame backup `20261126-110702-bar-stage-28` taken before any frame edit — whichever is the clean islands state. Verify the restored files match that backup with checksums, and say which backup was used in the report. If neither backup is clean, restore from the Stage 26 commit in git (`152e1b2`) and say so.
4. **Take a backup first.** Before any rollback, take a full backup of the current messed-up state (mode 700, local only, same scope as Stages 30–35), so the frame work is not lost if James wants it back. Name it in the report.
5. **Then diagnose the glitch, briefly.** After the rollback, check live: does the flickering / redrawing on the active window stop? Does the keyboard lag stop? Report whether it stopped, and what the idle status / shell CPU / QML errors show after the rollback. Do not spend a stage trying to fix the frame — the frame is out.

## Build checklist (standing rules)

- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files, saved per-workspace layouts. Runtime state (clipboard history, pins, recents, pause) stays local, never in git. Checksums live before = backup = live after.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- `hyprctl reload` only. No shell restart unless the rollback requires it, and then on its own, never combined with a summon loop.
- Theme-aware (Afterburn default), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/bar-rollback-islands-report.md, commit, push, hash only.

## Details

- Restore: `jimmy.bar` islands, `jimmy-strip` left strip, `shell.toml` tokens for the islands (bar height, island radius, text/glyph sizes, battery, weather, leader), `float-default.lua` centre (330, 273), Hyprland reserves, dock disabled. Remove / disable `jimmy.frame` and its tokens (`frame.tint`, `frame.edge`, `bevel-*` — none should remain).
- Verify live: islands are back, centred in the ears, top row centred, left numbers on the strip, panels drop from the right islands, toasts centre under the right island, fullscreen hides the bar cleanly, floating default opens 1100×619 at (330, 273), Super+L / Super+T still work, leader Super+D still works.
- Verify the glitch is gone: focus between windows, type in the active window, watch for flicker / redraw / lag. Report whether it stopped.
- Current theme is Afterburn Redline. Leave it as James left it — do not switch themes unless the rollback requires it, and if you do, put Redline back and say so.
- Report: which backup / commit was restored from, what was removed (frame), what was restored (islands), checksums, whether the flicker / lag stopped, and the live verification list.

## Out of scope

- No frame, no hull, no bevel, no molding, no hard line, no black, no tint.
- No new bar work, no new elements, no moving elements.
- No changes to the float default except restoring (330, 273), no changes to Super+L, Super+T, leader keys, or the launcher / emoji / clipboard pickers.
- Do not try to fix the frame in this stage. The frame is out.
