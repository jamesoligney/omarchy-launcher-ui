# YouTube mini video mode (chrome-free floating window)

- `~/.config/hypr/hyprland.lua`: rule `hyprbars:no_bar` for floating windows titled *YouTube* (no Omarchy titlebar).
- `~/.local/bin/yt-mini` + `SUPER + ALT + V` in `~/.config/hypr/bindings.lua`: toggles a floating window to 16:9 and has the browser fullscreen the player while Hyprland keeps the window size. `f` / F11 stay real fullscreen.
- Enhancer for YouTube custom CSS (crop to fill, no black bars):
  `.html5-video-player.ytp-fullscreen .html5-main-video { width:100% !important; height:100% !important; left:0 !important; top:0 !important; object-fit:cover !important; }`

## Undo
Delete the `hyprbars:no_bar` line in hyprland.lua, the `yt-mini` bind in bindings.lua, `rm ~/.local/bin/yt-mini`, and the CSS in Enhancer. Backups: `hyprland.lua.bak.*`, `bindings.lua.bak.*`.

## Gotcha
Do not use `hl.on(...)` handlers to experiment: they survive `hyprctl reload` and only a Hyprland restart clears them.
