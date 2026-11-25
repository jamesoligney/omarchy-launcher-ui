# Omarchy Bar — Stage 13 Brief
Date: 2026-11-25
Source of truth: `docs/omarchy-bar-refined-brief.md` + Stage 3–12 briefs in the repo. Build from those plus this brief. Do not rebuild from a task message alone.
Claude: download this brief from the URL in the prompt to `docs/omarchy-bar-stage-13-brief.md` first, then build Stage 13 from it.

Machine: Apple MacBook Pro (16-inch, M1 Max, 2021), Omarchy side only, Hyprland Lua, single internal monitor, no external monitor ever.
Repo: github.com/jamesoligney/omarchy-launcher-ui — reports to `docs/reports/`, commit, push, present the commit hash only.

## Standing rules
- **Build start / end (non-negotiable).** Start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. End: `omarchy toggle idle allow-idle` + `omarchy-kbd-backlight release` + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state — it flips it. End step in the report checklist.
- **Backup everything before editing.** Audit first, include everything that determines behaviour, only exclude with a stated reason. Runtime state out of GitHub, local backup mode 700.
- **Never `omarchy refresh shell`.** `omarchy restart shell` on its own, never combined with a summon.
- **Theme-aware, not fixed.** Afterburn default, currently green edition. Tokens in `shell.toml`.
- **Code standard:** efficient, clean, and light, always.
- **Interrogate the rest of the UI** on every change.
- **Locked — do not touch except as below:** island height 44, island radius 13 (outer corners, joint radius 2, joint gap 4), bar height 48, SF Compact Display Medium everywhere with no bold, text 20px, toast attached to right island with `toast.gap` 0, battery number only (no pill), calendar leader C, quick icons slide out left outside the island, Super+D hints only, leader letters dissecting the bottom outline, leader hints switchable (`leader.hints`), sparks hybrid ember/lightning (good now — do not touch), islands wide (padding-x 44 / spacing 48 — leave here for now), glow masked outside only, glass dark / see-through.

## 1. Move the AI mark to the status island — 4th staggered light
- **The AI icon is the perfect candidate for the secondary island.** It is really just a static thing in the main island now, anyway, until we figure out how to implement a larger, more organic, and fluid panel.
- **Move it:** from the main right island to the far right status island, as the 4th staggered light, alongside Wi-Fi (N), Bluetooth (T), and mic (M).
- **That makes four lights, even:** 2 up / 2 down in the staggered grid, balanced, which is what James wanted to see.
- **Same size / pattern as the other status lights:** 13px, staggered (even slots up, odd slots down, 6px from the middle), same step (15px), same padding. It is a status light now — grayed out / quiet when calm, lit / accent / red by the same colour rule as before (red over limit, accent near, full foreground while an agent window runs, calm 60% otherwise). Do not make it bigger than the other lights to compensate.
- **Click:** opens the agents panel, as before. Leader: keep its leader key **A**, on the bottom outline like the others, in the status island. Check for collisions — A was already the agents leader, N/T/M are the other status lights, no new collision should appear.
- **Main island:** after the AI mark leaves, the main right island should close up / re-centre cleanly — time, weather, battery, lights, quick strip — with no gap left where the AI mark was, and reordered to time, battery, weather (see §4). State in the report how the main island re-centred.
- **Do not build the agent side panel / mission control in this stage.** That is still a phase down the road, after the AI Notch interrogation. This stage is only moving the mark.

## 2. Panels from the status island — decide, do not guess
- Stage 12 left this open: hosted panels (network, Bluetooth) still drop from the main island's centre, not from the status island.
- **Decide now:** network, Bluetooth, mic, and agents panels should drop from the island that holds their icon — i.e. from the status island's centre — not from the main island. That is the coherent rule: a panel drops from the island its icon lives in.
- If that rule breaks toasts / calendar / other panels that hang from the main island, state the break and keep the main-island rule for those — do not move everything blindly. Only the four status lights' panels move, if clean.


## 3. Weather icons — a prettier set, still grayscale
- **Get a different set of icons for the weather. Something prettier.** James does not like the current icon set.
- **Still grayscale** — no colour in the weather icon. Prettier means more elegant, more refined, better shapes — not chunkier, not cartoon, not filled blobs, and NOT thinner.
- **Style to aim for:** a better, prettier icon set — more refined, more legible, more beautiful at a glance. **NOT thinner** — James said the current icons could not be any thinner than they are right now, so do not make them thinner. Aim for better shapes / proportions / clarity, not a thinner stroke. Consistent with the island language: quiet, elegant, grayscale. The current set is Nerd Font weather glyphs; replace them, do not just recolour them.
- **Coverage:** all the conditions the stock widget already shows — clear / sunny, partly cloudy, cloudy / overcast, rain, heavy rain, snow, fog / mist, thunderstorm, etc. Every condition must have an icon in the new set; do not leave one falling back to the old set.
- **Size / placement unchanged:** icon-only in the main right island, 20px, same as before. Click still opens the weather panel. Staleness states unchanged.
- **Source:** use a clean, openly licensed weather icon set, or draw the set as simple SVG / QML paths in the same style — whichever is cleaner and lighter. State the source in the report. Do not pull in a heavy icon font just for weather.
- **For James's eye:** the new set should read as prettier at a glance, in grayscale, at 20px, on a dark wallpaper.


## 4. Reorder the main right island — time, battery, weather
- **Since the AI mark is moving to the secondary island, reorder the main right island: time, then battery percentage, then weather.**
- Order from the notch outward: time nearest the notch, battery next, weather last. Left-to-right in the right island: time, battery, weather.
- Leader letters move with their elements: C stays on time, B stays on battery, W stays on weather — same keys, new positions, on the bottom outline as before.
- Quick strip, toasts, calendar, and panels must still attach / drop correctly after the reorder — fix any break and say so.

## Out of scope
- Agent side panel / mission control — phase down the road, after the AI Notch interrogation.
- Drawer / panel — later phase, not this stage.
- Dock remake — after the bar.
- Direct Super+letter binds — future, after the leader is in muscle memory.
- ALS backlight daemon — do not rebuild it.
- Sparks — good now, do not touch.
- Screen recording / remote session — James does not use them, do not add them.
- Island width, radius, glow, text size — no change.
- Toasts, quick icons, hover pop-out — no change except as in §1–4.

## Verify live, then report
- AI mark is in the status island, 4th staggered light, 13px, same colour rule, click opens agents panel, leader A, no collisions. Four lights read even, 2 up / 2 down.
- Main island re-centred cleanly with no gap where the AI mark was, and reordered to time, battery, weather.
- Status lights' panels drop from the status island, or the reason stated if they do not.
- Weather icons are a new, prettier grayscale set (not thinner), all conditions covered, no old glyphs left.
- **Backup was taken at build start** — name it in the report.
- `omarchy-shell idle status` after build: `"enabled": true, "stayAwake": false`. Backlight restored.
- Report to `docs/reports/bar-stage-13-report.md`, commit, push, present the commit hash only.
