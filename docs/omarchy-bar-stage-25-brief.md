# Omarchy Bar — Stage 25 Build Brief

Status: Build brief. Build from docs/omarchy-bar-refined-brief.md plus this brief.
Purpose: Fix toast centering — a toast centers under the full island it belongs to, not the primary island alone.

## The problem (James, 2026-11-25)

A toast from a message window in another workspace did not center on the right island. It centered under the primary island. The right island is now wider: it encompasses two pieces (the main right island — time, battery, weather — and the joined status island — Wi-Fi, Bluetooth, mic, AI). The toast should center under the full island on the top right side.

## Locked decisions

1. A toast centers under the **full island it belongs to**, measured by that island's full current width (for the right side: main + status joined), not the primary island alone.
2. This is **one rule for all toasts**, whatever their source (message windows in other workspaces, backlight, volume, and so on). Do not fix one toast and leave the same primary-only anchoring elsewhere.
3. A toast still **grows out of the island that owns what it's about** (the earlier rule: if the backlight control lives in an island, its toast grows out of that spot). This fix is about which width it centers under, not about moving toasts to a different island.
4. Verify live with a real toast from a message window in another workspace, plus the backlight / volume toasts if they use the same path.

## Build checklist (standing rules)

- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files, saved per-workspace layouts. Runtime state (clipboard history, pins, recents, pause) stays local, never in git. Checksums live before = backup = live after.
- `hyprctl reload` only. No shell restart unless the change requires it. Never `omarchy refresh shell`.
- Theme-aware (Afterburn default), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/bar-stage-25-report.md, commit, push, hash only.

## Details

- Find where a toast's anchor / center is computed. It currently uses the primary island's geometry. Change it to use the **full island's geometry** (the combined span of the main island + the joined status island, for the right side).
- The right island's width can change, so the centering must use the **live width at the moment the toast appears**, not a hardcoded width.
- Check whether the same primary-only anchoring affects toasts on the left side (under the left island / the exploded name). If the left island is also composed of pieces, apply the same full-width rule. If it is a single piece, say so in the report.
- Check the other toast sources (keyboard backlight, volume, and any others): do they center under their island's full width? Fix any that use the primary-only geometry, same rule.
- Fullscreen: note in the report what toasts do in fullscreen. Don't change fullscreen behavior unless it's broken.
- Verify live: trigger a toast from a message window in another workspace and confirm it centers under the full right island (screenshot). Trigger a backlight / volume toast and confirm it centers under its island's full width.

## Out of scope

- No work on the integration / frame feeling (dropdowns feeling attached, Caelestia-style oneness). James wants to live with the current build a while before deciding that. Do not start it.
- No changes to the strip, the exploded name, the dock, the float default, or Super+L.
- No new toasts, no new toast types.
