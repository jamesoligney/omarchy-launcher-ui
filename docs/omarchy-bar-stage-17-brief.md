# Omarchy Bar — Stage 17 Brief
Date: 2026-11-25
Source of truth: `docs/omarchy-bar-refined-brief.md` + Stage 3–16 briefs in the repo. Build from those plus this brief. Do not rebuild from a task message alone.
Claude: download this brief from the URL in the prompt to `docs/omarchy-bar-stage-17-brief.md` first, then build Stage 17 from it.

Machine: Apple MacBook Pro (16-inch, M1 Max, 2021), Omarchy side only, Hyprland Lua, single internal monitor, no external monitor ever.
Repo: github.com/jamesoligney/omarchy-launcher-ui — reports to `docs/reports/`, commit, push, present the commit hash only.

## Standing rules
- **Build start / end (non-negotiable).** Start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. End: `omarchy toggle idle allow-idle` + `omarchy-kbd-backlight release` + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state — it flips it. End step in the report checklist.
- **Backup everything before editing.** Audit first, include everything that determines behaviour, only exclude with a stated reason. Runtime state out of GitHub, local backup mode 700.
- **Never `omarchy refresh shell`.** `omarchy restart shell` on its own, never combined with a summon.
- **Theme-aware, not fixed.** Afterburn default, currently red edition. Tokens in `shell.toml`.
- **Code standard:** efficient, clean, and light, always.
- **Interrogate the rest of the UI** on every change.
- **Locked — do not touch except as below:** island height 44, island radius 13 (outer corners, joint radius 2, joint gap 4), bar height 48, SF Compact Display Medium everywhere with no bold, text 18px, glyphs 20px, toast attached to right island with `toast.gap` 0, battery number only (no pill), calendar leader C, quick icons slide out left outside the island, Super+D hints only, leader letters dissecting the bottom outline, leader hints switchable (`leader.hints`), sparks hybrid ember/lightning (good now — do not touch), glow masked outside only, glass dark / see-through, main island order time, battery, weather, custom filled weather icons, AI mark half white basic.

## 1. Secondary island — less spacing, narrower than the primary island
- **Less spacing on the secondary island. It is now wider than the primary island.**
- The secondary island's icons are not going to be accessed so frequently. That is why it is called a secondary island. It should not be wider than the primary island.
- **Give the status island its own tighter spacing / padding, separate from the main islands.**
  - Stage 16 removed the status island's private layout and made it follow the main islands' padding-x 36 / spacing 38. That made it too wide.
  - Bring back a status-specific spacing, but only for spacing / padding — NOT for icon size. Glyphs stay regular 20px, in a row, centred vertically, as in Stage 16.
  - Try e.g. status padding-x ~16-20, status spacing ~16-22, or whatever makes the status island clearly narrower than the main right island, while still reading as the same system. State the values in the report.
  - Main islands keep padding-x 36 / spacing 38 — do not change them in this stage.
- Island itself unchanged: height 44, radius 13 outer / 2 joint, same glass / glow, same segmented joint. Leader letters stay on the bottom outline, under their lights.

## 2. Clock — bring AM / PM back
- **Bring PM and AM back to the clock.**
- This reverses the earlier Q4 decision (12-hour, no AM/PM). James now wants AM/PM shown.
- **Format:** 12-hour with AM/PM, e.g. `2:38 PM`, no seconds. Token `clock.format` should be `h:mm AP` (or the equivalent that Qt treats as true 12-hour — see Stage 9: Qt treats `h` as 0–23 unless the format also contains `AP`, so `AP` must be present).
- **Size:** AM/PM in the same text size (18px) as the time, or slightly smaller if that reads better — state the value in the report. Do not make the clock dominate the island.
- **Leader:** C stays on the time, on the bottom outline. Calendar panel unchanged.
- **Verify live:** at an afternoon time the bar shows e.g. `2:38 PM`, at a morning time `9:04 AM`.

## Out of scope
- Agent side panel / mission control — phase down the road, after the AI Notch interrogation.
- Drawer / panel — later phase, not this stage.
- Dock remake — after the bar.
- Direct Super+letter binds — future, after the leader is in muscle memory.
- ALS backlight daemon — do not rebuild it.
- Sparks — good now, do not touch.
- Screen recording / remote session — James does not use them, do not add them.
- Notch width — provisional 174, not messing anything up, leave it for now.
- Weather icons, AI mark, glow, radius, main island spacing — no change except as in §1–2.

## Verify live, then report
- Secondary island is narrower than the primary island, with its own tighter spacing values stated, glyphs still 20px regular size.
- Clock shows AM / PM, 12-hour, no seconds, verified live in both AM and PM if possible, otherwise at the current time.
- **Backup was taken at build start** — name it in the report.
- `omarchy-shell idle status` after build: `"enabled": true, "stayAwake": false`. Backlight restored.
- Report to `docs/reports/bar-stage-17-report.md`, commit, push, present the commit hash only.
