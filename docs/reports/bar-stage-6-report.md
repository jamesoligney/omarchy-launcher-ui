# Bar Stage 6: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-6-brief.md`. I downloaded the brief from the given URL into `docs/` first and committed it with this report.

These locks are untouched: island height 38, radius 9, bar height 44, island text 16px, SF Compact Display Medium with no bold, and the toast attachment (`toast.gap` 0). Only `island.padding-x` and `island.spacing` changed (§5).

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261125-122546-bar-stage-6`** (mode 700, 78 files). Taken before any edit, after an audit of everything that determines the bar's behaviour (the `jimmy.*` plugins, `hypr/*.lua`, `shell.json`, `shell.toml`, hooks, theme files, the backlight helper and unit). Checksums were verified before and after, and the backup equals live |
| Reload | `omarchy restart shell` run twice, each time on its own. Never `refresh`, never combined with a summon. `hyprctl reload` for the binds: `configerrors` is empty |
| Debug / temporary code | No temporary hooks this round. `console.log` = 0 in `jimmy.bar` and `jimmy.osd`. The one remaining match, in `jimmy.idle/Service.qml:56`, is that plugin's existing idle-event log from an earlier stage, not build debug |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | 194 live files checked; 4 changed and resynced (`Bar.qml`, `Osd.qml`, `bindings.lua`, `shell.toml`). Live checksums are identical before and after, and the snapshot equals live. A stray local `Menu.qml.bak.3b-anim` was left out of git (it is an old backup copy, not live code). No runtime state in git |

## 1. Battery: the number only

- **Removed:** the pill, fill, outline, shimmer animation, the root `shimmerColor`, and the tokens `battery.shimmer-ms`, `battery.bar-width` and `battery.bar-height`.
- **Now:** a plain `79%` in SF Compact Display Medium with tabular figures. It is the same `Label` as the rest of the island, so it has the same weight and size. There is no plus/minus and no bar.
- **Colour:**
  - **Plugged in:** accent. This is `!UPower.onBattery`, so it also covers a battery held at its charge limit.
  - **On battery:** neutral (the quiet foreground).
  - **≤ 20 %:** amber.
  - **≤ 10 %:** red (theme `urgent`).
- **Amber:** the theme has no amber role; its roles are foreground, background, accent, urgent and muted. Amber is therefore derived: the accent mixed toward `urgent` by `battery.low-mix` (0.45, new token). It follows any theme and reads apart from the plugged-in accent.
- **Verified live:** plugged in at 79 % gives an accent number (screenshot; `status.battery: {percent: 79, charging: true, pluggedIn: true}`). I could not test amber and red: the machine stayed plugged in. They are two lines in one colour binding.

## 2. Quick toggles: back to icons to the left

- **Removed:** the dropdown card. This removes both of its bugs at the root: the last item can no longer close it, and there is no card left to overlap the calendar.
- **Now:** the strip lives inside the right island, left of the time.
  - **Order:** reminder, night light (Locus), silence, stay awake. Stay awake is nearest the time.
  - **Icons only:** grey (quiet, 45 %) when off, accent when on.
  - **Click:** toggles stay awake or silence. Reminder and night light are actions: reminder opens the reminder summon, night light opens the Locus panel.
  - **Lit items stay in the bar** after the strip closes. Stay awake, while on, sits lit left of the time until clicked off or turned off by its keybind. Silence does the same.
- **Hover:** one hover zone covers the strip and the time together, so moving from the time onto an icon never leaves it.
  - It opens after 180 ms on the time.
  - It closes 300 ms after the pointer leaves the zone.
- **Q:** `Super+Ctrl+Q`, or `Super+D` then `Q`, opens the same strip with keyboard focus on the bar layer.
  - Focus starts on stay awake.
  - Left/Right move, Enter toggles, Esc closes; Q again also closes.
- **Calendar:** the calendar panel drops below the island and the strip is inside the island, so they cannot collide.
- **Verified live:**
  - **Q:** `status.quick` showed `{open: true, keyboard: true, index: 3}`. A `Left` key moved it to index 2, and `Escape` closed it (`open: false`). Screenshot: the strip had grey icons, stay awake lit, and a focus ring.
  - **Calendar:** I opened it while the strip was open (screenshot). The calendar sits under the island and the strip stays in the island, with no overlap.
- **Not testable here: a real hand on the pointer.** Hover and clicks need your mouse. There is no uinput tool here, and warped pointer motion no longer delivers hover events (see Stage 5). The hover zone is a single `HoverHandler` on one item, so there is no gap to cross by construction.

## 3. Leader hints: badges over the thing

- **Old:** letters pinned to the island's corner, plus outlines on the workspace numbers.
- **New:** a small translucent accent badge (accent at 62 %, 15 px tall, radius 4, letter in the theme background) **centred over** each element:
  - each workspace number shows its digit;
  - **Q** on stay awake (the strip's anchor), **C** on the time, **W** on weather, **B** on the battery number, **A** on the AI mark.
- **While the leader is active,** the strip also shows its icons, so Q's target is visible.
- **Badges exist only while** `submap == "bar"`. They go as soon as the leader exits (Esc or one key).
- **Verified live:**
  - `hl.dsp.submap("bar")` turned the badges on (`status.leader: true`, screenshot), with every badge centred on its element.
  - Reset turned them off (`leader: false`) and the island collapsed back (screenshot).
- **First pass, fixed live:** Q sat between two strip icons and the badges were too opaque over the numbers. Q now sits on stay awake, and the badges are lighter and smaller.

## 4. Calendar leader: T is now C

- **Collision check first.** The `bar` submap held `code:10`–`code:18` (1–9), `W`, `T`, `B`, `A`, `Q` and `Escape`. **C was free in the leader submap.**
- **Change:** `T` → `C` in the `bar-leader` block of `bindings.lua`.
- **Verified:** after `hyprctl reload`, `hyprctl binds` lists the `bar` submap as A, B, **C**, Escape, Q, W and the nine digits. There is no T. `configerrors` is empty.
- **No direct `Super+letter` binds were added,** as instructed.

## 5. Islands: wider and airier

| Token | Was | Now |
|---|---|---|
| `island.padding-x` | 10 | 16 |
| `island.spacing` | 12 | 18 |
| `battery.low-mix` | — | 0.45 (new, amber) |
| `toast.padding-x` | — | 10 (new, see below) |
| `battery.bar-width`, `bar-height`, `shimmer-ms` | 52, 22, 7000 | removed |

- **Unchanged:** height, radius and bar height. The islands are still centred in their ears and grow symmetrically: the `Island` component centres on the ear and only its width changes.
- **Rest of the UI.** `island.padding-x` was also the padding of the **toasts** (`jimmy.osd`). Toasts are out of scope, so they now read their own `toast.padding-x` = 10. They look exactly as before.
- **Still on the island token:** `PanelShell` (shared). With the quick dropdown gone, `PanelShell` has no users today. I kept it as the shared shell for future island panels.

## Still open

- **Real mouse:** hover over the time and slide onto the icons; click each icon.
- **Battery colours:** amber and red only show off the charger at ≤ 20 % and ≤ 10 %.
- **For your eye:** badge opacity (0.62) and the amber mix (0.45). Each is one value.
- **Still pending:** `notch.width` (ruler), the broken `notify-send` (libnotify symbol error), and #12 (OpenCode/Grok status push). The AI mark is still red, truthfully, because OpenCode's monthly limit is at 100 %.
