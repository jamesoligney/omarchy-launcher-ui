# Omarchy Bar — Stage 20 Brief
Date: 2026-11-25
Source of truth: `docs/omarchy-bar-refined-brief.md` + Stage 3–19 briefs in the repo. Build from those plus this brief. Do not rebuild from a task message alone.
Claude: download this brief from the URL in the prompt to `docs/omarchy-bar-stage-20-brief.md` first, then build Stage 20 from it.

Machine: Apple MacBook Pro (16-inch, M1 Max, 2021), Omarchy side only, Hyprland Lua, single internal monitor, no external monitor ever.
Repo: github.com/jamesoligney/omarchy-launcher-ui — reports to `docs/reports/`, commit, push, present the commit hash only.

## Standing rules
- **Build start / end (non-negotiable).** Start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. End: `omarchy toggle idle allow-idle` + `omarchy-kbd-backlight release` + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state — it flips it. End step in the report checklist.
- **Backup everything before editing.** Audit first, include everything that determines behaviour, only exclude with a stated reason. Runtime state out of GitHub, local backup mode 700.
- **Never `omarchy refresh shell`.** `omarchy restart shell` on its own, never combined with a summon.
- **Theme-aware, not fixed.** Afterburn default, currently red edition.
- **Code standard:** efficient, clean, and light, always.
- **Interrogate the rest of the UI** on every change.
- **Locked — do not touch except as below:** bar islands as in Stage 17, Stage 18–19 floating default mechanism (global rule + floating-mode hook + Super+T toggle, tiling opt-in, dialogs keep their own size).

## 1. 1100 x 700 is wrong — take the measurements exactly from the Zen window on workspace 3
- **1100 by 700 is too [big / wrong]. It is the wrong dimension.**
- **The Zen window on workspace 3 is the proper size, dimension, and location.**
- **Look at that window and take its measurements exactly from there. Do not guess, do not invent a new size, do not round it to a nice number.**
- **How to measure it, live, on the machine:**
  - Run `hyprctl clients` (or `hyprctl clients -j`) and find the Zen window on workspace 3.
  - Record, exactly as Hyprland reports it: its size (width x height), its position (x, y), whether it is floating, and its workspace.
  - That size and that position are the new default — size and location both, exactly as measured.
- **Set the new default from those measurements:**
  - Replace `o.float_default = { width = 1100, height = 700 }` in `~/.config/hypr/float-default.lua` with the Zen window's exact width and height.
  - If the Zen window's position is not exactly centred on the usable area, do NOT force it to centre — take its position exactly as well. If the rule currently centres with `center = true`, change it so new floating windows land at the Zen window's exact position, or at the equivalent centred position if that is what the measurement shows. State in the report which it is, with the numbers.
  - One variable, one file, as in Stage 18 — change the size / position there, nothing else repeats the numbers.
- **Do not move, resize, close, or otherwise touch the Zen window on workspace 3.** Measure it only. James will judge it by eye after.
- **If the Zen window is not open / not on workspace 3 when you look:** stop, do not guess a size, and say so in the report — do not build Stage 20 on an invented size. State what you found instead.
- **Verify live, with a new window:** open a new floating window (e.g. Ghostty) and measure it with `hyprctl clients` — it must match the Zen window's size and position exactly, within Hyprland's own rounding.

## Out of scope
- Agent side panel / mission control — phase down the road, after the AI Notch interrogation.
- Drawer / panel — later phase, not this stage.
- Dock remake — after the bar.
- Direct Super+letter binds — future, after the leader is in muscle memory.
- ALS backlight daemon — do not rebuild it.
- Sparks, weather icons, AI mark, glow, radius, spacing, clock — no change.
- Notch width — provisional 174, not messing anything up, leave it for now.
- Cascade vs. stacked for two windows — not this stage, unless the Zen measurement changes it. State what happens with two windows at the new size, if tested.
- Remembering a window's previous formation across restarts (Cmd+L idea) — future, not this stage.

## Verify live, then report
- Zen window on workspace 3: exact size, position, floating state, workspace, as measured with `hyprctl clients`, stated in the report.
- New default: exact width, height, and position, stated in the report, with file and line.
- New floating window measured live: matches the Zen window exactly.
- Super+T toggle still works as in Stage 18–19.
- **Backup was taken at build start** — name it in the report.
- `omarchy-shell idle status` after build: `"enabled": true, "stayAwake": false`. Backlight restored.
- Report to `docs/reports/bar-stage-20-report.md`, commit, push, present the commit hash only.
