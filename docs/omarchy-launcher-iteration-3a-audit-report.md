# Omarchy launcher — iteration 3a audit (read-only)

Date: 2026-11-23  
Machine: Omarchy side, `jimmy`, Hyprland/Lua, eDP-1 1728×1117 logical, Afterburn.  
Method: files read only. No bind changed, no service/shell/Hyprland reload, no plugin/theme change, no launcher opened. The only file written is this report.

> Note: the referenced full spec (`~/workspace/omarchy-launcher-rice-spec.md`) and iteration 3 brief (`~/workspace/omarchy-launcher-iteration-3-brief.md`) are not present on this machine. This audit uses the brief text supplied in chat and the live files below. If those documents contain extra parity requirements, re-check this report against them.

## 1. Bind sources and precedence

| Source | Where it lives | What it contributes |
|---|---|---|
| Omarchy defaults | `/usr/share/omarchy/default/hypr/bindings/*.lua`; loaded by `hyprland.lua` | Stock app launches and Omarchy commands |
| User Hyprland | `~/.config/hypr/bindings.lua` | `o.bind` / `o.rebind` overrides: Vicinae, Flea, Scratchpad, yt-summary, yt-mini, close-window-or-tab |
| Live Hyprland table | `~/.cache/omarchy/keybindings-*.records` (read) and `hyprctl binds` | The actual active chords and descriptions, including user rebinds |
| Omarchy menu definitions | `/usr/share/omarchy/default/omarchy/omarchy-menu.jsonc` + `~/.config/omarchy/extensions/omarchy-menu.jsonc` | Rows/actions/aliases. **No keybind fields**; binds are resolved from Hyprland |
| Vicinae | `~/.config/vicinae/settings.json` → `providers.applications.entrypoints` | Six app-launch shortcuts: Muse.AI, Ghostty, Helium, Floorp, Orca, Zen; plus the core emoji panel |
| Vicinae other stores | `~/.local/share/vicinae/shortcuts/shortcuts.json` (empty), `vicinae.db` `shortcut` table (empty) | Nothing additional |
| Superwhisper | `~/.config/superwhisper/shortcuts.active.json`, generated Lua | Dictation toggle/cancel only; already mirrored in Hyprland |
| Omapop | plugin service; `shell.json` `shortcut` unset | Mouse selection actions in Hyprland; no app launch |
| Other launchers | no rofi/wofi/fuzzel/walker/ulauncher/albert configs | None |

Precedence for the launcher display today: **Vicinae first**, then Hyprland/Omarchy. Vicinae wins for the same app (e.g. Ghostty).

Snapshot note: `~/.config/vicinae/settings.json` has mtime **2026-11-23 10:11:23** and already contains the Zen shortcut. The v2 launcher’s map does **not** contain Zen yet; this is a display gap to fix in 3b, not a missing bind.

## 2. App-launch binds

“Bind as pressed” is the human chord; symbols use the launcher order `⌃ ⌥ ⌘ ⇧` with spaces. “v2 shows” means the current `jimmy.menu` clone’s mapped hint, for build planning.

| Item | Bind as pressed | Symbols | Source | v2 shows |
|---|---|---|---|---|
| Ghostty (Terminal) | `Super+Return` | `⌘ ↵` | Omarchy | Conflict: currently overridden by Vicinae `⌥ G` |
| Ghostty | `Alt+G` | `⌥ G` | Vicinae | yes |
| Helium Browser | `Alt+H` | `⌥ H` | Vicinae | yes |
| Muse.AI | `Alt+M` | `⌥ M` | Vicinae | yes |
| Orca | `Alt+O` | `⌥ O` | Vicinae | yes |
| Floorp | `Alt+F` | `⌥ F` | Vicinae | yes |
| Zen Browser | `Alt+Z` | `⌥ Z` | Vicinae | **no — v2 map missing Zen** |
| Chromium (Browser) | `Super+Shift+B` | `⌘ ⇧ B` | Omarchy | yes |
| Chromium (Browser) | `Super+Shift+Return` | `⌘ ⇧ ↵` | Omarchy | no (alternate chord) |
| Browser private | `Super+Shift+Alt+B` | `⌥ ⌘ ⇧ B` | Omarchy | no |
| Flea (File manager) | `Super+Shift+F` | `⌘ ⇧ F` | User Hyprland (`o.rebind`) | yes |
| Flea (File manager, cwd) | `Super+Shift+Alt+F` | `⌥ ⌘ ⇧ F` | User Hyprland | no |
| Tmux | `Super+Alt+Return` | `⌥ ⌘ ↵` | Omarchy | no |
| Herdr | `Super+Ctrl+Return` | `⌃ ⌘ ↵` | Omarchy | no |
| Editor (nvim) | `Super+Shift+N` | `⌘ ⇧ N` | Omarchy | no (no GUI app row) |
| Spotify (Music) | `Super+Shift+M` | `⌘ ⇧ M` | Omarchy | yes |
| Music TUI (cliamp) | `Super+Shift+Alt+M` | `⌥ ⌘ ⇧ M` | Omarchy | no |
| Signal | `Super+Shift+G` | `⌘ ⇧ G` | Omarchy | no (if installed) |
| Obsidian | `Super+Shift+O` | `⌘ ⇧ O` | Omarchy | yes |
| Omawrite | `Super+Shift+W` | `⌘ ⇧ W` | Omarchy | yes |
| 1Password (Passwords) | `Super+Shift+/` | `⌘ ⇧ /` | Omarchy | yes |
| Omacalc (Calculator) | `Super+Shift+Q` | `⌘ ⇧ Q` | Omarchy | yes |
| Omacalc (alternate) | `XF86Calculator` | — | Omarchy | no |
| ChatGPT | `Super+Shift+A` | `⌘ ⇧ A` | Omarchy | no (if webapp installed) |
| Grok | `Super+Shift+Alt+A` | `⌥ ⌘ ⇧ A` | Omarchy | no (if webapp installed) |
| Calendar (HEY) | `Super+Shift+C` | `⌘ ⇧ C` | Omarchy | no |
| Email (HEY) | `Super+Shift+E` | `⌘ ⇧ E` | Omarchy | no |
| New email (HEY) | `Super+Shift+Alt+E` | `⌥ ⌘ ⇧ E` | Omarchy | no |
| YouTube | `Super+Shift+Y` | `⌘ ⇧ Y` | Omarchy | yes |
| WhatsApp | `Super+Shift+Alt+G` | `⌥ ⌘ ⇧ G` | Omarchy | yes |
| Google Messages | `Super+Shift+Ctrl+G` | `⌃ ⌘ ⇧ G` | Omarchy | yes |
| Google Photos | `Super+Shift+P` | `⌘ ⇧ P` | Omarchy | yes |
| Google Maps | `Super+Shift+S` | `⌘ ⇧ S` | Omarchy | yes |
| X | `Super+Shift+X` | `⌘ ⇧ X` | Omarchy | no |
| X Post | `Super+Shift+Alt+X` | `⌥ ⌘ ⇧ X` | Omarchy | no |
| Activity (btop) | `Super+Shift+T` | `⌘ ⇧ T` | Omarchy | no |
| Agent picker | `Super+Shift+Ctrl+A` | `⌃ ⌘ ⇧ A` | Omarchy | no |
| Vicinae | `Alt+Space` | `⌥ Space` | User Hyprland (`o.bind`) | yes |
| Files / Nautilus | — | — | — | no hint (correct) |

Conditional stock binds not active in the live table: Docker (`Super+Shift+D`) is only bound when `lazydocker` is present; it is not in the live cache. Treat as “not currently bound” rather than missing.

Window/workspace management, mouse, media and input-method binds are intentionally not in this table; they are not app launches or launcher commands. They remain in the live cache if needed.

## 3. Command binds

These are the Omarchy/system commands that the launcher/menu exposes. The stock menu JSONC has no bind metadata; the chord is resolved from Hyprland by description.

| Command | Bind as pressed | Symbols | Source | v2 shows |
|---|---|---|---|---|
| Omarchy menu | `Super+Space` | `⌘ Space` | Omarchy | entry point |
| Apps menu | `Super+Alt+Space` | `⌥ ⌘ Space` | Omarchy | yes |
| System menu | `Super+Escape` | `⌘ Esc` | Omarchy | yes |
| Keybindings viewer | `Super+K` | `⌘ K` | Omarchy | yes |
| Tmux keybindings | `Super+Alt+K` | `⌥ ⌘ K` | Omarchy | yes |
| Herdr keybindings | `Super+Ctrl+K` | `⌃ ⌘ K` | Omarchy | yes |
| Theme menu | `Super+Ctrl+T` | `⌃ ⌘ T` | Omarchy | yes |
| Theme menu (alt) | `Super+Shift+Ctrl+Space` | `⌃ ⌘ ⇧ Space` | Omarchy | alternate |
| Background switcher | `Super+Ctrl+Space` | `⌃ ⌘ Space` | Omarchy | alternate |
| Background switcher | `Super+Ctrl+W` | `⌃ ⌘ W` | Omarchy | yes |
| Lock | `Super+Ctrl+L` | `⌃ ⌘ L` | Omarchy | yes |
| Clipboard manager | `Super+Ctrl+V` | `⌃ ⌘ V` | Omarchy | yes |
| Emoji picker | `Super+Ctrl+E` | `⌃ ⌘ E` | Omarchy | **no — menu row `trigger.emoji` not mapped in v2** |
| Screenshot | `Print` | `Print` | Omarchy | alternate |
| Screenshot | `Super+Ctrl+Alt+C` | `⌃ ⌥ ⌘ C` | Omarchy | yes |
| Screenrecording | `Alt+Print` | `⌥ Print` | Omarchy | yes (generic/stops) |
| Color picker | `Super+Print` | `⌘ Print` | Omarchy | yes |
| OCR from screenshot | `Super+Ctrl+Print` | `⌃ ⌘ Print` | Omarchy | yes |
| Capture menu | `Super+Ctrl+C` | `⌃ ⌘ C` | Omarchy | yes |
| Hardware menu | `Super+Ctrl+H` | `⌃ ⌘ H` | Omarchy | yes |
| Toggle menu | `Super+Ctrl+O` | `⌃ ⌘ O` | Omarchy | yes |
| Share | `Super+Ctrl+S` | `⌃ ⌘ S` | Omarchy | yes |
| Set reminder | `Super+Ctrl+R` | `⌃ ⌘ R` | Omarchy | yes |
| Show reminders | `Super+Ctrl+Alt+R` | `⌃ ⌥ ⌘ R` | Omarchy | no |
| Clear reminders | `Super+Shift+Ctrl+R` | `⌃ ⌘ ⇧ R` | Omarchy | no |
| Toggle top/menu bar | `Super+Shift+Space` | `⌘ ⇧ Space` | Omarchy | yes |
| Toggle notification silencing | `Super+Ctrl+Alt+,` | `⌃ ⌥ ⌘ ,` | Omarchy | yes |
| Toggle idle locking | `Super+Ctrl+I` | `⌃ ⌘ I` | Omarchy | yes |
| Toggle full-screen desktop | `Super+Ctrl+Alt+F` | `⌃ ⌥ ⌘ F` | Omarchy | no |
| Toggle laptop display | `Super+Ctrl+Delete` | `⌃ ⌘ ⌦` | Omarchy | no |
| Toggle display mirroring | `Super+Ctrl+Alt+Delete` | `⌃ ⌥ ⌘ ⌦` | Omarchy | no |
| Toggle window transparency | `Super+Backspace` | `⌘ ⌫` | Omarchy | no |
| Toggle window gaps | `Super+Shift+Backspace` | `⌘ ⇧ ⌫` | Omarchy | no |
| Toggle single-window aspect | `Super+Ctrl+Backspace` | `⌃ ⌘ ⌫` | Omarchy | no |
| Toggle tiled fullscreen | `Super+Ctrl+F` | `⌃ ⌘ F` | Omarchy | no |
| Transcode | `Super+Ctrl+.` | `⌃ ⌘ .` | Omarchy | no |
| Monitor scaling up | `Super+/` | `⌘ /` | Omarchy | no |
| Monitor scaling down | `Super+Alt+/` | `⌥ ⌘ /` | Omarchy | no |
| Bluetooth panel | `Super+Ctrl+B` | `⌃ ⌘ B` | Omarchy | no |
| Network panel | `Super+Ctrl+N` | `⌃ ⌘ N` | Omarchy | no |
| Power panel | `Super+Ctrl+P` | `⌃ ⌘ P` | Omarchy | no |
| Audio panel | `Super+Ctrl+A` | `⌃ ⌘ A` | Omarchy | no |
| Display panel | `Super+Ctrl+D` | `⌃ ⌘ D` | Omarchy | no |
| Bar panels 1–9 | `Super+Ctrl+1…9` | `⌃ ⌘ 1…9` | Omarchy | no |
| Scratchpad panel | `Super+N` | `⌘ N` | User Hyprland | no |
| Summarize YouTube | `Super+Alt+Y` | `⌥ ⌘ Y` | User script | no |
| Mini video | `Super+Alt+V` | `⌥ ⌘ V` | User script | no |
| Center window | `Super+Alt+C` | `⌥ ⌘ C` | User Hyprland | no |

System/media keys (brightness, volume, mic mute, media transport, screenshot review keys) and notification/editing binds are outside the launcher command set; they remain active and unchanged.

## 4. Omarchy menu bind coverage

The menu JSONC rows do not carry a `bind` field. The clone resolves hints by mapping menu ids to live bind descriptions. The command table above is that mapping.

Two known coverage gaps in the current v2 clone:

1. **Zen** (`providers.applications.entrypoints.zen`, `alt+Z`) is not in `Launcher.js`; the Zen app row therefore has no hint today.
2. **`trigger.emoji`** (`Emoji`, action `omarchy-menu-emoji` → toggles `omarchy.emojis`) is the same overlay that `Super+Ctrl+E` opens, but v2 does not map it. It should show `⌃ ⌘ E`.

`Floorp` is installed as a Flatpak and is already mapped/displayed as `⌥ F`.

## 5. Conflicts

- **Ghostty — real same-app conflict.** Vicinae `Alt+G` (`⌥ G`) vs Omarchy `Super+Return` (`⌘ ↵`). Vicinae wins; Ghostty shows `⌥ G`. If the Vicinae bind is moved to `bindings.lua`, the Omarchy Terminal bind still exists and would also launch Ghostty; decide whether to keep both or rebind one.
- **Helium — browser ambiguity, not a same-app conflict.** Helium has Vicinae `Alt+H` (`⌥ H`). Omarchy’s “Browser” bind `Super+Shift+B` launches **Chromium**, not Helium. Do not put the Chromium bind on Helium; keeping `⌥ H` is correct.
- **Zen — no same-app conflict.** Vicinae `Alt+Z` (`⌥ Z`). Omarchy has no Zen bind. `Super+Ctrl+Alt+Z` is “Reset zoom” (a window command with a different chord); it is not a duplicate.
- **No duplicate Vicinae chords.** The six Vicinae app shortcuts use M, G, H, F, O, Z, all unique. Cross-source same letters exist with different modifiers (e.g. Alt+M Muse.AI vs Super+Shift+M Music; Alt+F Floorp vs no Super+Shift+F? Flea is Super+Shift+F), but these are different chords, not conflicts.
- **No existing Hyprland Alt+letter binds** for H/G/M/F/O/Z (only Alt+Space, Alt+Tab, Alt+Alt_R, Alt+F1/F2, Alt+Print). Adding the six Vicinae launches to `bindings.lua` would not collide with an existing Hyprland chord.

## 6. Missing binds

No bind found in any source:

- **Files / Nautilus** — no bind. `Super+Shift+F` opens Flea.
- **Nightlight On/Off** — no Omarchy bind.
- **Wi-Fi / Bluetooth toggles** — not menu rows; the only related menu rows are `update.hardware.wifi` and `update.hardware.bluetooth` (restart services), with no bind.
- **Screensaver** (`system.screensaver`) — no bind.
- **Font / Appearance > Font** — no bind.
- **Setup > Keybindings** — no bind; `Super+K` opens the viewer, not the editor.
- **Install / Remove / most Setup / most Update rows** — no bind.
- **Screenrecord start variants** (no audio, desktop audio, microphone, webcam) — no individual bind; `Alt+Print` opens the submenu or stops the active recording.
- **Share sub-options** (clipboard/file/folder/receive) — no individual bind; the Share menu has `Super+Ctrl+S`.
- **Hardware sub-options** — no individual binds; the parent menu has `Super+Ctrl+H`.
- **Update Omarchy / Install package** — no bind.
- **Most installed apps** — no app-launch bind; the launcher correctly shows no hint.

## 7. Vicinae storage and migration implications

### Storage

- File: `~/.config/vicinae/settings.json`
- Block: `providers.applications.entrypoints`
- Shape:

```json
"applications": {
  "entrypoints": {
    "Muse.AI":             { "shortcut": "alt+M" },
    "com.mitchellh.ghostty": { "shortcut": "alt+G" },
    "helium":              { "shortcut": "alt+H" },
    "one.ablaze.floorp":   { "shortcut": "alt+F" },
    "orca":                { "shortcut": "alt+O" },
    "zen":                 { "shortcut": "alt+Z" }
  }
}
```

- These are **Vicinae-internal app entrypoint shortcuts**, not Hyprland binds. The Vicinae server (`vicinae-server`, running; `vicinae ping` succeeds) registers them globally.
- The file is JSONC with comments. Vicinae may rewrite it; edits through the Vicinae settings GUI are safest. A plain `jq` rewrite would drop comments/formatting.
- The only logged shortcut failure is `@toggle-launcher` on `alt+SPACE`, because Hyprland owns `Alt+Space` (Vicinae log: “reserved by a compositor keybind”). That is intentional; app entrypoint shortcuts are separate.
- `~/.local/share/vicinae/shortcuts/shortcuts.json` is `[]`; the `shortcut` table in `vicinae.db` is empty. No other Vicinae shortcut store found.
- `providers.core.entrypoints.search-emojis` uses `alt+shift+E`; it is a core action (Vicinae emoji search), not an app launch. It is not the same row as Omarchy’s Emoji overlay.

### Moving one to `bindings.lua`

For each app, add an `o.bind` in `~/.config/hypr/bindings.lua` and remove/clear the matching `shortcut` in Vicinae. Leaving both would register the same chord twice; the Vicinae or Hyprland side would fail or double-fire.

Recommended launch values (from the desktop entries):

| App | Current Vicinae bind | Desktop `Exec` / launch value |
|---|---|---|
| Ghostty | `alt+G` | `ghostty --gtk-single-instance=true`; `{ launch = "ghostty" }` or `o.launch_terminal()` |
| Helium | `alt+H` | `helium-browser %U`; `{ launch = "helium-browser" }` |
| Muse.AI | `alt+M` | `omarchy-launch-webapp "https://muse.ai/"`; `{ webapp = "https://muse.ai/" }` |
| Orca | `alt+O` | `/home/jimmy/Applications/Orca.AppImage %U`; `{ launch = "/home/jimmy/Applications/Orca.AppImage" }` |
| Floorp | `alt+F` | `flatpak run … one.ablaze.floorp`; `o.launch("flatpak run one.ablaze.floorp")` or `uwsm-app -- flatpak run …` |
| Zen | `alt+Z` | `/opt/zen-browser-bin/zen-bin %u`; `{ launch = "/opt/zen-browser-bin/zen-bin" }` |

Example shape:

```lua
o.bind("ALT + H", "Helium", { launch = "helium-browser" })
o.bind("ALT + Z", "Zen Browser", { launch = "/opt/zen-browser-bin/zen-bin" })
```

After moving:

1. Remove the `shortcut` value in Vicinae (GUI or JSONC edit), so only Hyprland owns the chord.
2. Reload Vicinae/Hyprland at a time James can step away.
3. Update `Launcher.js`/the bind target map: once the Vicinae entrypoint is gone, the hint falls back to the Hyprland description. Add/rename the app target to the new `o.bind` description (especially Ghostty, whose old fallback is `Terminal`; Zen, which is not mapped at all in v2).
4. Keep the Vicinae `core.search-emojis` shortcut out of scope unless the build wants to bind a Vicinae-specific emoji action.

## 8. Emoji picker — what exists today

**Plugin:** `/usr/share/omarchy/shell/plugins/emojis/` (`omarchy.emojis`, overlay-only, `keepLoaded: true`).  
**Open:** `Super+Ctrl+E` (Hyprland), menu `Trigger > Emoji` (`omarchy-menu-emoji` → toggles `omarchy.emojis`).  
**Data:** `emojis.json`, 1,870 entries; each entry has only `e` (emoji) and `k` (space-separated names/keywords).  
**Search:** `EmojiSearch.js` lowercases the query and does a substring match against `k` only, capped at 1,000 results. It is not fuzzy and does not search the emoji character itself.  
**Layout:** 400×500 logical card, 44×44 grid cells, keyboard arrows/PageUp/PageDown, Enter inserts.  
**Recently used:** none.  
**Categories:** none. The data has no category field.  
**Pinning/favorites:** none.  
**Symbols:** no typographic symbol table. “em dash” → — does not exist (`em dash`, `emdash`, `—`, `→`, `⌘` all return 0 hits). Emoji arrows and symbol-like emoji exist, but arbitrary text symbols do not.  
**Insertion:** `omarchy-menu-emoji-insert` puts the emoji on the clipboard with `--sensitive`, sleeps, sends `Shift+Insert` via `wtype`, then releases the clipboard. It pastes into the focused app; sensitive copy is skipped by clipboard history.  
**Tokens:** uses the shared `[menu]` surface tokens, not the `[launcher]` tokens. Current Afterburn values: background `#0c0d0b` at alpha 1.0, text `#e8e4dc`, border `hyprland.active-border-foreground`, scrim `#0c0d0b` 0.5, selected background `#e8e4dc` 0.08, selected text `#f59145`; radius = `Style.cornerRadius` (Hyprland rounding 8); font = `Style.font.menuFamily` (JetBrainsMono Nerd Font); search `heading` 16, emoji `display` 24. No blur rule and an opaque background.

### Emoji gaps vs Vicinae parity

- **Search by name:** partial. Substring keywords work for existing emoji names, but “em dash” and typographic symbols do not exist.
- **Recently used:** missing.
- **Categories:** missing (no data field, no UI).
- **Symbols as well as emojis:** missing text-symbol data and symbol search.
- **Pinning/favorites:** missing (not in the stated parity list, but absent).
- **Search by the symbol character itself:** missing; only `k` is matched.
- **Visual parity:** uses `[menu]` (opaque, radius 8, no blur), not `[launcher]` (glass, radius 16, `[launcher]` accents).

To match Vicinae, the build would need: a symbol/category data source, a category UI, persisted recents, search over names/symbols/characters, and a shared token pass so the picker matches the launcher.

## 9. Clipboard picker — what exists today

**Plugin:** `/usr/share/omarchy/shell/plugins/clipboard/` (`omarchy.clipboard`, overlay-only, `keepLoaded: true`).  
**Open:** `Super+Ctrl+V` (Hyprland), menu `Trigger > Clipboard History` (`omarchy-shell shell summon omarchy.clipboard`).  
**Storage:** `~/.local/state/omarchy/clipboard-history.json`, limit 500; current file has **476 entries** (411 text, 65 images), ~660 KB. Images are SHA-256 deduplicated under `~/.local/state/omarchy/clipboard-images`.  
**Capture:** `wl-paste --watch` for text and image/png, started by the plugin; `capture.sh` skips `x-kde-passwordManagerHint` and `CLIPBOARD_STATE=sensitive`; watchers restart if they die.  
**Search:** substring over text + file names + image metadata, capped at 50 displayed rows; not fuzzy, no field syntax.  
**Layout:** 875×600 logical card; left list and right preview/detail pane; 50 rows; row height ~50.  
**Preview + detail:** yes. Text is shown in the right pane; images get a preview; file URIs are detected and named.  
**Type filter:** none. The model knows `text`/`image`/`file`, but there is no filter UI.  
**Recently used:** history order only; no separate recents section.  
**Pause clipboard:** none. The watchers always run; no pause flag or control.  
**Pinning/favorites:** none.  
**Paste to focused app:** yes. Enter pastes via `omarchy-clipboard-paste-text --shift-insert --history-index` (wl-copy + Shift+Insert); images/files use `omarchy-clipboard-paste-file`; Shift+Enter copies only; Alt+Enter opens the item.  
**Clear/delete:** Delete removes one entry; Shift+Delete clears all with confirmation.  
**Tokens:** same shared `[menu]` tokens as emoji; radius 8; font menuFamily; search heading 16, rows title 14, body/caption 12/10; opaque, no blur. The launcher’s `[launcher]` tokens do not apply.

### Clipboard gaps vs Vicinae parity

- **Large-history search:** works but is a full JSON load and linear JS scan; 500-entry cap. No database/index. Current 476 entries are fine; thousands would need a different store.
- **Type filter:** missing.
- **Preview + detail pane:** present.
- **Pause clipboard:** missing.
- **Paste to focused app:** present.
- **Recently used:** only history order; no dedicated recents.
- **Pinning/favorites:** absent (not in the stated parity list, but absent).
- **Visual parity:** `[menu]` opaque/radius 8/no blur, not the launcher glass/radius 16 tokens.

To match Vicinae, the build needs: type-filter UI, pause state + control, optionally pin/favorites, and a token pass; a DB-backed search is only needed if the history target grows well beyond 500.

## 10. Bar access today

**Hotkeys:**
- `Super+Ctrl+E` → Emojis (`omarchy:panel.omarchy.emojis`).
- `Super+Ctrl+V` → Clipboard manager (`omarchy:panel.omarchy.clipboard`).

**Menu:**
- `Trigger > Emoji` → `omarchy-menu-emoji` (toggles `omarchy.emojis`).
- `Trigger > Clipboard History` → `omarchy-shell shell summon omarchy.clipboard`.

**Bar widgets:** none for clipboard or emoji. Both plugins declare only `overlay`; the current `shell.json` bar layout has no clipboard/emoji entries. The bar has `omarchy.menu`, `omarchy.tray`, `omarchy.agents`, etc., but no clipboard/emoji widget.

**Hooks available for adding access:**
- A first-party/third-party plugin with `kinds: ["bar-widget"]` and an `entryPoints.barWidget` manifest, using the `BarWidget` base and `BarIconButton`.
- `~/.config/omarchy/shell.json` `bar.layout.{left,centerBegin,center,centerEnd,right,tray}` entries.
- `omarchy bar set` for scripted config changes.
- Custom bar modules: `type: "command"` with `exec`/`interval`/`onClick`, or `type: "qml"` with a `~/.config/omarchy/bar/modules/*.qml` source.
- The `omarchy.tray` slot can host plugin widgets; the current tray already hosts several user plugins.

A clipboard/emoji bar widget or a status/pause control would have to be built; there is no stock widget to enable.

## 11. Design-token mismatch (important for 3b)

The launcher uses `~/.config/omarchy/shell.toml` `[launcher]`:
- 607×459 max, radius 16/10, glass background 84%, accent selected fill 16%, hint 13, etc.

Emoji/clipboard use the stock `[menu]` + `Style`:
- `[menu]` opaque background (#0c0d0b alpha 1.0), radius 8, no blur, selected background 8%, selected text accent.
- No use of `[launcher]`.

So the pickers currently look like the stock menu, not the v2 launcher. A token pass is required for visual parity. The stock layers `omarchy-emojis` and `omarchy-clipboard` have only a `no_anim` rule; no blur rule.

## 12. Unconfirmed

- The full spec/brief files at `~/workspace/` are missing; this audit uses the chat brief. Re-check parity details if the files exist elsewhere.
- Vicinae app shortcuts were read from `settings.json` and the running server; they were not physically pressed. The Vicinae log confirms the only failing shortcut is the launcher toggle `Alt+Space`, intentionally owned by Hyprland.
- Clipboard history contents were not read for privacy; only counts/types and the file size.
- Vicinae’s own emoji/clipboard UI features were not inspected beyond the parity list in the brief; this report describes the stock Omarchy implementations.
- `Zen` was added to Vicinae at 10:11:23 during the audit; the snapshot is as of that timestamp. If James changes Vicinae again, re-audit.
- The current v2 launcher does not yet show Zen or the `trigger.emoji` hint; these are display-map gaps, not missing binds.
- No build or migration was started, as instructed.
