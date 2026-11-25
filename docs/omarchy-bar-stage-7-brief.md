# Omarchy Bar — Stage 7 Brief
Date: 2026-11-25
Source of truth: `docs/omarchy-bar-refined-brief.md` + Stage 3, 4, 5, and 6 briefs in the repo. Build from those plus this brief. Do not rebuild from a task message alone.
Claude: download this brief from the URL in the prompt to `docs/omarchy-bar-stage-7-brief.md` first, then build Stage 7 from it.

Machine: Apple MacBook Pro (16-inch, M1 Max, 2021), Omarchy side only, Hyprland Lua, single internal monitor, no external monitor ever.
Repo: github.com/jamesoligney/omarchy-launcher-ui — reports to `docs/reports/`, commit, push, present the commit hash only.

## Standing rules
- **Build start / end (non-negotiable).** Start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. End: `omarchy toggle idle allow-idle` + `omarchy-kbd-backlight release` + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state — it flips it. End step in the report checklist.
- **Backup everything before editing.** Audit first, include everything that determines behaviour, only exclude with a stated reason. Runtime state out of GitHub, local backup mode 700.
- **Never `omarchy refresh shell`.** `omarchy restart shell` on its own, never combined with a summon.
- **Theme-aware, not fixed.** Afterburn default. Tokens in `shell.toml`.
- **Code standard:** efficient, clean, and light, always.
- **Interrogate the rest of the UI** on every change.
- **Locked — do not touch:** island height 38, island radius 9, bar height 44, island text 16px, SF Compact Display Medium everywhere with no bold, toast attached to right island with `toast.gap` 0, battery number only (no pill), calendar leader C.

## 1. Quick icons — slide out to the LEFT, outside the island, island stays fixed
- **Bug: the quick icons currently live inside the island, and shove the island to the right.** Hovering the time shifts the time over by four icons plus spaces. That is wrong.
- **Fix: the quick tray slides out to the left of the clock, outside the island. The clock / island stays right where it is.** The island's width and position never change when the strip opens. No shifting.
- Icons only, grayed out when off. Click one, it stays visible / lit. It remains live until clicked again, or turned off by some other means.
- Items: Stay awake, Set reminder, Night light (Locus), Silence notifications. Stay awake, when on, stays lit in the bar to the left of the time until clicked off.
- Hover over the time opens the strip to the left. Q (Super+Ctrl+Q, or Super+D then Q) opens the same strip with keyboard focus.
- Calendar pop-out must not overlap this strip — the strip is to the left, the calendar drops from the island, they must not collide.

## 2. Super+D leader — hints only, do NOT open the quick icons by default
- **Bug: Super+D currently pops out the quick icons by default.** That should not happen.
- **Fix: Super+D shows the leader hints only.** It opens nothing. Q *after* Super+D opens the quick strip. Super+D alone is hints-only until a letter is pressed.
- Leader keys stay: 1-9 workspace, W weather, C calendar, B battery, A agents, Q quick toggles, Esc leaves.

## 3. Leader hints — on the bottom outline, dissecting the letters
- **The centred-over-the-icon overlay does not work.** It sits in the middle, obscuring what is below it and not really readable.
- **New: centre each letter on the bottom outline of the island, so the bottom edge dissects the letter.** The line cuts through the middle of the letter. That is the design.
- If that is not possible in QML, the fallback is: letters move down and appear to be **hanging off the bottom of the outline** of the island. Do not put them above the bottom outline — there is almost certainly not room for them there.
- Letters are subtle. Same position every time, on the same line, centred over each element's x-position. They disappear when the leader exits (Esc, or after one key).
- Letters: digits over workspace numbers, Q on stay awake, C on time, W on weather, B on battery number, A on AI mark.

## 4. Battery — sparks, like embers, off the number while charging
- Battery is a number only, no pill. Colour is the charging indicator: accent when plugged in / charging, neutral / white on battery, amber ≤20%, red ≤10%. That colour change is the best indication — keep it.
- **New, while charging only: little sparks jump off the percentage, like embers.**
  - **Origin:** from any position on the charged number itself — e.g. it could originate at the bottom of the 9 and spark upwards.
  - **Direction:** upwards, like an ember floating away upwards. Not in all directions.
  - **Size:** a little bigger than 1-2px — something you can actually see for a moment.
  - **Motion:** fade out as they jump / float away.
  - **Frequency:** random, every ~0.75 to 1.5 seconds. Not sizzling with them, just occasional.
  - **Colour:** theme accent, same as the charging number.
- When unplugged, sparks stop, number goes back to white / neutral.
- This must be subtle enough to live with while plugged in at ~80% all day. If it is too much, make it sparser / smaller / slower, and state the values in the report. Do not bring back the pill, outline, or shimmer.

## Out of scope
- Agent side panel / mission control — phase down the road, after the AI Notch interrogation.
- Dock remake — after the bar.
- Island height / radius / reserve / font / weight — locked, do not touch except as in §1-3.
- ALS backlight daemon — do not rebuild it.
- Toasts — fine as they are, no change.

## Verify live, then report
- Hover over time: quick tray slides out to the left, outside the island, island / time do not move. Click an icon, it stays lit until clicked off.
- Super+D alone opens no strip, only hints. Q after Super+D opens the strip.
- Leader letters sit on the bottom outline, dissecting the letters (or hanging off it, if dissecting is not possible — state which shipped, and why).
- Battery sparks: embers originate on the number, float upwards, fade out, random ~0.75-1.5s, accent colour, only while charging. Off when unplugged.
- **Backup was taken at build start** — name it in the report.
- `omarchy-shell idle status` after build: `"enabled": true, "stayAwake": false`. Backlight restored.
- Report to `docs/reports/bar-stage-7-report.md`, commit, push, present the commit hash only.
