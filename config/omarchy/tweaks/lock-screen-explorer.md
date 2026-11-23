# Lock Screen Explorer

**Added:** 2026-11-10 — version 2.0.12, commit `2eea881`

[omarchy-lock-explorer](https://github.com/SirJul1337/omarchy-lock-explorer) by
SirJul1337 (MIT). Replaces Omarchy's lock screen with ~60 designs plus a picker
and a visual designer. `omarchy-shell lock explore` opens the picker.

## What changed

```sh
omarchy plugin add https://github.com/SirJul1337/omarchy-lock-explorer.git --enable --yes
```

That one command did everything:

- cloned the plugin to `~/.config/omarchy/plugins/io.github.sirjul1337.lock-explorer/`
- added its id to `plugins` in `~/.config/omarchy/shell.json`
- **moved `omarchy.lock` into `disabledPlugins`** in the same file

The last point is the one to remember. The plugin's manifest declares
`clonedFrom: omarchy.lock`, so the shell swaps itself in as the thing that
answers `omarchy-shell lock` — it *is* the lock screen now, not a skin on top
of it.

## Bar icon (added the same day)

A lock (󰌾) at the end of the bar's right section: click opens the picker
panel, right click the full explorer.

```sh
omarchy-shell lock setBarIcon on      # off to remove
```

That is the plugin's own IPC and it keeps its Settings row in sync; the
*Bar icon* row under System in Settings does the same thing. Underneath, both
run `extras/bar-icon.sh`, which appends a `qml` module to `bar.layout.right`
in `shell.json`:

```json
{ "id": "lock-explorer", "type": "qml",
  "source": "~/.config/omarchy/plugins/io.github.sirjul1337.lock-explorer/BarWidget.qml" }
```

Move it with `omarchy bar move lock-explorer`. Check it with
`bash ~/.config/omarchy/plugins/io.github.sirjul1337.lock-explorer/extras/bar-icon.sh --status`.

It has to be opt-in because a plugin cannot add itself to the bar at install
time. Two things to know about the edit:

- The script rewrites the whole `shell.json` with keys sorted, so the file
  comes back reordered even though the content is the same. Backup taken
  first: `~/.config/omarchy/shell.json.bak.1794350933`. Sections other than
  `right` were diffed afterwards and were unchanged.
- If `bar.layout` had been absent, the script would have copied the entire
  default layout into `shell.json` — the shell has no deep merge, so the first
  bar customization has to carry the whole thing. It was already customized
  here, so this did not happen.

## Settings changed by hand

These live on the plugin's entry in `shell.json` and go away with the plugin,
so they need no separate undo. Each has a row in Settings (`U` in the picker)
that does the same thing.

| Setting | Command | Stored as |
|---------|---------|-----------|
| 12-hour clock, 2026-11-10 | `omarchy-shell lock setClockFormat 12` (`24` reverts) | `clock12: true` |

## Weather design in Fahrenheit (2026-11-10)

The built-in Weather design hardcodes Celsius and km/h, and the plugin has no
weather unit setting. Omarchy's own bar weather widget shows Fahrenheit here
(it resolves units from the `en_US` locale), so the two disagreed.

Fixed with the documented customize path, which survives plugin updates:

```sh
omarchy-shell lock customize weather   # -> ~/.config/omarchy/lock-designs/Weather.qml
omarchy-shell lock rescanDesigns
omarchy-shell lock setDesign my-weather
```

Four edits in that copy, nothing else:

| Was | Now |
|-----|-----|
| `current.temp_C` | `current.temp_F` |
| `current.FeelsLikeC` | `current.FeelsLikeF` |
| `maxtempC` / `mintempC` | `maxtempF` / `mintempF` |
| `windspeedKmph + " km/h"` | `windspeedMiles + " mph"` |

wttr.in's `format=j1` response already carries all of those, so nothing extra
is fetched. `qmllint` parses the result clean, and
`diff ~/.config/omarchy/plugins/io.github.sirjul1337.lock-explorer/designs/Weather.qml ~/.config/omarchy/lock-designs/Weather.qml`
shows only those four lines plus the comment header and the `import` line that
`customize` adds.

The design now in use is `my-weather`, listed under **Custom** in the picker.
The stock Celsius **Weather** is untouched and still selectable.

**Undo:** `omarchy-shell lock setDesign weather` goes back to the stock one;
`rm ~/.config/omarchy/lock-designs/Weather.qml` drops the copy. Note that
`~/.config/omarchy/lock-designs/` is scanned for designs, so keep backups and
stray `.qml` files out of it. (`Card.qml` sits there as an unmodified copy from
an earlier `C` keypress — harmless, just an extra Custom entry.)

Reported upstream as [lock-explorer-weather-units-issue.md](lock-explorer-weather-units-issue.md)
— the suggestion being that the design defer to Omarchy's own
`Model.shouldUseImperial` rather than hardcode units. If a release picks that
up, the custom copy can be deleted and the stock design selected again.

## Check it is working

```bash
bash ~/.config/omarchy/plugins/io.github.sirjul1337.lock-explorer/extras/doctor.sh
```

The plugin's own check. The lines that matter are "omarchy-shell lock is
answered by this plugin" and the `password (/etc/pam.d/omarchy-lock-password)`
line under Sign-in — together they mean the screen will lock and you can type
your way back in. Both were ok at install. `--fix` repairs the two safe cases
(a second copy of the plugin, and neither lock screen being on).

It also flagged, as a note rather than a problem: no FIDO2 security key
service. Only relevant if a hardware key gets enrolled later;
`extras/setup-fido2.sh` sets it up.

## Undo

```sh
omarchy plugin remove --yes io.github.sirjul1337.lock-explorer
omarchy plugin enable omarchy.lock
```

**The second line is not optional.** Removing the plugin does not reliably
switch Omarchy's own lock screen back on — the README warns it can report
"Restored omarchy.lock" while nothing answers `omarchy-shell lock`, which
means nothing locks the screen at all. Confirm with the doctor or:

```bash
omarchy plugin list | grep -i lock
```

Unlike the Fathom note, this undo has **not** been round-tripped here — doing
so would have uninstalled the thing just asked for. It is the author's
documented procedure, and `doctor.sh --fix` is the backstop if a removal does
leave both lock screens off.

Leftovers after removal: `omarchy plugin remove` keeps a backup at
`~/.config/omarchy/plugins/.io.github.sirjul1337.lock-explorer.bak.*` — delete
or move it before ever reinstalling, or the shell may load the stale copy. Any
designs built in the designer stay in `~/.config/omarchy/lock-designs/`.

## Worth knowing

- Reviewed before installing: no network calls other than `curl` to wttr.in
  for the Weather design (same service as the Omarchy weather widget), no
  `eval`, and `pkexec`/`sudo` only inside the opt-in boot-screen and FIDO2
  scripts — nothing in the install path. The repo has a CI check that bans
  `eval`.
- The boot screen feature (theming the disk-decryption prompt) is separate and
  opt-in. It writes to `/boot/` via `pkexec` and prompts for a password. Not
  enabled; it would deserve its own note.
- `qt6-multimedia` and `qt6-imageformats` were already installed, so the video
  and clip designs and WebP wallpapers all work. Without them those designs
  just switch themselves off.
- If `omarchy-shell lock explore` ever answers `Function not found`, the stock
  service is still holding the IPC target: `omarchy restart shell`.
