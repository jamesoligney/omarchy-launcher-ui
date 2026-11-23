# Jimmy launcher v2 (simplified Raycast)

This is a clone of the first-party `omarchy.menu` plugin, reskinned as a
centered Raycast-style launcher. Stock Omarchy files are untouched.

- Plugin id: `jimmy.menu` (under `~/.config/omarchy/plugins/jimmy.menu`)
- Stock plugin: `omarchy.menu`, left intact and disabled by the clone workflow
- Open: `Super + Space` (unchanged)
- Revert: `omarchy plugin disable jimmy.menu` (stock menu comes back)
- Re-enable: `omarchy plugin enable jimmy.menu`

## Design tokens

All appearance tokens live in `~/.config/omarchy/shell.toml` under `[launcher]`.
They are machine-level overrides layered on top of whatever theme is active.
Colour values are role names (`background`, `foreground`, `accent`) resolved by
`Commons.Color` against the active theme's `colors.toml`, so switching themes
re-tints the launcher without editing QML.

| Token | Value | Meaning |
| --- | --- | --- |
| `width` | 607 | card width, logical px (v1: 740) |
| `max-height` | 459 | card height cap, logical px (v1: 560) |
| `top-fraction` | 0.16 | top of card as a fraction of screen height |
| `panel-radius` | 16 | card corner radius |
| `row-radius` | 10 | selected-row radius |
| `row-height` | 50 | result row height (v1: 54) |
| `row-gap` | 2 | gap between rows |
| `icon-size` | 22 | app/command icon box |
| `search-size` / `search-weight` | 22 / 500 | search field |
| `name-size` / `name-weight` | 15 / 500 | result name |
| `subtitle-size` | 11 | result subtitle |
| `hint-size` | 13 | keybind hint |

Measured from the live QML on eDP-1 (1728x1117 logical):

| | v1 | v2 | change |
| --- | --- | --- | --- |
| Root card width | 740 | 607 | −18.0% |
| Root card height | 510 | 428 | −16.1% |
| Height cap | 560 | 459 | −18.0% |

Muted text is `foreground` at `muted-alpha` (0.55); hints are `foreground` at
`hint-alpha` (0.66). The selected row uses the theme accent at 16% for the fill
and 55% for the border; selected text is the theme's `foreground`. The panel
background is the theme background at 84% alpha with Hyprland blur.

## Animation

- Open: `scale 0.96 → 1.0` over 220 ms with `Easing.OutBack` and
  `overshoot: 1.25`; card opacity and scrim fade over 140 ms.
- Close: `scale → 0.97` and opacity/scrim → 0 over 100 ms with `Easing.InCubic`.
  The layer is held for 115 ms by `closeTimer` so the close frame renders.

The card is anchored in the upper third and grows downward, so the animation
does not move the header.

## Keybind hints

Hints are resolved on every open, in this order:

1. **Vicinae** — `~/.config/vicinae/settings.json`
   → `providers.applications.entrypoints` (`alt+H` = Helium, etc.).
   Vicinae wins over Omarchy/Hyprland for the same app.
2. **Hyprland / Omarchy** — `omarchy menu keybindings --print`, which reads the
   live bind table (including user `o.rebind`s and Omarchy defaults).
3. Anything not found in either source shows no hint and reserves no column.

Modifiers are rendered in fixed order (`Ctrl`, `Alt`, `Super`, `Shift`) with a
space between each token: `⌃ ⌥ ⌘ ⇧`, `⌘ ⇧ B`, `⌥ H`. The hint uses
`JetBrainsMono Nerd Font`, which covers `⌘` (U+2318), `⇧` (U+21E7), `⌃`
(U+2303) and `⌥` (U+2325).

### Audit — apps

| App | Raw bind | Symbols | Source |
| --- | --- | --- | --- |
| Ghostty | `alt+G` | `⌥ G` | Vicinae |
| Helium Browser | `alt+H` | `⌥ H` | Vicinae |
| Muse.AI | `alt+M` | `⌥ M` | Vicinae |
| Orca | `alt+O` | `⌥ O` | Vicinae |
| Floorp | `alt+F` | `⌥ F` | Vicinae |
| Chromium | `SUPER SHIFT + B` | `⌘ ⇧ B` | Hyprland |
| Flea | `SUPER SHIFT + F` | `⌘ ⇧ F` | Hyprland |
| Spotify | `SUPER SHIFT + M` | `⌘ ⇧ M` | Hyprland |
| Omacalc | `SUPER SHIFT + Q` | `⌘ ⇧ Q` | Hyprland |
| 1Password | `SUPER SHIFT + SLASH` | `⌘ ⇧ /` | Hyprland |
| Omawrite | `SUPER SHIFT + W` | `⌘ ⇧ W` | Hyprland |
| Obsidian | `SUPER SHIFT + O` | `⌘ ⇧ O` | Hyprland |
| YouTube | `SUPER SHIFT + Y` | `⌘ ⇧ Y` | Hyprland |
| WhatsApp | `SUPER SHIFT ALT + G` | `⌥ ⌘ ⇧ G` | Hyprland |
| Google Messages | `SUPER SHIFT CTRL + G` | `⌃ ⌘ ⇧ G` | Hyprland |
| Google Photos | `SUPER SHIFT + P` | `⌘ ⇧ P` | Hyprland |
| Google Maps | `SUPER SHIFT + S` | `⌘ ⇧ S` | Hyprland |
| Superwhisper | `CTRL ALT + space` | `⌃ ⌥ Space` | Hyprland |
| Vicinae | `ALT + SPACE` | `⌥ Space` | Hyprland |

### Audit — commands

| Command | Symbols | Source |
| --- | --- | --- |
| Apps | `⌥ ⌘ Space` | Hyprland |
| System menu | `⌘ Esc` | Hyprland |
| Lock | `⌃ ⌘ L` | Hyprland |
| Theme | `⌃ ⌘ T` | Hyprland |
| Background | `⌃ ⌘ W` | Hyprland |
| Hide / Show Bar | `⌘ ⇧ Space` | Hyprland |
| Keybindings | `⌘ K` | Hyprland |
| Tmux keybindings | `⌥ ⌘ K` | Hyprland |
| Herdr keybindings | `⌃ ⌘ K` | Hyprland |
| Capture menu | `⌃ ⌘ C` | Hyprland |
| Screenshot | `⌃ ⌥ ⌘ C` | Hyprland |
| Screenrecord | `⌥ Print` | Hyprland |
| OCR text | `⌃ ⌘ Print` | Hyprland |
| Color picker | `⌘ Print` | Hyprland |
| Clipboard History | `⌃ ⌘ V` | Hyprland |
| Set reminder | `⌃ ⌘ R` | Hyprland |
| Share | `⌃ ⌘ S` | Hyprland |
| Toggle menu | `⌃ ⌘ O` | Hyprland |
| Hardware menu | `⌃ ⌘ H` | Hyprland |
| Stay Awake / Allow Sleep | `⌃ ⌘ I` | Hyprland |
| Notifications On / Silence | `⌃ ⌥ ⌘ ,` | Hyprland |

### Conflicts and omissions

- **Ghostty** — Vicinae `alt+G` wins over Omarchy `Super+Return` (`⌘ ↵`).
  This is the only same-app conflict.
- **Helium** — Vicinae `alt+H`. Omarchy's `Super+Shift+B` "Browser" launches
  Chromium, so Helium has no Omarchy bind of its own.
- **Floorp** — Vicinae `alt+F`; installed as a Flatpak and displayed normally.
- **Files / Nautilus** — no bind in any source. `Super+Shift+F` launches Flea.
- **Nightlight On/Off** — no Omarchy keybind.
- **Wi-Fi / Bluetooth toggles** — bar panels, not stock menu rows.
- **Emoji** — `⌃⌘E` opens the emoji panel, not the menu's Emoji row.
- **Setup > Keybindings** — `⌘K` opens the keybindings viewer, not the editor.
- **Install/Remove** and most **Setup/Update** rows — no binds.
- **Screenrecord variants** — the generic `⌥ Print` opens the submenu/stops
  recording; individual audio/webcam variants have no bind.

### Other stores checked

- `~/.local/share/vicinae/shortcuts/shortcuts.json` — empty.
- `~/.local/share/vicinae/vicinae.db` `shortcut` table — empty.
- `~/.config/superwhisper/shortcuts.active.json` — dictation
  (`Ctrl+Alt+Space` toggle, `Escape` cancel), already reflected in Hyprland.
- `~/.config/omarchy/extensions/omarchy-menu.jsonc` — menu rows/actions, no
  keybinds.
- Omapop plugin — configurable shortcut is unset; mouse actions are in
  Hyprland, not app launches.
- No other launcher stores (rofi/wofi/fuzzel/walker/ulauncher/albert) exist.

## Blur

`~/.config/hypr/menu-glass.lua` enables the theme's glass blur and adds a
`blur = true` layer rule for the `omarchy-menu` namespace. No keybinds are
involved.

## Verified

- Helium `⌥ H`, Ghostty `⌥ G`, Muse.AI `⌥ M`, Orca `⌥ O`, Theme `⌃ ⌘ T`,
  Files no hint.
- Open animation recorded at 60 fps; close keeps the layer for 115 ms and
  fades out.
- Afterburn → Tokyo Night → Catppuccin Latte → Afterburn re-tints correctly.
- Disabling the plugin restores the stock menu.

Math / unit conversion is intentionally not in v2.
