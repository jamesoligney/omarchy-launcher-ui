# Omarchy Bar — Stage 16 Brief
Date: 2026-11-25
Source of truth: `docs/omarchy-bar-refined-brief.md` + Stage 3–15 briefs in the repo. Build from those plus this brief. Do not rebuild from a task message alone.
Claude: download this brief from the URL in the prompt to `docs/omarchy-bar-stage-16-brief.md` first, then build Stage 16 from it.

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

## Context — minimal, elegant, with James's thumbprint
- James's original goal was something extremely minimal and elegant. The bar has drifted back toward a full bar, piece by piece. This stage is a step back toward that — not adding, but making the secondary island stop looking like an overthought afterthought.
- A menu bar is okay as long as it has character, as long as it has James's thumbprint on it. This bar does look different from a traditional menu bar. The secondary island, as it is now, does not work — it looks too different from the primary island, and that difference is distracting, causing James to investigate the small icons more, which is beside the point.

## 1. Secondary island — glyphs back to regular size, normal spacing
- **Keep the secondary island idea, but bring those glyphs back to regular size and normal spacing, not wide spacing.**
- Status lights (Wi-Fi N, Bluetooth T, mic M, AI A) were 13px, staggered, then in a line at 13px with a 20px step. That is too small and too different from the primary island.
- **New: same size as the main island's glyphs — 20px glyph size, in a single row, centred vertically, like the main island.** Text in the status island, if any, stays 18px. Leader letters stay on the bottom outline, same as the others.
- **Normal spacing, not wide spacing.** The status lights should use the same spacing language as the main island, not the overshot wide spacing. If the main island's spacing is cut down in §2, the status island follows it.
- The island itself stays the same shape: height 44, radius 13 outer / 2 joint, same glass / glow, same segmented joint to the main island. Only the contents get bigger and more normal.
- AI mark stays half white / basic, as in Stage 15. Mic stays persistent grayed out until in use. Wi-Fi / Bluetooth keep their status / click / leader behaviour, just at regular size.

## 2. Cut down the spacing a little, on both islands
- **Cut down the spacing altogether a little bit, on both islands.**
- Current spacing is the overshoot from Stage 11: `island.padding-x` 44, `island.spacing` 48. That was on purpose, to find too wide. It is bordering on too much.
- **Pull it back a little — not all the way.** James still likes more space between elements, just not this much. Try e.g. padding-x 44 → 36, spacing 48 → 38, or a similar modest pull-back, and state the values in the report. Judge live by eye.
- Apply to both islands — main left, main right, and status island — so they stay one system. Quick strip spacing follows the island spacing, as before, unless that breaks it — if so, say so.
- Text stays 18px, glyphs stay 20px, island height 44, radius 13, bar 48 — no other size changes in this stage.

## Out of scope
- Agent side panel / mission control — phase down the road, after the AI Notch interrogation.
- Drawer / panel — later phase, not this stage.
- Dock remake — after the bar.
- Direct Super+letter binds — future, after the leader is in muscle memory.
- ALS backlight daemon — do not rebuild it.
- Sparks — good now, do not touch.
- Screen recording / remote session — James does not use them, do not add them.
- Notch width — provisional 174, not messing anything up, leave it for now.
- Weather icons, AI mark colour, glow, radius — no change except as in §1–2.

## Verify live, then report
- Secondary island glyphs are regular size (20px), in a row, normal spacing, and read as part of the same system as the primary island — not an overthought afterthought, not smaller / distracting.
- Spacing is pulled back a little on both islands, still airier than the original, with the new padding-x / spacing values stated.
- **Backup was taken at build start** — name it in the report.
- `omarchy-shell idle status` after build: `"enabled": true, "stayAwake": false`. Backlight restored.
- Report to `docs/reports/bar-stage-16-report.md`, commit, push, present the commit hash only.
