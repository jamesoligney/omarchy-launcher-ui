# Omarchy Bar — Stage 27 Build Brief

Status: Build brief. Build from docs/omarchy-bar-refined-brief.md plus this brief.
Purpose: Exempt the quake console and the other special windows from the floating default — they have their own place, they should not open at 1100x619 centred.

## The problem (James, 2026-11-26)

In the zeal to have windows opening in the centre position, we forgot about the "special" windows. The quake console is also opening in our centre position, which it shouldn't.

A bunch of stuff is messed up — a few things, not just quake. This stage is to find the special windows, list them, and exempt them all, not just quake.

## Locked decisions

1. **The quake console goes back to its stock behaviour:** a half-height console that drops down over whatever workspace you're on, dimmed background, `Super + Grave` to toggle. First open starts your default agent; pressing again tucks it away, session where you left it.
   - While it holds a single window, it drops down as a **centred panel** rather than spanning the screen. Put a second app on it and it goes back to full width, so the two have room to sit side by side.
   - It does NOT open at 1100x619 centred in the middle of the screen.
2. **Special windows are exempt from the float default, all of them.** Audit them, list them in the report, and exempt them as a class — do not fix quake and leave the same centre-forcing on the next special.
   - Known specials to check: quake console (`Super + Grave`, special agent console workspace), scratchpad (`Super + S`, special hidden workspace), agent console, and any other special workspace / dropdown / overlay window Omarchy defines.
   - Stage 23's report said special workspaces (scratchpad, agent console) were untouched, workspace id < 1 skipped — but the Stage 23 open hook (finish 30ms later, float a still-tiled window and set the default) is almost certainly what is catching quake now. Find which hook / rule catches it and exempt specials there.
3. **Every normal app window still takes the default.** This is an exemption for specials only. Ghostty, Helium, Floorp, Zen, Chromium web apps, and every other normal app still open floating at the default, and still reset to it when their workspace switches to floating.
4. **Current default, for reference:** `o.float_default = { width = 1100, height = 619 }`, centred at **(329, 273)** after Stage 24's 30px left strip (was 314 before the strip). Do not change the size or the centre in this stage.

## Build checklist (standing rules)

- Backup at build start: mode 700, local only, everything that determines behavior. Audit first, include every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, shell.json / shell.toml, theme files, saved per-workspace layouts. Runtime state (clipboard history, pins, recents, pause) stays local, never in git. Checksums live before = backup = live after.
- `hyprctl reload` only. No shell restart unless the change requires it. Never `omarchy refresh shell`.
- Theme-aware (Afterburn default), no hardcoded palette. Keyboard-first. Efficient, clean, light code.
- Verify live, don't over-polish. Report to docs/reports/bar-stage-27-report.md, commit, push, hash only.

## Details

- Measure the quake console live first, before and after: open it with `Super + Grave`, record its size / position / workspace / tags with `hyprctl clients`, and state which rule / hook put it at the centre.
- Find the stock quake definition in Omarchy (special workspace, size, position, single-window centred panel vs. two-window full width) and restore that behaviour exactly — do not invent a new quake size.
- Audit the other specials the same way: open each one, record how it opens now vs. how Omarchy stock opens it, and exempt it if the float default is forcing it.
- The exemption must be in the rules / hooks, not a one-off move of the quake window by hand. A new quake open, a new scratchpad open, must open correctly on their own.
- Verify live: quake open / close / reopen (single window, centred panel, half-height, drops from top, dimmed background, agent session intact), quake with a second window (full width), scratchpad open / close, and a normal app window (Ghostty / Helium) still opening at 1100x619 at (329, 273).

## Out of scope

- No changes to the top bar, the left strip, the exploded name, the dock, the float default size / centre, Super+L, or toast centering.
- No new binds, no new specials.
- The frame / integration work (Caelestia-style oneness) stays a future direction, not this stage.
- The other "messed up" things James mentioned, if they are not special windows — list them in the report if you find them, do not silently fix unrelated things in this stage.
