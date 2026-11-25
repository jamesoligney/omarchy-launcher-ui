# Omarchy Bar — Stage 11 Brief
Date: 2026-11-25
Source of truth: `docs/omarchy-bar-refined-brief.md` + Stage 3–10 briefs in the repo. Build from those plus this brief. Do not rebuild from a task message alone.
Claude: download this brief from the URL in the prompt to `docs/omarchy-bar-stage-11-brief.md` first, then build Stage 11 from it.

Machine: Apple MacBook Pro (16-inch, M1 Max, 2021), Omarchy side only, Hyprland Lua, single internal monitor, no external monitor ever.
Repo: github.com/jamesoligney/omarchy-launcher-ui — reports to `docs/reports/`, commit, push, present the commit hash only.

## Standing rules
- **Build start / end (non-negotiable).** Start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. End: `omarchy toggle idle allow-idle` + `omarchy-kbd-backlight release` + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state — it flips it. End step in the report checklist.
- **Backup everything before editing.** Audit first, include everything that determines behaviour, only exclude with a stated reason. Runtime state out of GitHub, local backup mode 700.
- **Never `omarchy refresh shell`.** `omarchy restart shell` on its own, never combined with a summon.
- **Theme-aware, not fixed.** Afterburn default, currently green edition. Tokens in `shell.toml`.
- **Code standard:** efficient, clean, and light, always.
- **Interrogate the rest of the UI** on every change.
- **Locked — do not touch except as below:** island height 44, island radius 11, bar height 48, SF Compact Display Medium everywhere with no bold, toast attached to right island with `toast.gap` 0, battery number only (no pill), calendar leader C, quick icons slide out left outside the island, Super+D hints only, leader letters dissecting the bottom outline, leader hints switchable (`leader.hints`), sparks hybrid ember/lightning (good now — do not touch).

## 1. Leader vs. microphone — note, diagnose, fix if clean
- **Noted by James:** the microphone keybind, which is just the Right Option key (Superwhisper push-to-talk), does not work if the leader is up — if he does Super+D first, Right Option does nothing.
- **Not a huge deal, unlikely he will use both at the same time** — but note it, diagnose it, and fix it if there is a clean fix.
- Likely cause: the Hyprland `bar` submap for Super+D captures / swallows keys while active, so Right Option never reaches Superwhisper. Check: does the submap block it, is Right Option bound in the submap, is Superwhisper listening at a level the submap overrides?
- Fix if clean: make Right Option pass through / work while the leader is up, without breaking the leader keys (1-9, W, C, B, A, Q, Esc). If there is no clean fix, state the cause in the report and leave it — do not hack the leader or the mic bind to force it.

## 2. Islands — MUCH wider. Overshoot on purpose.
- **When James says widen, he means widen. It has been so incremental that it has been barely noticeable.**
- **Make it a whole lot wider so he can say “oh no, that's too wide, pull it down a little.” That is the only way to find the optimal wideness.**
- This is an overshoot on purpose. Do not do another +4 / +6. Jump it — e.g. `island.padding-x` 26 → 40+, `island.spacing` 28 → 44+, or whatever jump makes the difference obvious by eye. State the values in the report.
- **Text is NOT getting larger this time.** James asked: the text isn't getting any larger every time he asks to widen, is it? Correct — widening is horizontal space between elements, not text size. **Pull text down to 20px (from 21px), and icons down to 20px with it.** 20 is more than sufficient; James may pull it down a little more later. Keep island height 44, radius 11, bar 48. Only the horizontal room grows: more padding-x, more spacing between elements.
- Islands stay centred in their ears, expanding symmetrically. Quick strip, toasts, panels must still attach correctly at the new island edges — fix any break and say so.

## 3. Glow — more glowy, not a brighter outline
- **The glow behind the islands should be more glowy. It just looks like a brighter outline right now. It does not look like a glow.**
- James knows this is challenging because it is a small space: in that small space, you have to illustrate a bright light fading to a disappearing / non-existent light — a very short span to create a glow. That is what he is asking for.
- **Fix:** make the glow actually fall off. Bright near the outline, fading to nothing over a short distance — a real gradient / blur falloff, not a hard 1px bright edge.
  - Increase the blur and the alpha near the edge, so the glow is visible as a halo, not as an outline. Try e.g. `glow-alpha` 0.14 → 0.25–0.35, `glow-blur` 10 → 18–24, and judge live. State the values in the report.
  - If `RectangularShadow` cannot give a real falloff in this small space, say so and try the next clean approach — do not just raise the alpha on the same hard edge, that will only make a brighter outline.
- Apply to both islands, same glow, same tokens. Toasts / panels / PanelShell share the same glow language if they have it — do not make them glow differently.
- Off switch stays: `island.glow-alpha = 0`.

## Out of scope
- Agent side panel / mission control — phase down the road, after the AI Notch interrogation.
- Dock remake — after the bar.
- Direct Super+letter binds — future, after the leader is in muscle memory.
- ALS backlight daemon — do not rebuild it.
- Sparks — good now, do not touch.
- Toasts, quick icons, hover pop-out, leader letters — no change except as in §1–3.

## Verify live, then report
- Right Option mic while Super+D leader is up: fixed, or cause stated if no clean fix.
- Islands are MUCH wider — obviously wider by eye, text at 20px (pulled down from 21px), height 44, radius 11, bar 48, with the new padding-x / spacing values stated.
- Glow is glowier — a bright-to-nothing falloff, a halo, not a brighter outline. Values stated.
- **Backup was taken at build start** — name it in the report.
- `omarchy-shell idle status` after build: `"enabled": true, "stayAwake": false`. Backlight restored.
- Report to `docs/reports/bar-stage-11-report.md`, commit, push, present the commit hash only.
