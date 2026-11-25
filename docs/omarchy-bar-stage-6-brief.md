# Omarchy Bar — Stage 6 Brief
Date: 2026-11-25
Source of truth: `docs/omarchy-bar-refined-brief.md` + Stage 3, 4, and 5 briefs in the repo. Build from those plus this brief. Do not rebuild from a task message alone.
Claude: download this brief from the URL in the prompt to `docs/omarchy-bar-stage-6-brief.md` first, then build Stage 6 from it.

Machine: Apple MacBook Pro (16-inch, M1 Max, 2021), Omarchy side only, Hyprland Lua, single internal monitor, no external monitor ever.
Repo: github.com/jamesoligney/omarchy-launcher-ui — reports to `docs/reports/`, commit, push, present the commit hash only.

## Standing rules
- **Build start / end (non-negotiable).** Start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. End: `omarchy toggle idle allow-idle` + `omarchy-kbd-backlight release` + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state — it flips it. End step in the report checklist.
- **Backup everything before editing, this round.** Stage 5 missed the local pre-edit backup — do not repeat that. Audit first, include everything that determines behaviour, only exclude with a stated reason. Runtime state out of GitHub, local backup mode 700.
- **Never `omarchy refresh shell`.** `omarchy restart shell` on its own, never combined with a summon.
- **Theme-aware, not fixed.** Afterburn default. Tokens in `shell.toml`.
- **Code standard:** efficient, clean, and light, always.
- **Interrogate the rest of the UI** on every change.
- **Locked — do not touch:** island height 38, island radius 9, bar height 44, island text 16px, SF Compact Display Medium everywhere with no bold, toast attached to right island with `toast.gap` 0.

## 1. Battery — lose the pill, number only
- **Remove the battery pill entirely.** It is noise. The fill, the outline, the shimmer — none of it tells the story better than the number. The number is hard to see inside the pill, and the shimmer is not enough.
- **Now: just the number, boring but effective.** SF Compact Display Medium, tabular figures, same weight as everything else.
- **Colour is the charging indicator:**
  - Plugged in / charging: number in the highlight / accent colour of the current theme
  - On battery / discharging: number neutral
  - Low: amber at ≤20%, red at ≤10%, same thresholds as before
- No plus/minus next to the number — superfluous. No fill, no outline, no shimmer, no pill. Do not bring the pill back in through the side door by pinning the number to one side of a progress bar. The number already says where the progress is.
- Remove the `battery.shimmer-ms` / `pulse-ms` tokens and the shimmer animation.

## 2. Hover pop-out — revert to original: icons to the left, no words, no dropdown
- **Revert the dropdown card.** It was a new invention, and it causes two problems: the bottom item (Silence notifications) still closes it when the mouse hits it, and it overlaps the calendar pop-out when James wants to click the clock.
- **Original stock behaviour, in the new island language:** hovering the time pops the icons out **to the left**, just the icons, grayed out when off. Click one, it stays in the bar lit up. No words, no card, no dropdown.
- Items: Stay awake, Set reminder, Night light (Locus), Silence notifications. Same list as before.
- Stay awake, when on, lives visibly in the bar to the left of the time, lit up, until clicked off (or a keybind turns it off). A light you cannot touch is not even decoration.
- **Q for the quick pop-out stays.** Q (Super+D, then Q, and Super+Ctrl+Q) opens that left-side icon strip, with focus. It opens icons to the left, not words dropping down. Do not get rid of Q.
- Calendar pop-out must not overlap this strip — the strip is to the left, the calendar drops from the island, they must not collide.

## 3. Leader hints — overlay over the icons / numbers, not stuck on the island
- **Super+D leader is fabulous, keep it.** The hint implementation is not: letters stuck on the right island in inconsistent places look awkward and forced.
- **New: overlay the letter over the actual icon / number it belongs to.** A small letter badge, centred over each icon / workspace number, same position every time, translucent, consistent. It maps directly — you see the letter *on* the thing you are about to press.
- Alternative considered and rejected as second choice: a pop-out cheat-sheet below the island. Overlay is direct, do that.
- Hints disappear when the leader exits (Esc, or after one key). Do not leave them on the bar.
- Workspace switching via Super+D then 1-9 stays, even though Super+digit is easier — it is awesome, keep it.

## 4. Calendar leader — T becomes C
- **Calendar should be C, not T.** T was for Time, but the thing being opened is the calendar.
- Change the leader submap: C opens the calendar. Check for collisions in the leader submap first, and state in the report that C is free there.
- Do NOT yet add direct Super+letter binds (Super+C, Super+W, etc.) in this round. That is a future step, once the letters are in muscle memory — check which Super+letter chords are actually free first, and only move the ones that do not collide. Leader first, direct binds later.

## 5. Islands — expand them, more breathing room
- Islands are looking squished / pinched right now. There is plenty of space up there — the ears are ~777px wide, the islands use about half of that.
- **Expand each island a bit, put more space between the elements.** More `padding-x`, more `spacing` between items, airier. Same height (38), same radius (9), same bar height (44) — wider, not taller.
- This also helps the overlay hints in §3 — more room for the letter badges to sit over the icons without crowding.
- Islands stay centred in their ears, expanding symmetrically.

## Out of scope
- Agent side panel / mission control — phase down the road, after the AI Notch interrogation.
- Dock remake — after the bar.
- Island height / radius / reserve / font / weight — locked, do not touch except the spacing / padding in §5.
- ALS backlight daemon — do not rebuild it.
- Toasts — fine as they are, no change.

## Verify live, then report
- Battery is a number only, no pill, no shimmer, no outline. Accent when charging / plugged in, neutral on battery, amber/red low.
- Hover over time: icons pop to the left, grayed / lit, click toggles, stays lit in the bar. Bottom item (Silence notifications) does not close it. Calendar pop-out does not overlap it. Q opens the same strip with focus.
- Super+D hints are overlays centred over each icon / number, consistent, and disappear on exit. Calendar is C, not T.
- Islands are wider, airier, elements have breathing room, still centred in their ears.
- **Backup was taken at build start this round** — name it in the report.
- `omarchy-shell idle status` after build: `"enabled": true, "stayAwake": false`. Backlight restored.
- Report to `docs/reports/bar-stage-6-report.md`, commit, push, present the commit hash only.
