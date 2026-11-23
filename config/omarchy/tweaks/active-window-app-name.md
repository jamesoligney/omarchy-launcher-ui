# Active-window widget: app name first

Bar widget now shows **App** · window title (app name bold, from the desktop entry, falling back to the app id).

- Cloned `omarchy.active-window` -> `~/.config/omarchy/plugins/jimmy.active-window/ActiveWindow.qml`; edited the label into a Row of Text items. Default max width raised 280 -> 460 (override with `maxWidth` in shell.json).
- Needs `omarchy restart shell` after edits.
- Won't get upstream changes to the stock widget.

## Undo
    omarchy plugin enable omarchy.active-window   # swaps the bar back
    rm -r ~/.config/omarchy/plugins/jimmy.active-window
    omarchy restart shell
