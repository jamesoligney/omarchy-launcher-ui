# Top Bar v6 Brief — Workspaces Under the Notch

Status: Build brief. James said go, 2026-11-27.
Build from docs/omarchy-bar-refined-brief.md plus this brief.

## What changes

### 1. Workspaces move under the notch

- The workspaces (workspace chips / numbers) move out of the left island's top level and into the space **below the notch** — the band under the 32px notch cut-out, inside the 75px top bar.
- James, 2026-11-27: "I found the perfect thing for the space below the notch — workspaces."
- That band is part of the same bar surface, clickable, with leader keys, panels if needed — it was already assured functional, not cosmetic. Do not re-ask whether it can be functional.
- Workspaces must be centred under the notch, visible, and usable: click a workspace to go to it, leader keys still work, current workspace is clear.
- Do not put anything else under the notch in this stage. Just workspaces.

### 2. Left island: both levels left-justified

- **Top level: focused window title only, left-justified.** Workspaces are no longer up there. Title stays as it is otherwise.
- **Bottom level: the secondary tray-ish programs row, left-justified.** Previously this row was right-justified against the notch. Now it is left-justified, in the same left island.
- So the left island is now: title at top, left-justified; icon row below, left-justified. Both levels share the same left edge (30px padding, as now).
- The icon row itself is unchanged in content and order for now: Locus, audio, Superwhisper, Omapop, FX, scratchpad, matrixscreens, monitor, tricky-tiles, jimmy.menu, then Wi-Fi / Bluetooth / mic / agents status lights. Do not trim, reorder, or remove anything in this stage. Do not touch `jimmy.menu`'s layout entry.
- Right island is untouched: time / battery / weather, 26/28px, centred in the right ear.

### 3. Geometry to confirm live

- Bar stays 75px deep, reserves `[0, 75, 0, 0]`, windows start y 82, tint 0.22, notch cut-out 174×32.
- Left island: 30px padding both sides. Top level ink centre ~20, bottom level ink centre ~54 (as v1–v5).
- Workspaces under the notch: centred in the notch width, ink centre in the band below the notch (y ~54), fitting in the 174px notch width or spreading a little either side only if needed — report the actual width and where it sits.
- If the workspaces row is wider than the notch, say so and show the actual measurement — do not silently shrink the chips or move them elsewhere. James to judge by eye.

## Later list — do NOT build now

These are James's later items. Record them in the report as "later", do not build them in this stage.

1. **Emoji picker: default to last item chosen.** When the emoji picker comes up, it should default to the last item chosen. (James, 2026-11-27: "when that emoji picker comes up, I need it to default to the last item chosen.")
2. **Emoji picker keybind — check what we have.** James asked: "didn't we have a keybind for that emoji picker?" Answer in the report: our `jimmy.emojis` picker is Super+Ctrl+E, `jimmy.clipboard` is Super+Ctrl+V. Oma-cast also brings up emoji when he hits emojis — note which picker that is, what key opens it, and whether the "default to last item" item applies to `jimmy.emojis`, oma-cast's emoji, or both. Do not change any emoji keybind in this stage.

## Build checklist (standing rules)

- **Minimum testing only.** Open once, type once / click once, Esc once, stop. No automated test loops, no dozens of rounds, no `wtype` driving the desktop, no launching apps unattended. This is a standing rule from 2026-11-27 (oma-cast trial — James had to stop extensive testing).
- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `jimmy.*` plugin, shell.json / shell.toml, theme files. Runtime state stays local, never in git.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- `hyprctl reload` only. No shell restart unless the change requires it, and then on its own, never combined with a summon loop.
- Theme-aware (Afterburn Redline live, verify on Afterburn default, then restore Redline), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/bar-topbar-v6-report.md, commit, push, hash only.

## Details

- Audit first: read live `jimmy.bar` / `Bar.qml`, `shell.json` layout, and the current workspaces implementation (where the chips live now, how they are rendered, how they are clicked / leader-keyed). State in the report where the workspaces code moved from and to.
- Do not change the float default (1100×619, centre (314, 286)), Super+L / Super+T, leader Super+D, Super+Space (oma-cast), Alt+Space (Vicinae), or the emoji / clipboard pickers.
- Do not trim the bottom row. Do not remove `jimmy.menu`, `omarchy.tray` stays removed, do not re-add the tray.
- Verify live: title top-left, icon row bottom-left, workspaces centred under the notch, click a workspace and it switches, leader keys still work, bar 75px, reserves `[0, 75, 0, 0]`, no QML errors, theme Redline then Afterburn then Redline back.
- Report: what moved, actual widths / positions (left island ink x, workspaces ink x and y, how wide the workspaces row is vs the 174px notch), what was tested (once each), and the later list above, verbatim.

## Out of scope

- Do not build the emoji "default to last item" change.
- Do not change emoji / clipboard keybinds.
- Do not trim, reorder, or remove bottom-row icons.
- Do not change the right island.
- No frame, no hull, no bevel, no molding, no hard line.
