# SUPER + W closes a browser tab, or the window in other apps

## What changed
- `~/.config/hypr/bindings.lua`: `o.rebind("SUPER + W", ...)` inside a `close-window-or-tab: begin/end` block. Replaces Omarchy's default `SUPER + W` close-window bind (`default/hypr/bindings/tiling.lua`).
- If the focused window's class is a browser, the bind sends Ctrl+W with `hl.dsp.send_key_state` (down, then up after 50 ms). Otherwise it dispatches `hl.dsp.window.close()`.
- Backup of bindings.lua from before the edit: `~/.config/hypr/bindings.lua.bak.1794879483` (the bind as it was before the Lua rewrite is in the later backups).

## Why not a shell script with wtype
`wtype` injects keys through a virtual keyboard. The physically held SUPER merges into the chord, so Helium received Super+Ctrl+W and ignored it. Omarchy's clipboard binds (`default/hypr/bindings/clipboard.lua`) use `send_key_state` for the same reason.

## Behaviour
- Browser with one tab: Ctrl+W closes the last tab, so the window closes.
- Browser with several tabs: only the current tab closes.
- Any other window: closes the window, as before.
- Browser classes (lowercased): chromium, google-chrome, chrome, brave-browser, microsoft-edge, vivaldi-stable, helium, firefox, zen, librewolf, one.ablaze.floorp.

## How to check
- `hyprctl configerrors` prints nothing (clean).
- Helium and Floorp with several tabs: one press closes one tab (confirmed 2026-11-16).

## Undo
1. Delete the `close-window-or-tab: begin` ... `end` block in `~/.config/hypr/bindings.lua`.
2. `hyprctl reload`. SUPER + W goes back to Omarchy's default close-window.
