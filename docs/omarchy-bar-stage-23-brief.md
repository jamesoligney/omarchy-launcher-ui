# Omarchy Bar — Stage 23 Brief
Date: 2026-11-25
Source of truth: `docs/omarchy-bar-refined-brief.md` + Stage 3–22 briefs in the repo. Build from those plus this brief. Do not rebuild from a task message alone.
Claude: download this brief from the URL in the prompt to `docs/omarchy-bar-stage-23-brief.md` first, then build Stage 23 from it.

Machine: Apple MacBook Pro (16-inch, M1 Max, 2021), Omarchy side only, Hyprland Lua, single internal monitor, no external monitor ever.
Repo: github.com/jamesoligney/omarchy-launcher-ui — reports to `docs/reports/`, commit, push, present the commit hash only.

## Standing rules
- **Build start / end (non-negotiable).** Start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. End: `omarchy toggle idle allow-idle` + `omarchy-kbd-backlight release` + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state — it flips it. End step in the report checklist.
- **Backup everything before editing.** Audit first, include everything that determines behaviour, only exclude with a stated reason. Runtime state out of GitHub, local backup mode 700.
- **Never `omarchy refresh shell`.** `omarchy restart shell` on its own, never combined with a summon.
- **Theme-aware, not fixed.** Afterburn default, currently red edition.
- **Code standard:** efficient, clean, and light, always.
- **Interrogate the rest of the UI** on every change.
- **Locked — do not touch except as below:** bar islands as in Stage 17, floating default measured from Zen on workspace 3: `o.float_default = { width = 1100, height = 619 }`, centred on the usable area at (314, 273), in `~/.config/hypr/float-default.lua`. Stage 21–22 workspace-switch reset is in place.

## 1. Screenshot — sadly, still not working, and it is Helium specifically
- **Check the screenshot James sent with this stage (image-5cd65482.png).**
- **Terminal in front, Helium behind. Still not working.**
- **Ghostty in front is right:** 1100x619, (314, 273).
- **Helium behind it is still wrong:** larger, offset, sticking out behind Ghostty — not 1100x619, not at (314, 273).
- **This is Helium specifically, not browsers in general:**
  - **Floorp worked fine.** James checked Floorp and that worked fine.
  - **A personal web app of the New York Times, running in Chromium, also worked fine.**
  - Helium did not. Helium is the one that is still wrong.
- **Do not guess why Helium is different. Investigate it live, on the machine, and state the cause in the report.**

## 2. Investigate Helium, live, before fixing it
- **Run `hyprctl clients` (or `hyprctl clients -j`) and look at the Helium window on workspace 3, exactly as Hyprland reports it.**
  - Record: class, title, workspace, floating state, size, position, fullscreen state, and **every tag it carries** — especially `self-floated`, `float-default`, `omarchy-floating-workspace`, and any other tag.
  - Compare it, field by field, with Floorp and with the Chromium NYT web app, both of which work.
  - State in the report what is different about Helium, in Hyprland's own terms.
- **Possible lines to check — check them, do not assume any of them:**
  - Was Helium classified as `self-floated` when it opened, because it opened floating on its own account? If so, why — what made Hyprland float it on its own, and why does Floorp / Chromium not do the same?
  - Is Helium in `o.floating_apps`, or in any other exclusion list, under a different class / title than expected?
  - Did Helium arrive on workspace 3 by a route Stage 22 did not hook — moved onto it, leaving fullscreen, restored from a saved layout, or something else?
  - Is the Helium window in the screenshot the same window Stage 22 measured and reset, or a different / older Helium window?
- **Fix the cause, not the symptom.** Do not just move / resize this one Helium window by hand and leave the rule. The rule must make Helium — every Helium window, opened any way — take the default like every other normal app window.
- **Every application, every window that is opened — no per-app exceptions.** That was James's clarification in Stage 22, and it stands. Helium is not special.

## Out of scope
- Agent side panel / mission control — phase down the road, after the AI Notch interrogation.
- Drawer / panel — later phase, not this stage.
- Dock remake — after the bar.
- Direct Super+letter binds — future, after the leader is in muscle memory.
- ALS backlight daemon — do not rebuild it.
- Sparks, weather icons, AI mark, glow, radius, spacing, clock — no change.
- Notch width — provisional 174, not messing anything up, leave it for now.
- Cascade vs. stacked for two windows — not this stage, unless the fix changes it.
- Remembering a window's previous formation across restarts (Cmd+L idea) — future, not this stage.

## Verify live, then report
- Helium on workspace 3, measured with `hyprctl clients`: 1100x619 at (314, 273), after a workspace switch to floating — and after a fresh Helium open, if possible.
- Floorp and the Chromium NYT web app: still at the default, with measurements.
- Ghostty / Zen: still at the default.
- Cause of the Helium difference, stated in Hyprland's own terms, with the tags / class / route that made it different.
- Super+T still works as in Stage 18–19, or state the conflict if it does not.
- **Backup was taken at build start** — name it in the report.
- `omarchy-shell idle status` after build: `"enabled": true, "stayAwake": false`. Backlight restored.
- Report to `docs/reports/bar-stage-23-report.md`, commit, push, present the commit hash only.
