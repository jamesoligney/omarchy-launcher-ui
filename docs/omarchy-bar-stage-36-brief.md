# Omarchy Bar — Stage 36 Build Brief (revised)

Status: Build brief. Build from docs/omarchy-bar-refined-brief.md plus this brief.
Purpose: Diagnose and fix the flickering / redrawing on the active window. Do not build new frame work on top of a glitching UI.

## The problem (James, 2026-11-26)

- Stage 35 is live: flat tinted hull + 1px accent hard line at 0.85.
- Keyboard was lagging behind typing.
- Now the whole UI is glitching: **flickering and redrawing on the active window.**
- Idle status checked live 2026-11-26 12:41 PST: `"enabled": true, "stayAwake": false`, no screensaver / lock running, last event "active". Stay-awake is NOT stuck on. Orca is running (pid 12989, mapped), but `inhibitingIdle` was not shown in the grep output.

## Locked decisions

1. **Diagnosis first, no new frame work.** Do not dim the hard line, do not add a bevel, do not change the tint, until the flickering is diagnosed. If the frame is causing it, fix that. If it is not, say so plainly and do not change the frame to chase it.
2. **Check the frame first.** Stage 35 removed the 75-ring Canvas loop and restored the Stage 30 flat fill — confirm live that `Frame.qml` is actually that version: one path, `Qt.OddEvenFill`, filled once, 1px hard line, no ring loop, no `copy` compositing, no `shade()` / `tone()` / `mix()`, no `on…Changed` repaint handlers, no `grep bevel` in `Frame.qml` or `shell.toml`. Check whether the Canvas is repainting repeatedly, and what triggers a repaint (token, theme, size, window focus?). A Canvas that repaints on every window focus change would flicker the active window.
3. **Check the shell and the machine.** Report, with evidence:
   - `omarchy-shell` CPU / memory while the flicker is happening, and whether it spikes on focus change.
   - Any QML errors / warnings in the shell log, especially `jimmy.frame` / `jimmy.bar`.
   - `hyprctl clients` for Orca: `inhibitingIdle` true or false, and whether an agent is still running in Orca.
   - Whether the flicker happens on every focus change, only on some windows, or continuously even with no input.
   - Whether the flicker is the frame redrawing, the window redrawing, or both — screenshot / grim capture during a flicker if you can catch it.
4. **If the frame is the cause, roll it back.** The safe rollback is Stage 30: flat tinted hull, `frame.tint = 0.22`, **no hard line**, no bevel. Do that in this stage if the diagnosis proves the hard line / Frame.qml is repainting. If the frame is not the cause, do not roll it back — leave Stage 35 as it is and report the real cause.
5. **Dim the hard line only after the flicker is fixed.** James also wants the inner edge less bright (Stage 35 line at 0.85, (203, 11, 28) on Redline). That is step two in this stage, after the flicker: `frame.edge` 0.85 → 0.50, judge live, 0.35 if still too bright, 0.65 if too faint. Do not do it first.

## Build checklist (standing rules)

- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files, saved per-workspace layouts. Runtime state (clipboard history, pins, recents, pause) stays local, never in git. Checksums live before = backup = live after.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- Token steps hot-reload — `frame.edge` is a token, so dimming it should need no shell restart. Do not restart the shell unless the diagnosis requires it, and then on its own, never combined with a summon loop.
- Theme-aware (Afterburn default), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/bar-stage-36-report.md, commit, push, hash only.

## Details

- Reproduce the flicker first: focus between two windows, type in the active window, watch for redraw. Note exactly when it flickers — on focus, on typing, continuously, or only in one app.
- If a shell restart is needed as a test, do it on its own, once, and report whether the flicker stopped.
- Verify live after any fix: hull flat, desktop untinted, notch a hole, top row centred, left numbers on the 30px band, reserves `[30, 75, 15, 15]`, and no flicker on focus change / typing.
- Current theme is Afterburn Redline. Verify on Afterburn default as well, then put Redline back. Report both.
- Report: diagnosis with evidence (what was running, CPU, idle status, QML errors, whether the flicker reproduced, what caused it), what was fixed, and the hard-line dim step if it was done after the fix. If you cannot reproduce the flicker, say so — do not claim it is fixed.

## Out of scope

- No bevel, no molding, no gradient — the bevel is still out.
- No black hull, no tint change, no geometry change, no reserve change.
- No notch disguise, no pills coming back.
- No moving any element, no new elements.
- No changes to the float default, Super+L, Super+T, leader keys, or the launcher / emoji / clipboard pickers.
- Do not change the keyboard, Hyprland binds, or Superwhisper to chase the lag unless the diagnosis proves that is the cause.
