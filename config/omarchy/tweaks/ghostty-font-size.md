# Ghostty font size reduced to 11

## What changed
- `~/.config/ghostty/local.conf`: `font-size` changed from `14` to `10`. This is the user override file that `~/.config/ghostty/config` loads last, so it wins over the theme.
- Backup from before the edit: `~/.config/ghostty/local.conf.bak.<timestamp>` (the one created alongside this change).

## How to check
- `ghostty +show-config | grep font-size` prints `font-size = 10`.
- New Ghostty windows, or a config reload in the running window, show smaller text.

## Undo
1. Set `font-size = 14` back in `~/.config/ghostty/local.conf`, or copy the backup over it: `cp ~/.config/ghostty/local.conf.bak.<timestamp> ~/.config/ghostty/local.conf`.
2. Reload Ghostty's config (or open a new window).
