# Desktop tweaks

Notes on hand-made changes to this machine's desktop, so each one can be
found, understood and undone later.

One file per tweak. Each file says what changed, which files it touched, how
to check it is working, and how to undo it.

| Tweak | What it does |
|-------|--------------|
| [fathom-alt-tab.md](fathom-alt-tab.md) | Alt+Tab switches windows with the Fathom overlay instead of Hyprland's cyclenext |
| [lock-screen-explorer.md](lock-screen-explorer.md) | Replaces Omarchy's lock screen with the Lock Screen Explorer plugin and its designs |
| [klack-soundpack-keycodes.md](klack-soundpack-keycodes.md) | Renames the `cherry-mx-red` pack's Mechvibes keycode filenames to klack key tokens, restoring per-key sounds |
| [klack-pack-switcher.md](klack-pack-switcher.md) | `klack-pack` switches keyboard sound packs from the terminal or the Omarchy menu |
| [workspaces-focused-first.md](workspaces-focused-first.md) | Bar workspace row shows the focused workspace first in a block, then the other occupied ones |
| [scratchpad-hotkey.md](scratchpad-hotkey.md) | `SUPER + N` toggles the Scratchpad plugin's note panel |
| [glyph-menu-launcher.md](glyph-menu-launcher.md) | Glyph Menu plugin replaces the bar's Omarchy launcher button with a pickable glyph |
| [close-window-or-tab.md](close-window-or-tab.md) | `SUPER + W` closes a browser tab (the window, when it is the last tab) and closes the window in other apps, via a Lua bind using `send_key_state` |
| [border-fx-rust-toolchain.md](border-fx-rust-toolchain.md) | Installs the Rust toolchain so Border FX can build its window ring, not just the chrome effect |
| [ghostty-font-size.md](ghostty-font-size.md) | Ghostty font size lowered from 14 to 10 in `~/.config/ghostty/local.conf` |

Files that are not tweak notes: `lock-explorer-weather-units-issue.md` is an
upstream bug report drafted for the Lock Screen Explorer, kept next to the
tweak whose workaround it describes.
`plugins-to-revisit.md` is a standing list of plugins seen and parked, not
installed — entries move out of it when they become tweaks of their own.

## Conventions

- Mark edits to a shared config file with `-- <tweak>: begin` / `-- <tweak>: end`
  comments so the block can be lifted out cleanly later.
- Back up before editing: `cp f f.bak.$(date +%s)` (what `omarchy refresh` does too).
- After any `~/.config/hypr/*.lua` change: `hyprctl reload && hyprctl configerrors`.
