# Plugin snapshot (fallback point)

Copies of the user-authored Omarchy plugins, taken 2026-11-23.

**The live source is `~/.config/omarchy/plugins/`.** Edit there, not here; this folder is a snapshot and drifts as soon as the live files change.

| Folder | What it is |
|---|---|
| `jimmy.menu/` | The Raycast-style launcher (Super+Space) and its bar widget |
| `jimmy.emojis/` | Emoji picker |
| `jimmy.clipboard/` | Clipboard picker |
| `jimmy.apps/` | The apps window (grid of every app), opened from the launcher's Apps row |
| `jimmy.reminders/` | Reminders dialog (clone of the stock one, with the shared motion) |
| `jimmy.shared/` | `CardMotion.qml`, the open/close animation all three pickers import |
| `jimmy.workspaces/`, `jimmy.active-window/`, `jimmy.idle/` | The user's own bar and idle plugins |
| `bin/omarchy-launcher-paste` | Shared paste helper the emoji and clipboard pickers call (2026-11-24). Lives at `~/.local/bin/omarchy-launcher-paste` |

Not included: `*.bak*` files, and third-party plugins (see `../config/omarchy/third-party-plugins.tsv`). Runtime state is never in git.

## Restore

The three pickers import `../jimmy.shared`, so restore the folders together.

```bash
cp -a plugins/jimmy.* ~/.config/omarchy/plugins/
install -m 755 plugins/bin/omarchy-launcher-paste ~/.local/bin/omarchy-launcher-paste
omarchy restart shell
```

`cp -a` overwrites same-named files and leaves other live files in place. `omarchy restart shell` only, never `omarchy refresh shell`.
