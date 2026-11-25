# Bar tray audit (for bar restructure brief v2, Q7)

2026-11-24. Read-only audit: no plugin, config or binding was changed. James decides keep / drop from this list.

**Sources:** `~/.config/omarchy/shell.json` (bar layout, tray drawer, plugins list), every folder in `~/.config/omarchy/plugins/`, the live StatusNotifier tray (`org.kde.StatusNotifierWatcher`), `hypr/bindings.lua` and the stock binds, the launcher's menu rows (stock `omarchy-menu.jsonc` and the user extension), desktop entries, each plugin's IPC targets, and CLIs on `PATH`.

## The key finding

**Every tray widget's panel opens from the CLI with `omarchy-shell shell toggle <id>`.** I tested this live on each one. It opened the panel (a new `omarchy-keyboard-panel` layer) and a second toggle closed it, with nothing left open. Stock keybinds use the same route (`{ panel = "<id>" }` in Lua compiles to it; `Super+Ctrl+A` audio works this way).

So the filter splits three ways, not two:
- **Launcher / bind today:** already reachable without the tray.
- **CLI only, one launcher row away:** reachable by `omarchy-shell`, but nothing in the launcher or binds points at it yet. One menu row in `~/.config/omarchy/extensions/omarchy-menu.jsonc` (or one bind) would make it launcher-callable, so it would not need a drawer home.
- **Tray-only:** no CLI or keyboard route at all. The drawer's Plugins section would be its only home.

---

## A. Tray drawer widgets (`shell.json` → `bar.layout.tray`)

| Item (id) | What it does | Launcher / bind today | CLI route (tested) | Verdict |
|---|---|---|---|---|
| **Superwhisper** (`superwhisper.panel`) | Bar panel for Superwhisper: status, processing mode, last dictation, quick access to history | No row or bind for the panel. The Superwhisper **app** has a desktop entry and `/usr/bin/superwhisper` | `omarchy-shell shell toggle superwhisper.panel` opens it | **CLI only, one row away** |
| **Omapop** (`io.github.jondkinney.omapop`) | Select text with the mouse → a small action bar (cut, copy, paste, search, open links, PopClip-style extensions). The bar icon is its settings panel | None | `shell toggle` opens it; also IPC target `io.github.jondkinney.omapop` (`pause`, `resume`, `settings`, `status`…) | **CLI only, one row away.** The feature itself is mouse-selection-driven by nature |
| **Window Effects** (`omarchy-fx`) | Settings panel for the Hyprland effects plugin: wobbly windows, elastic moves, focus pulse, shake-to-find cursor | None | `shell toggle omarchy-fx` opens it | **CLI only, one row away** |
| **Scratchpad** (`acooper.scratchpad`) | Quick note pad that autosaves when dismissed | **`Super+N`** (in `bindings.lua`, "scratchpad-hotkey" block) | `shell toggle` | **Launcher / bind today** |
| **Matrix Screens** (`io.github.whiskeytangofussell.matrixscreens`) | Matrix rain as desktop background, screensaver and lock screen, in the theme's colours. The bar icon switches each one on or off. **Replaces Omarchy's lock screen while enabled** | None | `shell toggle` opens the panel; IPC targets `matrixscreens` (`toggle`, `screensaver`, `set`, `status`…) and `matrixscreens-panel`. Its `bin/matrix-screens` is not on `PATH` | **CLI only, one row away** |
| **Monitor / display** (`omarchy.monitor`, stock) | Brightness and display settings | **`Super+Ctrl+D`** (stock bind) | `shell toggle` | **Launcher / bind today** |
| **Tricky Tiles** (`io.github.denonmaryland.tricky-tiles`) | Settings for the window/workspace spring physics: presets, live preview, swipe gestures. Writes `hypr/tricky-tiles.lua` | None | `shell toggle` opens it; IPC target `io.github.denonmaryland.tricky-tiles` (`open`, `preset`, `set`…) | **CLI only, one row away** (a settings panel, rarely needed) |
| **Lock screen icon** (`lock-explorer`, inline QML entry pointing at the lock-explorer plugin's `BarWidget.qml`) | One icon. Left click runs `omarchy-shell lock explore`, right click `omarchy-shell lock exploreFull` | None. The launcher's "Lock" row locks the screen; it does not open the explorer | `omarchy-shell lock explore` (the icon's own command). `shell toggle lock-explorer` does nothing, because it is not a plugin id | **CLI only, one row away** |
| **Launcher button** (`jimmy.menu`) | Opens the launcher | **`Super+Space`** | yes | **Launcher / bind today.** Redundant in the drawer |

## B. System tray apps inside the tray (StatusNotifier, live right now)

These are apps' own tray icons, shown by `omarchy.tray`. Their **menus** exist only in the tray; the apps themselves launch normally.

| Tray icon | What it does | Launcher / bind today | Tray-only part | Verdict |
|---|---|---|---|---|
| **Superwhisper** (`superwhisper-in…`) | Dictation app's own tray icon and menu | App: desktop entry, `/usr/bin/superwhisper` | Its tray menu | Overlaps the Superwhisper panel in A; **one of the two is redundant** |
| **Vicinae** (`vicinae-server`) | Vicinae launcher's tray icon | Desktop entries; `Alt+Space` bind | Its tray menu | Vicinae is being phased out (AGENTS.md). **Drops when Vicinae is uninstalled** |
| **LocalSend** (`localsend_app`) | LAN file sharing; tray keeps it running in the background to receive | Desktop entry; launcher row "Receive" (`trigger.share.receive`) | Its tray menu (quit, open) | Launcher-callable to open. Tray icon matters only to show that it is listening |

## C. Other third-party plugins (not in the tray drawer)

Included because Q7 asks what else could need a home.

| Plugin (id) | Where it lives now | What it does | Launcher / bind / CLI | Verdict |
|---|---|---|---|---|
| **Locus** (`io.github.cwilliams5.locus`) | **Right side of the bar** (added since the last audit) | Night light that follows the sun or set hours: gradual warming, temperature slider, pause for colour-critical apps | No row or bind. `shell toggle` opens its panel (tested); IPC target `io.github.cwilliams5.locus.control` (`off`, `hold`, `movie`, `dim`…) | **CLI only, one row away.** **Overlaps the stock night light** (indicator and `omarchy.nightlight` service): keep one |
| **AI Usage** (`ai-usage.notch`) | Edge-attached surface (service), shown on hover | Rail of AI provider quota rings, per-provider cards, token sparkline | **None.** No IPC target; `shell toggle` does nothing (tested); opens by hover or click only | **Tray-only in effect: pointer-only.** **Overlaps `omarchy.agents`** (same usage data). Strongest drop candidate, or a candidate to fold into mission control |
| **Lock Screen Explorer** (`io.github.sirjul1337.lock-explorer`) | Service + overlay | Lock screen designs, a picker to preview and switch, and a designer | `shell toggle` opens the overlay (tested); `omarchy-shell lock explore` | **CLI only, one row away.** **Both it and Matrix Screens replace the lock screen**; only one can own it |
| **Omaland** (`bobbynicholas.omaland`) | Panel + service | Live editor for Hyprland look and feel; writes a managed block into `looknfeel.lua` | **Launcher:** desktop entry, searchable as "Omaland"; `shell toggle` | **Launcher / bind today** |
| **Fathom** (`io.github.mtolhuys.fathom`) | Overlay | Depth-based Alt-Tab | **Bind:** its own `hypr/fathom.lua`, loaded from `bindings.lua` (Alt+Tab) | **Launcher / bind today** |
| **Glyph Menu** (`io.github.smoothpixels.glyph-menu`) | Left of the bar | The mark on the menu button (141+ glyphs) | Launcher rows `style.bar.glyph.*` | Not a tray item. Bar decoration that is replaced or dropped by the restructure |
| **Smart Divider** (`io.github.nikhill-666.divider`) | Left of the bar | Divider between chip groups | Right-click to style; scripts | Bar decoration; replaced by the restructure's own layout |
| **Konocap** (`konochi.konocap`) | Service, no bar UI | Sliding titlebars for floating windows | IPC `status` only | No UI; nothing to house |
| **Border FX** (`wmfeht.border-fx`) | Service, no bar UI | Animated border ring around windows, panels, toasts | `scripts/border-fx` (not on `PATH`) | No UI; nothing to house |
| **Flea Shelf** (`io.github.thisisgm.flea-shelf`) | **Disabled** | A drop shelf for files on the bar | none | Disabled; drop or ignore |
| **Notch Bar** (`io.github.crumble21.notch-bar`) | **Disabled** | Third-party bar that splits around the notch | IPC `omarchy.bar` | Prior art for the restructure (brief v2, S2); not a tray item |

`jimmy.*` plugins are not listed: none of them is in the tray except the launcher button (A).

---

## Summary for the keep / drop decision

**Already launcher- or bind-callable (no drawer home needed):**
- Scratchpad (`Super+N`)
- Monitor (`Super+Ctrl+D`)
- Launcher button (`Super+Space`)
- Omaland (launcher)
- Fathom (Alt+Tab)
- LocalSend (launcher, to open it)

**CLI-callable, one launcher row away (no drawer home needed if James adds the row):**
- Superwhisper panel
- Omapop settings
- Window Effects
- Matrix Screens
- Tricky Tiles
- Lock explorer
- Locus

**Tray-only / pointer-only:**
- AI Usage notch (hover only; duplicates Agents)
- The three StatusNotifier menus (Superwhisper app, Vicinae, LocalSend)

**Overlaps to settle whatever the drawer decision:**
1. **Superwhisper panel vs Superwhisper's own tray icon:** two surfaces for one app.
2. **Locus vs the stock night light:** two night lights.
3. **AI Usage notch vs Agents (mission control):** same usage records, two surfaces.
4. **Matrix Screens vs Lock Screen Explorer:** both replace the lock screen; only one should own it (stock `omarchy.lock` is already disabled).
5. **Vicinae tray icon:** goes away with Vicinae.

## Not verified

- I did not open each StatusNotifier menu to list its items.
- `shell toggle` was tested with the drawer closed; how each panel anchors once it lives in the new side drawer is a design question for the build.
- Fathom's exact binds were read from its loader, not pressed.
