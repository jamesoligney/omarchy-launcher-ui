# Float Inheritance Brief — New Windows Follow the Workspace Mode

Status: Build brief. James said go, 2026-11-27.
Build from docs/omarchy-bar-refined-brief.md plus this brief.

## The change (James, 2026-11-27)

Right now every new normal window opens floating at 1100×619, centred, no matter what mode the workspace is in. That was Stage 19 — floating is the global default.

That is no longer what James wants. The new rule is **inheritance**:

> A workspace always starts in floating. Once a workspace is changed to tiling or scrolling, new windows should open with whatever the workspace has been set to.

In full:
1. **A fresh workspace starts in floating.** First window in a fresh workspace opens floating, centred, 1100×619, as now. This part stays.
2. **New windows inherit the workspace's current mode.** Open a window in a tiled workspace, it tiles. Open one in a scrolling workspace, it scrolls. Open one in a floating workspace, it floats centred at 1100×619.
3. **Switching the workspace back to floating restores the old behaviour** for new windows in that workspace: they float centred again.
4. **Moving a window into a workspace:** it inherits that workspace's mode on arrival — tiles if the workspace is tiled, scrolls if scrolling, floats centred if floating. Do not leave it floating in a tiled workspace.
5. **Opening a window in a floating workspace that already has windows:** still centred 1100×619, same as now.

James confirmed, 2026-11-27: "Yes, inheritance. They should inherit whatever the workspace has on it."

## What this unwinds

This is a behaviour change to the float-default rules from Stages 18–23 and Stage 27, not just a new rule on top. Claude must audit and unwind the "always float" parts:

- Stage 18: `o.float_default = { width = 1100, height = 619 }` in `~/.config/hypr/float-default.lua`, Omarchy floating-window tag rule, Super+T toggle with remembered size/place.
- Stage 19: floating is the default — every new normal window floats, via global rule + floating-mode hook, not Omarchy floating mode.
- Stage 20: size measured from Zen, 1100×619 at (314, 273) — later recomputed (314, 286) under the 75px top bar. Keep the size and centre for floating workspaces.
- Stage 21: workspace switch to floating (Super+L) resets its windows to default every time.
- Stage 22: every route into floating resets (switch, open, move-in, leave-fullscreen), no tag requirement, dialogs classified at open as `self-floated`.
- Stage 23: open path finishes 30ms later, floats a still-tiled normal app window and sets default, on any workspace, special workspaces (id < 1) skipped. Helium fix — do not re-break Helium. **Clarified 2026-11-27 by James: inheritance applies to ANY window, including Helium. Helium in a tiled workspace must tile, in a scrolling workspace must scroll, in a fresh / floating workspace must float centred at 1100×619. The Helium fix's forced-float part is exactly what inheritance unwinds for tiled / scrolling workspaces — the Helium-specific open hook must become mode-aware too, not bypass inheritance.**
- Stage 27: float default exempts special workspaces as a class (`workspace = "s[false]"`); quake, scratchpad, screen-share, PiP exemptions stay. Do not touch them.

Audit first: read live `float-default.lua`, `monitors.lua`, `bindings.lua`, and the workspace-mode code, and state in the report exactly which rules / hooks forced "always float" and what each one now does under inheritance. The floating default must still apply in floating workspaces, and must not apply in tiled / scrolling workspaces.

## Build checklist (standing rules)

- **Minimum testing only.** Open once, type once / click once, Esc once, stop. No automated test loops, no dozens of rounds, no `wtype` driving the desktop, no launching apps unattended. Standing rule from 2026-11-27 (oma-cast trial).
- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files. Runtime state stays local, never in git.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- `hyprctl reload` only. No shell restart unless the change requires it, and then on its own, never combined with a summon loop.
- Theme-aware, no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/float-inheritance-report.md, commit, push, hash only.

## Details

- Super+L still cycles tiling → scrolling → floating per workspace. Super+T still tiles / floats back at remembered size/place for the focused window — say in the report how Super+T interacts with inheritance (a Super+T-floated window in a tiled workspace stays floated until what?).
- Super+O (float a window and pin it across workspaces) is unchanged.
- Dialogs: keep the Stage 22 `self-floated` classification — dialogs keep their own size, do not inherit tiling.
- Special windows stay exempt (Stage 27): quake, scratchpad, screensaver, screen share, PiP. Do not touch them.
- Do not change the float size (1100×619) or centre (314, 286) for floating workspaces. Do not change the bar (75px, reserves `[0, 75, 0, 0]`), Super+Space (oma-cast), Alt+Space (Vicinae), leader Super+D, or the top bar layout.
- Verify live, once each: fresh workspace, first window floats centred; switch that workspace to tiling, open a new window, it tiles; switch to scrolling, open a new window, it scrolls; switch back to floating, open a new window, it floats centred; move a window into a tiled workspace, it tiles. No QML errors.
- Report: what was unwound (file / rule / hook, before and after), what inheritance means for each route (open, move-in, switch, leave-fullscreen), Super+T interaction, and the live test results, once each.

## Out of scope

- Do not change the float size, centre, bar, top bar layout, workspaces-under-the-notch (Top Bar v6, separate brief), or the emoji picker.
- Do not change Super+L, Super+T, Super+O, or the leader keys.
- Do not touch special windows (Stage 27).
- No frame, no hull, no bevel, no molding, no hard line.
