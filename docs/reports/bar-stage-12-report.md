# Bar Stage 12: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-12-brief.md`. I downloaded the brief from the given URL into `docs/` first and committed it with this report.

These locks are untouched: island height 44, bar 48, SF Compact Display Medium with no bold, text 20 px, `toast.gap` 0, the battery as a number only, C for the calendar leader, the quick strip outside the island, `Super+D` showing hints only, the letters on the outline, `leader.hints`, the sparks, and the width (padding-x 44 / spacing 48).

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261125-133646-bar-stage-12`** (mode 700, 196 files), taken before any edit. It covers the full behaviour set: every `jimmy.*` plugin, `hypr/*.lua`, `shell.json`, `shell.toml`, hooks, theme files, extensions, the Vicinae settings, the paste and backlight helpers, and the systemd unit. Checksums: live before = backup = live after. Excluded: runtime state, because nothing here touches it |
| Reload | `hyprctl reload` for the leader keys (`configerrors` empty), then `omarchy restart shell` once, on its own; never `refresh`, never combined with a summon |
| Debug / temporary code | None. `console.log` = 0 in `jimmy.bar` and `jimmy.shared`. The shell log shows no errors from the bar, `IslandGlow` or `MultiEffect` |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced: `Bar.qml`, `IslandGlow.qml`, `bindings.lua`, `shell.toml`. Live checksums are identical before and after, and the snapshot equals live. No runtime state in git |

## 1. Third island: Wi-Fi, Bluetooth, mic

- **My understanding of the brief:** the two right islands are separate islands joined as **one island divided in two**.
  - **Joint:** the corners that face each other are square (`island.joint-radius` 2), and a 4 px gap separates them (`island.joint-gap`).
  - **Ends:** the outside corners are the full 13.
  - **Glow:** the pair glows as one, so the halo fills the gap between them.
  - **Live:** the gap reads as a thin lit seam between two segments of one island, not two pills floating apart (screenshots).
- **Shape:** the same island as the others: height 44, radius 13, same glass, border and glow. Only the contents are small.
- **Geometry split:**
  - **Main right island:** keeps its centre in the right ear, so nothing that hangs from it moved (the toast, the calendar and other panels).
  - **Status island:** hangs off its right, across the joint.
  - **Room:** the status island is about 75 px wide and well inside the ear's usable edge (18 px corner inset).
- **Staggered status lights:**
  - **Rows and size:** 13 px icons on two rows, even slots up and odd slots down, 6 px from the middle each way (`status.stagger`).
  - **Spacing:** a 15 px step between lights (`status.step`) and 16 px end padding (`status.padding-x`).
  - **Leader letters:** each light's item spans the island's height, so its letter lands on the outline like every other letter.
- **Lights:**

| Light | State → look | Click | Leader |
|---|---|---|---|
| Network | Wi-Fi: signal-strength glyph, quiet · Ethernet: wired glyph · Wi-Fi on but down: urgent · Wi-Fi off: dim | network panel | **N** |
| Bluetooth | off: dim · on: quiet · device connected: accent | Bluetooth panel | **T** (blue**T**ooth; free since the calendar moved to C) |
| Mic | persistent; idle: grey and dim · muted: mic-off glyph · **in use: accent**, lit | mute toggle (the hosted mic widget's own `toggleMute`) | **M** (`omarchy-audio-input-mute`, the same as the mic-mute key) |

- **Data sources:** Quickshell's own `Networking` and `Bluetooth` services, with the same device logic as the stock panels. The Wi-Fi glyph comes from the stock network `Model.js` (`wifiIconFor`). There is no polling.
- **Collision check:** before this round the leader held 1–9, W, C, B, A, Q and Esc. B stays battery, so Bluetooth is **T**. **N, T and M were all free.**
  - **Verified:** `hyprctl binds` now lists the `bar` submap as the nine digits plus A, B, C, Escape, M, N, Q, T and W.
- **The mic moved:** it left the main island and no longer pops in and out there.
  - It sits rightmost in the status island and lights **accent when in use**. The brief said accent; it was urgent red before.
- **Not added:** screen recording and remote session. They stay as they were, in the main island, and only appear while active.
- **Verified live:**
  - **Status:** `omarchy-shell jimmy.bar status` → `status: {net: wifi, bluetooth: on, micMuted: false, micInUse: false}`. That matches the screenshot: Wi-Fi glyph up, Bluetooth down, mic up and grey.
  - **Bluetooth panel:** the T action opened it (`adopted: ["omarchy.bluetooth"]`, screenshot).
  - **Letters:** the leader showed N T M under the three lights, on the outline.
- **Fixed live, twice:**
  - **Spacing:** at a 12 px step, N and T touched, so the step went to 15 px.
  - **Letter dimming:** the dim state of an off light also dimmed its letter (M), so dimming now applies to the glyph only.
- **Note:** hosted panels (network, Bluetooth) still drop from the main island's centre, like every other panel, not from the status island. Say if they should drop from the status island instead.
- **Room for more:** each extra light adds 15 px. The ear has about 130 px spare to the right of the status island, so **about 8 more lights** fit in the staggered grid (audio output, stay awake, night light, silence and so on). None were added.

## 2. Corner radius: 13

`island.radius` 11 → **13**. One token drives all of these, so they changed together:
- the **left island**, **right island** and **status island** (outer corners; the joint stays square);
- **toasts** (`jimmy.osd`);
- **notifications** (`jimmy.notifications`);
- the **reminder card** (`jimmy.reminders`);
- **`PanelShell`**;
- **adopted panels** (`PanelAdopter`).

Verified on the islands, a toast and the Bluetooth panel (screenshots).

## 3. Glow: outside only, glass stays dark

- **The mask:** `IslandGlow` now renders its `RectangularShadow` into a layer and draws it through a `MultiEffect` with an **inverted mask of the surface's own shape**, including per-corner radii.
  - **Result:** the glow exists only outside the outline. The glass is neutral and see-through to the wallpaper again.
- **A joined pair glows as one:** a single glow spans both islands and cuts both out. The gap between them glows, and neither island's halo spills into the other's interior.
- **Applies to:** all three islands, toasts, notifications, the reminder card, `PanelShell` and adopted panels, through the same component.
- **Values unchanged:** alpha 0.32, blur 20. With the inside cut away they read as a halo fading out from the outline, so they needed no retune.
- **Verified live:**
  - **Islands:** dark interiors, with the halo around the left island and around the joined pair.
  - **Cards:** the toast and Bluetooth card are dark inside with the halo outside (screenshots).
- **Off switch unchanged:** `island.glow-alpha = 0`.

## New tokens (`shell.toml`)

| Token | Value |
|---|---|
| `island.radius` | 11 → **13** |
| `island.joint-gap` / `joint-radius` | **4 / 2** |
| `status.icon-size` / `step` / `stagger` / `padding-x` | **13 / 15 / 6 / 16** |

## Still open

- **Real mouse:** clicks on the three status lights and the quick icons (no uinput tool here).
- **Your keys:** leader N / T / M.
- **For your eye:**
  - the joint gap (4 px) and corner (2);
  - the status icon size (13);
  - whether network and Bluetooth panels should drop from the status island.
- **Still pending:** `notch.width` (ruler), the broken `notify-send`, and #12.
