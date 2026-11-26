# Omarchy Bar — Stage 28 Build Brief

Status: Build brief. Build from docs/omarchy-bar-refined-brief.md plus this brief.
Purpose: Build the frame — one unified rounded shell around the desktop — and lose all the pills. Leave every bar element where it is, just fit the frame in around them.

## The problem (James, 2026-11-26)

The bar has drifted back toward a full bar, piece by piece. The Caelestia direction is a frame, not a bar: one shell around the desktop, everything living inside it. The diagram (v5, `workspace/omarchy-shell-frame-diagram.html`) is right: one unified rounded frame, accent glass, top 75px, left 30px, right 15px, bottom 15px, notch shown cutting through the top.

Research verdict (2026-11-26, sources in chat): per-segment top reserve is **not** possible in Hyprland 0.56 — usable area is a single rectangle, top reserve is a single scalar. So the top is uniform 75px, no step, no split. The split at x 980 (Workspace 1: Orca 933 / Muse 733, 16px gap) is dropped — it was only for the deeper frame area.

## Locked decisions

1. **One unified frame, no pills.** Lose *all* the pills — top islands and left strip pill. Elements live directly on the frame, no island glass / outline / glow per island. The frame itself is the background.
   - Top: time, battery %, weather, and the status lights (Wi-Fi, Bluetooth, mic, AI) sit directly on the 75px top frame, same x positions, same order as now.
   - Left: workspace numbers sit directly on the 30px left frame, vertically centred, no pill behind them. The left pill is gone.
   - Toasts, panels, pop-outs and picker cards keep their own card look — they are pop-outs, not bar pills. Only the bar pills go.
2. **Frame depths (uniform top):** top **75px**, left **30px**, right **15px**, bottom **15px**. One hull, outer corners rounded, inner opening corners rounded. Accent glass, theme-aware, same accent as now. No black top yet — unified colour until we see how the notch looks live. No 2px underline under the top — that line made it look segmented.
3. **Notch:** shown in the diagram cutting through the top frame, 174px wide (provisional, unmeasured) × 32px tall, centred. Do not try to disguise it in this stage — see how it reads against accent glass live, disguise is a later decision.
4. **Frame owns the reserves.** One full-screen Bottom-layer surface with a rounded opening cut out, four single-value exclusive zones: top 75, left 30, right 15, bottom 15. That is the Caelestia mechanism — one hull, four zones, `gaps_out` measured from the opening. Bar surfaces stop reserving space; they become drawings inside the frame (`ExclusionMode.Ignore` / exclusiveZone 0). Do not let two reserves stack — frame owns it, bar owns none.
5. **Elements stay put, otherwise.** Same contents, same order, same x positions as now. Only vertical position changes: top elements re-centre in the 75px top zone (about 13px down from the 48px zone). Left numbers stay vertically centred in the left frame.
6. **Windows refit, unavoidably.** Top reserve 48 → 75, right reserve 0 → 15, bottom reserve 0 → 15. Tiled windows get shorter and narrower; floating default centre moves from (330, 273) — recompute it from the new usable area (1728 − 30 − 15 wide, 1117 − 75 − 15 tall) and report the new centre. Do not change the floating default size (1100 × 619).

## Build checklist (standing rules)

- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files, saved per-workspace layouts. Runtime state (clipboard history, pins, recents, pause) stays local, never in git. Checksums live before = backup = live after.
- Build start: `omarchy-kbd-backlight hold` + `omarchy toggle idle stay-awake`. Build end: `omarchy toggle idle allow-idle` + backlight release + confirm `omarchy-shell idle status` shows `"enabled": true, "stayAwake": false`. Never use bare `omarchy toggle idle` to check state. Never `omarchy refresh shell`.
- `hyprctl reload` only. No shell restart unless the change requires it, and then on its own, never combined with a summon loop.
- Theme-aware (Afterburn default), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/bar-stage-28-report.md, commit, push, hash only.

## Details

- Build the frame first, as its own surface (`jimmy.frame` or similar), before moving any element. Report its geometry live: outer corners, inner opening, depths, and `hyprctl monitors` reserved — expect `[30, 75, 15, 15]`.
- Move the reserves to the frame: remove the bar's top reserve and the left strip's reserve, so they do not stack with the frame's. Verify reserved is exactly `[30, 75, 15, 15]`, not a sum.
- Top elements: same order, same x, re-centred vertically in 75px. Status lights (Wi-Fi N, Bluetooth T, mic M, AI A) keep their leaders, clicks, and colours (AI plain half-white, mic accent when in use). Battery keeps its number-only, accent-when-plugged, sparks. Clock keeps `h:mm AP`, 18px text / 20px glyphs.
- Left numbers: directly on the left frame, vertically centred, active workspace accent, others quiet, click switches, Super+D 1–9 unchanged. No pill, no background behind the numbers.
- Fullscreen: frame hides cleanly, same as the bar did. Verify a fullscreen YouTube window is absolutely fullscreen.
- Toasts / panels / quick strip: they anchor to the islands — if the islands move down ~13px, anchors move with them. Verify a toast centres under the whole right island area, a calendar drops from the time, and network/Bluetooth/mic/agents panels drop from the status lights.
- Floating default: recompute centre from new usable area, verify a fresh Ghostty and a fresh Helium open at 1100 × 619 at the new centre, and a workspace switch to floating still resets windows to default.
- Verify live with Workspace 1 (Orca + Chat — Max, split x 980): both tiled, same height, split in the same place, just shorter/narrower inside the frame.
- Notch: report how it reads against accent glass in a screenshot. Do not disguise it, do not blacken the top, do not add a workaround in this stage.

## Out of scope

- No moving any element to a new home — no drawer, no tray area, no right-side frame contents, no agent side panel. Elements stay where they are, on the frame.
- No notch disguise, no black top, no colour change to the frame.
- No changes to the float default size, Super+L, Super+T, leader keys, or the launcher / emoji / clipboard pickers.
- No frame / integration feeling work beyond the frame itself — dropdowns feeling attached is a live-with-it item, not this stage.
