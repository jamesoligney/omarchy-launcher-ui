# Brief: Omarchy launcher — iteration 3b, build (run later, when James can step away)

## Context
- Machine: Mac (M-series, ARM), dual-boot. This work is on the **Omarchy** side (Asahi-based Linux, Hyprland, Lua config only — `~/.config/hypr/*.lua`, never `.conf`, never `hyprctl keyword`).
- User: `jimmy`, home `/home/jimmy`.
- Do not touch the macOS side or OmniWM.
- Do not edit stock files in `/usr/share/omarchy` — updates will wipe them. The launcher and every other menu you touch are user plugin clones under `~/.config/omarchy/plugins/`; edit those clones only.
- **Never run `omarchy refresh shell`.** It is a reset, not a reload — it restores `shell.json` to Omarchy defaults, puts the bar back on top, and wipes the bar/plugin settings. It did exactly that on 2026-11-23. The safe reload is `omarchy restart shell`, and the shell also reloads automatically when `shell.json` is copied back. If you ever need to restore `shell.json`, copy back the backup whose timestamp matches the event — do not copy the first `.bak` file you find, old ones accumulate.
- Full spec: `~/workspace/omarchy-launcher-rice-spec.md`. Full iteration 3 plan: `~/workspace/omarchy-launcher-iteration-3-brief.md`. Audit report (from iteration 3a): `~/workspace/omarchy-launcher-iteration-3a-audit-report.md`.

## Why this is separate
Iteration 3a (audit) runs first, while James is using the machine, and is read-only. **This build runs later, when James can step away from the machine**, because it restarts the shell, reloads Hyprland, and swaps plugins — the machine will be briefly unusable during those steps. Do not start this brief until James has approved the 3a audit table.

## Code standard — always
- Efficient, clean, and light code is the standard, every iteration. Coding quality must not relax and lean mid. No bloated, heavy, or sloppy work, no duplicated logic, no heavy dependencies for a small job. If a native Omarchy / Quickshell component already does it, use that.

## What this iteration is
A system, not a single panel. The goal is an Omarchy-side system that replaces Vicinae, so Vicinae can eventually be phased out and uninstalled. Current theme is Afterburn, default edition (original orange: accent #FF9145, ember #FF5A1F, flare #FFC48A, background #0C0D0B, foreground #E8E4DC). All colours must come from the active theme, never hardcoded. A theme switch must re-tint every menu you touch.

## Part A — binds: one source, in `bindings.lua`
This supersedes the v2 "Vicinae wins" rule. **Vicinae is no longer a source of truth. The single source of truth for binds is Hyprland `bindings.lua`.**

### A2. Migrate Vicinae binds into `bindings.lua` (only the binds James approved in the 3a audit)
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
### B1. Emoji picker
Vicinae parity: search by name at the top ("Search for emojis and symbols…") — typing "em dash" must find —; Recently used row at the top; categories; large grid, keyboard-navigable, Enter to paste into the focused app; symbols as well as emojis (his Recently used are —, ⌘, →, •). Apply the launcher's design tokens: theme-aware colours, corner radius, blur, typography, centred floating panel. It must not look like the default square boring Omarchy box.

### B2. Clipboard picker
Vicinae parity: searchable history ("Browse clipboard history…", 409 items in his screenshot, so search must work across a large history); type filter; list with truncated preview + relative time, detail pane with full text + Type / Size / Copied at, Pause clipboard; paste to the focused app. Apply the same design tokens as the launcher and emoji picker.

### B3. Recently used and pins — search speed is the hard requirement
- **Lightning-fast search comes first.** Nothing here may slow search down. Pins and Recently used must not interfere with search speed.
- Recently used is what James typically uses — it must be present in both pickers.
- Manual pins are the frosting: the user can pin a clipboard entry or an emoji/symbol so it stays at the top and does not get pushed out as history grows. Recents decay; pins do not. Pins are optional on top of recents, never a replacement, and never at the cost of search speed.

### B4. Bar as hub
- The bar must support managing clipboard, emoji, etc. — these pickers must be reachable and manageable from the Omarchy bar, in the same design language, not only from hotkeys. The visual menubar redesign is still a later phase — this part is functionality and access from the bar, not a full bar redesign.

## Part C — animation (fix the v2 miss)
- The v2 brief asked for subtle zoom + bounce (~200ms, scale 0.96 → 1.0, spring overshoot). James reports no animation on open. Omarchy's own motion guidelines say the menu/launcher has **no open/close motion**, and **never bounce/overshoot**. That is a house-style guideline, not a technical limit — the launcher is a QML plugin clone and can animate scale/opacity internally, and Hyprland's `no_anim` layer rule for the menu surface does not prevent QML-internal animation. **James has overruled the guideline: the launcher should animate like any other piece of UI, and the bounce is wanted.**
- Implement the v2 animation: subtle zoom + bounce, scale ~0.96 → 1.0, small spring overshoot, ~200ms, plus a faster fade/scale-down close animation if the shell supports it. Verify it live — open the launcher repeatedly and confirm the animation is visible, subtle, and has no lag. If it is not visible, find out why (not wired, overridden, or suppressed) and fix it — do not silently drop it again. Report the exact values used and the live result.

## Steps (in order)
1. **Migrate (A2):** move approved binds into `bindings.lua`, remove them from Vicinae, reload Hyprland, verify each bind live.
2. **Live-read + create (A3 + A4):** menu reads `bindings.lua` on every open; add create-bind in the menu with conflict check, writing only to `bindings.lua`. Verify: create a test bind in the menu, confirm it works and shows on the next open, then remove the test bind.
3. **Emoji (B1) and clipboard (B2):** apply the shared tokens, implement search + Recently used + pins (B3), verify against the Vicinae parity lists above with live tests.
4. **Bar hub (B4):** add bar access/management for clipboard and emoji.
5. **Animation (Part C):** implement the allowed subtle version, verify live, report values.
6. **Theme check:** switch themes (Afterburn → a non-Afterburn theme → back) and confirm every menu you touched re-tints, with no hardcoded colours left behind.
7. Report: the migration list, the live-test results for every migrated and created bind, the emoji/clipboard parity checklist, the animation values and whether they are visible live, and anything still unconfirmed.

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
