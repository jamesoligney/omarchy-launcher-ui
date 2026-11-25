# Bar Stage 5: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-5-brief.md`. The brief was downloaded from the given URL into `docs/` first and is committed with this report. Locks respected: island size, radius, bar height, text size, SF Compact Display Medium with no bold, and the toast attachment (`toast.gap` 0) are untouched.

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| Backup before editing | **Missed this round: no new local pre-edit backup was taken.** The restore point is the Stage 4 commit `2326859`. Its snapshot was verified equal to live (checksums) and live stayed that way until this round, so it holds the pre-change version of every file touched here: `jimmy.bar/Bar.qml`, `jimmy.shared/PanelShell.qml`, `hypr/bindings.lua`, `shell.toml`. `shell.json` was not changed. Earlier local backups remain in `~/.local/state/omarchy-launcher-backups/` |
| Reload | `omarchy restart shell` only, each on its own; never `refresh`, never combined with a summon |
| Debug / temporary code | A temporary `hoverTest` IPC hook was used to test the hover timing and **removed before the final restart** (`grep TEMP-` = 0, `console.log` = 0). The hover flags stay in the permanent `omarchy-shell jimmy.bar status` |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`**; backlight `mode: auto` |
| Snapshot | 193 live files resynced; checksums identical before and after; snapshot equals live; no runtime state in git |

## 1. Battery charging: a shimmer, not a pulse

- **Removed:** the 2 px outline that pulsed in opacity.
- **Now:** while charging, the pill's own **1 px outline** drifts its *colour* slowly between two accent shades and back: accent at 35 % → a slightly lighter accent at 75 % → back. It is one smooth out-and-back loop of **7 s** (`battery.shimmer-ms` = 7000, which replaces `pulse-ms`). The number stays as it was, not accent.
- **Measured live**, reading the outline colour once a second through `status`: `#71f7974f`, `#59f59145`, `#6bf6954c`, `#98fba25f`, `#bbfeac6d`, `#b6feaa6b`, `#8dfa9f5a`, `#63f59349`. A slow, low-contrast drift; nothing blinks.
- **Fixed along the way:** the first version declared the animation on a property of an item inside the per-screen delegate, and it did not run (the outline sampled constant). It now lives once at the bar's root (`shimmerColor`) and every pill reads it, which is also lighter.

## 2. Hover pop-out: the hover zone (bug fixed)

**Cause:** two gaps in the hover zone.
- **Time:** its hover area was only the height of the time's text, not the island.
- **Card:** its hover detector sat inside the card's 10 px padding.

Moving down from the time crossed a dead band (the rest of the island plus the card's top padding). A slow move exceeded the 300 ms grace and closed the pop-out.

**Fix (no redesign):**
- **Time:** its hover zone now spans the island's full height. The pop-out card is attached at the island's bottom edge, so the two zones meet with no gap.
- **Card:** `PanelShell` exposes `hovered` from a `HoverHandler` over the **whole** card, padding included.
- **Grace:** the pop-out closes only after the pointer has left both for **300 ms** (kept). Opening still waits 180 ms on the time.

**Verified:**
- **Timing, with a temporary hook driving the two hover inputs exactly as the pointer does:**
  - opens over the time;
  - **stays open across the move time → card** (100 ms between);
  - stays open while resting on the card;
  - still open 150 ms after leaving both, **closed at 500 ms**;
  - a brief slip out and back to the time keeps it open;
  - leaving again closes it.
- **Keyboard path:** the command `Super+Ctrl+Q` runs opened the pop-out with focus (`opened: true, keyboard: true`) and the second press closed it.
- **Not testable here: a real hand on the pointer.** This round, warped pointer motion (`hl.dsp.cursor.move`) stopped delivering enter and leave events to the bar: its hover flags stayed frozen whatever the pointer did. So the geometry part of the fix is verified by reading the code and the timing part by the hook. Your own mouse is the final check.

## 3. Workspace numbers clickable, and the all-ways rule

- **Bug found:** clicking a number sent `workspace N` to Hyprland, which this Lua config rejects (`')' expected near 'N'`). The click now sends `hl.dsp.focus({ workspace = "N" })`. **Verified:** that exact dispatch switched 8 → 3 and back.
- **Leader built: `Super+D`** (checked free), then one key, as a Hyprland submap (`hl.define_submap("bar", "reset", …)`) in `bindings.lua`:
  - **Keys:** 1–9 workspace (the same `o.workspaces.focus` as `Super+digit`), W weather, T calendar, B battery and power, A agents, Q quick toggles, Esc leaves.
  - **One key exits the leader.**
  - **Hints:** while it is active the bar shows each letter (T Q over the time, W, B, A) and outlines the workspace numbers.
  - **Verified:** entering the submap turned the hints on (`status.leader: true`, screenshot); reset turned them off. Hyprland lists the 9 digit binds in the same form as the stock `Super+digit` binds.

**Audit: every island element, three ways**

| Element | Mouse | Keyboard | Leader | Change |
|---|---|---|---|---|
| Workspace numbers | **click (was broken)** | Super+1–9 (stock) | 1–9 | click fixed; leader added |
| App name | — | — | — | flagged: display only; no sensible action for the focused window's name |
| Stay-awake light | click toggles off | Super+Ctrl+Q → Enter | Q → Enter | unchanged |
| Time | click: calendar; hover: quick toggles | Super+Ctrl+Alt+D (calendar), Super+Ctrl+Q | T, Q | leader added |
| Weather | click: weather panel | **none before** | W | leader added (was mouse-only) |
| Battery | click: power panel | Super+Ctrl+P (stock) | B | leader added |
| Screen-record light | **click: stop recording (new)** | stock capture keys | — | was display-only; click added |
| Mic light | **click: mute toggle (new, the hosted mic widget's own `toggleMute`)** | the mic-mute key (stock) | — | was display-only; click added |
| Remote-session light | — | — | — | flagged: display only; there is no "end session" action to call |
| AI mark | click: agents panel | **none before** | A | leader added (was mouse-only) |

Toasts: unchanged; the audit found no orphan.

## 4. Agents: capsules off, one quiet mark, no side panel

- **Removed:** the four capsules and the robot glyph.
- **Not built:** a side panel or mission control, as instructed.
- **Now:** one AI mark, the Nerd Font "sparkles" glyph (U+F0674). That is a one-line glyph choice, not a new icon.
  - **Calm at rest:** quiet colour, 60 % opacity.
  - **Colour only when worth seeing:** red when a tracked plan is over a limit, accent when near one (≥ 0.85), full foreground while an agent window runs.
  - **Click** opens the existing agents panel; leader A.
- **It is red right now, truthfully:** OpenCode's record shows its **monthly limit at 100 %** (peaks: claude 0.67, opencode 1.0, grok no limits). That is real data, not invented. If you'd rather not see an over-limit monthly plan on the bar, drop `opencode` from `agents.ids` in `shell.toml`: one line, and the mark goes calm.

## 5. #13 (Teams usage): closed

**Closed, with the reason:**
- **Where the usage was:** your Teams usage this morning came through a **Helium browser window (claude.ai)**, not through Orca or the local Omarchy agent environment.
- **What the local records see:** only what runs in that local environment, so browser Teams usage will never register there. That is a boundary, not a bug.
- **Why it can't move:** the Teams projects stay in that Claude instance, with cloud access and their project documentation; they cannot move into Orca.
- **Not re-opening** unless the data source changes.
- **Contract:** the optional `agent.account` field added in Stage 4 stays, for when local agent data exists. The per-account watcher in the bar was removed with the capsules.

## Token changes (`shell.toml`)

| Token | Was | Now |
|---|---|---|
| `battery.pulse-ms` | 1800 | removed |
| `battery.shimmer-ms` | — | 7000 (one slow out-and-back loop) |

## Still open

- **For your eye:**
  - Whether the 7 s colour drift is subtle enough at 80 % all day. Low and high shades are one line each in the bar if they need nudging.
  - Whether the red AI mark should ignore monthly over-limits.
- **Real mouse:** hover over the time, then into the pop-out; and clicks on the mic and record lights (no uinput tool here; warped pointer motion no longer delivers hover).
- **Missed backup:** the local pre-edit backup this round (above). Next round takes it at build start as usual.
- **Still pending:** `notch.width` (ruler) and the broken `notify-send` (libnotify symbol error, from Stage 4).
