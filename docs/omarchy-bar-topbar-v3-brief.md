# Omarchy Bar — Top Bar v3 Build Brief

Status: Build brief. Build from docs/omarchy-bar-refined-brief.md plus this brief.
Purpose: Tighten the second level, give Omapop an icon, and pull the second level to the right so it lives below the notch. The space under the notch is functional — Max already assured James of that — so use it.

## The problem (James, 2026-11-26)

Top Bar v2 is live: left island with 30px padding, two levels, everything in the bottom row, right island untouched.

James, live:
- "There's a bunch of weird spaces up there. Can we, first of all, reduce the space between the icons on that second level? And also, can we find an icon for Omapop? And then just tighten it all up so that we can actually fit it on there and see what's up there."
- "I see there's an arrow at the very end. I don't know where that's going to or what's happening."
- "This begs the question, though, can we actually use the space under the notch? If so, you want to just pull that second level to the right so it lives below the notch for now."
- Max already assured James that space under the notch is functional. Use it. Do not re-ask whether it can be functional.

## Locked decisions

1. **Tighten the second level.** Reduce the space between the icons on the second level, and tighten the whole row up — spacing, padding, gaps — so everything actually fits in one row and James can see what is up there. Report the old spacing and the new spacing.
2. **Find an icon for Omapop.** Omapop is in the second level but has no / wrong icon. Give it a real icon, in the same style as the other tray / status icons, theme-aware. If no suitable stock icon exists, draw / pick one and say what it is in the report.
3. **Pull the second level to the right so it lives below the notch.** Move the entire second level — Wi-Fi, Bluetooth, mic, agents, tray, Omapop, everything in it — from the left ear to the band below the notch (y 32–75, centred under the 174×32 cut-out). It lives there for now. The band is functional: clickable elements, panels drop from it, leader keys work on it, just as they did in the left ear.
4. **Left island is now top level only.** With the second level moved out, the left island is just workspaces + focused title, in one row, left-justified with 30px padding. Do not add anything else to the left in this stage.
5. **The arrow at the very end.** Investigate what that arrow is — overflow / "more" indicator, submenu, or something else. Report what it opens / where it goes. If tightening the row makes everything fit, the arrow should go away — if it does not, say why it is still there and what it does. Do not leave an unexplained arrow in the bar.
6. **Right island untouched, quick tiles untouched.** Do not change time / battery / weather, do not move the quick tiles.
7. **No geometry change.** Bar stays 75px deep, reserves `[0, 75, 0, 0]`, windows start y 82, float default 1100×619 centred at (314, 286). Tint stays `bar.tint = 0.22`.

## Build checklist (standing rules)

- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files, saved per-workspace layouts. Runtime state (clipboard history, pins, recents, pause) stays local, never in git. Checksums live before = backup = live after.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- `hyprctl reload` only. No shell restart unless the change requires it, and then on its own, never combined with a summon loop.
- Theme-aware (Afterburn default), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/bar-topbar-v3-report.md, commit, push, hash only.

## Details

- Audit first: read live `jimmy.bar/Bar.qml` (v2) and list the second-level inventory, its spacing, and what the arrow at the end is. State exactly what changes: new spacing, Omapop icon source, and the move to the band below the notch.
- If the second level does not fit in the band below the notch after tightening, say so in the report — do not shrink icons to fit unasked, do not drop items silently. Report what fits, what does not, and what would need to be trimmed first. That is the easy first edit.
- Leader keys: Super+D letters must still sit on their elements in the new home under the notch. Verify they are legible and not clipping.
- Panels: status-light / tray panels must drop from the elements under the notch. Calendar still drops from the right ear.
- Verify live: second level is under the notch, tight, all icons visible including Omapop, no unexplained arrow, left is one row, right island unchanged, notch is a clean cut-out above the second level, bar is 75px, desktop untinted, reserves `[0, 75, 0, 0]`, float default still (314, 286), Super+L / Super+T / leader still work, fullscreen hides the bar cleanly.
- Current theme is Afterburn Redline. Verify on Afterburn default as well, then put Redline back. Report both.
- Report: old vs new spacing, Omapop icon, what the arrow was, the full inventory under the notch, what fits / what does not, and what James should trim first.

## Out of scope for v3

- No trimming in this stage beyond what is needed to fit — see it first, trim next.
- No frame, no hull, no bevel, no molding, no hard line.
- No changing the right island, no changing the quick tiles.
- No new elements beyond what we already have (just surface the hidden ones, and give Omapop its icon).
- No drawer, no agent mission control, no dock remake.
- No changes to the launcher / emoji / clipboard pickers, except that they must still work with the new bar.
