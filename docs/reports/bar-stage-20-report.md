# Bar Stage 20: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-20-brief.md`. I downloaded the brief from the given URL into `docs/` first and committed it with this report.

The bar and the Stage 18–19 mechanism are untouched: the global rule, the floating-mode hook, the `Super+T` toggle, tiling as the opt-in, and dialogs keeping their own size. Only the default size changed.

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261125-153321-bar-stage-20`** (mode 700, 208 files), taken before any edit. It covers every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, `shell.json`, `shell.toml`, hooks, theme files, extensions, the Vicinae settings, helpers and the systemd unit, plus (local only) the saved per-workspace layouts. Checksums: live before = backup = live after |
| Reload | `hyprctl reload` only (`configerrors` empty) |
| Debug / temporary code | None. Both test windows were closed and focus returned to Orca on workspace 1. **The Zen window was only measured**, never touched |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced: `config/hypr/float-default.lua`. Live checksums are identical before and after, and the snapshot equals live. No runtime state in git |

## 1. The Zen window, measured

`hyprctl clients -j`, exactly as Hyprland reports it:

| Field | Value |
|---|---|
| Class | `zen` (a YouTube tab) |
| Workspace | **3** |
| Floating | **yes** |
| Size | **1100 × 619** |
| Position | **(314, 273)** |
| Fullscreen | no |

**The position is the exact centre of the usable area for that size:**
- **x:** (1728 − 1100) / 2 = **314**.
- **y:** 48 (bar reserve) + (1117 − 48 − 619) / 2 = 48 + 225 = **273**.

So the default keeps `center = true`. A hard-coded position would have given the same numbers, but it would break the moment the size is tuned again.

## 2. New default

- **`o.float_default = { width = 1100, height = 619 }`**, in **`~/.config/hypr/float-default.lua`, line 5** (snapshot: `config/hypr/float-default.lua`). It was 1100 × 700.
- **Position:** centred on the usable area, which for this size is **(314, 273)**, the Zen window's exact position.
- **Still one variable in one file:** every rule, the floating-mode hook and the `Super+T` toggle read it. A comment above it records where the numbers came from.

## Verified live

| Test | Result |
|---|---|
| New Ghostty on a fresh workspace (6) | **float, 1100 × 619 at (314, 273)**, an exact match with Zen |
| A second new Ghostty on the same workspace | **1100 × 619 at (314, 273)**: the two stack exactly, as in Stage 19 (cascade is still a choice for later) |
| `Super+T` after moving one to (364, 303) | → tiled (337, 55, 1055 × 1055) → `Super+T` → **floating at (364, 303), 1100 × 619** |
| Zen on workspace 3, after everything | unchanged: **1100 × 619 at (314, 273)** |

## Still open

- **Your eye:** new windows at the Zen size.
- **Stacked vs. cascade** for two windows: still stacked, unchanged this stage.
- **Still pending:** the broken `notify-send` and #12.
