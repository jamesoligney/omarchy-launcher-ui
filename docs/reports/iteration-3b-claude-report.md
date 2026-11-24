# Iteration 3b, Part A: Claude report (2026-11-23)

Status: partly done. The binds are migrated and registered. The menu code is written and partly exercised live. Key-press verification and the on-screen hint checks are not done, and the first of those needs James at the keyboard.

## Files changed

Outside this repo (live config, not committed):

- `~/.config/hypr/bindings.lua`
  - Added a block after the "Center window" bind: `ALT + M` Muse.AI, `ALT + G` Ghostty, `ALT + H` Helium, `ALT + F` Floorp, `ALT + O` Orca, `ALT + Z` Zen.
  - Super+Return is untouched. It is the stock terminal bind, so Super+Return and Alt+G both stay.
  - A test bind (`ALT + K` 1Password, written by the menu) and a hand test bind (`ALT + Q`) were both added and then removed. The file now has 0 lines matching either test.
  - Backup from before the migration: `bindings.lua.bak.1795466327`.
- `~/.config/vicinae/settings.json`
  - Removed the six `shortcut` entries under `providers.applications.entrypoints`. The block is now `"entrypoints": {}`.
  - Left `providers.core.entrypoints.search-emojis` (`alt+shift+E`) alone. It is a Vicinae core action, not an app launch.
  - Backup: `settings.json.bak.1795466327`.
  - Restarted `vicinae-server` with `--replace`. `vicinae ping` succeeds.
- `~/.config/omarchy/plugins/jimmy.menu/Launcher.js`
  - Removed the hard-coded Vicinae map (`vicinaeEntrypoints`), `vicinaeForApp`, `symbolsForShortcut`, and `resolveAppBind`.
  - Ghostty now maps to "Ghostty" (was "Terminal"). Added id mappings for Helium, Muse.AI, Floorp, Orca and Zen.
  - Added `parseBindingsLua`, `mergeRecords`, `altConflict`, and `appBindLine`.
  - Added a detail line for the new root command.
- `~/.config/omarchy/plugins/jimmy.menu/Menu.qml`
  - Live-read: on every open, the menu runs `cat ~/.config/hypr/bindings.lua`, parses it, and merges it over `omarchy menu keybindings --print`. No cache, no watcher, no baked table.
  - Create-a-bind: a root command "Create app shortcut" is injected in code. Enter opens the Apps list in pick mode. Choosing an app moves to a letter prompt that shows either a conflict message or "Enter to add". Enter appends one line to `bindings.lua`, runs `hyprctl reload`, and closes the menu.
  - Deliberate deviation from "press the keys": Hyprland owns any Alt+letter that is already bound, even while the menu is open. So the letter is typed and the menu adds Alt.
  - Snapshot taken after these edits and before the restart: `~/.local/state/omarchy-launcher-backups/1795466655/jimmy.menu`. There is no copy of the pre-change plugin.
- Shell restarted with `omarchy restart shell`. `omarchy refresh shell` was never run.

In this repo: only this report, `docs/reports/iteration-3b-claude-report.md`.

## Verified live

- The six binds are in the Hyprland table with the right descriptions: modmask 8 (Alt) on M, G, H, F, O, Z. `hyprctl configerrors` is empty after each reload.
- The Helium launch command works: `uwsm-app -- helium-browser` ran and printed its version. The other five launch commands were not run directly.
- The menu opens and renders correctly.
- Typing "create" finds the "Create app shortcut" row.
- Enter moves to the pick stage, which lists apps.
- Picking 1Password and typing `m` shows "Alt + M is already used by Muse.AI". Nothing is written (0 matching lines).
- Picking 1Password and typing `k`, then Enter, appended `o.bind("ALT + K", "1Password", …)`. `hyprctl reload` made it live (modmask 8, key K, description 1Password). Removing it from the file and reloading cleared the live bind.
- Hand-written bind: a line `o.bind("ALT + Q", "Hand test bind", …)` was added and reloaded. It went live, then was removed and reloaded, and it is gone.
- File-only conflict, tested with Node against the real file contents, before any reload: Alt+Q gives "Hand test bind", Alt+M gives "Muse.AI", and Alt+R is free.
- Hint strings, tested with Node against the real `bindings.lua`: Ghostty ⌥ G, Helium ⌥ H, Muse.AI ⌥ M, Zen ⌥ Z, Orca ⌥ O, Floorp ⌥ F, Vicinae ⌥ Space.
- `qmllint` on Menu.qml: no errors. Its warnings are only for unresolved Quickshell imports.

## Not verified

- **Key presses for the six binds.** Synthetic keys (`wtype`) do not fire Hyprland binds in this session. Alt+H, Alt+G and the stock Super+K all produced nothing. Nothing here proves the binds fire on a real keypress.
- **Launching each app by its bind.** Only Helium's command was run directly. Orca and Muse.AI windows were already open, so a press could not be told apart from before.
- **The 1Password hint after removal.** The menu did not show the list. `omarchy-shell shell summon omarchy.menu '{"initialMenu":"apps"}'` opens the app grid, which is a different surface. Typed input is also unreliable: `wtype` dropped or reordered characters, so the search text was garbled.
- **Live menu hints for the six migrated binds.** The hint strings were checked only in Node, not on screen.
- **A hand-added bind appearing in the menu on the next open.** The Node parse and the live registration were checked, but not the menu.
- **A conflict refused by the live menu for a file-only conflict.** Only the logic was checked.
- Not started: the theme-switch re-tint check, the animation (Part C), Parts B and the bar hub, and uninstalling Vicinae.

## Needs James at the keyboard

1. Press each of Alt+M, Alt+G, Alt+H, Alt+F, Alt+O and Alt+Z, and confirm each app opens. Check that Vicinae does not also launch anything.
2. Confirm Super+Return still opens Ghostty.
3. Press Super+Space, go to Apps, and confirm the hints: Ghostty ⌥ G (Super+Return no longer shows on that row, per the decision), Helium ⌥ H, Muse.AI ⌥ M, Floorp ⌥ F, Orca ⌥ O, Zen ⌥ Z. 1Password should show ⌘ ⇧ / with no ⌥ K.
4. Try "Create app shortcut": pick an app, type `m` (should be refused, Muse.AI), then a free letter, then Enter.
5. Decide whether the letter-typing step (instead of pressing Alt+letter) is acceptable.

---

# Launcher animation, fresh pass (2026-11-23)

## Why the earlier springs never felt like the window switch

Every attempt tuned peak or damping of one uniform `scale` spring. The numbers were right but the perception was not, for three reasons:

1. **Overshoot is a fraction of travel, and the travel is tiny.** ζ = 0.75 overshoots 2.8% of the distance travelled. A window moves hundreds of pixels, so that is 20+ px of visible overshoot. The launcher went 0.65 to 1.0 over a 740 px card: peak 1.0111 is about 8 px, spread over ~120 ms. Below perception.
2. **The fade hides the rise.** The 160 ms OutCubic fade is ~70% done by 50 ms, but the spring only crosses 1.0 around 150 ms. The only part with visible motion was the overshoot, which was 1%.
3. **Uniform scale from one spring reads as mechanical.** A real position spring moves a whole object and its neighbours at once. Equal X/Y scaling on a rectangle is one number going up and down, with no secondary motion.
4. Qt `SpringAnimation` is also a fixed-step semi-implicit Euler integrator (numerical damping, step dependent), so ζ was only approximate.

## What changed (`jimmy.menu/Menu.qml`)

- Replaced `SpringAnimation` with an **exact damped oscillator** evaluated from elapsed time: `s(t) = 1 - (1-s0)·e^(-ζωt)·(cos ωd·t + ζω/ωd · sin ωd·t)`. A single linear `springT` (0 to 0.7 s) is animated; frame-rate independent, no integrator damping.
- **Two springs, squash and stretch:** `card.transform = Scale` with separate X and Y.
  - X: start 0.80, ω = 24, ζ = 0.40. Leads, peaks 1.050 at ~135 ms.
  - Y: start 0.70, ω = 20, ζ = 0.46. Lags, peaks 1.058 at ~185 ms.
  - The card therefore goes wide, then tall, then settles with a small undershoot (~0.987). Organic wobble, not three bounces: the second swing is ~1%.
- Fade unchanged (160 ms). Close unchanged (100 ms, `card.scale` to 0.97); `card.scale` is left at 1 on open so the two compose, and an interrupted open closes without a jump.
- Backup of the previous file: scratchpad copy `Menu.qml.pre-boink` (not in the repo).

## Verified live

Temporary `console.log` on a real open (`omarchy restart shell`, never `refresh`). Trace, X / Y:
`0.805/0.706 (10 ms), 0.924/0.838 (60), 1.032/0.988 (110), 1.050/1.033 (135, X peak), 1.047/1.055 (160), 1.032/1.058 (185, Y peak), 0.990/1.017 (260), 0.987/1.003 (285, X trough), 1.003/0.989 (410), 1.000/1.000 (660)`.
This matches the closed-form model. Debug line removed afterwards (0 matches), shell restarted again.

## Not verified

Feel. I cannot judge it by eye. The levers, in order: Y/X start values (travel), ζ (0.40 / 0.46; lower is boingier, ~0.25 starts to look cartoonish), and ω (higher is snappier).

---

# Same animation on the emoji and clipboard pickers (2026-11-23)

## What changed

The launcher's open and close motion is now one shared component, not three copies.

- **New:** `~/.config/omarchy/plugins/jimmy.shared/CardMotion.qml` holds the whole motion: the exact damped-oscillator springs (X: start 0.80, ω 24, ζ 0.40; Y: start 0.70, ω 20, ζ 0.46), the 160 ms fade, and the 100 ms close to 0.97. It exposes `play()`, `hide()`, `stop()` and `xScale`/`yScale`.
- **`jimmy.menu/Menu.qml`:** its inline `springT`, `spring()`, `openAnim` and `closeAnim` were removed and replaced by `CardMotion { id: motion }`. Behaviour is unchanged (re-traced, below).
- **`jimmy.emojis/Emojis.qml` and `jimmy.clipboard/Clipboard.qml`:** the old `0.96 → 1.0` OutCubic zoom and 140 ms fade are gone. Each card gets the same `Scale` transform bound to `motion.xScale/yScale`, and each plugin uses `CardMotion`.
- All three import it by relative path, `import "../jimmy.shared"`.

## Behaviour changes you should know about

- **The pickers had no close animation before.** The layer vanished on dismiss. To give them the launcher's close, each now has a `closing` flag and a 115 ms `closeTimer` (the launcher's mechanism), so the layer outlives `opened` while the 100 ms close plays.
- **Keyboard focus is released at once.** `shownKeyboardFocus` is `Exclusive` only while `opened`, `None` while closing. Without that, a paste fired on dismiss would have reached the fading picker for 115 ms instead of the app underneath. Both pickers dismiss then paste immediately.
- Reopening during the close cancels it and replays the open.

## Verified live (trace on a real open, `omarchy restart shell` only)

Same X / Y / card opacity at matching times in all three:

| t (ms) | launcher | emojis | clipboard |
|---|---|---|---|
| ~11 | 0.800 / 0.700 | 0.8000 / 0.7000 | 0.8000 / 0.7000 |
| ~43 | 0.879 / 0.785 (52) | 0.8540 / 0.7577 | 0.8540 / 0.7577 |
| ~143 | 1.047 / 1.022 (135) | 1.0496 / 1.0320 (X peak) | 1.0496 / 1.0320 |
| ~176 | 1.043 / 1.058 (Y peak) | 1.0431 / 1.0579 | 1.0431 / 1.0579 |
| ~309 | 0.987 / 0.999 (X trough) | 0.9879 / 0.9967 | 0.9879 / 0.9967 |
| ~676 | 1.000 / 1.000 | 1.0001 / 0.9997 | 1.0001 / 0.9997 |

Card opacity reaches 1.00 by ~143 ms in the pickers. Close on the clipboard picker: scale `1.0000 → 0.9700` and opacity `1.00 → 0.03` across the 100 ms, after which the layer is hidden. All debug logging was removed (`grep ANIMDEBUG` returns 0 in every file); emoji picker still opens after the final restart.

## Not verified

- **Close on the emoji picker and the launcher was not re-traced.** They use the same component and the same hook; only the clipboard close was traced.
- **A real paste after a dismiss.** I cannot press keys or paste here, so the focus release is reasoned, not observed. Worth one real emoji insert and one clipboard paste.
- **Feel**, as before.

## Duplication

None of the motion values are duplicated. The remaining per-plugin code is the `closing` flag, the 115 ms timer and the `Scale` transform (about 15 lines each in the two pickers). The launcher has its own equivalent.

## Coupling note

The three plugins now depend on `jimmy.shared` being present. It has no manifest and no entry point, so it is not a plugin itself. The shell logs "Local plugin changed, reloading: jimmy.shared" when it is edited, which is harmless. These files live under `~/.config/omarchy/plugins/` and are not tracked in this repo.

---

# Keyboard-switchable chips: clipboard and emoji pickers (2026-11-23)

## What changed

Both pickers handle the chip keys in the search field's existing `Keys.onPressed` (priority `BeforeItem`), so focus never leaves the search field and typing keeps working. The filter changes on the keypress itself (`setTypeFilter` / `setCategory`, which rebuild the list at once).

**Clipboard** (`jimmy.clipboard/Clipboard.qml`)
- `Ctrl+1` All, `Ctrl+2` Text, `Ctrl+3` Images, `Ctrl+4` Files.
- `Tab` / `Right` next chip, `Shift+Tab` / `Left` previous, wrapping. The search line has no text cursor of its own, so plain Left and Right were free.
- The chip list moved from `filterRow.filters` to `root.typeFilters`, so the keys and the chips read one list.

**Emoji** (`jimmy.emojis/Emojis.qml`)
- There was no "All" chip (the picker opened on all with nothing highlighted). I added one as the first chip so the open state is visible and reachable by key.
- `Ctrl+1` All, `Ctrl+2` to `Ctrl+9` Smileys, People, Animals, Food, Travel, Activities, Objects, Symbols, and `Ctrl+0` Flags (the tenth chip).
- `Tab` next, `Shift+Tab` previous, wrapping. Left and Right stay with the emoji grid; I did not add chip arrows here because they would take over grid navigation.
- Categories only apply while browsing (the chips are hidden during a search), so a chip key also clears the search text and shows that category. That is a choice; say if you would rather the keys do nothing while searching.

**Hints on the chips:** each chip shows its shortcut after the label as `⌃N`, in the launcher's `hint-alpha` colour, one point smaller. Both pickers got a `hintText` colour matching the launcher's token. Emoji chip padding was tightened (10 instead of 24) because ten chips with hints first overflowed the card ("Flags ⌃0" was clipped); a screenshot after the fix shows all ten fitting.

## Verified live (`omarchy restart shell` only)

Synthetic keys via `wtype`, a temporary log on the filter property, and `grim` screenshots:

- Clipboard: `Ctrl+3` image, `Ctrl+2` text, `Tab` image, `Left` text, `Ctrl+1` all. Screenshot after `Ctrl+3`: Images chip highlighted, list shows only screenshots.
- Emoji: `Ctrl+3` people, `Ctrl+0` flags, `Tab` all (wrap), `Tab` smileys, `Ctrl+1` all. Typing a letter afterwards still reached the search field.
- Backward step: `ISO_Left_Tab` (what a real Shift+Tab produces) gave smileys, people, smileys, all.
- Debug logging removed (0 matches in both files). Both pickers still open after the final restart.

## Not verified

- **Shift+Tab as `wtype -M shift -k Tab`** stepped forward, so the handler also treats Tab with the Shift modifier as backward, but I could not confirm that path. Please press a real Shift+Tab once.
- **Typing after a chip key in the clipboard picker** was not tested; the emoji picker was.
- **How the hints look.** I looked at the screenshots but cannot judge the design for you.

---

# Chip shortcuts moved from Ctrl to Option (2026-11-23)

Both pickers now switch chips with **Option (Alt) + number** instead of Ctrl + number. Hints on the chips read `⌥N` instead of `⌃N`.

- **Clipboard:** `⌥1` All, `⌥2` Text, `⌥3` Images, `⌥4` Files.
- **Emoji:** `⌥1` All, `⌥2` to `⌥9` Smileys, People, Animals, Food, Travel, Activities, Objects, Symbols, `⌥0` Flags.
- `Tab` / `Shift+Tab` (and Left/Right in the clipboard picker) are unchanged.
- Code: the modifier check is now `Qt.AltModifier` and the hint glyph is `⌥`, in `Clipboard.qml` and `Emojis.qml`. Nothing else changed. On Linux, Option is the Alt key.
- Checked first that no Hyprland bind uses Alt plus a digit (`hyprctl binds`: none), so the keys reach the picker.

## Verified live

One `omarchy restart shell`, then one open per picker, `wtype -M alt <digit>`, and screenshots of the chip row. No debug logging was added this time.

- Clipboard: `⌥3` highlights Images, then `⌥2` highlights Text. All four chips show `⌥1` to `⌥4`.
- Emoji: `⌥5` highlights Food, `⌥0` highlights Flags. All ten chips show `⌥1` to `⌥9` and `⌥0`; the row fits inside the card.

## Not verified

- `⌥1` and `⌥4` (clipboard) and the other emoji keys were not pressed individually; they share the one handler that `⌥2`, `⌥3`, `⌥5` and `⌥0` went through.
- Typing into the search field after an Option key press, in either picker.
- A real keyboard rather than `wtype`, in particular whether Option on the Mac keyboard layout reaches the app as Alt.

---

# One pin key, and a keyboard audit of all three UIs (2026-11-23)

## 1. Pin is ⌥P everywhere

- **Clipboard:** `⌥P` pins / unpins the selected item (was `Ctrl+P`). The Pin button in the detail pane now shows `⌥P` on itself.
- **Emoji:** `⌥P` pins / unpins (was `Ctrl+P`). The emoji picker has no pin button, so the hint is in its footer.
- `Ctrl+P` no longer does anything in either picker (checked live).

## 2. Audit: every clickable element in the launcher, emoji and clipboard UIs

Method: grepped every `MouseArea` / `onClicked` and every `Keys.onPressed` branch in `Menu.qml`, `Emojis.qml` and `Clipboard.qml`, and read each one. I also checked which Alt letters Hyprland owns, because Hyprland keeps those even while a picker has keyboard focus: `hyprctl binds` shows Alt + `F G H M O Z`, `Space`, `Tab`. So Option shortcuts must avoid those. `P` and `S` are free.

| UI | Element | Was | Now |
|---|---|---|---|
| Clipboard | **Pause / Resume button** | **mouse-only** | **`⌥S`**, hint on the button (`⏸ Pause ⌥S`, `▶ Resume ⌥S`) and in the footer |
| Clipboard | Pin button (detail pane) | `Ctrl+P` | **`⌥P`**, hint on the button |
| Clipboard | Type chips | `⌥1`–`⌥4` (last round) | unchanged, hints on chips |
| Clipboard | Row click = paste | Enter | unchanged |
| Clipboard | Copy | `Shift+Enter`, listed in footer | unchanged |
| Clipboard | **Open** | `Alt+Enter`, **not shown anywhere** | unchanged key, now in the footer as `⌥Enter open` |
| Clipboard | Remove one | `Del`, in footer | unchanged |
| Clipboard | **Clear history** | `Shift+Del`, **not shown anywhere**, no button | unchanged key, now in the footer as `⇧Del clear` |
| Clipboard | Clear confirm dialog | keyboard (Enter, Esc, Tab/arrows) | unchanged |
| Clipboard | Backdrop click closes | Esc | unchanged |
| Emoji | Category chips | `⌥1`–`⌥0`, Tab (last round) | unchanged, hints on chips |
| Emoji | Pin | `Ctrl+P` | **`⌥P`**, hint in footer |
| Emoji | Grid cell click = paste | Enter | unchanged |
| Emoji | Backdrop click closes | Esc | unchanged |
| Emoji | Footer | `Enter paste · Ctrl+P pin · Esc close` | `Enter paste · ⌥P pin · ⌥1–0 or Tab category · Esc close` |
| Launcher | Row click | Enter / arrows | unchanged |
| Launcher | Uninstall app | `Del`, confirm dialog is keyboard-driven | unchanged (see below) |
| Launcher | Create-shortcut flow | fully keyboard (pick, letter, Enter, Esc) | unchanged |
| Launcher | Backdrop click closes | Esc | unchanged |
| Launcher | Bar icon (launcher widget) | click | unchanged (see below) |

Only one element was truly mouse-only: the clipboard **Pause** button. Two keyboard-only actions (Open, Clear history) had no on-screen hint; they now do.

## 3. Deliberately not changed

- **Copy, Open, Remove, Clear keep their existing keys** (`Shift+Enter`, `Alt+Enter`, `Del`, `Shift+Del`) instead of being moved to new Option letters. They are already keyboard-reachable and the natural keys for those actions; moving them would be churn. Open is `⌥Enter`, so it already follows the Option pattern. I only made them visible.
- **Launcher `Del` to uninstall has no on-screen hint.** The launcher has no footer, and the selected row's right side is already the bind hint, so a hint would need a design decision. Flagging it rather than inventing a place.
- **The launcher's bar icon stays mouse-only.** A bar widget is a pointer target by nature; the keyboard path to the same action is `Super+Space`.
- **Backdrop click to dismiss** stays as a mouse affordance; `Esc` is the key.
- **Mouse wheel scrolling** has no extra key; the list and grid already scroll with arrows, PageUp/PageDown, Home and End.
- **The emoji pin has no button.** I did not add one; the pinned marker on the glyph is its only visual, and the footer carries `⌥P`.

## Risks to know about

- `⌥P` and `⌥S` are now used inside the pickers. If someone later creates an app shortcut on Alt+P or Alt+S (the launcher's create-a-bind flow), Hyprland would take the key while a picker is open. The launcher's conflict check only knows Hyprland binds, not these picker keys.
- The footer is long on the clipboard picker (`Enter paste · ⇧Enter copy · ⌥Enter open · ⌥P pin · ⌥S pause · Del remove · ⇧Del clear · Esc close`). It fits at the current width in the screenshot; a narrower card would need it to elide or wrap.

## Verified live

One `omarchy restart shell`, one open of each picker, keys sent with `wtype`, screenshots of the whole card. No debug logging. Every toggle was undone, and the state files were checked afterwards: `emoji-pins.json` `[]`, `clipboard-pins.json` `[]`, `clipboard-paused` `0`.

- Clipboard: `⌥S` changed the button to `▶ Resume ⌥S` (highlighted); `⌥S` again restored `⏸ Pause ⌥S`. `⌥P` changed the button to `📌 Pinned ⌥P` and marked the row; `⌥P` again unpinned. `Ctrl+P` left it unpinned. Footer is fully visible.
- Emoji: `⌥P` pinned the selected emoji (marker and a pinned row appeared); `⌥P` again unpinned; `Ctrl+P` did nothing.

## Not verified

- **A real keyboard.** `wtype` only, as before; whether Option on the Mac layout arrives as Alt.
- **Open (`⌥Enter`), Clear (`⇧Del`) and Remove (`Del`)** were not pressed (they change the user's real history). Only their footer text was checked.
- **Launcher UI**: audited by reading the code, not by pressing keys in it this round.
- **Typing after ⌥S or ⌥P** into the search field.

---

# Emoji Recently used strip: visible pinned items, keyboard access (2026-11-23)

## 1. Why the em dash was invisible, and the fix

The glyph `Text` in the strip (and in the main grid) had **no colour set**. QtQuick `Text` defaults to black, so a text-style symbol such as `—` was black on a dark card. Colour emoji were unaffected because they are colour glyphs, which is why only symbols disappeared. The same bug was in the grid, so symbols there were invisible too.

Changes in `jimmy.emojis/Emojis.qml`:
- Both glyph `Text` items now use `root.foreground`.
- Each strip item is now a **bordered box with a background** (`foreground` at 7% fill, 1 px border at 14%; pinned items get a stronger border at 35%), and the glyph renders at `displayLarge` instead of `display`. The strip is taller to fit (`recentsHeight` is `cellSize + 24` instead of a fixed 62).
- The **selected** strip item gets the selection background and the accent border, and its **name** appears on the "Recently used" line: the first two words in the foreground colour, the rest muted. For `—`: **em dash** mdash emdash long horizontal bar. For 😀: **grinning face** smile happy. The names come from the existing search keywords in `emoji-data.json` (`glyphNames`, built once when the data loads); there is no separate name field in the data, so these are the search words rather than a curated name.

## 2. Keyboard access to the strip

- **Up** from the grid's first row moves focus into the strip (on its first item, or the last one you were on).
- **Left / Right** move between items (pinned first, then recent), stopping at the ends.
- **Down** returns to the grid, on the cell you left.
- **Enter** pastes the strip item. **⌥P** pins / unpins it. Page Up / Page Down also leave the strip.
- Focus leaves the strip when you type, change category, reopen, move the mouse over the grid, or when the strip disappears (search). The grid highlight is hidden while the strip has focus, so only one thing looks selected.
- The footer now reads `Enter paste · ⌥P pin · ↑ recent · ⌥1–0 or Tab category · Esc close`.

## 3. Standing rule: the clipboard picker

Checked for both problems:
- **Invisible pinned items:** none. Pinned clipboard items are normal rows in the main list (hoisted to the top by `ClipboardHistory.js`), with the same explicit text colour as every other row, a 📌 marker and a "Pinned ⌥P" button in the detail pane. Screenshots from the last round show a pinned row clearly.
- **Unreachable pinned area:** none. There is no separate pinned strip. The pinned rows are the first rows of the list, so Up / Down / Home reach them and Enter pastes them.
- **No change made** to the clipboard picker. One edge case I did not fix: a pinned text item that is only whitespace would render as an empty-looking row.

## Verified live

One `omarchy restart shell` per code change (two in total), real opens of the emoji picker, keys via `wtype`, screenshots of the strip. Your real pins were used: `["—"]`. To test Left / Right I pinned 😀 temporarily and unpinned it afterwards; `emoji-pins.json` was checked afterwards and is `["—"]` again.

- Strip at rest: the em dash is a bordered box with a light glyph and a pin marker.
- Up from the first row: the em dash box takes the accent border, the grid cursor disappears, and `em dash mdash emdash long horizontal bar` appears on the label line.
- Right: moves to 😀 and the line reads `grinning face smile happy`. Left goes back. Down returns the highlight to the grid's first cell. Pinning from inside the strip (⌥P) removed 😀 from the strip.
- Name line first rendered too low (baseline anchoring); fixed to centre on the label and rechecked after a restart.

## Not verified

- **Enter on a strip item.** I did not press it: it pastes into the focused window, which here is this session. It goes through the same `activateGlyph` the strip click already used.
- **A long strip** (many recents) scrolling horizontally with Left / Right. Only two items existed; the scroll call is `positionViewAtIndex(..., Contain)`.
- **Feel and the look of the boxes** beyond what the screenshots show.

---

# Fallback snapshot of the live launcher code (2026-11-23)

A copy of the live files was committed so there is a known-good point to restore. Nothing was moved or edited: SHA-256 of all 17 live files (the four plugin folders and `bindings.lua`) was taken before and after the copy and is identical, and each copied folder was diffed against its live source (identical).

## Committed

Under `plugins/` (copied from `~/.config/omarchy/plugins/`):
- `jimmy.menu/`: `Menu.qml`, `Launcher.js`, `MenuModel.js`, `BarWidget.qml`, `manifest.json`, `README.md` (the plugin's own)
- `jimmy.emojis/`: `Emojis.qml`, `EmojiSearch.js`, `emoji-data.json`, `manifest.json`
- `jimmy.clipboard/`: `Clipboard.qml`, `ClipboardHistory.js`, `capture.sh`, `manifest.json`
- `jimmy.shared/`: `CardMotion.qml`
- `plugins/README.md`: says the live source is `~/.config/omarchy/plugins/` and gives the restore steps

Under `config/` (copied from `~/.config/hypr/`):
- `bindings.lua`
- `config/README.md`: says the live source is `~/.config/hypr/bindings.lua` and gives the restore steps

## Deliberately not committed

- `jimmy.menu/Menu.qml.bak.3b-anim` and every other `*.bak*` file (stale backups), including the `bindings.lua.bak.*` copies.
- Runtime state under `~/.local/state/omarchy/` (clipboard history, pins, recents, pause flag). Clipboard history can hold anything you copied, so it stays out of git.
- `~/.config/omarchy/shell.toml` (the `[launcher]` design tokens, including the glass alpha). It was not on the list, so it is **not** in this snapshot; restoring the plugins alone will not bring back a changed token.

## Restore

Plugins (restore all four together; the three UIs import `../jimmy.shared`):

```bash
cp -a plugins/jimmy.menu plugins/jimmy.emojis plugins/jimmy.clipboard plugins/jimmy.shared ~/.config/omarchy/plugins/
omarchy restart shell
```

Binds:

```bash
cp -p config/bindings.lua ~/.config/hypr/bindings.lua
hyprctl reload
```

`cp -a` overwrites same-named files and leaves other live files in place. Back up the live `bindings.lua` first if it has binds you want to keep. `omarchy restart shell` only, never `omarchy refresh shell`.

The snapshot reflects the state at the commit that adds it: the Option-key chips, Option+P pin, Option+S pause, the shared card motion, and the emoji Recently used strip changes.


---

# Complete fallback snapshot (2026-11-23)

This **replaces the earlier "Fallback snapshot of the live launcher code" section**, which covered only four plugin folders and `bindings.lua` and missed `shell.toml`, `shell.json`, the other Hyprland files, the hooks and more. It was a fraction. This round started with an audit of everything that determines how the launcher, emoji picker, clipboard picker, bar, animation and binds behave, and the snapshot follows that audit.

## What the audit found

- **Launcher and pickers:** the four `jimmy.*` plugin folders; the glass blur rule for the three picker layers in `hypr/menu-glass.lua`; the design tokens in `shell.toml` (`[launcher]`); the launcher's menu rows in `extensions/omarchy-menu.jsonc`; the bar entry and the `disabledPlugins` / `cloneSourceRestores` lists in `shell.json` (these are what make the clones replace the stock menu, emoji and clipboard plugins).
- **Bar:** `shell.json` (layout, plugin settings), `shell.toml` (`[bar]`), the user's own bar plugins `jimmy.workspaces`, `jimmy.active-window`, `jimmy.idle`.
- **Animation:** `jimmy.shared/CardMotion.qml` (picker motion), `hypr/tricky-tiles.lua` and `tricky-tiles.json` (window-switch spring), `hypr/omarchy_fx.lua`, `hypr/border-fx.lua`, `hypr/no-shadow.lua`, `hypr/looknfeel.lua`, `omarchy-fx.conf`.
- **Binds:** `hypr/bindings.lua` (single source of truth), `hypr/hyprland.lua` (the loader that decides which files run and in what order), `hypr/autostart.lua`, `hypr/input.lua`, `hypr/monitors.lua`; `vicinae/settings.json`, which I edited in Part A.
- **Theme tinting:** the theme files that give the launcher its colours (`colors.toml`, `hyprland.lua`, editions) and the `theme-set.d` hooks that rewrite `shell.json` colour keys on a theme change.

## Committed (159 files under `plugins/` and `config/`, including the two READMEs and the plugin inventory)


- `config/`: `README.md`
- `config/hypr/`: `.luarc.json`, `autostart.lua`, `bindings.lua`, `border-fx.lua`, `hyprland.lua`, `hyprsunset.conf`, `input.lua`, `looknfeel.lua`, `menu-glass.lua`, `monitors.lua`, `no-shadow.lua`, `omarchy_fx.lua`, `tricky-tiles.lua`, `xdph.conf`
- `config/omarchy/extensions/`: `omarchy-menu.jsonc`
- `config/omarchy/hooks/battery-low.d/`: `play-warning-sound.sample`
- `config/omarchy/hooks/font-set.d/`: `show-font-notification.sample`
- `config/omarchy/hooks/post-boot.d/`: `weather.sample`
- `config/omarchy/hooks/post-update.d/`: `show-update-notification.sample`
- `config/omarchy/hooks/pre-refresh-pacman.d/`: `add-custom-repo.sample`
- `config/omarchy/hooks/theme-set.d/`: `10-owe-sync`, `50-afterburn-extras`, `60-borderfx-colors`, `show-theme-notification.sample`
- `config/omarchy/`: `omarchy-fx.conf`, `shell.json`, `shell.toml`, `third-party-plugins.tsv`, `tricky-tiles.json`
- `config/omarchy/tweaks/`: `README.md`, `active-window-app-name.md`, `border-fx-rust-toolchain.md`, `close-window-or-tab.md`, `cmatrix-screensaver.md`, `fathom-alt-tab.md`, `ghostty-font-size.md`, `glyph-menu-launcher.md`, `klack-pack-switcher.md`, `klack-soundpack-keycodes.md`, `lock-explorer-weather-units-issue.md`, `lock-screen-explorer.md`, `parked-ideas.md`, `plugins-to-revisit.md`, `scratchpad-hotkey.md`, `workspaces-focused-first.md`, `yt-idle-inhibit.md`, `yt-mini-video.md`
- `config/vicinae/`: `settings.json`
- `plugins/`: `README.md`
- `plugins/jimmy.active-window/`: `ActiveWindow.qml`, `manifest.json`
- `plugins/jimmy.clipboard/`: `Clipboard.qml`, `ClipboardHistory.js`, `capture.sh`, `manifest.json`
- `plugins/jimmy.emojis/`: `EmojiSearch.js`, `Emojis.qml`, `emoji-data.json`, `manifest.json`
- `plugins/jimmy.idle/`: `IdleModel.js`, `Service.qml`, `manifest.json`
- `plugins/jimmy.menu/`: `BarWidget.qml`, `Launcher.js`, `Menu.qml`, `MenuModel.js`, `README.md`, `manifest.json`
- `plugins/jimmy.shared/`: `CardMotion.qml`
- `plugins/jimmy.workspaces/`: `Workspaces.qml`, `manifest.json`
- `config/omarchy/themes/`: small text files only (`colors.toml`, `hyprland.lua`, `edition.conf`, `icons.theme`, `btop.theme`, `neovim.lua`, `CHANGELOG.md`, the `.editions/` and `extras/` text files) for `afterburn-cyber` (6 files), `afterburn-lite` (4 files), `afterburn-overdrive` (5 files), `afterburn-phantom` (4 files), `afterburn-redline` (5 files), `afterburn-voltage` (5 files), `afterburn` (58 files)

`config/omarchy/third-party-plugins.tsv` lists the 16 third-party plugins (id, version, size) so they can be reinstalled.

## Excluded, and why

**Runtime state, never in git (backed up locally instead):**
- Everything in `~/.local/state/omarchy/`: `clipboard-history.json` (about 730 KB), `clipboard-images/`, `clipboard-pins.json`, `clipboard-paused`, `emoji-pins.json`, `emoji-recents.json`, `notifications/`, `current/` (active theme copy), `toggles/`, `windows/`, `workspace-layouts/`, the logs and lock files. Clipboard history and notifications can contain copied secrets.
- `~/.config/omarchy/defaults/` (`agent`, `dictation` which is mode 600, `dictation.lock`) and `lock-explorer.json` (generated by a plugin): private or generated, not launcher behaviour.
- **Local backup:** `/home/jimmy/.local/state/omarchy-launcher-backups/state-20261123-150633` (mode 700, 134 MB). It holds `omarchy-state/` (a full copy of the state dir) and `excluded-config/` (the two items just above), plus a `RESTORE.txt`. It is on this machine only.

**Not behaviour, or reproducible:**
- **Third-party plugin code** (16 folders, about 150 MB): upstream code, reinstallable, listed in the `.tsv`. Their settings are in `shell.json` (committed). I did not inspect the third-party folders for plugin-local data files, so anything a plugin keeps inside its own folder is not covered.
- **Wallpapers and images:** `~/.config/omarchy/backgrounds/` (23 MB), every theme's `backgrounds/`, `preview*.png`, `unlock.png`. They set the look behind the glass but not behaviour; large binaries.
- **Rest of the theme repos:** `.git/`, `tests/`, `tools/`, `docs/`, README/LICENSE/WALLPAPERS of the Afterburn themes (each theme is its own upstream git clone, 394 MB in total), and files over 200 KB.
- **Lock screen and screensaver:** `lock-designs/`, `lock-videos/`, `lock-components/`, `matrix-screens/`, `branding/`, `themed/`. They do not touch the launcher, pickers, bar, animation or binds.
- **Backups of the backups:** every `*.bak*` file (17 `shell.json.bak*`, 7 `bindings.lua.bak*`, 7 `hyprland.lua.bak*`, `omarchy-menu.jsonc.bak*`, `tweaks/README.md.bak*`, `Menu.qml.bak.3b-anim`, Vicinae's `settings.json.bak*`). Superseded copies, some mode 600; the live files are the source.
- **Stock Omarchy** (`/usr/share/omarchy`): not ours, and updates replace it. Per AGENTS.md we never edit it.
- **Not looked at:** the font setting (`omarchy-font-current`) and anything Omarchy or Hyprland keeps outside `~/.config/hypr`, `~/.config/omarchy` and `~/.config/vicinae`. I did not trace where the font is stored. Vicinae's own clipboard database and data folder were not touched or copied.

A secret scan (API key, token, password, private key, bearer patterns) over every committed file found nothing real. The only matches were the word "password" in comments and app names, and Vicinae's empty credential fields.

## Verified

- SHA-256 of all 156 live source files was taken before the copy and again after: identical. Nothing live was edited or moved.
- Every committed file was compared with its live source byte for byte: all identical.
- The staged files were checked for state-like names and secret patterns: none. The only name matches were three stock `*-notification.sample` hook files.
- `omarchy restart shell` was not needed; nothing live changed.

## Restore

From the repo (details in `plugins/README.md` and `config/README.md`):

```bash
cp -a plugins/jimmy.* ~/.config/omarchy/plugins/            # the seven user plugins; restore together
install -m 755 plugins/bin/omarchy-launcher-paste ~/.local/bin/omarchy-launcher-paste
cp -a config/hypr/. ~/.config/hypr/ && hyprctl reload
cp -p config/omarchy/shell.json config/omarchy/shell.toml config/omarchy/tricky-tiles.json config/omarchy/omarchy-fx.conf ~/.config/omarchy/
cp -p config/omarchy/extensions/omarchy-menu.jsonc ~/.config/omarchy/extensions/
cp -a config/omarchy/hooks/. ~/.config/omarchy/hooks/
cp -a config/omarchy/tweaks/. ~/.config/omarchy/tweaks/
cp -a config/omarchy/themes/. ~/.config/omarchy/themes/
cp -p config/vicinae/settings.json ~/.config/vicinae/settings.json
omarchy restart shell
```

Back up the live `shell.json` and `bindings.lua` first if they hold anything you want to keep. `cp -a src/. dest/` merges and never deletes. **Never `omarchy refresh shell`**: it resets `shell.json` to defaults. Reinstall third-party plugins from the `.tsv`.

From the local state backup (machine only): see `/home/jimmy/.local/state/omarchy-launcher-backups/state-20261123-150633/RESTORE.txt`. The short version is `cp -a /home/jimmy/.local/state/omarchy-launcher-backups/state-20261123-150633/omarchy-state/clipboard-history.json ... ~/.local/state/omarchy/` for just the picker data, or `cp -a /home/jimmy/.local/state/omarchy-launcher-backups/state-20261123-150633/omarchy-state/. ~/.local/state/omarchy/` for everything.

## Standing rule added

`AGENTS.md` now has a "Backups — standing rule" section: backups must be complete, audit first, never commit a fraction; name anything left out and why; never put runtime state in git, back it up locally in a timestamped mode-700 folder; verify live files unchanged and snapshot equals live.

# Picker paste into Floorp (2026-11-24)

Both pickers closed and pasted nothing into Floorp. The same Enter paste worked in Helium. One shared helper now picks the chord. The launcher does not paste, so it was left alone.

## What happened

Reproduced in a focused Floorp text field, once from the emoji picker and once from the clipboard picker: the picker closed, focus returned to Floorp, and the field did not change.

## Root cause

Both pickers called the stock insert binaries, and both binaries paste with `wtype` `Shift+Insert`:

- Emoji: `omarchy-menu-emoji-insert` copies with `wl-copy --sensitive`, waits 0.15s, sends Shift+Insert, then drops the clipboard.
- Clipboard text: `omarchy-clipboard-paste-text --shift-insert --history-index`.
- Clipboard image/file: `omarchy-clipboard-paste-file`, which ends on the same Shift+Insert.

Floorp is Firefox. Firefox-family editable fields do not implement Shift+Insert. They paste on Ctrl+V. Helium (Chromium) does implement Shift+Insert, which is why only Floorp failed.

Floorp being a Flatpak is not the cause. `wtype` delivers the key at the compositor, and the window class `one.ablaze.floorp` was visible to `hyprctl`. Focus is also not the cause: the picker dismisses before the helper runs, the layer drops keyboard focus on dismiss, and the helper waits 0.15s before sending the chord, so the key hits the app underneath.

A second gap showed up while checking terminals. Ghostty binds Shift+Insert to `paste_from_selection` (the primary selection), so a clipboard entry never lands there. Its clipboard paste chord is Ctrl+Shift+V. A direct Shift+Insert into Ghostty pasted the primary selection; Ctrl+Shift+V pasted the clipboard.

## The fix

One helper, `~/.local/bin/omarchy-launcher-paste`. Both pickers call it and nothing else sends a paste chord:

- `jimmy.emojis/Emojis.qml` — `activateIndex` and `activateGlyph` run `omarchy-launcher-paste emoji <glyph>`.
- `jimmy.clipboard/Clipboard.qml` — Enter runs `omarchy-launcher-paste text --history-index N` or `omarchy-launcher-paste file <mime> <path>`.

The helper copies first (stock `--copy-only` for history text and files; `wl-copy --sensitive` for emoji, same as stock), waits 0.15s, reads `hyprctl activewindow`, and sends:

- Ctrl+V for Firefox-family classes and comms (Floorp, Firefox, LibreWolf, Zen, Waterfox).
- Ctrl+Shift+V for terminals (Ghostty, Alacritty, kitty, foot, WezTerm, GNOME Terminal, Konsole, Tilix, Terminator).
- Shift+Insert for everything else, which is the old stock behaviour.

Copy-only (Shift+Enter) still calls the stock binaries and sends no key. The launcher has no paste path.

## Files

Live:

- `~/.local/bin/omarchy-launcher-paste` (new)
- `~/.config/omarchy/plugins/jimmy.emojis/Emojis.qml`
- `~/.config/omarchy/plugins/jimmy.clipboard/Clipboard.qml`

Repo snapshot (fallback; live files stay the source):

- `plugins/bin/omarchy-launcher-paste`
- `plugins/jimmy.emojis/Emojis.qml`
- `plugins/jimmy.clipboard/Clipboard.qml`
- `plugins/README.md` (restore now installs the helper)

No stock file under `/usr/share/omarchy` was edited. No debug `console.log` or `ANIMDEBUG` left in the picker or launcher QML. Shell reload was `omarchy restart shell` only.

## Backup

`/home/jimmy/.local/state/omarchy-launcher-backups/20261124-112810-paste-fix` (mode 700). It holds both picker plugins, the launcher clone, `jimmy.shared`, the helper, `shell.json`, `shell.toml`, `bindings.lua`, and `menu-glass.lua`. Checksums before and after the copy matched, and the snapshot matched live at the time. Runtime state (clipboard history, pins, recents, pause flag) was left out on purpose. Not included, and why: themes, the bar, and other plugins are not on the paste path.

After that snapshot, only the two QML comments were reworded so they mention the terminal chord. The paste calls and the helper are byte-for-byte the verified ones.

## Verified live

Done in the session that wrote the helper, against the same helper and the same paste calls. Results read back from the focused app, not from a screenshot of the picker:

- Floorp emoji, search "em dash", Enter: the field became `—`.
- Floorp clipboard text, search the copied `FLOORP-CLIP-OK-42`, Enter: that string landed after the em dash.
- Helium emoji, same search, Enter: `—`.
- Helium clipboard text, search `HELIUM-CLIP-OK-42`, Enter: that string landed.
- Ghostty, helper text paste of `TERM-HELPER-OK`: the file the terminal was writing received it.
- Ghostty, clipboard picker, search `GHOSTTY-PICKER-OK-77`, Enter: the terminal received it. Shift+Insert alone would have pasted the primary selection instead.
- Floorp image row, Enter: the test page title went to `IMG:1:TXT:0`.
- Helium image row, Enter: the test page title went to `IMG:1:TXT:0`.

The first image attempt on Floorp hit the text row above the image (title `IMG:0:TXT:49`, then a dead `file://` navigation). Moving to the image row and pressing Enter pasted the image. That was selection, not the chord.

Test windows and the two local HTML fixtures were closed and removed afterward.

## Not verified

- Zen, LibreWolf, Waterfox, and the other Firefox-family names in the helper. They are classified and were not opened.
- Terminals other than Ghostty. Only Ghostty was pasted into.
- A paste James types himself. The checks above drove the pickers with `wtype` and read the result back from the window title or the terminal's output file.
- Whether Ctrl+V is the right chord inside a Floorp page that has rebound paste. The test pages used the default content-editable field.
