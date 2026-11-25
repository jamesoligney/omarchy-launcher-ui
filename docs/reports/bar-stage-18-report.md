# Bar Stage 18: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-18-brief.md`. I downloaded the brief from the given URL into `docs/` first and committed it with this report.

The bar is untouched this round (the Stage 17 locks). This stage is the Q8 floating default only.

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261125-152242-bar-stage-18`** (mode 700, 202 files), taken before any edit. This round it also took **every `~/.config/hypr/*.lua`**, since window rules and binds live there. It also covers every `jimmy.*` plugin, `shell.json`, `shell.toml`, hooks, theme files, extensions, the Vicinae settings, the paste and backlight helpers, and the systemd unit. Checksums: live before = backup = live after. Excluded: runtime state, because nothing here touches it |
| Reload | `hyprctl reload` only (`configerrors` empty after each). No shell restart was needed |
| Debug / temporary code | None. Test windows (a floating Ghostty and an imv) were closed. The tiled window used for the Super+T test was returned to tiled at its original geometry, and focus was restored |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | New `config/hypr/float-default.lua` added; `config/hypr/bindings.lua` resynced. Live checksums are identical before and after, and the snapshot equals live. No runtime state in git |

## Floating default: 1100 × 700, centred

**One variable, one file:** **`o.float_default = { width = 1100, height = 700 }`**, in **`~/.config/hypr/float-default.lua`, line 4** (snapshot: `config/hypr/float-default.lua`). Change the size there; nothing else repeats the numbers.

Two pieces, both in that file. User config only; no stock file was edited.

### 1. Windows that open floating

- **The rule:** `o.window({ tag = "floating-window" }, { size = …, center = true })`.
  - **What it targets:** Omarchy's own "opens floating" category, i.e. its floating terminals, btop, file pickers and portal dialogs, previews, mpv, imv and the like.
  - **Why it wins:** it loads after Omarchy's defaults, so it replaces the stock 875 × 600.
- **Why the tag and not `float = true`:** I tried `float = true` first, and it does **not** fire for a window that another rule floated. Tested live, the window stayed at stock 875 × 600.
- **Not covered:** windows an app floats on its own (modal and transient dialogs, such as a browser's print dialog) keep the size their app asks for. A 1100 × 700 "OK / Cancel" box would be wrong.
- **Not this rule's business:** apps with their own stock float size (About, the calculator) are not tagged and keep theirs.

### 2. Floating a window later: Super+T

- **The bind:** `Super+T` is rebound in `bindings.lua` (block `float-default`, still the single source of binds) to `o.float_toggle()`.
- **First float:** the default size, **centred**.
- **Tiling it again:** the toggle remembers its floating size **and place**.
- **Floating it again:** it returns to exactly that size and place.
  - **Why this is needed:** Hyprland keeps a window's floating size on its own but not its position. Tested, a moved window came back elsewhere until the toggle stored it.
- **Already-open windows:** a window already floating is not touched by anything here; Helium's existing float stayed as it was. Only the toggle and newly opened tagged windows apply the default.

### Centring and the bar reserve

- **How it centres:** Hyprland's `center` (and the `center` dispatcher) centres on the monitor's **usable area**, which already excludes the 48 px top reserve.
- **The numbers:** on the 1728 × 1117 logical screen, a 1100 × 700 window lands at **x 314, y 233**.
  - **x:** (1728 − 1100) / 2 = 314.
  - **y:** 48 + (1069 − 700) / 2 ≈ 233.
  - **Without the reserve,** y would be 208. The window is centred under the bar, not under the notch.

### Verified live (measured with `hyprctl clients`)

| Test | Result |
|---|---|
| New floating **Ghostty** (`org.omarchy.terminal`, floats via the tag) | **1100 × 700 at (314, 233)** |
| New floating **imv** (image viewer, floats via the tag) | **1100 × 700 at (314, 233)** |
| A **tiled** window (the Muse web app), `Super+T` | floats at **1100 × 700, (314, 233)** |
| …moved and resized by the user, then `Super+T` (tiled), `Super+T` (float) | back at its own **(404, 288), 1000 × 650** |
| …`Super+T` once more | tiled again at its **original tiled geometry** (872, 55, 849 × 1055) |
| Other tiled windows | unaffected throughout |
| Fullscreen | unaffected: no rule touches fullscreen or tiled windows, and fullscreen still overrides any size |

## Still open

- **For your eye:** whether 1100 × 700 suits the YouTube-in-Helium workflow. It is one line to change.
- **Scope choice to confirm:** dialogs that apps float themselves keep their own size. Say if you want them at the default too; that is one more rule.
- **Not done:** remembering a window's previous formation across restarts (the Cmd+L idea is future). The toggle's memory lasts for the Hyprland session.
- **Still pending:** the broken `notify-send` and #12.
