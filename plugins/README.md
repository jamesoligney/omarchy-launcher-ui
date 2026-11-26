# Plugin snapshot (fallback point)

Copies of the user-authored Omarchy plugins, taken 2026-11-23 and kept in step with the stages (latest 2026-11-26).

**The live source is `~/.config/omarchy/plugins/`.** Edit there, not here; this folder is a snapshot and drifts as soon as the live files change.

| Folder | What it is |
|---|---|
| `jimmy.menu/` | The Raycast-style launcher (Super+Space) and its bar widget |
| `jimmy.emojis/` | Emoji picker |
| `jimmy.clipboard/` | Clipboard picker |
| `jimmy.apps/` | The apps window (grid of every app), opened from the launcher's Apps row |
| `jimmy.reminders/` | Reminders dialog (clone of the stock one, with the shared motion) |
| `jimmy.battery/` | Battery service (clone): low-battery check driven by UPower signals, no timer |
| `jimmy.bar/` | Bar elements drawn on the frame (Stage 28), no pills; switch with `omarchy bar use jimmy.bar` / `omarchy bar use omarchy.bar` |
| `jimmy.frame/` | One rounded glass frame around the desktop (Stage 28); owns the reserves (top 75, left 30, right 15, bottom 15) and the notch cutout |
| `jimmy.notch-ruler/` | Notch calibration overlay (Stage 1); `omarchy-shell shell summon jimmy.notch-ruler` |
| `jimmy.osd/` | On-screen display (clone): every toast grows out of the right row of `jimmy.bar` |
| `jimmy.notifications/` | Notifications (clone): the deck hangs centred under the right row of `jimmy.bar`, island style |
| `jimmy.shared/` | `CardMotion.qml` (open/close animation, reads `[motion]` tokens), `PowerEvents.qml` (UPower change signal), `Tokens.js` (token readers), `AppName.js` (app-name resolver), `MinuteClock.qml` (minute tick), `BarGeometry.js` (ears), `Staleness.qml` (fresh/stale/offline), `PanelShell.qml` (panels from a row), `PanelAdopter.qml` (stock panels in the same language) |
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

## Helper scripts (`plugins/bin/`)

Live copies live in `~/.local/bin/`. Restore with `install -m 755 plugins/bin/<name> ~/.local/bin/<name>`.

- `omarchy-launcher-paste`: the shared paste helper both pickers call.
- `omarchy-kbd-backlight`: ambient-light keyboard backlight daemon and manual keys. Its user service is `config/systemd/user/omarchy-kbd-auto.service`; restore it to `~/.config/systemd/user/`, then `systemctl --user daemon-reload && systemctl --user enable --now omarchy-kbd-auto.service`.

