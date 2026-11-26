# Omarchy Bar — Launcher Fix Brief

Status: Fix brief. Build from docs/omarchy-bar-refined-brief.md plus this brief.
Purpose: Fix the launcher. Super+Space does nothing. It broke in one of the last two turns (Top Bar v4 or v5).

## The problem (James, 2026-11-26)

- Launcher is broken. Super+Space does nothing.
- James does not know when it broke. One of the last two turns, I think — Top Bar v4 (tray out, second level back left) or Top Bar v5 (easy trim).
- Suspect, not proven: v5 pulled out `jimmy.menu` and `glyph-menu` from the bottom row, on the report's claim that both open a menu Super+Space already opens. If the launcher *is* `jimmy.menu`, pulling it out would break Super+Space. That needs to be checked live, not assumed.

## Locked decisions

1. **Diagnose first, then fix.** Check live, in order:
   - What does Super+Space bind to in `~/.config/hypr/bindings.lua`? Is the bind still there, and what does it call?
   - Is `jimmy.menu` still loaded / present? Was it removed in v5 from `shell.json` → `bar.layout` / `inventoryIds`, and if so, does Super+Space depend on it?
   - Is `glyph-menu` the Omarchy menu, and is `jimmy.menu` the launcher frame? Say which is which, in the report — do not conflate them again.
   - What changed in v4 and v5 that could have broken it? Diff the v4 and v5 backups / commits against the v3 state, and name the change that broke it.
2. **Fix it by restoring what was removed, if that is the cause.** If `jimmy.menu` was the launcher and v5 removed it, put it back — in the bar layout, not just in the code. If the bind was broken, re-wire Super+Space to the launcher directly. Do not add a new launcher, do not rebuild the launcher from scratch.
3. **Do not trim anything else in this stage.** This is a fix, not a trim. Leave the other v5 removals (keyboard-layout, power, indicators, system-update, glyph-menu — unless glyph-menu is the cause) as they are, unless the diagnosis proves one of them broke the launcher.
4. **Verify live by pressing the key.** The fix is not verified until Super+Space opens the launcher, search works, and an app launches from it. Claude cannot press James's keys — so verify as far as possible live (bind present, plugin loaded, no QML errors, `omarchy-shell` status), and then James verifies by hand. Report exactly what was verified and what needs James's keypress.

## Build checklist (standing rules)

- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files, saved per-workspace layouts. Runtime state (clipboard history, pins, recents, pause) stays local, never in git. Checksums live before = backup = live after.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- `hyprctl reload` only. No shell restart unless the change requires it, and then on its own, never combined with a summon loop.
- Theme-aware (Afterburn default), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/launcher-fix-report.md, commit, push, hash only.

## Details

- Start from the v5 state. Do not roll back the whole bar to v3 — fix the launcher only.
- If `jimmy.menu` needs to come back, put it back where it belongs — say whether that is in the bottom row (visible) or loaded but hidden (no bar icon, launcher still works). James's preference is to see everything we have, then trim — so if it comes back visible, say so, and it can be trimmed later by choice, not by accident.
- Check the other v5 removals did not break anything else: keyboard-layout, power, indicators, system-update, glyph-menu. Report any other breakage found.
- Verify live: Super+Space bind present in `bindings.lua`, launcher plugin loaded, no QML errors, bar still 75px, reserves `[0, 75, 0, 0]`, left island / right island unchanged, desktop untinted.
- Current theme is Afterburn Redline. Do not switch themes in this stage.
- Report: what broke it (with evidence — diff / bind / plugin status), what was fixed, and what James needs to verify by hand (Super+Space, search, launch an app).

## Out of scope

- No new launcher, no rebuild of the launcher.
- No trimming, no moving the second level, no changing the right island, no changing the quick tiles.
- No frame, no hull, no bevel, no molding, no hard line.
- No changes to the float default, Super+L, Super+T, leader keys, or the emoji / clipboard pickers, except that they must still work.
