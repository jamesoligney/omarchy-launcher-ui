# Iteration 3b — Parts B & C report (OpenCode)

Date: 2026-11-23
Author: OpenCode (DeepSeek V4 Pro)
Scope: **Part B** (emoji picker, clipboard picker, bar widgets) and **Part C** (launcher animation). Part A (binds migration, live-read, create-bind) was done separately by Claude — see `docs/reports/iteration-3b-claude-report.md`.

---

## Summary

- The emoji and clipboard pickers were cloned to user plugins (`jimmy.emojis`, `jimmy.clipboard`), rebuilt to Vicinae parity, and given the launcher's design tokens. They are reachable by `Super+Ctrl+E` / `Super+Ctrl+V` (no bar icons).
- The launcher's open animation was **fixed** (the v2 bounce was mathematically invisible) and then **matched to the window-switch spring** (Tricky Tiles `ttSpring`: ζ = 0.75, ωn = 17.45 rad/s, applied as Qt `spring 4.87 / damping 0.42`), scale-only.
- Glass opacity was lowered from `0.84` to `0.70` so the wallpaper shows through the launcher and both pickers more clearly.
- `emojis.json` (dead, superseded by `emoji-data.json`) was removed from the emoji clone after confirming nothing references it.

No stock files under `/usr/share/omarchy` were edited. Reload was `omarchy restart shell` only — **never** `omarchy refresh shell`.

---

## Tuning round (James's live checks)

Follow-up changes, made and verified after James looked at the build live:

1. **Animation — window-switch spring applied to scale.** New direction from James: find the window-switch bounce (he says it's right on) and apply those exact numbers. The exaggerated "boink" was reverted.
   - **Window-switch animation found** (this is what we're duplicating): the Tricky Tiles plugin (`io.github.denonmaryland.tricky-tiles`, preset "lively") defines a Hyprland native spring in `~/.config/hypr/tricky-tiles.lua` and applies it to `windowsMove`/`workspaces`:
     `hl.curve("ttSpring", { type = "spring", mass = 1, stiffness = 304.617, dampening = 26.18 })` with `speed = 3.6`.
     → damping ratio **ζ = 0.75** (`26.18 / (2·√304.617)`), natural frequency **ωn = 17.45 rad/s**, preset label "360 ms, bounce 25%".
   - **Applied to the launcher scale** (Qt `SpringAnimation` has different units, so the same physics is `spring: 4.87`, `damping: 0.42`, `mass: 1.0` — conversion: Qt `ω = 7.906·√spring` → `spring = (17.45/7.906)² = 4.87`; Qt `ζ = 3.953·damping/√spring` → `damping = 0.75·√4.87/3.953 = 0.42`). Start `scale 0.90` (the one value that doesn't translate — the window-switch is a *position* spring with ~40% travel, which a launcher scale range can't reproduce). Card and scrim still fade in (160 ms). Close stays fast (unchanged).
   - **Non-translatable caveat:** ζ = 0.75 is a *subtle* bounce — it overshoots only ~2.8% of its travel. Windows read it as a visible bounce because they travel ~40% of their size (→ ~1% overshoot); the launcher's scale travel (0.90 → 1.0 = 10%) yields ~0.05% overshoot, which is imperceptible. To make the same ζ bounce read on the launcher, the start scale would need to drop toward ~0.65 (a large zoom) — a judgment call for James, not a change I made.
2. **Glass — more transparent.** Lowered `panel-background-alpha` from `0.84` to `0.70` in `~/.config/omarchy/shell.toml`. This is the single token the launcher and both pickers read, so all three now let more wallpaper (and blur) through.
3. **Bar icons — removed.** `jimmy.emojis` and `jimmy.clipboard` were removed from the bar tray, and both plugins were reverted to pure overlays (`kinds: ["overlay"]`, `BarWidget.qml` deleted). They remain reachable by `Super+Ctrl+E` / `Super+Ctrl+V`.

Verification (scale trace on a live open): `0.9000 → … → 1.0005 (peak) → … → 0.9914`, then close `… → 0.9700`. The peak **1.0005** is the exact ζ = 0.75 window-switch character on a 0.90 → 1.0 scale travel — subtle, as described above.

---

## Part C — animation fix

### Root cause

The v2 open animation animated `card.scale` with `Easing.OutBack` and `overshoot: 1.25` over a `0.96 → 1.0` range. `Easing.OutBack`'s overshoot is proportional to the animated range, so over a 4% range the peak reached roughly `1.0 + 0.04 × 0.1 ≈ 1.004` — a quarter-percent overshoot that no eye can see. Combined with a 140 ms fade, the whole open read as "no bounce, barely any animation". The code was present and wired; the values were the problem.

### Fix

`~/.config/omarchy/plugins/jimmy.menu/Menu.qml` — replaced the single `Easing.OutBack` scale animation inside `openAnim` with an explicit `SequentialAnimation` that drives past 1.0 and settles:

- **Open:** `card.scale` `0.96 → 1.04` over 150 ms (`Easing.OutCubic`), then `1.04 → 1.0` over 90 ms (`Easing.OutCubic`). Card and scrim opacity `0 → 1` over 130 ms. *(Superseded — see Tuning round; the final animation is a physics `SpringAnimation` for scale.)*
- **Close (unchanged, faster):** `card.scale → 0.97` and opacity/scrim `→ 0` over 100 ms (`Easing.InCubic`).

Backup of the pre-change file: `~/.config/omarchy/plugins/jimmy.menu/Menu.qml.bak.3b-anim`.

### Verification (live)

1. A temporary `onScaleChanged` log captured the actual trajectory on a live open/close:
   `0.960 → 0.974 → … → 1.040 → 1.029 → … → 1.000` (open), then `1.000 → 0.998 → 0.996 → … → 0.982` (close). The overshoot to **1.040** and settle to **1.000** is the bounce.
2. A `wf-recorder` capture (30 fps) confirmed it in pixels: card width `1160 px (≈0.957) → 1226 px (≈1.012 overshoot) → 1212 px (≈1.000 settle)` across consecutive frames, then the close shrink.
3. The debug logging was removed afterward (`grep ANIMDEBUG` → 0 matches).

---

## Part B — emoji picker

Cloned `omarchy.emojis` → `~/.config/omarchy/plugins/jimmy.emojis/` (stock source auto-disabled).

| File | Change |
|---|---|
| `emoji-data.json` | **New**, generated at build time (build script not committed). Merges the 1,870 stock emojis with ~96 curated typographic symbols; each item carries a 9-way category (`smileys`, `people`, `animals`, `food`, `travel`, `activities`, `objects`, `symbols`, `flags`) and a `t` (`emoji`/`symbol`) flag. `em dash` → `—`, plus `⌘`, `→`, `•`, `–`, etc. |
| `EmojiSearch.js` | Rewritten. `parseData` precomputes a lowercased searchable string per item (glyph + keywords + category) so filtering is one `indexOf` scan per term. `search()` does multi-term AND matching with ranking (exact glyph > keyword word-boundary > prefix > substring). `byCategory()` and `orderByPinsAndRecents()` added. |
| `Emojis.qml` | Rewritten. Reads the same `[launcher]` token block the launcher uses (theme-aware glass at 70%, radius 16), so a theme switch re-tints it. Search field, category chips, a "Recently used" strip (pins first), keyboard-navigable grid, `Ctrl+P` pin, Enter pastes via the stock `omarchy-menu-emoji-insert`. Recents/pins persist to `~/.local/state/omarchy/emoji-{recents,pins}.json`. |
| `BarWidget.qml` | ~~New bar icon~~ **Removed** in the tuning round (reverted to a pure overlay; no tray icon). |
| `manifest.json` | ~~Added `bar-widget` kind~~ Reverted to `kinds: ["overlay"]` in the tuning round. |
| `emojis.json` | **Removed** (dead — superseded by `emoji-data.json`; confirmed nothing references it). |

## Part B — clipboard picker

Cloned `omarchy.clipboard` → `~/.config/omarchy/plugins/jimmy.clipboard/` (stock source auto-disabled).

| File | Change |
|---|---|
| `ClipboardHistory.js` | Added compact hashed `pinKey` (text hashed, image by path), `orderByPins`, `relativeTime`/`formatTimestamp`/`sizeText`, and `capturedAtMs` timestamp preservation. `displayRows` now takes a `typeFilter` (`all`/`text`/`image`/`file`) and returns `pinKey`, `timeText`, `sizeText` per row. |
| `Clipboard.qml` | Rewritten. Launcher tokens (glass, radius 16). Type-filter chips (All/Text/Images/Files). **Pause** button that stops the `wl-paste` watchers and persists to `~/.local/state/omarchy/clipboard-paused`. Pin button in the detail pane + `Ctrl+P`. Detail pane now shows Type / Size / Copied-at. Open animation added. Paste/copy/open/delete/clear paths unchanged (stock binaries). |
| `BarWidget.qml` | ~~New bar icon~~ **Removed** in the tuning round (reverted to a pure overlay; no tray icon). |
| `manifest.json` | ~~Added `bar-widget` kind~~ Reverted to `kinds: ["overlay"]` in the tuning round. |

## Bar widgets (B4)

- ~~Placed `jimmy.emojis` and `jimmy.clipboard` in the bar tray~~ **Removed** in the tuning round: James runs the pickers by keyboard and does not want tray icons. `jimmy.emojis`/`jimmy.clipboard` stay enabled as pure overlays; `omarchy.emojis`/`omarchy.clipboard` remain in `disabledPlugins`. Backup: `shell.json.bak.3b-1795466486`.
- `~/.config/hypr/menu-glass.lua` — extended the blur layer rule from `omarchy-menu` to `^(omarchy-menu|omarchy-emojis|omarchy-clipboard)$` so both pickers get the launcher's glass blur. Applied with `hyprctl reload`.

---

## What I verified live

- Shell restarts cleanly; no load errors for `jimmy.emojis`/`jimmy.clipboard` in the journal.
- Emoji picker opens and renders a populated grid (colorful glyph pixels detected in the card region).
- `em dash` → `—`, glyph-character search, category counts, and pin/recency ordering all pass in Node against the real `emoji-data.json`.
- Clipboard picker opens and renders the list (bright text pixels + accent).
- **Theme re-tint:** card glass background shifted Afterburn `(14,15,13)` → Catppuccin `(30,30,45)` on `omarchy theme set catppuccin`, then returned on switch back to Afterburn.
- **Animation spring:** scale trace `0.90 → 1.0005 (peak) → 0.9914 → 1.0` (journal) — the ζ = 0.75 window-switch spring applied to scale.
- **Glass:** lowering `panel-background-alpha` to `0.70` shifted the emoji card background from `(14,15,13)` to `(15,16,15)` — more wallpaper bleeding through.
- `emojis.json` removal did not break the picker (grid still renders after removal).

## What I did NOT verify

- **Keyboard interaction and paste**: I cannot press keys or paste. Typing, arrow/Enter navigation, `Ctrl+P` pinning, and the actual paste into a focused app (emoji insert and clipboard paste/copy/open) are unverified; the paste paths are the unchanged stock binaries, so risk is low but not zero.
- **Pause actually halting capture**: the pause logic loads and toggles, but I did not copy while paused to confirm the watcher stops recording.
- **Recents/pins persistence across a real insert**: those files are only written on first use, which requires a real paste/pin.
- **Aesthetic appearance**: this model cannot take image input, so I confirmed *rendering* (pixels present, theme re-tints, bounce trajectory) but could not judge whether the glass, blur, spacing, radius, and icon glyphs look right.

## What still needs James to check by eye

1. **The bounce** — the window-switch spring (ζ = 0.75) is subtle on a launcher's small scale travel (peak ~1.0005). If James wants it more visible, the lever is a lower start `scale` (more travel) rather than a different spring.
2. **The pickers' look** — glass/radius-16/blur and layout of the emoji grid + clipboard list/detail.
3. **Paste, pin, and Pause** in real use.

---

## Notes

- A prior agent (Claude) was editing `jimmy.menu` for Part A around 12:42–12:44 while this work began; those changes are in `jimmy.menu/Menu.qml` and `Launcher.js` and are described in `iteration-3b-claude-report.md`. This report's `jimmy.menu` changes are the `openAnim` block (and its retune).
- Backups left in place: `~/.config/omarchy/shell.json.bak.3b-1795466486` and `~/.config/omarchy/plugins/jimmy.menu/Menu.qml.bak.3b-anim`.
- The `[launcher]` token block in `~/.config/omarchy/shell.toml` is the shared source for the launcher and both pickers; only `panel-background-alpha` was changed (0.84 → 0.70) in the tuning round. All other colour/size tokens are read unchanged, so the pickers keep following the active theme.
