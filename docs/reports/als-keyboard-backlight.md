# Ambient-light keyboard backlight + manual keys (2026-11-25)

Status: **built, running and enabled at login.** One script, `~/.local/bin/omarchy-kbd-backlight`, plus a user service, `omarchy-kbd-auto.service`. The manual keys are bound in `hypr/bindings.lua`. Stay awake and idle were not touched: `omarchy-shell idle status` showed `enabled: true, stayAwake: false` before and after.

## Hardware (as given, re-checked)

- **Light sensor:** `/sys/bus/iio/devices/iio:device0/in_illuminance_input` (`name` = `aop-sensors-als`). Read 21–27 lux in your lit room during the build. The daemon finds the sensor by looking for the iio device that has `in_illuminance_input`, so a renumbered `iio:device*` does not break it. `iio:device1` (lid angle) is ignored.
- **Keyboard backlight:** `kbd_backlight`, max 255. `/sys/class/leds/kbd_backlight/brightness` is root-owned but world-readable, so the daemon **reads** the level directly and **writes** only through `brightnessctl` (logind), and only when the level changes.
- **No `iio-sensor-proxy`** is installed, and the sysfs channel has no event interface without root buffer setup. So the daemon samples the sensor: one sysfs read every 2 s (0.5 Hz), no process spawn per sample.

## 1. The auto daemon

`omarchy-kbd-backlight daemon`, run by `~/.config/systemd/user/omarchy-kbd-auto.service` (`WantedBy=graphical-session.target`, `Nice=10`, restarts on failure). It uses about 15 MB of memory; the CPU cost is one file read every 2 s.

**Each tick:**
1. Read lux and update a **moving average of log(lux)**. Exponential, with a 20 s time constant: a passing shadow or a hand over the sensor barely moves it.
2. Read the current level. If it differs from what the daemon last wrote, **someone else changed it** (keys, lock, `brightnessctl`). Auto then pauses for the override timeout instead of fighting.
3. If paused (build hold, lock/idle blank, manual override), do nothing.
4. Otherwise compute the target. Move only if the target is at least 2 steps (32 levels) away, or when switching on or off, with a 400 ms fade.

### Lux-to-brightness mapping

- **Off/on hysteresis:** off when the smoothed lux rises **above 15**; on only when it falls **below 10**. Between 10 and 15 the backlight keeps its current state, so no flicker at the threshold.
- **When lit:** log-linear from 15 lux (dimmest) to **1 lux and below (128 of 255, 50 %)**, in steps of 16. Auto never goes above 50 %, a comfortable dark-room level like macOS; the manual keys can still reach 100 %.

| Smoothed lux | Level (of 255) |
|---|---|
| ≥ 15 (your lit room: 19–27) | 0 (off) |
| 10 (coming on) | 16 |
| 5 | 48 |
| 2 | 96 |
| ≤ 1 (covered sensor: 0.545) | 128 |

Tunable without code: `~/.config/omarchy/kbd-backlight.conf`, `KEY=VALUE` lines (`interval`, `smoothing`, `lux_dark`, `lux_on`, `lux_off`, `max_level`, `step`, `min_change`, `fade_ms`, `override_min`, `hold_max_hours`), then `systemctl --user restart omarchy-kbd-auto`.

### It never fights anything else

| Situation | What the daemon does |
|---|---|
| **Build hold** (`omarchy-kbd-backlight hold`) | Paused until `release`. A forgotten hold expires after **4 h** |
| **Stock lock/idle blank** (`omarchy-brightness-keyboard off` … `restore`) | Paused while the stock blank file exists, so it never relights a locked keyboard |
| **Manual key or any outside `brightnessctl`** | Paused for the override timeout, then adopts whatever level it finds and moves gently from there |

## 2. Manual keys

**Chosen: Ctrl + F1 (down) and Ctrl + F2 (up)**, plus the dedicated backlight keysyms (`XF86KbdBrightnessDown/Up`) in case F5/F6 send them.

**Why:**
- **Ctrl + the display-brightness keys is Omarchy's own MacBook convention.** The stock `bindings/media.lua` says "MacBooks have no keyboard-backlight keys. Ctrl and the display brightness keys drive the keyboard backlight instead." F1/F2 reach Hyprland as `XF86MonBrightnessDown/Up` on this keyboard (`hid_apple` `fnmode` = 3), so this pair always works. It also collides with nothing.
- **F5/F6 could not be settled without a key press, and I cannot press keys.** The Apple SPI keyboard registers both the old Mac top-row codes (`KEY_KBDILLUMDOWN/UP` on F5/F6) and the 2021 ones (`KEY_MICMUTE`, `KEY_SLEEP`…), so its capability bitmap does not say which F5/F6 send. Rebinding `XF86KbdBrightnessDown/Up` means F5/F6 drive the backlight **if** they send those codes. If they send mic-mute or sleep (the 2021 dictation and Do Not Disturb keys), those stay as they are; nothing was guessed onto them.
- **To find out**, press F5 and F6 with this running: `libinput debug-events --device /dev/input/event0 | grep KEY` (or `wev`). `KEY_KBDILLUMDOWN/UP` means F5/F6 already work.

**What a press does:**
- The same 10 % step as stock (`omarchy-brightness-keyboard`), so 255 is reachable in 10 presses.
- **The stock OSD shows the level** (keyboard icon and %; checked on screen at 9 %).
- **A journal line**, e.g. `manual up: level 25/255 (9%), auto paused 10.0 min` (`journalctl --user -t omarchy-kbd-backlight`).
- `omarchy-kbd-backlight status` prints lux, level, mode, and seconds until auto resumes.

### Override timeout: 10 minutes

A manual press (or any outside change) pauses auto for **10 minutes after the last press**. Each press restarts the 10 minutes. Then the daemon adopts the level you left and moves from there only if the light calls for a change of at least 2 steps.

Why 10 minutes: long enough that a nudge sticks for a working session, short enough that walking into a different room soon behaves automatically again. Set it with `override_min` in the config file.

## Build rule (added to `AGENTS.md`)

- **Build start:** `omarchy-kbd-backlight hold` saves the level, sets 0, and pauses auto.
- **Build end:** `omarchy-kbd-backlight release` restores the level and resumes auto.
- **Raw `brightnessctl`:** don't use it during a build. Auto would treat it as a manual override and take over again after 10 minutes.
- **Stay awake:** the new section also records the stay-awake steps and the warning that bare `omarchy toggle idle` flips the state (from the screensaver diagnosis).

This build followed it: `hold` at the start (saved 0), `release` at the end (restored 0, auto resumed; it stays off in your lit room).

## How to turn auto off if it misbehaves

```bash
omarchy-kbd-backlight auto off        # stops the service and disables it at login
omarchy-kbd-backlight auto on         # back on
journalctl --user -u omarchy-kbd-auto -f   # watch what it decides, with lux and levels
```

The manual keys keep working with auto off. To remove the feature entirely:
1. `auto off`.
2. Delete the `kbd-backlight` block in `bindings.lua`; the stock binds come back on `hyprctl reload`.
3. Remove the script and the unit.

## Verified live

| Check | Result |
|---|---|
| Mapping (dry run of the real function) | values in the table above, including the hysteresis on the way back up (11 and 14 lux keep 16; 16 lux turns it off) |
| Daemon loop, isolated test (fake sensor, own runtime folder, real LED) | dark: 0 → 128. An outside change to 60 was detected and held for the whole test override, then auto went back to 128. Bright (30 lux): faded 128 → 80 → 32 → 0 along the smoothing |
| Lock/idle blank | with the stock blank file present and the fake sensor dark: stayed 0, logged `paused: lock/idle blank` |
| Service | `active`, `enabled`, 15 MB; logged `paused: build hold`, then `auto resumed at level 0` after `release` |
| Bound command | `omarchy-kbd-backlight up` → level 25 (9 %), the OSD showed the keyboard icon at 9 %, journal line written; `down` → 0 |
| Binds | `hyprctl configerrors` empty; Omarchy's keybindings table lists Ctrl+F1/F2 and `XF86KbdBrightnessDown/Up` as keyboard brightness down/up |
| Idle | `omarchy-shell idle status`: `enabled: true, stayAwake: false`, before and after |

**Bug found and fixed during testing:** config values were cast to their default's type, so a fractional `override_min` (e.g. 7.5) truncated (0.2 became 0 and auto resumed instantly). The two time settings are now floats; the re-test held the override for its full window.

## Not verified

- **A real key press** of Ctrl+F1/F2 or F5/F6: no uinput tool is installed, and Hyprland ignores virtual-keyboard input for binds. The binds and their command were checked separately.
- **A real dark room or covered sensor driving the service.** Covered by the fake-sensor test of the same loop, but not with your hand over the real sensor.
- Behaviour across suspend/resume. The service restarts on failure, but resume was not exercised.

## Files

**Live:**
- `~/.local/bin/omarchy-kbd-backlight` (new)
- `~/.config/systemd/user/omarchy-kbd-auto.service` (new; enabled)
- `~/.config/hypr/bindings.lua` (the `kbd-backlight` block)

**Repo snapshot:**
- `plugins/bin/omarchy-kbd-backlight`
- `config/systemd/user/omarchy-kbd-auto.service`
- `config/hypr/bindings.lua`
- `plugins/README.md` and `config/README.md` (restore steps)
- `AGENTS.md` (build start/end rule)

**Snapshot and backup:**
- Full resync: 175 live files, checksums identical before and after, snapshot equals live.
- Backup before editing: `~/.local/state/omarchy-launcher-backups/20261125-094750-kbd-backlight` (mode 700).
- No runtime state in git. The daemon's own state (hold, override) lives in `$XDG_RUNTIME_DIR`, which is cleared at logout.
