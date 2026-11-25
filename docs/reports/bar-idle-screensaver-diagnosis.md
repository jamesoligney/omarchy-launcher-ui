# Diagnosis: screensaver never started after 30 minutes away (2026-11-25)

**Diagnose only. No live config was changed.** All findings come from the idle service's own status and event log, the stay-awake state file, `hyprctl`, `systemd-inhibit` and the toggle script.

## Answer

**The idle timers are not broken. Stay awake was ON the whole time you were away, and it is still ON now.** The idle service disarms the screensaver and lock on purpose while stay awake is on.

Three things hid that from you:

1. **The status output reads backwards.** `omarchy toggle idle status` describes *stay awake*, not idle. `{"enabled":true, "tooltip":"Allow Idle Lock & Screensaver"}` means **stay awake is enabled**. The tooltip names the action that would turn it off.
2. **`omarchy toggle idle` with no argument flips the state; it does not report it.** Its output is the new *idle* state: `disabled` means "idle is now disabled", i.e. stay awake was just turned **on**. Running it to check turned stay awake back on at 09:03:57.
3. **`jimmy.bar` has no stay-awake indicator.** The stock bar shows a Stay Awake light (`omarchy.indicators` → `StayAwake.qml`). The islands bar (Stage 2) does not, so nothing on screen showed that the machine was being kept awake. That is the brief v2 R2 gap ("status lights must never hide") in practice.

`jimmy.bar` did **not** replace the idle service. Idle is a separate service (`omarchy.idle`, enabled, running and answering IPC). `jimmy.idle` is disabled, and switching bars does not touch idle.

## Evidence

**Idle service, now** (`omarchy-shell idle status`):

```
"enabled": false, "stayAwake": true, "stayAwakeStatePath": ".../indicators/stay-awake",
"idle": false, "screensaver": 600, "lock": 900,
"timers": { "screensaver": false, "lock": false, "screensaverLaunchGrace": false },
"lastEvent": "idle-cycle-cancel: stay-awake", "lastEventAt": "2026-11-25T17:03:57Z"
```

`shell.json` → `"idle": { "screensaver": 600, "lock": 900 }`: a 10-minute screensaver and a 15-minute lock, which is correct. The timers are not running because stay awake cancels the idle cycle.

**Stay-awake state file:** `~/.local/state/omarchy/indicators/stay-awake` exists, created **09:03:57.505**.

**Idle service event log today** (local time, from the journal):

| Time | Event | Meaning |
|---|---|---|
| 08:33:56 | `stay-awake: enabled ipc` | Stay awake turned on through IPC: the stock bar's Stay Awake indicator click or `omarchy-shell idle disable/toggle`. **About 5 min before the Stage 0–2 build started** (first backup 08:38:53) |
| 08:41:21, 08:42:39, 08:43:12 | `service-ready`, then `stay-awake: enabled state-file` | The build's shell restarts. Stay awake persists across restarts through the file, as designed |
| *(no events)* | | Build finished around 08:50; stay awake was still on, so no idle cycle could start. **This is the 30 minutes away** |
| 09:02:39 | `stay-awake: disabled state-file`, `idle-monitor: active` | Stay awake turned off (file removed). Idle armed again |
| 09:03:57 | `stay-awake: enabled state-file` | The file was created again, 78 s later: the no-argument `omarchy toggle idle` flipping it back on. Its output `disabled` was read as "stay awake disabled" |

Your shell history (`~/.bash_history`) contains `omarchy toggle idle stay-awake` and `omarchy toggle idle allow-idle`. The 08:33:56 event, though, was IPC, not that script, which logs as `state-file`. I can't tell from the logs who clicked or called it.

## Second, independent blocker: Orca's idle inhibitor

Even with stay awake off, **the screensaver cannot fire while Orca holds an idle inhibitor**:

- `hyprctl clients`: the Orca window has `inhibitingIdle: true`. It is the only window that does. It is **app-side**: Orca carries no `noidle` tag, and no Hyprland rule in `hypr/*.lua` or the stock app rules targets it.
- `systemd-inhibit --list`: Orca also holds `sleep:handle-lid-switch`, "**Agents are working**" (block).
- The idle service's `IdleMonitor` runs with `respectInhibitors: true`, so any Wayland idle inhibitor stops the idle timeout.

It was inhibiting at the time of this check, while an agent (this session) was working. **Not known:** whether Orca releases the inhibitor when no agent is running, so whether it also blocked the screensaver after the build ended. Stay awake alone fully explains the missed screensaver; this is the next thing that would block it.

## What is broken, and the fix (not applied)

| # | Problem | Fix |
|---|---|---|
| 1 | Stay awake is **still on now** | `omarchy toggle idle allow-idle` (explicit; never the bare `toggle` to check). Confirm with `omarchy-shell idle status` → `"enabled": true, "stayAwake": false` |
| 2 | Checking the state flips it | Only ever check with `omarchy toggle idle status`, and read it as: `enabled:true` = **stay awake ON**. Better: `omarchy-shell idle status`, which names `stayAwake` directly |
| 3 | No stay-awake light on `jimmy.bar` | Stage 3 of the bar: a contextual light on the right island while stay awake is on, read from the idle service (`shell.firstPartyServiceFor("omarchy.idle")`, which is open to bar plugins). Same family as the privacy lights (R2) |
| 4 | The build rule had a start step but no end step | Codify the standing build rule as two explicit steps (below), with the end step checked |
| 5 | Orca can block idle during agent work | Decide whether that is wanted. If the screensaver should run while agents work, it needs an Orca-side setting (none found in `~/.config/orca`). To confirm the other half, check `hyprctl clients -j` → Orca `inhibitingIdle` while no agent is running |

## Standing build rule (proposed exact steps)

The keyboard backlight device is `kbd_backlight` (`brightnessctl -l`: max 255, currently 0). The display is `apple-panel-bl`.

**When a build begins:**
```bash
brightnessctl -d kbd_backlight --save         # remember the current level
brightnessctl -d kbd_backlight set 0          # keyboard light off
omarchy toggle idle stay-awake                # freeze screen: no screensaver/lock during the build
```

**When the build is complete:**
```bash
omarchy toggle idle allow-idle                # screensaver and lock back to normal
brightnessctl -d kbd_backlight --restore      # keyboard backlight back to how it was
omarchy-shell idle status                     # must show "enabled": true, "stayAwake": false
```

Use the explicit `stay-awake` / `allow-idle` verbs, never the bare `toggle`, so each step is safe to repeat. The end step belongs in every build report's checklist, next to "no debug logs left" and "backups complete". With the stay-awake light on the bar (fix 3), a forgotten end step would also show on screen.

Proposed `AGENTS.md` wording, not added in this diagnose-only pass:

> **Build start / end.** At build start: save and turn off the keyboard backlight (`brightnessctl -d kbd_backlight --save; … set 0`) and `omarchy toggle idle stay-awake`. At build end: `omarchy toggle idle allow-idle`, `brightnessctl -d kbd_backlight --restore`, and confirm `omarchy-shell idle status` shows `stayAwake: false`. Never use bare `omarchy toggle idle` to check state; it flips it.

## Not verified

- Who issued the 08:33:56 IPC call (the indicator click and `omarchy-shell idle` look the same in the log).
- Whether Orca's inhibitor is released when no agent is working.
- The screensaver actually starting after the fix. Nothing was changed, so the 10-minute timeout was not exercised.
