# Omarchy Bar — Stage 15 Brief
Date: 2026-11-25
Source of truth: `docs/omarchy-bar-refined-brief.md` + Stage 3–14 briefs in the repo. Build from those plus this brief. Do not rebuild from a task message alone.
Claude: download this brief from the URL in the prompt to `docs/omarchy-bar-stage-15-brief.md` first, then build Stage 15 from it.

Machine: Apple MacBook Pro (16-inch, M1 Max, 2021), Omarchy side only, Hyprland Lua, single internal monitor, no external monitor ever.
Repo: github.com/jamesoligney/omarchy-launcher-ui — reports to `docs/reports/`, commit, push, present the commit hash only.

## Standing rules
- **Build start / end (non-negotiable).** Start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. End: `omarchy toggle idle allow-idle` + `omarchy-kbd-backlight release` + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state — it flips it. End step in the report checklist.
- **Backup everything before editing.** Audit first, include everything that determines behaviour, only exclude with a stated reason. Runtime state out of GitHub, local backup mode 700.
- **Never `omarchy refresh shell`.** `omarchy restart shell` on its own, never combined with a summon.
- **Theme-aware, not fixed.** Afterburn default, currently cyan edition. Tokens in `shell.toml`.
- **Code standard:** efficient, clean, and light, always.
- **Interrogate the rest of the UI** on every change.
- **Locked — do not touch except as below:** island height 44, island radius 13 (outer corners, joint radius 2, joint gap 4), bar height 48, SF Compact Display Medium everywhere with no bold, toast attached to right island with `toast.gap` 0, battery number only (no pill), calendar leader C, quick icons slide out left outside the island, Super+D hints only, leader letters dissecting the bottom outline, leader hints switchable (`leader.hints`), sparks hybrid ember/lightning (good now — do not touch), islands wide (padding-x 44 / spacing 48 — leave here for now), glow masked outside only, glass dark / see-through, main island order time, battery, weather, custom filled weather icons, status island in a line.

## 1. AI mark — just half white, basic, for now
- **The AI mark is in the accent colour, and it should not be.**
- **Leave it as half white, the same as the other status lights right now.** Quiet, neutral, ~50-60% opacity, like Wi-Fi / Bluetooth / mic when idle.
- **Until we figure out how to make model activity work, keep it basic.** No accent when an agent is running, no red, no over-limit colour — just half white, always, for now.
- Click still opens the agents panel, leader A still on the status island's outline, size still 13px in the row. Do not build the agent side panel / mission control in this stage.

## 2. Text 18px, glyphs stay 20px — split them
- **The font size is too big in the islands. It is at 20 now. Drop it down to 18 and take a look. It is just too in your face.**
- **Keep the glyphs at 20, drop the fonts — the letters and the numbers — to 18.**
  - Text to 18px: time, battery %, app name, workspace numbers, toast text, and any other island text.
  - Glyphs stay 20px: weather icon, lights / status glyphs in the main island, quick icons, stay-awake cup, etc.
  - Status island lights stay 13px — do not change them in this stage.
- **This means splitting the token:** `island.font-size` currently drives both text and icons at 20px. Split it into a text size (18) and a glyph / icon size (20), with separate tokens, so they can be tuned independently in future. State both token names and values in the report.
- **James may reverse this at some point** — if he does, he is more likely to remove some elements at the same time, rather than just grow the text back. For now, 18px text / 20px glyphs is the test.
- Islands: height, radius, width, spacing, padding stay as they are — do not shrink the islands to match the smaller text, and do not grow the glyphs to fill the space. Just let the smaller text sit in the same islands and judge by eye.

## Out of scope
- Agent side panel / mission control — phase down the road, after the AI Notch interrogation. This stage only makes the mark basic.
- Drawer / panel — later phase, not this stage.
- Dock remake — after the bar.
- Direct Super+letter binds — future, after the leader is in muscle memory.
- ALS backlight daemon — do not rebuild it.
- Sparks — good now, do not touch.
- Screen recording / remote session — James does not use them, do not add them.
- Notch width — James to run the ruler live, separate from this build.
- Island width, radius, glow — no change.

## Verify live, then report
- AI mark is half white / quiet, always, no accent, no red.
- Text is 18px, glyphs are 20px, split into separate tokens, stated in the report. Status lights still 13px.
- Islands read less in-your-face, with the same height / width / spacing.
- **Backup was taken at build start** — name it in the report.
- `omarchy-shell idle status` after build: `"enabled": true, "stayAwake": false`. Backlight restored.
- Report to `docs/reports/bar-stage-15-report.md`, commit, push, present the commit hash only.
