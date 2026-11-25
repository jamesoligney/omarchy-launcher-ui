# Omarchy Bar — Stage 8 Brief
Date: 2026-11-25
Source of truth: `docs/omarchy-bar-refined-brief.md` + Stage 3–7 briefs in the repo. Build from those plus this brief. Do not rebuild from a task message alone.
Claude: download this brief from the URL in the prompt to `docs/omarchy-bar-stage-8-brief.md` first, then build Stage 8 from it.

Machine: Apple MacBook Pro (16-inch, M1 Max, 2021), Omarchy side only, Hyprland Lua, single internal monitor, no external monitor ever.
Repo: github.com/jamesoligney/omarchy-launcher-ui — reports to `docs/reports/`, commit, push, present the commit hash only.

## Standing rules
- **Build start / end (non-negotiable).** Start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. End: `omarchy toggle idle allow-idle` + `omarchy-kbd-backlight release` + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state — it flips it. End step in the report checklist.
- **Backup everything before editing.** Audit first, include everything that determines behaviour, only exclude with a stated reason. Runtime state out of GitHub, local backup mode 700.
- **Never `omarchy refresh shell`.** `omarchy restart shell` on its own, never combined with a summon.
- **Theme-aware, not fixed.** Afterburn default. Tokens in `shell.toml`.
- **Code standard:** efficient, clean, and light, always.
- **Interrogate the rest of the UI** on every change.
- **Locked — do not touch except as below:** island radius 9, bar height 44, SF Compact Display Medium everywhere with no bold, toast attached to right island with `toast.gap` 0, battery number only (no pill), calendar leader C, quick icons slide out left outside the island, Super+D hints only, leader letters dissecting the bottom outline.

## 1. Battery — electricity, not embers
- **Replace the embers.** They float up and fade like embers from a fire. That is the wrong feeling. This is electricity going into the computer.
- **New: little lightning arcs / electric sparks, like a Tesla coil.** Jagged, electric, in the theme accent colour, jumping off the number at random, then gone. Not dramatic, not sizzling — just a little crackle, every ~0.75–1.5 seconds at random, only while charging.
- Reference: the little sparks that fly off the cursor / text box in Ghostty / terminal themes. James may send a screenshot of those — if he does, match that language. If not, build from this description: Tesla-coil lightning, jagged, electric, accent, random origin on the number, fading fast.
- Colour change stays as the main indication: accent when plugged in / charging, neutral / white on battery, amber ≤20%, red ≤10%. Sparks stop when unplugged.
- Must be subtle enough to live with while plugged in at ~80% all day. If it is too much, make it sparser / smaller / slower, and state the values in the report. Do not bring back the pill, outline, or shimmer.

## 2. Islands — bigger text, bigger icons, wider, more breathing room
- **There is room for the actual text to be larger and the icons to be larger within the islands.** Losing the battery pill left too much padding again.
- **Bar height is 44 — use it.** Island height is currently 38, with 3px padding top + bottom. Grow the island to fill more of the 44, grow the text and icons to fill the island, and give it more breathing room horizontally. Do not take a deeper reserve above 44 without James judging it live first — first use the 44 we already have, better.
- **Text:** larger than the current 16px. Try 18–20px, judge live by eye, state the value in the report. SF Compact Display Medium, no bold, tabular figures for the battery % and time.
- **Icons:** larger to match the text — weather, lights, agents mark, quick icons, all scaled together, not just the text. Keep them in proportion, do not let one icon dominate.
- **Horizontally:** widen the islands more, more `padding-x`, more `spacing` between elements. Airier, not pinched. Islands stay centred in their ears, expanding symmetrically.
- **Leader letters:** they sit on the bottom outline, dissecting the letters. If the text / icons get larger, the letters must stay legible on that outline — scale them if needed, state the value, and keep them subtle. They must be toggleable / offable cleanly in a future round, once James has learned them — build them so they can be turned off, do not bake them in.

## Out of scope
- Agent side panel / mission control — phase down the road, after the AI Notch interrogation.
- Dock remake — after the bar.
- Direct Super+letter binds — future, after the leader is in muscle memory.
- ALS backlight daemon — do not rebuild it.
- Toasts, quick icons, hover pop-out — fine as they are, no change unless the larger text / icons break them, in which case fix the break and say so.

## Verify live, then report
- Battery sparks are electric / lightning, not embers — jagged, accent, random, fading fast, only while charging. Off when unplugged.
- Text and icons are larger, islands are wider and airier, still centred in their ears, still 44px reserve, radius 9.
- Leader letters still dissect the bottom outline, legible, subtle, and can be turned off cleanly.
- **Backup was taken at build start** — name it in the report.
- `omarchy-shell idle status` after build: `"enabled": true, "stayAwake": false`. Backlight restored.
- Report to `docs/reports/bar-stage-8-report.md`, commit, push, present the commit hash only.
