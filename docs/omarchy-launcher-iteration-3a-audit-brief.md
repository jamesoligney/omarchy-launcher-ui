# Brief: Omarchy launcher — iteration 3a, audit only (read-only)

## Context
- Machine: Mac (M-series, ARM), dual-boot. This work is on the **Omarchy** side (Asahi-based Linux, Hyprland, Lua config only — `~/.config/hypr/*.lua`, never `.conf`, never `hyprctl keyword`).
- User: `jimmy`, home `/home/jimmy`.
- Do not touch the macOS side or OmniWM.
- Full spec: `~/workspace/omarchy-launcher-rice-spec.md`. Full iteration 3 plan: `~/workspace/omarchy-launcher-iteration-3-brief.md`. This brief is only the audit step of that plan.

## Why this is separate
James is using this machine while the audit runs. **This step must not disturb him.** Read files only.

## Hard rules for this step
- **Read-only. Do not edit, move, delete, or create any file** (except the audit report itself, which you write to `~/workspace/` as instructed below).
- **Do not restart the shell, reload Hyprland, restart any service, or run any command that changes state.** No `omarchy restart shell`, no `omarchy refresh shell` (that one is a reset to defaults — never use it), no `hyprctl reload`, no plugin enable/disable, no theme switch.
- **Do not change, move, or delete any keybind.** Audit and report only.
- Code standard: efficient, clean, and light — even the audit scripts/commands should be minimal.

## What to audit

### 1. Binds — where they live today
- Hyprland `bindings.lua` + stock Omarchy binds: list every app-launch and command bind.
- Omarchy menu definitions: list every bind shown in the menu.
- **Vicinae:** find where Vicinae stores its app-launch shortcuts on this machine (config file, database, or settings — inspect, do not guess) and extract every Alt+<letter> app launch, e.g. Alt+H = Helium, plus any Zen bind.
- Any other launcher / shortcut store on this machine.
- Produce a table: item (app/command), bind as pressed, symbol form with a space between symbols (e.g. `⌥ H`, `⌘ ⇧ B`), current source (Hyprland / Omarchy / Vicinae / other).
- Note every conflict (same app with different binds in different sources, same letter used by two apps) and every item with no bind found. Do not guess a bind. Do not resolve conflicts yourself — list them.
- Note, for each Vicinae bind, how it is stored and what would be involved in moving it to `bindings.lua` and removing it from Vicinae (e.g. is it a Hyprland bind that calls Vicinae, or a Vicinae-internal shortcut?).

### 2. Emoji and clipboard — what Omarchy has today (read-only inspection)
- Find the stock Omarchy emoji picker and clipboard picker plugins (do not edit them, do not edit `/usr/share/omarchy`).
- For each, report: where it lives, what search it supports (by name? by category?), whether it has Recently used, whether it has pinning, how it pastes to the focused app, and what its current design tokens are (colours, radius, blur, type).
- Compare against Vicinae parity (from the spec): emoji search by name (e.g. "em dash" → —), Recently used, categories, symbols as well as emojis; clipboard search across a large history, type filter, preview + detail pane, Pause clipboard, paste to focused app.
- List the gaps, in plain terms — what would have to be built or changed to match Vicinae.

### 3. Bar — how clipboard / emoji are reached today
- Report how the clipboard and emoji pickers are currently reached from the Omarchy bar (bar widgets, hotkeys, menu entries), and what bar hooks exist for adding access/management there.

## Report
Write the report to `~/workspace/omarchy-launcher-iteration-3a-audit-report.md` and print a short summary in chat:
- The bind table (all of it).
- The conflicts and missing binds.
- How each Vicinae bind is stored, and what moving it would involve.
- The emoji and clipboard gap lists.
- The bar access list.
- Anything still unconfirmed.
- **Stop there. Do not start the migration or the build.** James checks the bind table first; the build (iteration 3b) runs later, when he can step away from the machine.

## Success criteria
- The bind table is complete and accurate, with sources named.
- No file was edited, no service restarted, no bind changed, and James's machine was usable throughout.
- The report names everything the build will need, with nothing guessed.
