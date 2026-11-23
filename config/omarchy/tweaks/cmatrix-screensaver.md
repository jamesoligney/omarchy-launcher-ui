# cmatrix screensaver (theme-coloured)

Replaces the idle screensaver with cmatrix, tinted by the theme accent.

- `~/.local/bin/theme-matrix` — inner script; picks the ANSI slot nearest `accent` in the current theme's colors.toml, runs `cmatrix -abs -C <name>`.
- `~/.local/bin/theme-screensaver-launch` — copy of `omarchy-launch-screensaver` that runs theme-matrix. Re-copy if upstream's launcher changes.
- `~/.config/omarchy/plugins/jimmy.idle` — clone of omarchy.idle with the launch command swapped.
- Menu "Screensaver" entry still runs the stock ttfx one.

## Undo
    omarchy plugin enable omarchy.idle   # (or disable jimmy.idle)
    rm -r ~/.config/omarchy/plugins/jimmy.idle ~/.local/bin/theme-matrix ~/.local/bin/theme-screensaver-launch
    omarchy restart shell

## SUPERSEDED 2026-11-13 by Matrix Screens plugin
Switched to io.github.whiskeytangofussell.matrixscreens (github.com/WhiskeyTangoFussell/omarchy-matrix-screens, v0.3.2).
- jimmy.idle disabled, omarchy.idle re-enabled; cmatrix scripts left in ~/.local/bin, unused.
- Plugin replaces the lock screen, so io.github.sirjul1337.lock-explorer is DISABLED.
- Settings: ~/.config/omarchy/matrix-screens/settings.json (screensaver=true, lock_screen off).
### Undo
    omarchy plugin remove io.github.whiskeytangofussell.matrixscreens --yes
    omarchy plugin enable io.github.sirjul1337.lock-explorer

## UPDATE 2026-11-13: rain + Explorer lock coexist
Matrix Screens plugin trimmed to rain-only: its Service.qml no longer contains the lock, and `omarchy.clonedFrom` was removed from its manifest.json.
Lock Screen Explorer is re-enabled and owns the lock. Rain polls `omarchy-shell lock isLocked` every 1.5s to stop under the lock.
Originals: Service.qml.orig-lock, manifest.json.orig (in the plugin dir). Plugin updates will overwrite these edits.
### Undo (back to plugin's own lock)
    cd ~/.config/omarchy/plugins/io.github.whiskeytangofussell.matrixscreens
    mv Service.qml.orig-lock Service.qml; mv manifest.json.orig manifest.json
    omarchy plugin disable io.github.sirjul1337.lock-explorer; omarchy restart shell
