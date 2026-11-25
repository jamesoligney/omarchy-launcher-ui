# Omarchy Bar — Stage 14 Brief
Date: 2026-11-25
Source of truth: `docs/omarchy-bar-refined-brief.md` + Stage 3–13 briefs in the repo. Build from those plus this brief. Do not rebuild from a task message alone.
Claude: download this brief from the URL in the prompt to `docs/omarchy-bar-stage-14-brief.md` first, then build Stage 14 from it.

Machine: Apple MacBook Pro (16-inch, M1 Max, 2021), Omarchy side only, Hyprland Lua, single internal monitor, no external monitor ever.
Repo: github.com/jamesoligney/omarchy-launcher-ui — reports to `docs/reports/`, commit, push, present the commit hash only.

## Standing rules
- **Build start / end (non-negotiable).** Start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. End: `omarchy toggle idle allow-idle` + `omarchy-kbd-backlight release` + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state — it flips it. End step in the report checklist.
- **Backup everything before editing.** Audit first, include everything that determines behaviour, only exclude with a stated reason. Runtime state out of GitHub, local backup mode 700.
- **Never `omarchy refresh shell`.** `omarchy restart shell` on its own, never combined with a summon.
- **Theme-aware, not fixed.** Afterburn default, currently cyan edition. Tokens in `shell.toml`.
- **Code standard:** efficient, clean, and light, always.
- **Interrogate the rest of the UI** on every change.
- **Locked — do not touch except as below:** island height 44, island radius 13 (outer corners, joint radius 2, joint gap 4), bar height 48, SF Compact Display Medium everywhere with no bold, text 20px, toast attached to right island with `toast.gap` 0, battery number only (no pill), calendar leader C, quick icons slide out left outside the island, Super+D hints only, leader letters dissecting the bottom outline, leader hints switchable (`leader.hints`), sparks hybrid ember/lightning (good now — do not touch), islands wide (padding-x 44 / spacing 48 — leave here for now), glow masked outside only, glass dark / see-through, main island order time, battery, weather.

## 1. AI mark — lose the red
- **Lose the red on the AI mark. It is too distracting.**
- The AI mark is red all day because OpenCode's monthly limit is at 100%, and that red is an alarm, not a status light.
- **New colour rule, until the larger organic agent panel is figured out:** no red at all.
  - Idle / calm: quiet neutral gray, 60% opacity, as before.
  - An agent window is actually running: accent, lit.
  - Over a limit / near a limit: do NOT turn red. Stay quiet neutral, or at most accent — James to judge by eye, but red is out.
- Click still opens the agents panel, leader A still on the status island's outline, size still 13px in the staggered / in-a-line grid (see §2).

## 2. Secondary island — in a line, not staggered
- **Change the status island from staggered to all in a line.**
- All four status lights (Wi-Fi N, Bluetooth T, mic M, AI A) at the same small size (13px), in a single horizontal row, centred vertically in the 44px island, with tighter spacing / less breathing room than the staggered version.
- These are just lights — grayed out / lit, keybind-driven, click targets are not a concern — so a tight row will look intentional, not cramped, and calmer than up/down/up/down.
- Leader letters: all on the same line, on the bottom outline, under their lights, as before. Spacing step: retune for a tight row, state the new step value in the report. If in-a-line feels too tight live, state that and say what the next step would be — do not revert to staggered unasked.
- Island itself unchanged: same height 44, same radius 13 outer / 2 joint, same glass / glow, same segmented joint to the main island.

## 3. Weather icons — custom, filled, in the style of James's reference image
- **Go custom. Off-the-shelf sets in grayscale all look the same as each other — Lucide, Nerd Font, Meteocons Monochrome all flatten to the same sun/cloud/rain silhouettes at 20px.**
- **Reference image:** James pasted a filled weather glyph set he liked. Download it from https://muse.ai/files/1320148857852241/1866194017740300/ryvbnccohf7q8fhyq3fqg9tj/image-4c07b111.png — save it to `docs/` as a reference only, do NOT commit the watermarked stock image as an asset, do NOT lift it directly. It has a Dreamstime watermark; it is a style reference only.
- **Draw a custom set in that style:** solid filled, bold, clear shapes, quirky / distinctive shapes — not generic outline icons. Examples from the reference: sun as a filled circle with a scalloped / wavy edge, snowflake chunky, moon with a star, cloud as a solid lump, rain drops as solid drops, tornado as a spiral, etc. At 20px they must be legible — James said they are big enough at 20px to tell what they are.
- **Still grayscale** — quiet ink, theme-aware, no colour. **NOT thinner** — these are filled, not outline.
- **Coverage:** all conditions the stock widget already shows — clear day/night, partly cloudy day/night, cloudy/overcast, fog/mist, drizzle, rain, heavy rain/showers, sleet/freezing rain, snow, thunderstorm, etc. Every condition must have an icon in the new custom set; do not leave one falling back to Lucide / Nerd Font.
- **Replace the Lucide set completely** from Stage 13 — no Lucide glyphs left in the island. Draw the custom set as SVG / QML paths, same technique as Stage 13 (`WeatherIcon.qml` / `WeatherIcons.js`), just new paths.
- **Size / placement unchanged:** icon-only in the main right island, 20px, click opens the weather panel, leader W, staleness dimming and offline dot unchanged.
- **Panel glyphs must match — all one system.** The stock weather panel (drop-down) still uses its own glyphs from Stage 13. Change it to use the same custom set, so the island and the panel are one system, not two. State in the report if the panel cannot use the same paths and why.

## Out of scope
- Agent side panel / mission control — phase down the road, after the AI Notch interrogation. This stage only removes the red.
- Drawer / panel — later phase, not this stage.
- Dock remake — after the bar.
- Direct Super+letter binds — future, after the leader is in muscle memory.
- ALS backlight daemon — do not rebuild it.
- Sparks — good now, do not touch.
- Screen recording / remote session — James does not use them, do not add them.
- Notch width — James to run the ruler live, separate from this build.
- Island width, radius, glow, text size — no change.

## Verify live, then report
- AI mark has no red — quiet neutral when idle, accent only when an agent is running.
- Status island is in a line, four 13px lights in a row, tighter, calmer, leader letters all on one line.
- Weather icons are custom, filled, in the style of the reference image, grayscale, all conditions covered, no Lucide / Nerd Font glyphs left, in the island AND in the weather panel.
- **Backup was taken at build start** — name it in the report.
- `omarchy-shell idle status` after build: `"enabled": true, "stayAwake": false`. Backlight restored.
- Report to `docs/reports/bar-stage-14-report.md`, commit, push, present the commit hash only.
