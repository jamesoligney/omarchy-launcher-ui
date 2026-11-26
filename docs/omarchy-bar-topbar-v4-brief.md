# Omarchy Bar — Top Bar v4 Build Brief

Status: Build brief. Build from docs/omarchy-bar-refined-brief.md plus this brief.
Purpose: Pull the tray icons out, push the second level back to the left where it belongs, and see where we are. Do not keep it under the notch.

## The problem (James, 2026-11-26)

Top Bar v3 is live: second level tightened, moved under the notch, Omapop icon fixed, arrow explained as the tray drawer chevron.

James:
- "Pull the tray icons out. We don't need a tray right now. We need to see everything that we have."
- "And then I do not want it underneath the notch. I just wanted you to pull it over if we needed more space. We do not, so push it back over to the left where it belongs in its island, and then we'll see where we are."

## Locked decisions

1. **Pull the tray icons out.** Remove `omarchy.tray` from the bar — the drawer chevron / arrow at the end, and the tray apps it holds (Vicinae, Superwhisper, LocalSend). We do not need a tray right now. Do not pin the tray apps instead, do not keep the chevron — remove the tray entirely from the bar in this stage.
2. **Push the second level back to the left.** Move the second level — everything that is left after the tray is pulled out — back from under the notch to the left island, bottom row, right-justified with 30px padding, as in Top Bar v2. It belongs in its island on the left. It does not live under the notch.
3. **Band under the notch is empty again.** With the second level moved back left, the band below the notch (y 32–75, centred) is empty bar fill again, as in v1 / v2. No elements there in this stage. Do not put anything else there.
4. **Keep the v3 tightening and the Omapop fix.** Spacing stays tightened (`band.spacing` / `band.widget-spacing` as in v3, or the equivalent in the left island), Omapop icon stays visible — do not reintroduce the weird spaces, and do not break the Omapop icon fix.
5. **Left island is two levels again.** Top level: workspaces + focused title, left-justified, 30px padding. Bottom level: everything secondary (after the tray is pulled out), right-justified, 30px padding. Right island untouched, quick tiles untouched.
6. **No geometry change.** Bar stays 75px deep, reserves `[0, 75, 0, 0]`, windows start y 82, float default 1100×619 centred at (314, 286). Tint stays `bar.tint = 0.22`.

## Build checklist (standing rules)

- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files, saved per-workspace layouts. Runtime state (clipboard history, pins, recents, pause) stays local, never in git. Checksums live before = backup = live after.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- `hyprctl reload` only. No shell restart unless the change requires it, and then on its own, never combined with a summon loop.
- Theme-aware (Afterburn default), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/bar-topbar-v4-report.md, commit, push, hash only.

## Details

- Audit first: read live `jimmy.bar/Bar.qml` (v3) and list the inventory under the notch, and identify exactly what is tray (`omarchy.tray`, chevron, Vicinae / Superwhisper / LocalSend tray apps). Remove only the tray — do not remove Superwhisper's own bar widget (`superwhisper.panel`) or Vicinae's launcher, unless they are tray-only, in which case say so.
- Move the remaining second level back to the left island bottom row. Report the new width / room in the left ear, and whether everything fits after the tray is pulled out.
- Leader keys: Super+D letters must still sit on their elements in the left island. Verify they are legible and not clipping.
- Panels: status-light / tray panels must drop from the bottom row elements in the left island. Calendar still drops from the right ear.
- Verify live: tray / chevron gone, second level back left, bottom row tight, Omapop icon visible, left island 30px padding both sides, right island unchanged, band under the notch empty, notch is a clean cut-out, bar is 75px, desktop untinted, reserves `[0, 75, 0, 0]`, float default still (314, 286), Super+L / Super+T / leader still work, fullscreen hides the bar cleanly.
- Current theme is Afterburn Redline. Verify on Afterburn default as well, then put Redline back. Report both.
- Report: what was pulled out (tray inventory), what is left in the bottom row (full inventory), what fits / what does not, and what James should trim first — the easy first edit, now that we can see everything we have.

## Out of scope for v4

- No trimming beyond pulling the tray out — see everything we have, trim next.
- No keeping anything under the notch, no valley, no band holding elements.
- No frame, no hull, no bevel, no molding, no hard line.
- No changing the right island, no changing the quick tiles.
- No new elements beyond what we already have.
- No drawer, no agent mission control, no dock remake.
- No changes to the launcher / emoji / clipboard pickers, except that they must still work with the new bar.
