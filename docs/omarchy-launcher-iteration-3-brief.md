# Brief: Omarchy launcher — iteration 3 (system, not just a panel)

> **Split 2026-11-23:** this brief is now two handoffs, because the build makes the machine briefly unusable and James does not want to interrupt the agent mid-build.
> - **3a — audit only, read-only, run now while he uses the machine:** `omarchy-launcher-iteration-3a-audit-brief.md`
> - **3b — build, run later when he can step away:** `omarchy-launcher-iteration-3b-build-brief.md`
> This file is the full plan both halves follow.

## Context
- Machine: Mac (M-series, ARM), dual-boot. This work is on the **Omarchy** side (Asahi-based Linux, Hyprland, Lua config only — `~/.config/hypr/*.lua`, never `.conf`, never `hyprctl keyword`).
- User: `jimmy`, home `/home/jimmy`.
- Do not touch the macOS side or OmniWM.
- Do not edit stock files in `/usr/share/omarchy` — updates will wipe them. The launcher is a user plugin clone under `~/.config/omarchy/plugins/`; edit that clone only. The same rule applies to every other menu you touch in this iteration: clone it as a user plugin, never edit stock.
- **Never run `omarchy refresh shell`.** It is a reset, not a reload — it restores `shell.json` to Omarchy defaults, puts the bar back on top, and wipes the bar/plugin settings. It did exactly that on 2026-11-23. The safe reload is `omarchy restart shell`, and the shell also reloads automatically when `shell.json` is copied back. If you ever need to restore `shell.json`, copy back the backup whose timestamp matches the event (on 2026-11-23 that was `shell.json.bak.1795458069`, 23 Nov 10:21) — do not copy the first `.bak` file you find, old ones accumulate.
- Full spec: `~/workspace/omarchy-launcher-rice-spec.md`. This brief is the work order; the spec is the source of truth.

## Code standard — always
- Efficient, clean, and light code is the standard, every iteration. Coding quality must not relax and lean mid. No bloated, heavy, or sloppy work, no duplicated logic, no heavy dependencies for a small job. If a native Omarchy / Quickshell component already does it, use that.

## What this iteration is
This is a system, not a single panel. The goal is an Omarchy-side system that replaces Vicinae, so Vicinae can eventually be phased out and uninstalled:
- The Omarchy menu (Super+Space) + Hyprland `bindings.lua` replace Vicinae for seeing binds and launching apps with Alt+<letter>.
- Omarchy's emoji picker and clipboard picker replace Vicinae's emoji picker and clipboard manager — the two Vicinae features James actually uses day to day.
- The Omarchy bar is the hub for managing clipboard, emoji, etc. — these tools are reachable and manageable from the bar, in the same design language.
- Every menu Omarchy spawns shares the same design: theme-aware colours, corner radius, blur, typography, centred floating-panel feel. The launcher was step 1; this iteration extends that design to the other menus.

Current theme is Afterburn, default edition (original orange: accent #FF9145, ember #FF5A1F, flare #FFC48A, background #0C0D0B, foreground #E8E4DC). All colours must come from the active theme, never hardcoded. A theme switch must re-tint every menu you touch.

## Part A — binds: one source, in `bindings.lua`
This supersedes the v2 "Vicinae wins" rule. **Vicinae is no longer a source of truth. The single source of truth for binds is Hyprland `bindings.lua`.**

### A1. Audit Vicinae binds first (before moving anything)
- Find where Vicinae stores its app-launch shortcuts on this machine (config file, database, or settings — inspect, do not guess) and extract every Alt+<letter> app launch, e.g. Alt+H = Helium, plus any Zen bind.
- Also audit Hyprland `bindings.lua` + stock Omarchy binds, and Omarchy menu definitions.
- Produce a table: item (app/command), bind as pressed, symbol form (e.g. `⌥ H`, with a space between symbols), current source (Hyprland / Omarchy / Vicinae).
- **Report the table and wait for James to approve it before migrating anything.** Moving/deleting binds is destructive — do not move or delete a Vicinae bind until he has checked the table. Only stop earlier if a bind is genuinely ambiguous and cannot be resolved from the sources.
- Do not guess a bind. If a bind cannot be found in any source, list it as missing.

### A2. Migrate Vicinae binds into `bindings.lua` (after approval)
- Move every approved Alt+<letter> app launch into `bindings.lua`, in the existing Hyprland Lua style already in that file.
- Remove the same bind from Vicinae, so no bind lives in two places. If removing it from Vicinae is not safely possible, say so and leave it — do not leave a duplicate silently.
- Reload Hyprland so the moved binds work (`hyprctl reload`, editing the .lua file for persistence — never `hyprctl keyword`).
- Verify live: press each migrated Alt+<letter> bind and confirm the app launches.

### A3. Live-read binds in the menu (no baked table)
- The v1/v2 menu baked the bind table in at build time, which is why a new Zen bind made in Vicinae never showed. Fix that: the menu must re-read `bindings.lua` on **every open** of Super+Space, so a new bind appears next time the menu opens with no manual refresh.
- No file watcher, no background process, no baked snapshot. Read on open, merge with Omarchy menu-definition binds for commands, display with a space between symbols (`⌘ ⇧ B`, `⌥ H`). No bind, no hint, no empty gap.

### A4. Create a bind from the Omarchy menu
- In the menu, the user can create a new Alt+<letter> app-launch bind: pick an app, press the keys.
- The menu writes the new bind to `bindings.lua` (the one place), reloads Hyprland, and the bind is live and visible in the menu on the next open because of A3.
- Conflict check before writing: if the Alt+<letter> is already used in `bindings.lua` or by an Omarchy bind, show the conflict and do not overwrite it. Ask the user to pick another letter.
- Do not write binds anywhere else. Do not write to Vicinae settings.

## Part B — emoji and clipboard: match Vicinae, then beat it on look
These are the two Vicinae features that have to be good on the Omarchy side before Vicinae can go. Cosmetics alone will not do it — the Omarchy versions must match what makes Vicinae's easier, then share the launcher's design.

### B1. Emoji picker
Vicinae parity, from James's screenshots (2026-11-23):
- Search by name at the top ("Search for emojis and symbols…") — typing "em dash" must find —.
- Recently used row at the top.
- Categories (Smileys & Emotion, etc.).
- Large grid, keyboard-navigable, Enter to paste into the focused app.
- Symbols as well as emojis — his Recently used are —, ⌘, →, •. Symbol search is a first-class feature, not an afterthought.
- Apply the launcher's design tokens to the picker: theme-aware colours, corner radius, blur, typography, centred floating panel. It must not look like the default square boring Omarchy box.

### B2. Clipboard picker
Vicinae parity, from James's screenshots (2026-11-23):
- Searchable history ("Browse clipboard history…") — his history is 409 items, so search must work across a large history, not just the last few.
- Type filter (All / text / link / etc., as Vicinae has it).
- List with truncated preview + relative time (16 min ago…), detail pane with full text + Type / Size / Copied at, Pause clipboard.
- Paste to the focused app from the picker.
- Apply the same design tokens as the launcher and emoji picker.

### B3. Recently used and pins — search speed is the hard requirement
- **Lightning-fast search comes first.** Nothing in this part may slow search down. Pins and Recently used must not interfere with search speed.
- Recently used is what James typically uses — it must be present in both pickers, reflecting what he actually used lately.
- Manual pins are the frosting: the user can pin a clipboard entry or an emoji/symbol so it stays at the top and does not get pushed out as history grows. Recents decay; pins do not. Pins are optional on top of recents, never a replacement for them, and never at the cost of search speed.

### B4. Bar as hub
- The bar must support managing clipboard, emoji, etc. — these pickers must be reachable and manageable from the Omarchy bar (bar widgets / access points), in the same design language, not only from hotkeys.
- The visual menubar redesign is still a later phase — this part is functionality and access from the bar, not a full bar redesign.

## Part C — animation (fix the v2 miss)
- The v2 brief asked for subtle zoom + bounce (~200ms, scale 0.96 → 1.0, spring overshoot). James reports no animation on open.
- Omarchy's own motion guidelines say the menu/launcher has **no open/close motion**, and **never bounce/overshoot**. That is a house-style guideline, not a technical limit. **James has overruled it: the launcher should animate like any other piece of UI, and the bounce is wanted.**
- Implement the v2 animation: subtle zoom + bounce, scale ~0.96 → 1.0, small spring overshoot, ~200ms. Verify it live; if it is not visible, find out why and fix it — do not silently drop it again.
- Report the exact values used and whether the animation is visible live.

## Steps (in order)
1. **Audit (A1):** find Vicinae's shortcut store, extract every Alt+<letter> bind, audit `bindings.lua` + Omarchy binds, report the table. Wait for James's approval.
2. **Migrate (A2):** move approved binds into `bindings.lua`, remove them from Vicinae, reload Hyprland, verify each bind live.
3. **Live-read + create (A3 + A4):** menu reads `bindings.lua` on every open; add create-bind in the menu with conflict check, writing only to `bindings.lua`. Verify: create a test bind in the menu, confirm it works and shows on the next open, then remove the test bind.
4. **Emoji (B1) and clipboard (B2):** apply the shared tokens, implement search + Recently used + pins (B3), verify against the Vicinae parity lists above with live tests.
5. **Bar hub (B4):** add bar access/management for clipboard and emoji.
6. **Animation (Part C):** implement the allowed subtle version, verify live, report values.
7. **Theme check:** switch themes (Afterburn → a non-Afterburn theme → back) and confirm every menu you touched re-tints, with no hardcoded colours left behind.
8. Report: the audit table, the migration list, the live-test results for every migrated and created bind, the emoji/clipboard parity checklist, the animation values and whether they are visible live, and anything still unconfirmed.

## Success criteria
- Every Vicinae Alt+<letter> bind James approved is in `bindings.lua`, works live, and is gone from Vicinae (or its removal is explicitly reported as not safely possible).
- A bind created in the Omarchy menu lands in `bindings.lua`, works immediately after a Hyprland reload, and shows in the menu on the next open. A conflicting letter is refused with a visible conflict message.
- A new bind added to `bindings.lua` by hand shows in the menu on the next open, with no manual refresh step.
- Emoji picker: search by name finds symbols (e.g. "em dash" → —), Recently used row present, categories present, pins stick, search is instant.
- Clipboard picker: search works across a large history, filter present, preview + detail pane present, pause present, paste to focused app works, pins stick, search is instant.
- Every menu touched shares the launcher's design tokens and re-tints on a theme switch.
- Animation is the v2 subtle zoom + bounce (~200ms), visible live.
- No stock files edited, no binds left in two places, code is efficient, clean, and light.

## Out of scope
- Visual menubar redesign (later phase — same tokens, later).
- Math / unit conversion, web search fallback, or new launcher features beyond create-bind.
- Replacing the launcher with Vicinae, Walker, or another launcher — this iteration replaces Vicinae with Omarchy, not the other way round.
- Changing the theme palette or the wallpaper.
- Uninstalling Vicinae yet — that happens only after James has used the Omarchy emoji, clipboard, and binds instead and is happy with them.
