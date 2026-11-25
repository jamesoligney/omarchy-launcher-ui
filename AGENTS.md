# AGENTS.md — Omarchy Launcher-UI

Project instructions for every agent working in this repo (Claude Code, OpenCode, DeepSeek). Read this file first. The spec in `docs/omarchy-launcher-rice-spec.md` is the source of truth for design decisions; this file is the working rules.

## What this is
A system, not a single panel: a modern, Raycast-style Omarchy launcher (Super+Space) plus the same design applied to every menu Omarchy spawns (emoji picker, clipboard picker, and any others), with the Omarchy bar as the hub for managing clipboard, emoji, etc. The goal is to replace Vicinae, so Vicinae can eventually be phased out and uninstalled.

## Machine / constraints
- Mac (M-series, ARM), Omarchy side only (Asahi Linux, Hyprland, Lua config `~/.config/hypr/*.lua`, never `.conf`, never `hyprctl keyword`). Do not touch macOS / OmniWM.
- User `jimmy`, home `/home/jimmy`. Screen eDP-1, 3456x2234 @120Hz, scale 2, logical 1728x1117.
- Current theme: Afterburn, default edition (accent #FF9145, ember #FF5A1F, flare #FFC48A, background #0C0D0B, foreground #E8E4DC). All colours come from the active theme, never hardcoded. A theme switch must re-tint every menu touched.
- Do not edit stock files in `/usr/share/omarchy` — updates wipe them. Clone menus as user plugins under `~/.config/omarchy/plugins/`; edit the clone only. Disabling a plugin must revert to stock exactly.
- **Never run `omarchy refresh shell`.** It is a reset, not a reload — it restores `shell.json` to Omarchy defaults and puts the bar back on top. It did that on 2026-11-23. The safe reload is `omarchy restart shell`; the shell also reloads automatically when `shell.json` is copied back. If restoring `shell.json`, copy back the backup whose timestamp matches the event, not the first `.bak` file found (old ones accumulate).

## Code standard — always
Efficient, clean, and light code is the standard, every iteration. No bloated, heavy, or sloppy work, no duplicated logic, no heavy dependencies for a small job. Use the native Omarchy / Quickshell component when one already does it.

## Binds — one source
- The single source of truth for binds is Hyprland `bindings.lua`. Vicinae is **not** a source of truth.
- App launches are Alt+<letter>, consistently. The six Vicinae binds to migrate (audit 2026-11-23, approved pending James's final go-ahead): Muse.AI `⌥ M`, Ghostty `⌥ G`, Helium `⌥ H`, Floorp `⌥ F`, Orca `⌥ O`, Zen `⌥ Z`.
- Ghostty: keep **both** Super+Return (default terminal) and Alt+G. Menu shows `⌥ G` for Ghostty.
- Helium: Super+Shift+B is Chromium, not Helium. Keep `⌥ H` for Helium.
- The menu must re-read `bindings.lua` on **every open** — no baked bind table, no file watcher, no manual refresh. A new bind shows on the next open.
- Create-a-bind in the menu writes only to `bindings.lua`, reloads Hyprland, and refuses a conflicting letter with a visible message.

## Emoji and clipboard — Vicinae parity
- Search speed is non-negotiable: lightning-fast search first. Recently used is what James typically uses. Manual pins are the frosting — they stick at the top and do not decay, only if they do not slow search.
- Emoji: search by name (e.g. "em dash" → —), Recently used row, categories, symbols as well as emojis, large grid, keyboard-navigable, Enter pastes into the focused app.
- Clipboard: searchable history (hundreds of items), type filter, preview + detail pane, Pause clipboard, paste to focused app.
- Both pickers share the launcher's design tokens (glass, radius 16), not the stock `[menu]` tokens (opaque, radius 8, no blur).
- Animation: James wants the subtle zoom + bounce from v2 (scale ~0.96 → 1.0, small spring overshoot, ~200ms). Omarchy's own motion guidelines say the launcher should have no open motion and never bounce — that is a house-style guideline, not a technical limit. The launcher is our plugin clone, in QML, and it can animate scale/opacity internally. James has overruled the guideline: bounce is wanted, subtle, not cartoonish. Implement it in the clone and verify it live; do not let the guideline silently drop it again.

## Backups — standing rule
Backups must be complete: **audit first, never commit a fraction.** Before snapshotting anything, list every file that determines the behaviour in question (plugins, binds, shell.json, shell.toml, hooks, themes, hypr includes, anything the loader pulls in), then include all of it. Anything left out must be named exactly in the report with the reason. Never put runtime state (clipboard history, pins, recents, pause flag, notifications) in git: it can hold copied secrets. Back it up locally in a timestamped, mode-700 folder under `~/.local/state/omarchy-launcher-backups/`. Verify the live files are unchanged (checksums before and after) and that the snapshot equals live.

## Build start / end — standing rule
- **Build start:** `omarchy-kbd-backlight hold` (saves the keyboard backlight level, sets it to 0, pauses the ambient-light daemon). If the screen must stay on for the build, `omarchy toggle idle stay-awake`.
- **Build end:** `omarchy-kbd-backlight release` (restores the level, auto resumes) and, if stay-awake was set, `omarchy toggle idle allow-idle`. Confirm `omarchy-shell idle status` shows `"stayAwake": false`, so the screensaver kicks on as normal.
- Never use bare `omarchy toggle idle` to check state; it flips it. Check with `omarchy toggle idle status` (`enabled:true` there means stay-awake is ON) or `omarchy-shell idle status`.
- Do not set the keyboard backlight with raw `brightnessctl` during a build: the daemon treats an outside change as a manual override and takes over again after 10 minutes. `hold` pauses it until `release`, and a forgotten hold expires after 4 hours.

## Current state (2026-11-23)
- v1 launcher live, v2 live with spaced keybind symbols (`⌘ ⇧ B`, `⌥ H`) and a 15–20% smaller panel. Animation did not land (see above).
- Iteration 3a audit done (read-only, DeepSeek plan mode). Report: `docs/omarchy-launcher-iteration-3a-audit-report.md`. It confirms the six Vicinae binds, their storage (`~/.config/vicinae/settings.json` → `providers.applications.entrypoints`), and the emoji/clipboard gaps.
- Iteration 3b build is **paused** until James approves the audit table and can step away from the machine (the build restarts the shell and reloads Hyprland). Brief: `docs/omarchy-launcher-iteration-3b-build-brief.md`.
- Project manager is Max (Muse). James switches between OpenCode and Claude Code for coding; Max keeps the spec, briefs, and decisions unified.

## Files in this repo
- `AGENTS.md` — this file.
- `docs/omarchy-launcher-rice-spec.md` — design spec, decisions, audit results.
- `docs/omarchy-launcher-iteration-3-brief.md` — full iteration 3 plan.
- `docs/omarchy-launcher-iteration-3a-audit-brief.md` — audit handoff (read-only).
- `docs/omarchy-launcher-iteration-3a-audit-report.md` — audit results.
- `docs/omarchy-launcher-iteration-3b-build-brief.md` — build handoff (run later).
- `docs/omarchy-launcher-iteration-2-brief.md` — previous iteration, for history.
- `plugins/`, `config/` — fallback snapshot of the live plugins and config (live sources stay in `~/.config/`; see their READMEs for restore).

## Before you start work
1. Read this file and the spec.
2. If your task is the 3b build, read the 3a audit report first and confirm James has approved the bind table.
3. Report what you did, what you verified live, and anything still unconfirmed. Do not guess a bind, a file location, or a symbol.
