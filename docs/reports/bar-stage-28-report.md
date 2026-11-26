# Bar Stage 28: one frame, no pills (2026-11-26)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-28-brief.md`. The brief was downloaded into `docs/` first (6,748 bytes) and is committed with this report.

**Not touched:** the contents, order and x positions of the bar elements; the floating default size (1100 × 619); Super+L; Super+T; the leader keys; the launcher / emoji / clipboard pickers. **No notch disguise, no black top, no element moved to a new home, no new binds, no new specials.**

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261126-110702-bar-stage-28`** — mode **700**, **2,403 files**, **872 MB**, local only, before any edit. Covers every `~/.config/hypr/*.lua`/`.conf`, every `~/.config/omarchy` file (plugins, themes, themed, hooks, extensions, tweaks, defaults, backgrounds, branding, lock-*, matrix-screens, `shell.json`, `shell.toml`), `~/.config/systemd`, `~/.config/vicinae`, `~/.local/bin` and the saved `~/.local/state/omarchy/toggles` + `workspace-layouts`. Checksums: **live before = backup = live after**. Excluded and named: old `*.bak*` config snapshots, runtime state (clipboard history/images/pins, emoji pins/recents, notifications, agents usage, indicators, scratchpad, current/done, generated theme backgrounds, logs), and symlinks (e.g. `superwhisper-panel`, not in the checksum manifest). The new `jimmy.frame` plugin is in the repo snapshot, not the pre-edit backup. No runtime state in git |
| Reload | `hyprctl reload` for Hyprland (monitor reserve 0, float comment). `omarchy restart shell` **twice, each on its own**: the first loaded the new QML and failed the frame on a QML `FINAL` property name (`top`); renamed to `frameTop`; the second loaded cleanly. Never `refresh`, never combined with a summon loop |
| Debug / temporary code | None. `console.log` = 0. The failed frame load was a real code fix, not a temporary hack. Final shell log: no QML errors from `jimmy.frame` or `jimmy.bar` (only the stock ShellIpc warning and the benign `qmlscanner` path warning every local plugin gets). All test windows closed; test notification dismissed; the YouTube window used for the fullscreen check was restored. Focus returned to Orca |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced: `config/hypr/monitors.lua`, `config/hypr/float-default.lua`, `config/omarchy/shell.json`, `config/omarchy/shell.toml`, `plugins/jimmy.bar/{Bar.qml,manifest.json}`, `plugins/jimmy.frame/{Frame.qml,manifest.json}`, `plugins/README.md`. Snapshot equals live; no runtime state in git |

## The frame, live

One hull on a full-screen **Bottom-layer** surface (`jimmy.frame`), drawn with a Canvas: rounded outside, rounded opening cut out, notch cut through the top. It is click-through. The bar and the left numbers are separate Top-layer drawings inside it.

| Geometry | Value |
|---|---|
| Depths | **top 75, left 30, right 15, bottom 15** (`[frame]` tokens, logical px) |
| Outer corners | radius **20** (`frame.radius`) |
| Inner opening | **1683 × 1027 at (30, 75)**, radius **16** (`frame.inner-radius`) |
| Notch | **174 × 32**, centred at x **777–951**, a hole through the top band; the physical cutout is 348 × 64 physical. No outline, no disguise |
| Glass | the old islands' glass: `background` at **0.70** (`launcher.panel-background-alpha`), with a **1px accent edge at 0.16** around the inner opening (`launcher.panel-border-alpha`). Theme-aware; no hardcoded palette. No per-island glow |
| Reserves | **`hyprctl monitors`: `[30, 75, 15, 15]`** — exactly, not a sum |
| Surfaces | `jimmy-frame` (Bottom, `ExclusionMode.Ignore`, full screen, Canvas); `jimmy-frame-top` / `-left` / `-right` / `-bottom` (Bottom, `ExclusionMode.Normal`, 1px, `exclusiveZone` 75 / 30 / 15 / 15, empty mask); `jimmy-bar` and `jimmy-strip` (Top, `Ignore`, no reserve) |

The monitor's own reserve is now **0** (`monitors.lua`), the old `jimmy-bar-reserve` (top 16) and the strip's left reserve (32) are gone. One frame owns all four edges; nothing stacks:

| | Before | After |
|---|---|---|
| `hyprctl monitors` reserved | `[32, 48, 0, 0]` | **`[30, 75, 15, 15]`** |
| Top reserve | monitor 32 + bar reserve 16 | frame **75** |
| Left reserve | strip 2 + 30 | frame **30** |
| Right / bottom | 0 / 0 | frame **15 / 15** |

## No pills; elements on the frame

- **Top rows:** the `Island` component is now a bare `Item` — no glass, no outline, no glow. Its width, centre and padding are unchanged, so every element keeps its old **x position and order**: the window title in the left ear; time, battery %, weather and the contextual lights in the right ear; Wi-Fi, Bluetooth, mic and agents in the status row. Only the vertical position changed: the rows fill the 75px top frame, so their content centres at **y 37.5** instead of 24 — **13.5px down**. The notch stays clear: the left row ends before x 777, the right row starts after x 951.
- **Left numbers:** the strip pill is gone. The workspace numbers are drawn directly on the frame's **30px** left band (x 0–30), vertically centred, active workspace in **accent**, the others quiet. No pill, no slot background. The click handler is the old one, unchanged (`hl.dsp.focus({ workspace = … })`), and its hit region is the number column.
- **Leaders:** Super+D still enters the `bar` submap and the letters land on the new frame's bottom edge: **Q C B W N T M A**, same keys, same order (screenshot).
- **Pop-outs keep their card look:** toasts, the calendar, the status panels and the quick strip are unchanged cards; only their anchors followed `bar.height` 48 → 75.

## Windows refit, floating centre recomputed

Work area: **1683 × 1027** (1728 − 30 − 15 wide, 1117 − 75 − 15 tall). Tiled windows are shorter and narrower; the floating size is untouched at **1100 × 619**.

| Workspace 1 | Before | After |
|---|---|---|
| Orca | (39, 55), 933 × 1055 | **(37, 82), 926 × 1013** |
| Chat — Max | (988, 55), 733 × 1055 | **(979, 82), 727 × 1013** |
| Split gap | 972–988 (centre 980) | 963–979 (centre 971) |

Both are still tiled at the same height. The gap centre moved 9px left because the work area shrank 13px (right 15, left 2 less than the old 32); the scrolling columns kept the **same relative split** (0.564 of the work area) and each is narrower (7px / 6px). The old “split x 980” is now 971 in absolute pixels, the same place relative to the frame.

**Floating default:** computed `(30 + (1683 − 1100)/2, 75 + (1027 − 619)/2)` = **(321.5, 279)**; Hyprland measured **1100 × 619 at (322, 279)**. Verified with a fresh Ghostty and by tiling a window and moving it to the floating workspace 3: it returned floating at **1100 × 619, (322, 279)**.

## Verified live

| Check | Result |
|---|---|
| Frame geometry / reserves | **`hyprctl monitors` = `[30, 75, 15, 15]`**; the four frame reserve layers + hull are present; no bar/strip reserve layer |
| Top elements | same x and order (screenshot); moved 13.5px down; no pills |
| Left numbers | 1 / 2 / 3 directly on the 30px band, vertically centred, active accent, no pill or background (screenshot); click handler unchanged |
| Leader | Super+D shows Q C B W N T M A on the frame's bottom edge (screenshot); keys and submap untouched |
| Windows (ws 1) | Orca 926 × 1013 at (37, 82), Chat 727 × 1013 at (979, 82), both tiled, same height; split proportion kept |
| Floating default | 1100 × 619 at **(322, 279)**; workspace switch to floating resets a tiled window there |
| Toast | `Frame toast check` centred under the right row, top edge just below the 75px frame (screenshot); card look kept |
| Calendar | drops from the time, below the frame (screenshot) |
| Network panel | drops from the Wi-Fi status light, below the frame (screenshot) |
| Quick strip | slides out left of the time at the new centre (screenshot) |
| Fullscreen | the YouTube window filled **1728 × 1117 at (0, 0)**, fullscreen 2 — frame, bar and numbers gone (screenshot); restored to its 1100 × 619 float at (307, 250) |
| Notch | a clean black cutout through the 75px top band, 174 × 32, centred; subtle against the dark glass, no disguise, no black top, no workaround (crop) |
| Health | `hyprctl configerrors` empty; no QML errors from the new frame or bar; no debug code; test windows closed; focus Orca |

## Files changed

- `~/.config/hypr/monitors.lua` — monitor reserve 0; the frame owns all four edges.
- `~/.config/hypr/float-default.lua` — comment updated to the new centre; size and behaviour unchanged.
- `~/.config/omarchy/shell.toml` — `[frame]` block (depths, radii); `[bar] height` 48 → 75; removed the now-unused `[strip]` block and `island.joint-radius`.
- `~/.config/omarchy/shell.json` — `jimmy.frame` enabled.
- `~/.config/omarchy/plugins/jimmy.frame/{manifest.json,Frame.qml}` — new frame service: hull Canvas + four reserve surfaces.
- `~/.config/omarchy/plugins/jimmy.bar/{Bar.qml,manifest.json}` — pills removed; top rows on the frame; left numbers on the 30px band; bar/strip reserves removed; `bar.height` 75.
- `plugins/README.md`, and the repo snapshots of the files above.
- `docs/omarchy-bar-stage-28-brief.md`, `docs/reports/bar-stage-28-report.md`.

## Still open / for your eye

- **Frame radii and edge:** outer **20**, inner **16**, and one **1px** accent edge around the opening are live-judgment values — the brief did not fix them. The edge is the hull boundary, not the old 2px underline; if it reads as a line, it can go or thin.
- **Accent glass:** the fill is the same dark glass as the old islands (background 0.70), with the accent only in the 1px edge. It is not an orange-tinted fill and the top is not black. If you want more accent in the glass, that is a colour decision, not done here.
- **Notch:** it reads as a clean black cutout, subtle against the dark glass. No disguise; that decision waits.
- **Split:** workspace 1's split is at 971 absolute (980 before) because the work area is 13px narrower; the columns keep the same relative split.
- **Cards:** toasts/panels hang from the frame's bottom (window top 73, visible card ~80), 2px above the frame edge, while the elements sit at 37.5. If you want them tucked closer to the elements, that is a token/anchor adjustment.
- **Left number click:** the handler is the Stage 26 one, unchanged; it was not synthetic-clicked in this build (no synthetic pointer), so the mouse path is code-verified, while the leader/keyboard path was exercised live.
- The other “messed up” items mentioned earlier were not part of this frame stage and were not changed.
