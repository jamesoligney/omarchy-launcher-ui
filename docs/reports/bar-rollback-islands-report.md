# Bar rollback: back to the islands of this morning (2026-11-26)

Built by Claude Sonnet 5.5 from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-rollback-islands-brief.md`. The brief was downloaded first.

**Result:** the frame is gone. The bar is back to the islands exactly as they were this morning, before any frame edit. Reserves are **`[32, 48, 0, 0]`**. The theme is still **Afterburn Redline**, as you left it.

**The flicker is not fixed by this, because the frame was never its cause.** It is the active-window border shimmer (`hypr-shiny-border`) with the Redline colours; see "The glitch" below. That is a separate decision for you.

## Backups

| Backup | What | Use |
|---|---|---|
| **`20261126-124806-pre-rollback-frame-stage-36`** | The current state before rollback: Stage 35 frame plus the interrupted Stage 36 (`frame.edge 0.50`). Mode 700, **2,403 files**, live = backup by checksum | Keeps the frame work, in case you want it back. It is also in git (`b3f792d` and earlier) |
| **`20261126-110702-bar-stage-28`** (restored from) | Taken at 11:07 at Stage 28's build start, **before any frame edit**, after Stage 27. 2,403 files, own `SHA256SUMS` verified intact. Its mode was 755; now set to **700** | **The clean islands state** |

**Why Stage 28's pre-frame backup and not Stage 26's:** both are pre-frame, but the Stage 28 backup includes Stage 27 (special windows exempt from the float default), which is not frame work and was part of "this morning". The Stage 26 backup would have undone it. Every restored file is **byte-identical to the Stage 27 commit (`26f9370`)** in git too. No rebuild from scratch.

## What changed

**Restored** (copied from the backup, checksums equal to it):

| File | sha256 (first 16) | |
|---|---|---|
| `jimmy.bar/Bar.qml` | `6028a07a00ad81ad` | Islands bar (title island, joined main and status islands, strip) |
| `jimmy.bar/manifest.json` | `8aae204b34e92c88` | "Islands bar" 0.2.0 |
| `shell.toml` | `4ad716ec9c20dcb8` | `bar.height 48`, `joint-radius 2`, `[strip] width 30 / min-height 0.5`; **no `[frame]`, `tint`, `edge` or `bevel-*`** |
| `hypr/monitors.lua` | `47abfd964764ffd0` | Hyprland top reserve 32 again |
| `hypr/float-default.lua` | `9dc8f333f6ef6315` | 1100×619, centred → (330, 273) |

**Removed:**
- `~/.config/omarchy/plugins/jimmy.frame/` (deleted live; kept in the pre-rollback backup and git history).
- The `jimmy.frame` entry in `shell.json`.
- `plugins/jimmy.frame/` from the repo snapshot.

No frame, hull, tint, hard line, bevel or rings remain.

**Deliberately not reverted, both theme-generated:**
- `shell.json`'s border-fx colours. Only the `jimmy.frame` entry was taken out, so `shell.json` differs from the backup **only** in the three Redline border colours.
- `hypr/border-fx.lua`. It differs from the backup only in those same colours.

Copying the backup versions back would have put Afterburn border colours under the Redline theme. The next `omarchy theme set` regenerates both anyway.

**Reloads:** one `hyprctl reload` (for the monitor and float files), then one `omarchy restart shell` on its own (`Bar.qml` is QML). `shell.json` was written once. Never `refresh`.

## Verified live

| Check | Result |
|---|---|
| Reserves | **`[32, 48, 0, 0]`** |
| Layers | `jimmy-bar` (0, 0, 1728×68), `jimmy-strip` (0, 48, 52×1069), `jimmy-bar-reserve`. **No `jimmy-frame*` layer** |
| Islands | Title island left; time "12:48 PM" + battery % + weather island nearest the notch; status island joined (Wi‑Fi, Bluetooth, mic, AI); left strip with numbers 1 2 3 |
| Windows | Tiled windows start at **x 39, y 55**: the islands' work area |
| Floating default | Rule restored: 1100×619, `center = true` on the usable area → x = 32 + (1696 − 1100)/2 = **330**, y = 48 + (1069 − 619)/2 = **273**. I did not open a new window to test it |
| Config / QML | `hyprctl configerrors` empty; no `jimmy.*` warnings after the restart |
| Theme | **Afterburn Redline**, unchanged |
| Idle (build end) | `omarchy toggle idle allow-idle` + `omarchy-kbd-backlight release` → **`"enabled":true,"stayAwake":false`** |

**Not exercised live** (I can't press your keys, and these are restored byte-for-byte from the known-good Stage 27 files): the panels dropping from the right islands, toasts under the right island, fullscreen hiding the bar, Super+L / Super+T, and leader Super+D. Worth a quick check by hand.

## The glitch: diagnosis (from the interrupted Stage 36, re-checked after the rollback)

**Frame cleared as a cause** (before the rollback, Stage 35 live):
- `Frame.qml` was the flat version: one path, odd-even fill, no loop, no timers or animations. Its repaint triggers were only its own token, theme and size properties, nothing tied to focus.
- Quickshell used about 1.5% CPU, the same idle and across 10 forced focus changes.
- The hull and line pixels were identical in 8 captures across focus flips.

**What is redrawing the active window:** six screen captures 150ms apart with no input show **the active window's border changing every frame**, while inactive borders stay fixed. That border is drawn by the `hypr-shiny-border` plugin (`border-fx.lua`: `effect "shiny"`, `shimmer = true`, `shimmer_hz 0.45`, `active_only = true`).

| Theme | Active border at y 162, x 1500, over about 1s | Swing |
|---|---|---|
| Afterburn | 202 → 228 (peach) | Gentle sheen |
| **Redline** | **75 → 209** (bright red ↔ near-black) | **Nearly 3×: reads as flashing** |

Redline's border gradient runs from bright red to fully transparent over a near-black base. The same shimmer that is a soft sheen on Afterburn becomes a strong flash on Redline. You switched to Redline at 11:54, and the flicker reports came after that.

**After the rollback (no frame at all):** the active border **still pulses** (117 → 227 at x 1500), and Hyprland is still at **about 30% CPU**. That confirms the frame was not the cause. **So the rollback does not stop the flicker.**

**Keyboard lag:** I could not reproduce it, because I cannot type into your windows. What the machine shows:
- Hyprland holds about 30% CPU because it re-composites the shimmering active border every frame.
- Orca is busy while an agent streams (Orca `inhibitingIdle: true` during these builds).
- CPU pressure is 11–24% (`/proc/pressure/cpu` "some").
- The battery sparks cost Quickshell about 8–9%; they run whenever the battery is charging or held at its charge limit.

None of that proves the lag, so **I'm not claiming it is fixed.** Idle state was clean throughout; stay-awake was not stuck.

**To stop the flicker** (not done; your call, outside this brief):
- turn the shimmer off in the border-fx plugin settings (`shimmer = false`); or
- use a calmer border-fx effect; or
- switch back to Afterburn default, where the same shimmer is a gentle sheen.

If the lag persists with the shimmer off, the next thing to check is whether it is in every app or only Orca while an agent is streaming.

### Side effect of the diagnosis, now cleared

To measure the sparks' cost I briefly set `battery.spark-min-ms`/`max-ms` to 600000 and restored them seconds later. The timer kept its long interval for one cycle, so the sparks paused for a few minutes. They are running again (Quickshell back to about 9%), and `shell.toml` equals the backup.

## Stage 36 (interrupted)

Stage 36's brief (`docs/omarchy-bar-stage-36-brief.md`) and its diagnosis crops (`docs/reports/bar-stage-36/`) are committed with this rollback.

Its one change was `frame.edge` 0.85 → 0.50. The line pixel went (203, 11, 28) → (137, 10, 21) on Redline and (146, 89, 44) on Afterburn; 0.35 was too faint. That change was removed with the frame. No separate Stage 36 report was written.

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0), `omarchy toggle idle stay-awake` |
| Backup first | `20261126-124806-pre-rollback-frame-stage-36`: mode 700, 2,403 files; live = backup before the rollback. Same scope as Stages 30–35. Excluded (named): `*.bak*`, `__pycache__`, symlinks (`afterburn-watch`, `orca-ide`, `superwhisper`), and all runtime state. No runtime state in git |
| Live after vs pre-rollback | Differs in exactly the rollback set: `Bar.qml`, `manifest.json`, `shell.toml`, `shell.json`, `monitors.lua`, `float-default.lua`, and the deleted `jimmy.frame/*` |
| Snapshot | `plugins/jimmy.bar/*`, `config/omarchy/shell.{json,toml}`, `config/hypr/{monitors,float-default,border-fx}.lua` equal live; `plugins/jimmy.frame` removed |
| Build end | **`"enabled":true,"stayAwake":false`**, backlight released (auto) |
