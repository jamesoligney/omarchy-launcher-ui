# Oma-cast Trial Brief

Status: Trial brief. Build from docs/omarchy-bar-refined-brief.md plus this brief.
Purpose: Trial oma-cast as the launcher on Super+Space. Leave Vicinae as is.

## The problem (James, 2026-11-27)

Our launcher menu (`jimmy.menu`, a clone of Omarchy's stock menu) is a little buggy. Sometimes it comes up and won't accept any keypresses.

Oma-cast (https://github.com/typecraft-dev/oma-cast) is a Raycast rebuild for Omarchy, as a native `omarchy-shell` plugin. It claims: "The window stays ready while hidden, so the hotkey opens it in a single frame." That is the opposite of the focus / ready-state bug in our launcher.

## Locked decisions

1. **Oma-cast on Super+Space.** Install oma-cast and bind it to Super+Space. That is the launcher key James uses. Super+Space currently opens the Omarchy menu / `jimmy.menu` — that bind moves to oma-cast for the trial.
2. **Leave Vicinae as is.** Do not unbind Vicinae from Alt+Space (Left Option+Space), do not uninstall it, do not change its binds. James still uses Vicinae to create app keybinds. Vicinae stays exactly as it is.
3. **Keep `jimmy.menu` enabled as a fallback, but not on Super+Space.** Do not delete `jimmy.menu`'s `shell.json` layout entry — v5 proved deleting it disables the launcher entirely. Keep it enabled (in `plugins[]` or in the bar layout, whichever keeps it loaded without taking Super+Space), and say in the report how it is kept enabled and what key, if any, opens it now. Do not remove it from the bar row unasked — if it stays in the bottom row, say so.
4. **Trial only, reversible.** Install via `omarchy plugin add https://github.com/typecraft-dev/oma-cast --enable`, then `omacast install` (CLI link), then `omacast setup hyprland` — but **do not let setup bind Alt+Space**. Edit the generated `omacast.lua` / Hyprland config to bind Super+Space instead, and do not overwrite an existing `omacast.lua` if one exists. Run `omacast doctor` and report what it says. Record exactly what was changed so the trial can be undone: plugin, CLI link, Hyprland config, and the Super+Space bind that was moved.
5. **Test the specific bug.** Open oma-cast many times, fast, from different apps, and type immediately each time. Report whether it ever comes up and refuses keypresses. Also test: search filters, Enter launches / focuses, Esc closes, Ctrl+K works, theme follows (Afterburn Redline, then Afterburn default).

## Build checklist (standing rules)

- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files, saved per-workspace layouts. Runtime state (clipboard history, pins, recents, pause) stays local, never in git. Checksums live before = backup = live after.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- `hyprctl reload` only. No shell restart unless the change requires it, and then on its own, never combined with a summon loop.
- Theme-aware (Afterburn default), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/omacast-trial-report.md, commit, push, hash only.

## Details

- Audit first: read live `bindings.lua` and the stock Super+Space bind (`/usr/share/omarchy/default/hypr/bindings/utilities.lua`: `o.bind("SUPER + SPACE", "Omarchy menu", { menu = "root" })`), and state how Super+Space will be moved to oma-cast without breaking the stock bind file (do not edit stock files in `/usr/share/omarchy`).
- Do not bind oma-cast to Alt+Space. Do not touch Vicinae's Alt+Space bind.
- Do not enable oma-cast's clipboard history / emoji hotkeys in this trial unless they are needed to test the launcher — leave Super+Ctrl+V / Super+Ctrl+E on our `jimmy.clipboard` / `jimmy.emojis` pickers for now. Report what oma-cast's own clipboard / emoji would replace, but do not replace them in this stage.
- Verify live: Super+Space opens oma-cast, typing works immediately every time, search / launch / focus works, Esc closes, bar is still 75px, reserves `[0, 75, 0, 0]`, Vicinae still opens on Alt+Space, `jimmy.menu` is still enabled, no QML errors.
- Current theme is Afterburn Redline. Verify on Afterburn default as well, then put Redline back. Report both.
- Report: what was installed, what binds changed (with file / line), what Vicinae still does, what `jimmy.menu` still does, `omacast doctor` output, the focus-bug test results, and how to undo the trial in one step.

## Out of scope for this trial

- Do not uninstall Vicinae, do not unbind Alt+Space, do not change Vicinae's binds.
- Do not remove `jimmy.menu`, do not disable it.
- Do not replace our emoji / clipboard pickers with oma-cast's yet.
- Do not change the bar, the float default, Super+L, Super+T, leader keys, or the top bar layout.
- No frame, no hull, no bevel, no molding, no hard line.
