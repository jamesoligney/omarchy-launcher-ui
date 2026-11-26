# Bar Stage 25: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-25-brief.md`. I downloaded the brief from the given URL into `docs/` first and committed it with this report.

**Not touched:** the strip, the window title, the dock, the float default, Super+L, and the frame / integration work (left alone, as asked).

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261125-163758-bar-stage-25`** (mode 700, 208 files), taken before any edit. It covers every `~/.config/hypr/*.lua`, every `jimmy.*` plugin, `shell.json`, `shell.toml`, hooks, theme files, extensions, the Vicinae settings, helpers and the systemd unit, plus (local only) the saved per-workspace layouts. Checksums: live before = backup = live after |
| Reload | **One `omarchy restart shell`, on its own:** a new shared QML type (and the `qmldir` that declares it) can't be hot-reloaded. Never `refresh`. No Hyprland change |
| Debug / temporary code | None. The test notification, volume toast and reminder card all closed. The volume was raised one step and lowered one step, so it ended where it was |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced: `Bar.qml`, `Osd.qml`, notifications `Service.qml`, `ReminderFlow.qml`, `PanelShell.qml`, plus the new `jimmy.shared/BarLayout.qml` and `jimmy.shared/qmldir`. Live checksums are identical before and after, and the snapshot equals live. No runtime state in git |

## Cause

- **Every surface that hangs from the right side** centred itself on **`ears.rightCenter`**, the centre of the right ear:
  - toasts (`jimmy.osd`);
  - the notifications deck (`jimmy.notifications`);
  - the reminder card (`jimmy.reminders`);
  - `PanelShell`.
- **Since Stage 12** only the **main** right island sits on that centre. The status island hangs off its right, so the visible right island is wider and its middle is further right.
- **These plugins had no way to see the bar's live islands,** so they all centred under the primary island alone.

## Fix: one rule, from the bar's live geometry

- **New `jimmy.shared/BarLayout.qml`:** a singleton holding the islands' live centres in screen x.
  - **Publisher:** `jimmy.bar` keeps it current with bindings. `rightCenter` = the middle of the **whole right island**, from the main island's left edge to the status island's right edge. `leftCenter` = the left island's centre.
  - **Live:** it is a binding, so any width change (time getting wider, a status light appearing) moves it, and a toast always uses the width at the moment it appears.
- **Fallback:** consumers call `BarLayout.right(ears.rightCenter)`, so if the bar isn't running they fall back to the old ear centre.
- **Applied to every surface with that anchoring,** one rule:

| Surface | Before | Now |
|---|---|---|
| Toasts (volume, brightness, mic and the like): `jimmy.osd` | ear centre | `BarLayout.right(...)` |
| Notifications deck (app messages): `jimmy.notifications` | ear centre | `BarLayout.right(...)` |
| Reminder card: `jimmy.reminders` | ear centre | `BarLayout.right(...)` |
| `PanelShell` (shared, unused today) | ear centres | `BarLayout.right/left(...)` |

- **`qmldir`:** a singleton needs one, so `jimmy.shared` now has a `qmldir` listing **every** existing shared type plus `BarLayout`. All plugins importing `jimmy.shared` loaded without error after the restart.
- **Unchanged:** which island a toast grows from. All of these already belong to the right side; only the width they centre under changed.
- **Dropdown panels** (calendar, weather, network…) are not toasts. They keep dropping from the island whose icon opened them, as before.

## Verified live (screenshots, measured in logical px)

| Toast | Its span | Centre | Whole right island (≈ 1209–1634) |
|---|---|---|---|
| **App notification** (sent through `omarchy-notification-send`, the same notification server path as a message from another workspace) | ≈ 1232–1610 | **≈ 1421** | centre **≈ 1421** |
| **Volume toast** (the real volume command) | ≈ 1291–1550 | **≈ 1420** | ✓ |
| **Reminder card** | ≈ 1272–1570 | **≈ 1421** | ✓ |

Before the fix, all three centred on the main island (≈ 1339).

**Not tested with a message from a real app window:** `notify-send` is still broken system-wide (the libnotify symbol error from Stage 4), and no app sent a message during the build. Every app notification goes through the same notifications deck verified above.

## Other checks the brief asked for

- **Left side:** the left island (the window title) is **a single piece**, so the full-width rule changes nothing there. No toast hangs from the left today. `PanelShell` would use `BarLayout.left` if one did.
- **Keyboard backlight:** the backlight helper (`omarchy-kbd-backlight`, which the backlight keys call) **shows no toast at all**, so there was nothing to re-centre. The display-brightness and mic toasts are `jimmy.osd`, the same path as volume.
- **Fullscreen:** the bar layers hide, but toasts and notifications still appear in the same place, top right under where the island would be. `BarLayout` keeps the last live centre while the bar is hidden. Not changed, since that isn't broken.

## Still open

- **Your check:** a real message from an app on another workspace.
- **Still pending:** the broken `notify-send` (libnotify), cascade vs. stacked, and #12.
