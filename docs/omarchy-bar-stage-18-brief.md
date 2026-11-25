# Omarchy Bar — Stage 18 Brief
Date: 2026-11-25
Source of truth: `docs/omarchy-bar-refined-brief.md` + Stage 3–17 briefs in the repo. Build from those plus this brief. Do not rebuild from a task message alone.
Claude: download this brief from the URL in the prompt to `docs/omarchy-bar-stage-18-brief.md` first, then build Stage 18 from it.

Machine: Apple MacBook Pro (16-inch, M1 Max, 2021), Omarchy side only, Hyprland Lua, single internal monitor, no external monitor ever.
Repo: github.com/jamesoligney/omarchy-launcher-ui — reports to `docs/reports/`, commit, push, present the commit hash only.

## Standing rules
- **Build start / end (non-negotiable).** Start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. End: `omarchy toggle idle allow-idle` + `omarchy-kbd-backlight release` + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state — it flips it. End step in the report checklist.
- **Backup everything before editing.** Audit first, include everything that determines behaviour, only exclude with a stated reason. Runtime state out of GitHub, local backup mode 700.
- **Never `omarchy refresh shell`.** `omarchy restart shell` on its own, never combined with a summon.
- **Theme-aware, not fixed.** Afterburn default, currently red edition. Tokens in `shell.toml` / Hyprland Lua as appropriate.
- **Code standard:** efficient, clean, and light, always.
- **Interrogate the rest of the UI** on every change.
- **Locked — do not touch except as below:** bar islands as in Stage 17 (height 44, radius 13, bar 48, text 18px, glyphs 20px, main island order time, battery, weather, status island tighter spacing 18/20, clock `h:mm AP`, AI mark half white, custom filled weather icons, sparks, glow masked outside only).

## 1. Default floating window — 1100 x 700, absolutely centred
- **Start all windows at 1100 by 700, absolutely centred.**
- This is the Q8 floating default from the bar design, now being built: a preset dimension to match the YouTube workflow in Helium, roughly 35-50% of the screen, dimensioned correctly, centred. 1100x700 is the jumping-off point to test live — James will run a couple of tests after this and see if it needs adjusting.
- **Scope — floating windows only, unless Hyprland makes that impossible to separate cleanly:**
  - New windows that open floating start at 1100x700, centred on the screen (absolute centre, both axes).
  - Tiled windows are unaffected — Hyprland tiling still lays them out as before. Do not force tiled windows to 1100x700.
  - If a window is floated later (Super+T / Hyper+Space / etc.), it should also land at 1100x700 centred, unless it already has a size / position the user set — state in the report what the rule does for already-open windows that are floated.
  - Fullscreen windows are unaffected.
- **How:** Hyprland window rules in the Lua config (`~/.config/hypr/*.lua`, `on-window-detected` / `windowrulev2` as appropriate for this Hyprland version — never `.conf`, never `hyprctl keyword` for persistence). Do not edit stock files in `/usr/share/omarchy`. This is a user config change, backed up and committed like the bar work.
- **Screen:** single internal monitor only, eDP-1, 3456x2234 @120Hz, scale 2, logical 1728x1117. Centre is the centre of that monitor. No external monitor ever.
- **Bar reserve:** the 48px top reserve is still in effect — a centred 1100x700 window should be centred on the usable screen, not under the bar / notch. State in the report how centring accounts for the reserve, if at all.
- **James will test after this build** and see if it needs adjusting — size, centre, or scope. Make the size / centre easy to change: a named token / variable in the config, not a magic number buried in three places. State the variable name and file in the report.

## Out of scope
- Agent side panel / mission control — phase down the road, after the AI Notch interrogation.
- Drawer / panel — later phase, not this stage.
- Dock remake — after the bar.
- Direct Super+letter binds — future, after the leader is in muscle memory.
- ALS backlight daemon — do not rebuild it.
- Sparks, weather icons, AI mark, glow, radius, spacing — no change.
- Notch width — provisional 174, not messing anything up, leave it for now.
- Remembering a window's previous formation (Cmd+L idea) — future, not this stage. This stage is only the default size / centre.

## Verify live, then report
- A new floating window opens at 1100x700, absolutely centred. Verified live with at least two different apps (e.g. Helium and Ghostty, or as available), with screenshots / measurements stated.
- Tiled windows are unaffected, fullscreen is unaffected.
- Size / centre is a named variable, stated in the report with file and line.
- **Backup was taken at build start** — name it in the report.
- `omarchy-shell idle status` after build: `"enabled": true, "stayAwake": false`. Backlight restored.
- Report to `docs/reports/bar-stage-18-report.md`, commit, push, present the commit hash only.
