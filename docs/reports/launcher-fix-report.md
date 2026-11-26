# Launcher fix: Super+Space restored (2026-11-26)

Built by Claude Sonnet 5.5 from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-launcher-fix-brief.md`. The brief was downloaded first. The theme stays **Afterburn Redline**; it was not switched.

**Cause: Top Bar v5 broke it, and it was my mistake.** V5 deleted `jimmy.menu`'s entry from `shell.json` → `bar.layout.tray`. That entry was the launcher plugin's **only** reference in `shell.json`, and the shell enables a non-first-party plugin only while `shell.json` references it. So the launcher was **disabled**, and Super+Space had nothing to open.

**Fix:** the entry is restored, exactly as it was (`{ "id": "jimmy.menu" }`, last in `bar.layout.tray`). The launcher is enabled again and opens through the bind's own command. Nothing else changed.

## Diagnosis (live, in the brief's order)

1. **The Super+Space bind is intact.** It isn't in `~/.config/hypr/bindings.lua`; it is the stock bind in `/usr/share/omarchy/default/hypr/bindings/utilities.lua`:

   ```lua
   o.bind("SUPER + SPACE", "Omarchy menu", { menu = "root" })
   ```

   The stock helper turns `{ menu = "root" }` into the shell's menu dispatcher (fallback `omarchy-menu toggle root`). `hyprctl binds` shows it live (`modmask 64`, `SPACE`, "Omarchy menu"). `bindings.lua` only has `ALT + SPACE` → Vicinae. The bind was never touched.

2. **The launcher plugin was disabled.** `omarchy-shell shell listPlugins` at diagnosis:

   | Plugin | What it is | enabled |
   |---|---|---|
   | `jimmy.menu` | **"Raycast launcher"**: our clone of `omarchy.menu` (kinds `menu` + `bar-widget`). **This is the launcher Super+Space opens** | **False** |
   | `omarchy.menu` | Stock Omarchy menu: deliberately in `disabledPlugins` (replaced by the clone) | False |
   | `io.github.smoothpixels.glyph-menu` | A third-party **bar button** (Hyprland mark) that opens the same menu. **Not a menu itself** (kind `bar-widget` only) | False |

   **Which is which:**
   - `jimmy.menu` **is** the launcher (the menu plugin itself, which also has a bar icon).
   - `glyph-menu` is only a button that calls it.

   V5's report treated both as "buttons for a menu Super+Space already opens". That is true of their icons, but `jimmy.menu`'s layout entry was also what kept the launcher enabled.

3. **Why the entry mattered** (`/usr/share/omarchy/shell/services/PluginRegistry.qml`, `isEnabled`):

   > Enabled = the plugin id is referenced somewhere in shell.json … `bar.id`, a layout entry inside `bar.layout.*`, or a top-level entry in `plugins[]`. First-party non-bar plugins are implicitly enabled.

   `jimmy.menu` is not first-party and was **not** in `plugins[]`. Its sole reference was the `bar.layout.tray` entry.

4. **What changed in v4 and v5:**
   - **v4** (`ec7879b`) removed only `omarchy.tray`, which is first-party and unrelated: **not the cause**.
   - **v5** (`b571d2d`), in `config/omarchy/shell.json`, removed `- "id": "jimmy.menu"` from `bar.layout.tray`, along with the other five entries: **the cause**.

   The live `shell.json` at diagnosis matched the v5 build-start backup everywhere except `bar.layout`.

## The fix

- Put `{ "id": "jimmy.menu" }` back at the end of `bar.layout.tray`, its pre-v5 position (8 of 8). It was copied from the v5 build-start backup, so it is byte-for-byte the original entry. The shell picked up the `shell.json` change by itself (no restart).
- **It comes back visible**: the launcher's frame icon is back at the end of the bottom row, before the status lights. Row **367 / 717**, still fits. That matches your "see everything, then trim" preference.
- **If you trim that icon later, do it without disabling the launcher:** move `jimmy.menu` into `plugins[]` (loaded, no bar icon) instead of just deleting the layout entry.

## Other v5 removals: checked, no other breakage

| Removed in v5 | Kind | Effect of removal |
|---|---|---|
| `omarchy.keyboard-layout` | First-party bar widget | Bar icon gone only. Nothing else used it |
| `omarchy.power` | First-party bar widget | Bar icon gone. **`jimmy.bar` still hosts it** for the battery's power panel (opened from the right ear in v5's verification; status `hosted` includes it) |
| `omarchy.indicators` | First-party bar widget | Bar icon gone. The `omarchy.indicators refresh` IPC is answered by `jimmy.bar` itself |
| `omarchy.system-update` | First-party bar widget | Bar icon gone only |
| `io.github.smoothpixels.glyph-menu` | Third-party bar widget only | Button gone. It only called the menu `jimmy.menu` provides |

`listPlugins` shows those five as `enabled: False` now, which is expected: they are bar widgets with no layout entry. None is a menu, overlay or service. **The emoji and clipboard pickers** (`jimmy.emojis`, `jimmy.clipboard`) are enabled through `plugins[]` and were never affected.

## Verified live

| Check | Result |
|---|---|
| Bind | Super+Space present in Hyprland (stock `utilities.lua`): "Omarchy menu" → `{ menu = "root" }` |
| Launcher plugin | `jimmy.menu` **enabled: True** after the fix (was False) |
| Opens | Ran the bind's own command, `omarchy-menu toggle root`: the `omarchy-menu` layer appeared, showing **the Raycast-style launcher** ("Search apps and commands…", Apps / Learn / Appearance / Trigger / Setup / Install / Remove). The same command closed it |
| QML | No `jimmy.menu` errors (only the usual "outside of the config folder" scanner note) |
| Bar | 75px; **`[0, 75, 0, 0]`**; left island and right island unchanged; bottom row now 367 / 717 with the launcher icon back; desktop (88, 0, 0) untinted; bar (42, 9, 11) |
| Pickers | `jimmy.emojis`, `jimmy.clipboard` enabled |

![Bar after the fix](launcher-fix/bar-after-fix.png)

## What you need to verify by hand

I can run the bind's command but can't press your keys:

1. **Press Super+Space**: the launcher opens.
2. **Type a search** (an app name): results filter.
3. **Press Enter on an app**: it launches.
4. Optionally, Super+Ctrl+E / Super+Ctrl+C for the emoji and clipboard pickers (unaffected, but quick to confirm).

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold`, `omarchy toggle idle stay-awake` |
| Backup | **`~/.local/state/omarchy-launcher-backups/20261126-141754-launcher-fix`**: mode 700, **2,401 files**, live = backup. Excluded (named): `*.bak*`, `__pycache__`, symlinks, runtime state. No runtime state in git |
| Live after vs backup | Only `shell.json` (one entry restored) |
| Reloads | None needed; the shell reloads `shell.json` itself. No restart, no `hyprctl reload` |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` → **`"enabled":true,"stayAwake":false`** |
| Snapshot | `config/omarchy/shell.json` equals live |
