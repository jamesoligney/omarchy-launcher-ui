# Bar Stage 11: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-11-brief.md`. I downloaded the brief from the given URL into `docs/` first and committed it with this report.

These locks are untouched: island height 44, radius 11, bar height 48, SF Compact Display Medium with no bold, `toast.gap` 0, the battery as a number only, C for the calendar leader, the quick strip outside the island, `Super+D` showing hints only, the letters on the outline, `leader.hints`, and the sparks.

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261125-131817-bar-stage-11`** (mode 700, 196 files), taken before any edit. It covers the full behaviour set: every `jimmy.*` plugin, `hypr/*.lua`, `shell.json`, `shell.toml`, hooks, theme files, extensions, the Vicinae settings, the paste and backlight helpers, and the systemd unit. Checksums: live before = backup = live after. Excluded: runtime state, because nothing here touches it |
| Reload | `hyprctl reload` for the bind (`configerrors` empty). Tokens reloaded live from `shell.toml`. No shell restart was needed, and nothing was summoned with a restart |
| Debug / temporary code | None. No QML changed this round |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced: `hypr/bindings.lua`, `shell.toml`. Live checksums are identical before and after, and the snapshot equals live. No runtime state in git |

## 1. Leader against the mic: fixed

- **Cause:**
  - **The mic binds:** Right Option push-to-talk is Omarchy's stock dictation bind (`default/hypr/bindings/dictation.lua`). It is an `o.bind_hold("ALT + Alt_R", …)` pair (press = `omarchy-dictation start`, release = `stop`), and both binds were registered in the **global submap only** (`hyprctl binds`: `submap ''`, `submap_universal false`).
  - **The leader:** `Super+D` enters the `bar` submap, and Hyprland then runs only that submap's binds.
  - **Result:** Right Option was not bound there, so the leader swallowed it. Superwhisper itself was not involved; it is started by that bind.
- **Clean fix:** Hyprland has a per-bind `submap_universal` flag for exactly this: a bind that fires in every submap.
  - **Where:** a marked block in `bindings.lua` (`dictation-universal`). The stock file is not edited.
  - **What it does:** it unbinds the stock pair and rebinds it with the **same** `o.bind_hold` call and options, plus `submap_universal = true`. It is guarded by the same `o.dictation_installed()` check as stock.
- **Verified:**
  - **Binds:** `hyprctl binds` now lists exactly two Alt_R binds, the press and the transparent release, both with `submap_universal: true`. The old pair is gone and `configerrors` is empty.
  - **Leader:** the `bar` submap still holds 1–9, W, C, B, A, Q and Esc, unchanged.
- **Not testable here: the physical key.** Synthetic keys (`wtype`) do not trigger Hyprland binds, so the last check is yours: `Super+D`, then hold Right Option.
- **To revert:** delete the `dictation-universal` block and run `hyprctl reload`; the stock binds return.

## 2. Islands: much wider, on purpose

| Token | Was | Now |
|---|---|---|
| `island.padding-x` | 26 | **44** |
| `island.spacing` | 28 | **48** |
| `island.font-size` | 21 | **20** (text and icons together) |

- **An overshoot by design,** so you can say "too wide" and pull it back. The left island went from roughly 250 to about 290 logical px with three elements. The right island now spans about 230 px of spacing alone. The difference is obvious by eye (screenshot).
- **Unchanged:** height 44, radius 11, bar 48. The islands are still centred in their ears and grow symmetrically. The ear width caps them (`maxIslandWidth`), and nothing reaches it.
- **Rest of the UI:**
  - **Toast:** still attached under the right island's centre (screenshot with the strip open and a volume toast).
  - **Calendar:** the adopted calendar still drops from the island (screenshot).
  - **Leader letters:** still on the outline under each element (screenshot).
- **Note on the quick strip:** it spaces its icons with the same `island.spacing`, so it widened in step (still outside the island, which stays fixed). If you want the strip tighter than the islands, the strip can get its own `quick.spacing` token. That is one line.

## 3. Glow: a halo, not an outline

- **Why it read as an outline:** at 10 px blur and 14 %, `RectangularShadow`'s falloff was too short and too faint. Outside the edge, you mostly saw its brightest first few pixels.
- **It does give a real falloff:** it is a Gaussian-like SDF glow, so a longer blur gives a longer fade. No new technique was needed.
- **Now:** `island.glow-blur` 10 → **20** and `island.glow-alpha` 0.14 → **0.32**. The glow is brightest at the outline and fades to nothing over about 15–20 px, visible as a halo above, below and at the ends of each island on the dark wallpaper (zoomed screenshot).
- **Bar layer:** its click-through band grew with it (height = bar + max(letter overhang, glow blur) = 68), so the halo isn't clipped. Input stays the 48 px bar.
- **Same glow everywhere,** because toasts, notifications, the reminder card, `PanelShell` and adopted panels all use the same `IslandGlow` and tokens. The toast and calendar card halos match the islands (screenshots).
- **Side effect to judge:** the island glass is 70 % opaque, so a little of the glow shows through the fill. The islands now look faintly lit from within (green on this theme). If you'd rather the fill stay neutral, the next step is cutting the glow out under the fill (a mask). That is heavier, so I did not do it unasked.
- **Off switch unchanged:** `island.glow-alpha = 0`.

## Still open

- **Your key:** `Super+D`, then Right Option.
- **For your eye:**
  - how far to pull the width back (padding-x 44 / spacing 48);
  - glow strength (0.32 / 20);
  - whether the strip should keep the island spacing.
- **Still pending:** `notch.width` (ruler), the broken `notify-send`, and #12.
