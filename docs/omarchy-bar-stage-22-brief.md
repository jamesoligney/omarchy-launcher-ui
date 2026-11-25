# Omarchy Bar — Stage 22 Brief
Date: 2026-11-25
Source of truth: `docs/omarchy-bar-refined-brief.md` + Stage 3–21 briefs in the repo. Build from those plus this brief. Do not rebuild from a task message alone.
Claude: download this brief from the URL in the prompt to `docs/omarchy-bar-stage-22-brief.md` first, then build Stage 22 from it.

Machine: Apple MacBook Pro (16-inch, M1 Max, 2021), Omarchy side only, Hyprland Lua, single internal monitor, no external monitor ever.
Repo: github.com/jamesoligney/omarchy-launcher-ui — reports to `docs/reports/`, commit, push, present the commit hash only.

## Standing rules
- **Build start / end (non-negotiable).** Start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. End: `omarchy toggle idle allow-idle` + `omarchy-kbd-backlight release` + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state — it flips it. End step in the report checklist.
- **Backup everything before editing.** Audit first, include everything that determines behaviour, only exclude with a stated reason. Runtime state out of GitHub, local backup mode 700.
- **Never `omarchy refresh shell`.** `omarchy restart shell` on its own, never combined with a summon.
- **Theme-aware, not fixed.** Afterburn default, currently red edition.
- **Code standard:** efficient, clean, and light, always.
- **Interrogate the rest of the UI** on every change.
- **Locked — do not touch except as below:** bar islands as in Stage 17, floating default measured from Zen on workspace 3: `o.float_default = { width = 1100, height = 619 }`, centred on the usable area at (314, 273), in `~/.config/hypr/float-default.lua`. Stage 21 workspace-switch reset is in place.

## 1. Screenshot — it is not right yet
- **Check the screenshot James sent with this stage (image-f577d910.png, workspace 3, 3:42 PM).**
- **The terminal window in front is right:** Ghostty, at the right dimension and location — 1100x619, (314, 273).
- **Behind it is a Helium window. That is obviously not the right dimension or the right location.** It is larger, offset, and sticking out behind Ghostty — not 1100x619, not at (314, 273).
- **That Helium window is the bug to fix in this stage.** It should be the same default size and position as Ghostty / Zen: 1100x619, (314, 273).
- **To be clear: this needs to apply to every application, every window that is opened.** No per-app exceptions. Helium is not special, Ghostty is not special, Zen is not special — every normal app window opens floating at the default, and resets to the default when its workspace switches to floating.

## 2. Why it is still wrong — the older / untagged window gap
- Stage 21's report names this gap explicitly, twice:
  - "Windows opened before today's tag existed and floating on their own account: not reset, because nothing marks them as default-sized. Any window opened from now on is covered."
  - "Untagged older windows: a floating window opened before this stage, by an app with no rule, is not reset; it isn't marked as default-sized. New windows are."
- Stage 21 also found Zen on workspace 3 already moved, at 1100x726, (290, 196) — the stock floating mode's placement — and left it as is, saying the next switch to floating would reset it.
- **That gap is now the work.** A window that was already open / already floating before the tag existed must still be reset when its workspace switches to floating. The tag must not be the only way a window qualifies.
- **Fix, in the workspace-switch reset:**
  - When a workspace switches to floating, reset **every normal app window on that workspace** to the default size and position — 1100x619, (314, 273) — whether or not it carries the `float-default` tag, whether or not it was opened before Stage 21, whether or not it was floated by the default rule or by the app / stock mode.
  - **Every application, every window that is opened — no per-app exceptions.** If the rule currently excludes a class (e.g. Helium / a browser) via `o.floating_apps` or any other list, remove that exclusion for normal app windows. The only windows that may keep their own size are modal dialogs and dialogs / popups Hyprland already floats — and if even those are in doubt, say so in the report, do not silently keep an exclusion.
  - Keep the other exclusions from Stage 18–21: modal dialogs and dialogs / popups Hyprland already floats keep the size their app asks for; apps with their own stock float size (About, calculator) keep theirs; fullscreen is unaffected; windows on other workspaces are untouched.
  - If a tag is still needed to tell a dialog apart from a normal app window, use a dialog / modal check, not the absence of `float-default` as the reason to skip a normal window.
- **Do not just fix Helium once by hand and leave the gap.** The fix must be in the rule / hook, so the next older window on any workspace is reset the same way when its workspace switches to floating.
- **Verify with Helium specifically:** after the fix, switch workspace 3 to floating (or the equivalent that triggers the reset) and measure Helium with `hyprctl clients` — it must be 1100x619 at (314, 273). Also verify Ghostty / Zen on workspace 3 are still at the default, and that a new window still opens at the default.

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
- Helium on workspace 3, measured with `hyprctl clients`: 1100x619 at (314, 273), after a workspace switch to floating.
- Ghostty / Zen on workspace 3: still at the default.
- An older / untagged window on another workspace, switched to floating: reset to the default, with measurements.
- Dialogs, stock float-size apps, fullscreen, other workspaces: unaffected, as in Stage 21.
- Super+T still works as in Stage 18–19, or state the conflict if it does not.
- Mechanism used, and its limits, stated in the report.
- **Backup was taken at build start** — name it in the report.
- `omarchy-shell idle status` after build: `"enabled": true, "stayAwake": false`. Backlight restored.
- Report to `docs/reports/bar-stage-22-report.md`, commit, push, present the commit hash only.
