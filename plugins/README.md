# Plugin snapshot (fallback point)

Copies of the live Omarchy launcher plugins, taken 2026-11-23 so there is a known-good point to return to.

**The live source is `~/.config/omarchy/plugins/`.** Edit there, not here. This folder is a snapshot and drifts as soon as the live files change.

| Folder | What it is |
|---|---|
| `jimmy.menu/` | The Raycast-style launcher (Super+Space) |
| `jimmy.emojis/` | Emoji picker |
| `jimmy.clipboard/` | Clipboard picker |
| `jimmy.shared/` | `CardMotion.qml`, the open/close animation all three import |

Not included: `*.bak*` backup files, and runtime state (pins, recents, clipboard history under `~/.local/state/omarchy/`).

## Restore

The three plugins import `../jimmy.shared`, so restore all four together.

```bash
cp -a plugins/jimmy.menu plugins/jimmy.emojis plugins/jimmy.clipboard plugins/jimmy.shared ~/.config/omarchy/plugins/
omarchy restart shell
```

`cp -a` into an existing folder overwrites files of the same name and leaves any extra live files in place. Use `omarchy restart shell` only, never `omarchy refresh shell`.
