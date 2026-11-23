# Design spec: Omarchy launcher — simplified Raycast (v1, planning)

## Goal
Make the Omarchy menu (Super+Space) look much more modern — a simplified Raycast — as the first step of a system-wide overhaul that will include the menubar. All GUI components should end up with a consistent, modern look. This is v1: the launcher only. The menubar is phase 2, using the same design tokens.

## Machine / constraints
- Mac (M-series, ARM), Omarchy side (Asahi Linux, Hyprland, Lua config `~/.config/hypr/*.lua`). Do not touch macOS / OmniWM.
- Screen: eDP-1, 3456x2234 physical, scale 2, logical 1728x1117.
- Current theme: Afterburn (was Matte Black as of 2026-11-16 — superseded), default edition — the original orange. Palette: accent #FF9145, ember #FF5A1F, flare #FFC48A, background #0C0D0B, foreground #E8E4DC. Ghostty already follows the Omarchy theme.
- Do not add or change any keybinds. Do not edit stock files in `/usr/share/omarchy` — updates will wipe them.
- James does NOT use Super+Alt+Space (apps-only menu). He uses Super+Space and types the program name.

## Decisions locked (2026-11-23)
1. **Layout:** centered floating panel, Raycast-sized. Search on top, results list below. No full-screen launcher, no extra chrome.
2. **Search scope:** apps + commands. Apps = programs (Helium, Ghostty, Files). Commands = Omarchy's own actions (change theme, update Omarchy, install a package, toggle Wi-Fi/Bluetooth/night light/do-not-disturb, lock, restart, screenshot, etc.).
3. **Theme — theme-aware, not fixed:** James is using Afterburn, and the launcher's colors must follow the active theme — Afterburn when he's on Afterburn, and any theme outside the Afterburn setup when he switches. No hardcoded palette. Do NOT hardcode Matte Black (earlier decision, superseded 2026-11-23). The launcher must read its colors from the active theme's `colors.toml` / shell tokens, the same way Ghostty follows the Omarchy theme, so a theme switch re-tints the launcher automatically.
4. **Keybinds shown:** every row that has a bind shows it, right-aligned, muted, in symbols. No bind, no hint — no empty column. This is a core requirement, not a nice-to-have: James frequently uses Vicinae today for exactly this reason, to see the binds.

## Keybind symbols
Map Hyprland/Omarchy modifiers to Mac-style symbols, since this is a Mac keyboard:
- Super = ⌘
- Shift = ⇧
- Ctrl = ⌃
- Alt / Option = ⌥

Examples: Super+Shift+B → `⌘⇧B`, Super+Ctrl+Shift+Space → `⌃⌘⇧Space`.
Use a font that renders these symbols cleanly at the result-row size. If a symbol does not render, say so rather than silently falling back to text for that one row.

## Design tokens (define once, reuse for the menubar in phase 2)
Define these as references to the active theme (`colors.toml` + `shell.toml` / menu tokens), not hardcoded values in QML — the launcher must re-tint when the theme changes, Afterburn or otherwise:
- Background + blur for the panel (glassy, so the wallpaper shows through faintly)
- Corner radius for the panel and for the selected row
- Spacing: search input padding, row height, row spacing, icon size
- Typography: search input size/weight, result name size/weight, subtitle size, keybind hint size
- Accent: selected-row background / border, using the theme accent (do not invent a new accent colour in v1)
- Muted text colour for subtitles and keybind hints

## Launcher layout (v1)
- Centered floating panel, roughly Raycast proportions (about 700–800 logical px wide, height grows with results, capped so it never covers the full screen). Position it in the upper third of the screen.
- Top: one search input, large type, placeholder that says what it searches (apps + commands).
- Below: results list. Each row: app/command icon left, name + one-line subtitle (what it does / which app it is), keybind symbols right-aligned and muted.
- Selected row: clearly highlighted with the theme accent (background and/or border), keyboard-navigable with arrows, Enter to run, Esc to close.
- Keep the list uncluttered: no categories, no headers, no extra panels in v1. Fuzzy matching as stock Omarchy does it.

## Behaviour (keep stock unless noted)
- Super+Space opens, Esc closes, arrows move, Enter runs the selected item.
- Typing searches apps and commands from one surface, as stock does.
- Math / unit conversion in the search box is NOT in v1 — note it as a possible v2, do not build it now.

## Implementation path (do not skip)
1. **Tokens first:** verify how the launcher currently reads the active theme, and define the tokens above as theme references. Verify a theme switch re-tints the launcher — test with Afterburn and at least one theme outside Afterburn. Do not create a custom theme that only works with one palette.
2. **Launcher as a plugin clone:** clone the stock menu / app-launcher as a user plugin under `~/.config/omarchy/plugins/` (the skal.menu pattern: clone the menu, edit the clone). Stock stays intact; disabling the plugin reverts to stock. Do not edit `/usr/share/omarchy` files.
3. **Keybind data:** find the source of truth for binds on this machine (Hyprland `bindings.lua` + Omarchy menu definitions) and map each app/command to its bind. Report any item where the bind could not be found — do not guess a bind, leave the hint off that row.
4. Verify with screenshots / live test: open Super+Space, type a program name, confirm the row shows its symbol bind; type a command name, confirm the same; confirm an item with no bind shows no hint.

## Success criteria (v1)
- Super+Space opens a centered, Raycast-sized floating panel, not the stock plain menu.
- Typing a program name shows its row with the correct symbol keybind on the right.
- Typing a command name does the same.
- Items with no bind show no hint and no empty gap where a hint would be.
- Disabling the plugin (or switching back to the stock theme) restores the stock menu exactly.
- Switching themes — Afterburn to a non-Afterburn theme and back — re-tints the launcher to the new theme's palette, with no hardcoded colours left behind.
- No keybinds changed, no stock files edited.

## Out of scope (v1)
- Menubar redesign (phase 2 — same tokens, applied to the bottom bar).
- Math / unit conversion, web search fallback, clipboard history, or new launcher features.
- Replacing the launcher with Vicinae, Walker, or another launcher.
- Changing the theme palette beyond what the tokens require, or changing the wallpaper.

## Open questions for the build
- Exact panel width / max height in logical px for this 1728x1117 screen.
- Exact corner radius and blur values that look right in the active theme (Afterburn default orange now — not Matte Black, which was superseded 2026-11-23).
- Which font renders ⌘ ⇧ ⌃ ⌥ cleanly in the shell — verify, do not assume.

## Iteration 2 notes (2026-11-23, v1 is live)
1. **Keybind spacing:** symbols run together and are hard to read. Fix: just a space between characters — `⌘ ⇧ B`, not pills. Keep it simple.
2. **Size + animation:** launcher window 15–20% smaller than v1. Animate in on open: subtle zoom + bounce to start (scale ~0.96 → 1.0, small spring overshoot, ~200ms). Subtle, not cartoonish — it opens a hundred times a day.
3. **Missing keybinds — audit all bind sources:** some binds are missing, e.g. Helium. James does NOT use the default browser bind for Helium — he uses Alt+H, created in Vicinae. He is trying to launch all apps with Alt+<letter> consistently. So the bind source of truth is NOT just Hyprland / Omarchy — Vicinae holds his personal app-launch binds. Before coding the fix, audit ALL places binds might live and produce a table (item, bind, source) for James to check:
   - Hyprland `bindings.lua` + stock Omarchy binds
   - Omarchy menu definitions
   - Vicinae — its app-launch shortcuts / config, e.g. Alt+H = Helium
   - Any other launcher / shortcut store on the machine
   Do not guess a bind. If a bind cannot be found in any source, leave the hint off and list it as missing in the audit.
   Also update the symbol map: Alt / Option = ⌥, so Alt+H renders as `⌥ H` (with spaces, per note 1).

## Iteration 3 notes (2026-11-23, James reporting on v2)
1. **Binds are a static snapshot, not live — needs fixing.** The v1/v2 build did the audit once and baked the bind table into the plugin. A new bind made after that (e.g. Zen, made in Vicinae) does NOT show in the Omarchy menu. There is no refresh step defined in the v1/v2 briefs. Wanted: automagic — the launcher should re-read the bind sources (Hyprland bindings.lua + Vicinae settings) on every open, so a new Vicinae bind appears next time Super+Space opens, with no manual refresh. Vicinae-wins on conflict still applies.
2. **Create a bind from the menu (phase 2, intricate):** James would like to create a new Alt+<letter> bind directly from the Omarchy menu. Much bigger build: needs UI to pick app + capture keys, conflict check, write to Vicinae settings and/or Hyprland bindings.lua, reload Hyprland, refresh the launcher table. Do only after the live-read in (1) works.
3. **Animation did not land — James overruled the Omarchy guideline (2026-11-23).** The v2 brief asked for subtle zoom + bounce (~200ms, scale 0.96→1.0, spring overshoot). James reports no animation on open. Omarchy's own motion skill says the menu/launcher has NO open/close motion, and never bounce/overshoot — but that is a house-style guideline, not a technical limit; the launcher is a QML plugin clone and can animate internally. James says that is not acceptable as a hard rule: the launcher should animate like any other piece of UI. Bounce is wanted, subtle, ~200ms. Implement it in the clone and verify it live; do not let the guideline silently drop it again.

## Iteration 3 audit results (2026-11-23, DeepSeek plan mode, read-only)
- **Vicinae six confirmed, in `~/.config/vicinae/settings.json` → `providers.applications.entrypoints`:** Muse.AI `⌥ M`, Ghostty `⌥ G`, Helium `⌥ H`, Floorp `⌥ F`, Orca `⌥ O`, Zen `⌥ Z` (added 10:11:23, v2 map missing it). Other Vicinae stores empty. No duplicate Vicinae chords; no existing Hyprland Alt+letter binds for H/G/M/F/O/Z, so adding the six to `bindings.lua` would not collide.
- **Ghostty decision (James):** keep BOTH Super+Return (default terminal) and Alt+G; menu shows `⌥ G` for Ghostty.
- **Helium:** Super+Shift+B is Chromium, not Helium — keep `⌥ H` for Helium.
- **Display gaps in v2:** Zen (no hint) and `trigger.emoji` (should show `⌃ ⌘ E`, Super+Ctrl+E).
- **Emoji today:** 1,870 entries, substring search over keywords only, no recents, no categories, no symbols ("em dash" → 0 hits), no pins, uses `[menu]` tokens (opaque, radius 8, no blur) not `[launcher]` (glass, radius 16).
- **Clipboard today:** 476 entries (411 text, 65 images), substring search capped at 50 rows, preview + detail pane present, paste to focused app present, no type filter, no pause, no pins, `[menu]` tokens.
- **Bar today:** no clipboard/emoji widgets, only hotkeys (Super+Ctrl+E / Super+Ctrl+V) and menu entries; a bar widget would have to be built.
- **Audit caveat:** spec + iteration 3 brief were NOT present on the Omarchy machine, so the audit used the brief text supplied in chat — re-check parity against the full spec before building 3b.
- **Single source of truth for binds is Hyprland `bindings.lua`, NOT Vicinae.** James wants all binds in one place, in that .lua file, outside Vicinae. The Vicinae-wins rule from v2 is superseded.
- **Ghostty bind decision (2026-11-23, James):** keep BOTH. Super+Return stays as the default terminal (which is Ghostty), and Alt+G stays as the Ghostty-specific bind. Both live in `bindings.lua`; the menu should show `⌥ G` for the Ghostty row.
- **Create binds from the Omarchy menu:** the menu should be able to create a new bind, writing it to `bindings.lua` (and reloading Hyprland), so the menu itself becomes the place binds are made and seen.
- **Goal is an alternative to Vicinae:** the Omarchy menu + `bindings.lua` should replace what he currently uses Vicinae for (seeing binds + launching apps with Alt+<letter>). Scope of a full Vicinae replacement (launcher toggle, clipboard, etc.) still to be discussed — app-launch binds are the first piece.
- **What Vicinae is actually for, day to day (2026-11-23):** primarily the emoji picker — much easier than Omarchy's — and sometimes the clipboard manager, which is more pleasant to use. Those are the two that have to be good on the Omarchy side before Vicinae can go. Plan: make Omarchy's emoji + clipboard integrated and genuinely useful, use them instead, then phase out and uninstall Vicinae. Cosmetics alone won't do it — the Omarchy versions need to match what makes Vicinae's easier/more pleasant (still to be pinned down in concrete terms).
- **Vicinae parity, from James's screenshots (2026-11-23):**
  - *Clipboard:* searchable history ("Browse clipboard history…", 409 items in his screenshot), type filter (All), list with truncated preview + relative time (16 min ago…), detail pane with full text + Type / Size / Copied at / MD5, Pause clipboard, "Paste to [focused app]" at the bottom, Actions (Ctrl+B).
  - *Emoji/symbols:* search by name ("Search for emojis and symbols…", e.g. typing "em dash" finds —), Recently used row at top, categories (Smileys & Emotion…), large grid, keyboard-navigable, and symbols as well as emojis — his Recently used are —, ⌘, →, •.
  - *Pinning is key:* James wants to pin items so they stay put — Vicinae shows them as Recently used, but he is not pinning anything there yet, and recents decay. Pinned clipboard entries and pinned emoji/symbols should stay at the top and not get pushed out as history grows.

## Code standards — always (2026-11-23, James)
- Coding quality must not relax and lean mid. Efficient, clean, and light code is always the standard for this system — no bloated, heavy, or sloppy work, even on small iterations. Every brief for the builder carries this.

## System vision (2026-11-23, James)
- This is ultimately a system, not a single panel. The Omarchy bar should have sufficient functionality to support managing clipboard, emoji, etc. — the bar is the hub for these tools, not just a launcher.
- Search speed is non-negotiable: lightning-fast search comes first. Recently used is what James typically uses; manual pins are the frosting — having both would be amazing, as long as pins/recents do not interfere with search speed.
- The launcher rice is not just the launcher. Every menu Omarchy spawns should be an extension of the same design: same tokens (theme-aware colours, corner radius, blur, typography), same centred floating-panel feel.
- Example that prompted this: the emoji picker still comes up in the default square boring Omarchy box — it should look like the launcher does.
- Applies to any menu Omarchy spawns (emoji picker, clipboard, image selector, and any others) — not just Super+Space. Each keeps its own layout/function (emoji grid, clipboard list, etc.) but shares the design language.
- This is part of the system-wide overhaul the launcher was step 1 of (menubar is the other phase).
