# Omarchy Bar — Stage 19 Brief
Date: 2026-11-25
Source of truth: `docs/omarchy-bar-refined-brief.md` + Stage 3–18 briefs in the repo. Build from those plus this brief. Do not rebuild from a task message alone.
Claude: download this brief from the URL in the prompt to `docs/omarchy-bar-stage-19-brief.md` first, then build Stage 19 from it.

Machine: Apple MacBook Pro (16-inch, M1 Max, 2021), Omarchy side only, Hyprland Lua, single internal monitor, no external monitor ever.
Repo: github.com/jamesoligney/omarchy-launcher-ui — reports to `docs/reports/`, commit, push, present the commit hash only.

## Standing rules
- **Build start / end (non-negotiable).** Start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. End: `omarchy toggle idle allow-idle` + `omarchy-kbd-backlight release` + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state — it flips it. End step in the report checklist.
- **Backup everything before editing.** Audit first, include everything that determines behaviour, only exclude with a stated reason. Runtime state out of GitHub, local backup mode 700.
- **Never `omarchy refresh shell`.** `omarchy restart shell` on its own, never combined with a summon.
- **Theme-aware, not fixed.** Afterburn default, currently red edition.
- **Code standard:** efficient, clean, and light, always.
- **Interrogate the rest of the UI** on every change.
- **Locked — do not touch except as below:** bar islands as in Stage 17, Stage 18 floating default (`o.float_default = { width = 1100, height = 700 }` in `~/.config/hypr/float-default.lua`, centred on the usable area, x 314, y 233).

## 1. The default for any workspace has to be floating
- **The default for any workspace, though, has to be floating. And right now it is not.**
- Stage 18 built the floating size (1100x700, centred) for windows that already open floating, and for Super+T. It did not change the default — new windows still open tiled.
- **New: every new window, on any workspace, opens floating by default, at 1100x700, absolutely centred on the usable area (under the 48px bar reserve).**
- **Tiling becomes the opt-in, not the default.** Super+T (the Stage 18 toggle) still tiles a window, and tiles it back to floating at its remembered floating size / place. The toggle behaviour from Stage 18 stays.
- **Scope — say in the report what is and is not floated by default:**
  - Normal app windows: floating by default.
  - Dialogs / modals / transient windows that an app floats on its own: keep the size their app asks for, as in Stage 18 — do not force a 1100x700 "OK / Cancel" box, unless James says otherwise. State what the rule does with them.
  - Apps with their own stock float size (About, calculator, etc.): state whether they keep theirs or take the default.
  - Fullscreen: unaffected.
  - Already-open windows: do not re-float or move anything already open. Only new windows take the new default.
- **How:** Hyprland window rules / workspace defaults in the Lua config (`~/.config/hypr/*.lua`, `float-default.lua` and / or `bindings.lua` as appropriate — never `.conf`, never `hyprctl keyword` for persistence). Do not edit stock files in `/usr/share/omarchy`. If Hyprland has no clean "floating is the default for a workspace" switch, use the cleanest window-rule equivalent, and state in the report exactly what mechanism was used and what its limits are.
- **Single monitor only:** eDP-1, 3456x2234 @120Hz, scale 2, logical 1728x1117. No external monitor ever.
- **James will test after this build** — new windows on a fresh workspace, on an existing workspace, and with two windows open at once (do they stack / overlap centred, or offset?). State in the report what happens with two floating windows — if they land exactly on top of each other, say so, and say what the intended behaviour is.

## Out of scope
- Agent side panel / mission control — phase down the road, after the AI Notch interrogation.
- Drawer / panel — later phase, not this stage.
- Dock remake — after the bar.
- Direct Super+letter binds — future, after the leader is in muscle memory.
- ALS backlight daemon — do not rebuild it.
- Sparks, weather icons, AI mark, glow, radius, spacing, clock — no change.
- Notch width — provisional 174, not messing anything up, leave it for now.
- Remembering a window's previous formation across restarts (Cmd+L idea) — future, not this stage.

## Verify live, then report
- A new window on a fresh workspace opens floating at 1100x700, centred.
- A new window on an existing workspace opens floating at 1100x700, centred.
- Two new windows: state what happens (stacked / offset), with measurements.
- Super+T still tiles and returns to floating at the remembered size / place.
- Tiled windows already open are unaffected; fullscreen is unaffected.
- Mechanism used, and its limits, stated in the report.
- **Backup was taken at build start** — name it in the report.
- `omarchy-shell idle status` after build: `"enabled": true, "stayAwake": false`. Backlight restored.
- Report to `docs/reports/bar-stage-19-report.md`, commit, push, present the commit hash only.
