# Omarchy Bar — Stage 5 Brief
Date: 2026-11-25
Source of truth: `docs/omarchy-bar-refined-brief.md` + Stage 3 and Stage 4 briefs in the repo. Build from those plus this brief. Do not rebuild from a task message alone.
Claude: download this brief from the URL in the prompt to `docs/omarchy-bar-stage-5-brief.md` first, then build Stage 5 from it.

Machine: Apple MacBook Pro (16-inch, M1 Max, 2021), Omarchy side only, Hyprland Lua, single internal monitor, no external monitor ever.
Repo: github.com/jamesoligney/omarchy-launcher-ui — reports to `docs/reports/`, commit, push, present the commit hash only.

## Standing rules
- **Build start / end (non-negotiable).** Start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. End: `omarchy toggle idle allow-idle` + `omarchy-kbd-backlight release` + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state — it flips it. End step in the report checklist.
- **Backup everything** before editing, audit first, only exclude with a stated reason. Runtime state out of GitHub, local backup mode 700.
- **Never `omarchy refresh shell`.** `omarchy restart shell` on its own, never combined with a summon.
- **Theme-aware, not fixed.** Afterburn default. Tokens in `shell.toml`.
- **Code standard:** efficient, clean, and light, always.
- **Interrogate the rest of the UI** on every change.
- **Locked — do not touch:** island size 38px high, island radius 9, bar height 44, island text 16px, SF Compact Display Medium everywhere with no bold, toast attached to right island with `toast.gap` 0.

## 1. Battery charging — shimmer, not pulse
- Replace the current charging outline: 2px, opacity 0.25 to 1 over 1.8s. That is a pulse, and it is too much.
- **New: a shimmer.** A thin line (1px) around the battery pill, subtly animating the *colour* of that line, in the system accent. Slow colour drift, low contrast, barely there unless you look for it. If you look at it long enough, something is moving there, slightly shimmering around the outline.
- **Why it must be subtle:** James is usually plugged in, hovering around 80%. The animation runs most of the time, all day. A pulse is an annoyance at that duty cycle; a shimmer is a quiet indicator.
- Do not also turn the number to accent. Shimmer only, judge it live.

## 2. Hover pop-out — fix the hover zone (bug)
- **Bug:** hovering the time opens the pop-out (Stay awake, Set reminder, Night light, Silence notifications), but as soon as the mouse leaves the bar — even to go down into the pop-out itself — it closes.
- **Fix:** the hover zone is the time *plus* the card. The pop-out stays open while the mouse is over either. It closes only when the mouse leaves both, with a grace delay (current close delay is 300ms — keep or tune it, state the value in the report).
- The keyboard path (Super+Ctrl+Q, focus, Up/Down, Enter, Esc) already works and stays open. Do not break it. The mouse path must work the same way.
- Look and feel are already good and consistent — do not redesign the pop-out, fix the hover zone only.

## 3. Workspace numbers — clickable, for consistency
- **Bug / gap:** workspace numbers in the left island cannot be clicked to change workspace.
- **Fix:** clicking a workspace number switches to that workspace. Same for the app name area where it makes sense.
- **Rule:** everything on the bar must be accessible in all the ways — mouse click, keyboard, and leader (Super+D, then 1-9). No mouse-only, no keyboard-only dead ends. Apply that rule to every island element while fixing this one, and list any other element that was mouse-only or keyboard-only.

## 4. Agents — capsules off the top island, no side panel yet
- **Remove the four per-model capsules from the top island.** They are noise: slim, static fills, no incremental movement, no data for Teams (see §5), and the robot glyph icon is superfluous.
- **Do NOT build a persistent side panel / mission control in this round.** That is a phase down the road. James does not know how it looks yet, and will interrogate the AI Notch plugin first for ideas. Leave the side panel off entirely.
- **Top island, for now:** a single, quiet AI mark in the right island — calm at rest, no capsules, no robot, no red dot. It may fill / colour to show state only when something is worth seeing (a model running, near limit, over limit), and it expands to the existing agents panel on click. If even that mark cannot be made quiet and meaningful with the data available, leave the island without an agents element and state why in the report. Do not invent data.
- **Do not build a new generic AI icon from scratch in this round** unless it is a one-line change. The icon question is open, pending the AI Notch interrogation.

## 5. Teams usage (#13) — closed, with the reason
- **Close #13.** James's Teams usage this morning came through a Helium browser window (claude.ai), not through Orca / the local Omarchy agent environment.
- Local usage records only see what runs in that local environment, so browser Teams usage will never register there. That is a boundary, not a bug.
- His Teams projects need to stay in that Claude instance, with cloud access and the documentation already set up in the project — they cannot move into Orca.
- Record that reason in the report, and do not re-open #13 unless the data source changes. The hook contract's optional `account` field (added in Stage 4) stays, for when local agent data is available.

## Out of scope
- Agent side panel / mission control — phase down the road, after the AI Notch interrogation.
- Dock remake — after the bar.
- Island size / radius / reserve / font / weight — locked, do not touch.
- ALS backlight daemon — do not rebuild it.
- Toasts — fine as they are, no change unless the hover / click audit in §3 finds an orphan.

## Verify live, then report
- Charging shimmer is subtle, slow colour drift on a thin line, pleasant while plugged in at ~80% for hours. Not a pulse.
- Hover pop-out stays open over time + card, closes only after leaving both. Super+Ctrl+Q still works.
- Clicking a workspace number switches workspace. Audit list of any other mouse-only / keyboard-only island elements, fixed or flagged.
- Capsules gone from the top island, no side panel built, quiet AI mark (or none, with reason stated).
- `omarchy-shell idle status` after build: `"enabled": true, "stayAwake": false`. Backlight restored.
- Report to `docs/reports/bar-stage-5-report.md`, commit, push, present the commit hash only.
