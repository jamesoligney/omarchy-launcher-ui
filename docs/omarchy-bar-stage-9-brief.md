# Omarchy Bar — Stage 9 Brief
Date: 2026-11-25
Source of truth: `docs/omarchy-bar-refined-brief.md` + Stage 3–8 briefs in the repo. Build from those plus this brief. Do not rebuild from a task message alone.
Claude: download this brief from the URL in the prompt to `docs/omarchy-bar-stage-9-brief.md` first, then build Stage 9 from it.

Machine: Apple MacBook Pro (16-inch, M1 Max, 2021), Omarchy side only, Hyprland Lua, single internal monitor, no external monitor ever.
Repo: github.com/jamesoligney/omarchy-launcher-ui — reports to `docs/reports/`, commit, push, present the commit hash only.

## Standing rules
- **Build start / end (non-negotiable).** Start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. End: `omarchy toggle idle allow-idle` + `omarchy-kbd-backlight release` + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state — it flips it. End step in the report checklist.
- **Backup everything before editing.** Audit first, include everything that determines behaviour, only exclude with a stated reason. Runtime state out of GitHub, local backup mode 700.
- **Never `omarchy refresh shell`.** `omarchy restart shell` on its own, never combined with a summon.
- **Theme-aware, not fixed.** Afterburn default. Tokens in `shell.toml`.
- **Code standard:** efficient, clean, and light, always.
- **Interrogate the rest of the UI** on every change.
- **Locked — do not touch except as below:** island height 40, island radius 9, bar height 44, SF Compact Display Medium everywhere with no bold, toast attached to right island with `toast.gap` 0, battery number only (no pill), calendar leader C, quick icons slide out left outside the island, Super+D hints only, leader letters dissecting the bottom outline, leader hints switchable (`leader.hints`).

## 1. Battery sparks — a hybrid of ember and lightning, random all the way around
- **The lightning looks silly.** It is a pretty good representation of lightning, but it is lightning, and it is silly. Do not keep it as-is.
- **New: a hybrid between ember and lightning.**
  - Ember side: a small, soft, glowing particle — roundish, warm, that floats / drifts and fades, like an ember.
  - Lightning side: an electric flicker / jagged edge to that particle — it crackles, it is electric, accent colour, not a soft fire ember and not a full zigzag bolt.
  - The result should read as an electric spark, not a fire ember and not a cartoon lightning bolt. Subtle, in accent colour, only while charging.
- **Origin must be random all the way around the number.** James has watched it and has never seen a spark come off anything but the top or the right edge. Never from the bottom or the left.
  - Origin: a random point on the number's edge, uniformly around the whole perimeter — top, bottom, left, right, all four sides, all corners.
  - Direction: outward from wherever it originates, in a random direction — not just up, not just top/right. If it originates at the bottom, it drifts down / outward; if on the left, it drifts left / outward.
  - Verify by watching / counting: sparks must be seen from all sides, not just top/right. State in the report how the origin distribution was checked.
- Keep: size a little bigger than 1-2px, something you can actually see for a moment; fade out as it moves; random gap ~0.75–1.5s; accent colour; only while charging; off when unplugged. Colour change (accent when charging, neutral on battery, amber ≤20%, red ≤10%) stays as the main indication.
- Must be subtle enough to live with while plugged in at ~80% all day.

## 2. Islands — still wider, give them some room
- Islands can still be wider. Give them some room.
- More `padding-x`, more `spacing` between elements, airier. Same height (40), same radius (9), same bar height (44) — wider, not taller, unless James judges live that a deeper reserve is needed. Do not take a deeper reserve by default.
- Islands stay centred in their ears, expanding symmetrically. Text and icons stay at the Stage 8 size (19px) unless the wider islands make a larger size read better — if so, try it, state the value, and let James judge by eye.

## 3. Clock — back to 12-hour time (bug)
- **The time is 24-hour time. Again, it should be 12-hour time.**
- Q4 was closed long ago: 12-hour, no AM/PM. Clock format token is `h:mm`.
- **Fix:** set the clock back to 12-hour, no AM/PM, and find out why it reverted to 24-hour — check the token, the clock component, and any Stage 8 change that touched it. State the cause in the report, do not just flip it back silently.
- Verify live: time shows e.g. 1:05, not 13:05, with no AM/PM.

## Out of scope
- Agent side panel / mission control — phase down the road, after the AI Notch interrogation.
- Dock remake — after the bar.
- Direct Super+letter binds — future, after the leader is in muscle memory.
- ALS backlight daemon — do not rebuild it.
- Toasts, quick icons, hover pop-out, leader letters — fine as they are, no change unless the wider islands break them.

## Verify live, then report
- Sparks are a hybrid ember / lightning — electric, glowing, not a cartoon bolt, not a fire ember. Origin is random all around the number, seen from top, bottom, left, and right. Only while charging.
- Islands are wider, airier, still centred, still 44px reserve, radius 9.
- Clock is 12-hour, no AM/PM, with the cause of the 24-hour reversion stated.
- **Backup was taken at build start** — name it in the report.
- `omarchy-shell idle status` after build: `"enabled": true, "stayAwake": false`. Backlight restored.
- Report to `docs/reports/bar-stage-9-report.md`, commit, push, present the commit hash only.
