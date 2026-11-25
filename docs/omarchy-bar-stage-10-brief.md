# Omarchy Bar — Stage 10 Brief
Date: 2026-11-25
Source of truth: `docs/omarchy-bar-refined-brief.md` + Stage 3–9 briefs in the repo. Build from those plus this brief. Do not rebuild from a task message alone.
Claude: download this brief from the URL in the prompt to `docs/omarchy-bar-stage-10-brief.md` first, then build Stage 10 from it.

Machine: Apple MacBook Pro (16-inch, M1 Max, 2021), Omarchy side only, Hyprland Lua, single internal monitor, no external monitor ever.
Repo: github.com/jamesoligney/omarchy-launcher-ui — reports to `docs/reports/`, commit, push, present the commit hash only.

## Standing rules
- **Build start / end (non-negotiable).** Start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. End: `omarchy toggle idle allow-idle` + `omarchy-kbd-backlight release` + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state — it flips it. End step in the report checklist.
- **Backup everything before editing.** Audit first, include everything that determines behaviour, only exclude with a stated reason. Runtime state out of GitHub, local backup mode 700.
- **Never `omarchy refresh shell`.** `omarchy restart shell` on its own, never combined with a summon.
- **Theme-aware, not fixed.** Afterburn default. Tokens in `shell.toml`.
- **Code standard:** efficient, clean, and light, always.
- **Interrogate the rest of the UI** on every change.
- **Locked — do not touch except as below:** SF Compact Display Medium everywhere with no bold, toast attached to right island with `toast.gap` 0, battery number only (no pill), calendar leader C, quick icons slide out left outside the island, Super+D hints only, leader letters dissecting the bottom outline, leader hints switchable (`leader.hints`), sparks hybrid ember/lightning (good now — do not touch).

## 1. Corner radius — 11
- **Island corner radius: 9 → 11.**
- History: started at 14, now at 9. 9 is too square, 14 was too pill. 11 is the middle — still a rounded square, not a pill, a little softer than 9.
- Apply to islands only, unless the same radius token drives toasts / panels / pop-outs — if it does, apply the same 11 there too, so the whole system stays one radius. State in the report which surfaces changed.

## 2. More vertical space — open up the islands
- **Open up the islands vertically.** There is still too much padding / pinch top and bottom, and the text / icons have room to grow.
- Bar height is currently 44, island height 40, gap 2px top + bottom. Use more vertical space: grow the island height, grow the text and icons to fill it, and if needed grow the bar reserve above 44 — James has said he is good with having some more room up there, and the islands can be bigger.
- Do not take a deeper reserve blindly — try a larger island within 44 first, then a deeper reserve (e.g. 48–52) if that is what it takes to open it up, and state both values in the report so James can judge live by eye. The reserve change must be explicit, not silent.
- Text and icons: larger to match the taller island, scaled together, SF Compact Display Medium, no bold. Leader letters stay on the bottom outline, dissecting — scale / nudge them if the taller island moves that outline, and state the values.

## 3. Slightest glow from the island outline, in accent
- **There should be just the slightest glow coming from the islands outline, in the accent colour.**
- Most of the wallpapers are dark up there, so a faint accent glow will help the islands sit on the screen without being loud.
- Subtle is the point: a faint outer glow, accent, low opacity, soft — barely there unless you look for it. Not a neon outline, not a pulse, not a shimmer. Static, quiet, like the islands are lit from within.
- Apply to both islands, same glow, same token. Toasts / panels that attach to the islands should share the same glow language if they have an outline — do not make them glow differently.

## Out of scope
- Agent side panel / mission control — phase down the road, after the AI Notch interrogation.
- Dock remake — after the bar.
- Direct Super+letter binds — future, after the leader is in muscle memory.
- ALS backlight daemon — do not rebuild it.
- Sparks — good now, do not touch.
- Toasts, quick icons, hover pop-out, leader letters — no change except as in §1–3 (radius, vertical space, glow).

## Verify live, then report
- Corner radius is 11, reads as rounded square, softer than 9, not a pill.
- Islands are opened up vertically — taller, text/icons larger, airier, with the bar reserve value stated (44 or the new value).
- Island outline has just the slightest accent glow, subtle on dark wallpapers, not loud.
- Sparks unchanged and still good.
- **Backup was taken at build start** — name it in the report.
- `omarchy-shell idle status` after build: `"enabled": true, "stayAwake": false`. Backlight restored.
- Report to `docs/reports/bar-stage-10-report.md`, commit, push, present the commit hash only.
