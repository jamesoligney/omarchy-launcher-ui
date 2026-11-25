# Omarchy Bar — Stage 21 Brief
Date: 2026-11-25
Source of truth: `docs/omarchy-bar-refined-brief.md` + Stage 3–20 briefs in the repo. Build from those plus this brief. Do not rebuild from a task message alone.
Claude: download this brief from the URL in the prompt to `docs/omarchy-bar-stage-21-brief.md` first, then build Stage 21 from it.

Machine: Apple MacBook Pro (16-inch, M1 Max, 2021), Omarchy side only, Hyprland Lua, single internal monitor, no external monitor ever.
Repo: github.com/jamesoligney/omarchy-launcher-ui — reports to `docs/reports/`, commit, push, present the commit hash only.

## Standing rules
- **Build start / end (non-negotiable).** Start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. End: `omarchy toggle idle allow-idle` + `omarchy-kbd-backlight release` + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state — it flips it. End step in the report checklist.
- **Backup everything before editing.** Audit first, include everything that determines behaviour, only exclude with a stated reason. Runtime state out of GitHub, local backup mode 700.
- **Never `omarchy refresh shell`.** `omarchy restart shell` on its own, never combined with a summon.
- **Theme-aware, not fixed.** Afterburn default, currently red edition.
- **Code standard:** efficient, clean, and light, always.
- **Interrogate the rest of the UI** on every change.
- **Locked — do not touch except as below:** bar islands as in Stage 17, floating default measured from Zen on workspace 3: `o.float_default = { width = 1100, height = 619 }`, centred on the usable area at (314, 273), in `~/.config/hypr/float-default.lua`.

## 1. Switching a workspace to floating resets its windows to the default size and position
- **If I have a window, a floating window open, and then I move it to scrolling or dwindle and back to floating, every time I switch the workspace to floating, it needs to set that window dimension and position.**
- **That is the default for floating.** So even if I change the workspace, tiling, option, and then go back to floating, it needs to go back to that dimension and position.
- **Behaviour:**
  - Take a floating window, move it to scrolling (or dwindle / tiled) — via Super+L cycling, or Super+T tiling it, or any other workspace-layout switch.
  - Then switch the workspace back to floating — via Super+L, or the workspace layout command, or any other route that puts that workspace into floating mode.
  - **Every time the workspace switches to floating, every window on that workspace is set to the default dimension and position: 1100x619, centred on the usable area at (314, 273), from `o.float_default`.**
  - It does not keep the size / place it had when it was tiled / scrolled, and it does not keep a moved / resized floating size from before. Floating mode means default size and position, every time.
- **Scope — say in the report what is and is not reset:**
  - Normal app windows on that workspace: reset to the default.
  - Windows already open on other workspaces: untouched — only the workspace being switched to floating is reset.
  - Modal dialogs, and dialogs / popups Hyprland already floats: keep the size their app asks for, as in Stage 18–19 — do not force them to 1100x619.
  - Apps with their own stock float size: state whether they keep theirs or take the default.
  - Fullscreen: unaffected.
- **How:** Hyprland / Omarchy workspace-layout hook, in the Lua config (`~/.config/hypr/*.lua`, `float-default.lua` and / or the workspace layout handling as appropriate — never `.conf`, never `hyprctl keyword` for persistence). Do not edit stock files in `/usr/share/omarchy`. If Omarchy's floating mode (Super+L) has its own size / cascade / titlebar behaviour, the reset must win over it for size and position, as the Stage 19 hook did for new windows. State in the report exactly what mechanism was used and what its limits are.
- **Super+T vs. workspace switch — do not conflate them:**
  - Super+T (Stage 18) remembers a window's floating size and place when it is tiled and floated again. That is per-window, and it stays as it is — unless it conflicts with this stage, in which case say so in the report.
  - This stage is about the workspace switching to floating mode (Super+L / layout switch), which resets the workspace's windows to the default. If the two behaviours conflict, the workspace-switch reset wins for that switch, and the report must say so.

## Out of scope
- Agent side panel / mission control — phase down the road, after the AI Notch interrogation.
- Drawer / panel — later phase, not this stage.
- Dock remake — after the bar.
- Direct Super+letter binds — future, after the leader is in muscle memory.
- ALS backlight daemon — do not rebuild it.
- Sparks, weather icons, AI mark, glow, radius, spacing, clock — no change.
- Notch width — provisional 174, not messing anything up, leave it for now.
- Cascade vs. stacked for two windows — not this stage, unless the reset changes it. State what happens with two windows when a workspace switches to floating.
- Remembering a window's previous formation across restarts (Cmd+L idea) — future, not this stage.

## Verify live, then report
- Start with a floating window at the default, move it to scrolling / dwindle, switch the workspace back to floating — it is back at 1100x619, (314, 273). Measured with `hyprctl clients`.
- Do it twice, on two different workspaces if possible — every time it switches to floating, it resets.
- Two windows on a workspace switched to floating: state what happens (stacked / offset), with measurements.
- Super+T still works as in Stage 18–19, or state the conflict if it does not.
- Mechanism used, and its limits, stated in the report.
- **Backup was taken at build start** — name it in the report.
- `omarchy-shell idle status` after build: `"enabled": true, "stayAwake": false`. Backlight restored.
- Report to `docs/reports/bar-stage-21-report.md`, commit, push, present the commit hash only.
