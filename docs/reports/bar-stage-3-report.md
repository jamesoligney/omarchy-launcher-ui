# Bar Stage 3 — islands live: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-3-brief.md`, both committed with this report. All eight items are built and live. Everything below was checked on the running machine unless it is listed under "Not verified".

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| Backup before editing | `~/.local/state/omarchy-launcher-backups/20261125-100128-bar-stage-3` (mode 700, 59 files, checksums): every `jimmy.*` plugin, all of `~/.config/hypr`, `shell.json`, `shell.toml`, the menu extension, both helper scripts, the backlight unit. `shell.json.bak.stage3-*` also taken before the OSD clone switch |
| Reload | `omarchy restart shell` only, each run on its own; never `refresh`, never combined with a summon |
| Debug logs | none added; `console.log` count in `jimmy.bar`, `jimmy.osd`, `jimmy.shared`, `jimmy.emojis` = 0. A permanent `omarchy-shell jimmy.bar status` IPC call was added instead (JSON of what the islands show) |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`**; backlight `mode: auto`, level 0 (bright room) |
| Snapshot | 180 live files resynced; checksums identical before and after; snapshot equals live; no runtime state in git |

## What was built

### 1. Islands centred in their ears
- **New shared geometry `jimmy.shared/BarGeometry.js`:** each ear is the strip from a screen edge to the notch. Each island is centred in its ear and grows both ways, so its centre never moves.
- **Live positions:** left ear centre x ≈ 389, right ear centre x ≈ 1340 (at `notch.width` 174).
- **Shared on purpose:** the toast system uses the same geometry, so toasts sit under the right island's centre.

### 2. Less pill, larger elements, same reserve
- **Island height:** 38 instead of 32, by cutting the gap above and below from 6 to 3, inside the same 44 px reserve. **The reserve was not increased.**
- **Shape:** radius 9 instead of 14, a rounded square rather than a pill.
- **Text:** 16 px, from a new token.
- **Quiet contract:** everything except the active workspace, the app name and the contextual lights sits at `quiet-alpha` 0.72.

### 3. Battery pill
- **Size:** 52 × 22 instead of 26 × 9. The % sits inside, bold, with tabular figures.
- **Fill = charge:** it eases over 600 ms when the level changes.
- **Colour:** amber at ≤ 20 % (the theme accent) and red at ≤ 10 % (the theme `urgent` colour). Neutral otherwise.
- **Charging:** option (b) from the refined brief, a soft pulse at the fill's leading edge in a single 1.8 s loop. It stops while the bar is hidden.
- **Data:** UPower properties, which are already signal-driven.

### 4. One toast system, from the right island
- **Clone:** the stock OSD (`omarchy.osd`, which every volume, brightness, keyboard-backlight and media toast goes through) is cloned as **`jimmy.osd`** with `omarchy plugin clone`.
- **Where:** its card now sits under the right island's centre (`bar.height + toast.gap`).
- **Look and motion:** the launcher's glass and border. It **grows out of the island** with the shared `CardMotion` (scale origin at its top edge), and closes with the shared close and hold.
- **Callers:** none changed, so every toast now comes from one place. The backlight daemon and its mapping are untouched.
- **Blur:** `omarchy-osd` was added to the glass blur rule in `hypr/menu-glass.lua`.

### 5. Stay-awake light and privacy lights (R2)
Contextual lights on the right island, shown only while on, never hidden:

| Light | Source (live, no polling) | Colour |
|---|---|---|
| Stay awake | the idle service (`shell.firstPartyServiceFor("omarchy.idle")`) | accent |
| Remote session | the remote-session service | urgent |
| Screen recording | the recorder already pushes `omarchy-shell omarchy.indicators refresh` on start and stop; `jimmy.bar` now answers that target with one `omarchy-capture-screenrecording --status` | urgent |
| Microphone in use | the hosted stock microphone widget's `inUse` (Pipewire), so the stock logic is reused, not copied | urgent |

The mic is primary and sits rightmost; the others stack to its left.

### 6. Weather live
- **Source:** the stock weather widget, hosted (see §8), keeps fetching on the stock source and interval (open-meteo plus wttr.in, 15 min). The island shows its icon only, in the stock theme-aware glyph set (9 conditions, day/night), reused from the stock `Model.js` rather than copied.
- **Location:** Berkeley, set with the stock command `omarchy-weather-location --set "Berkeley, California" 37.8716,-122.2727` (writes `~/.local/state/omarchy/settings/weather.json`; it did not exist before).
- **Staleness:** three states through a new shared `jimmy.shared/Staleness.qml`:
  - **Fresh:** full.
  - **Stale:** beyond 2× the interval, dimmed.
  - **Offline:** the primary fetch failing, or older than 4×, dimmed with a red mark.
- **Expand:** clicking the icon opens the full stock weather panel, which drops from the right island.
- **Manual refresh:** `omarchy-shell jimmy.bar refreshWeather`. Leader R comes with the leader in Stage 4.
- **Found and worked around: a stock bug.** open-meteo's server answers the stock panel's exact request with **HTTP 403** for curl's default User-Agent. The same URL with a browser User-Agent returns 200, and dropping either `timezone` or `forecast_days` also returns 200. With coordinates saved, the stock panel takes its icon *only* from open-meteo, so the stock icon stays blank ("—" in its own panel). The island derives the icon from the current conditions instead, which fall back to wttr.in. Not fixable here without editing `/usr/share/omarchy`; worth reporting upstream.

### 7. Agents live
- **Icon:** quiet (60 %) unless something is worth seeing.
- **Red dot:** when any tracked plan is used past `agents.near-limit` 0.85. Tracked ids: `agents.ids` = claude, opencode, grok, read from the usage records, which are watched files.
- **Right now** the dot is on, truthfully: **OpenCode's monthly limit reads 1.0 (100 %)**. Claude's session limit is at 34 % and its week at 13 %; Grok has no limits in its record.
- **Running:** full opacity while an Omarchy agent window (`org.omarchy.agent`) is open.
- **Click:** opens the stock agents panel (hosted) from the right island.
- **Hook contract reviewed, not built.** The frozen schema (`docs/contracts/agent-hook-payload.schema.json`) carries `agent.id` and `session.*`. **It has no account field**, and the refined brief's adopted payload asks for `account`. Before mission control is built, the contract needs an optional `account` (`main` / `teams`) at the hook layer. Not changed this round; flagged.
- **#13 (Claude Personal vs Teams), still open.** `~/.local/state/omarchy/agents/accounts/claude.json` lists two accounts (Personal "main", Pro, active; Teams) with `switch: manual`, and there is **one** `claude.json` usage record, for the active account only. So "both live without switching" is **not** possible from the current data. Not filled in.
- **#12 (OpenCode/Grok status push), still open.** Their records exist (`opencode.json` with limits, `grok.json` without), but nothing pushes live status. The amber "waiting" dot needs hooks and is not built.

### 8. Bar-widget panels: **restored as hosts**
- **Decision:** host the panels rather than replace them with the Super+D leader.
- **How:** `jimmy.bar` now hosts the stock widgets, invisibly, under the right island, through the shell's sanctioned route for replacement bars. It uses `pluginShellForBarEntry` and the widget registry; its `PluginBarApi` stubs cover popout bookkeeping and run.
- **Hosted:** audio, Bluetooth, network, power, monitor (display), clock (calendar), weather, agents and microphone. Nine widgets, all in the existing bar layout.
- **Result:** `Super+Ctrl+A/B/N/P/D` and `Super+Ctrl+Alt+D` work again, and every panel drops from the right island. No dead keys.
- **Why hosts, not the leader:**
  - **No targets yet:** the leader's letters would point at Stage 4 PanelShell panels that don't exist.
  - **No standalone apps:** there are no standalone audio or Bluetooth apps on this machine to point the keys at (only `nmtui` and `iwctl`).
- **Leader:** `Super+D` (free) stays planned for Stage 4, when the panels exist.

## Token values changed (`~/.config/omarchy/shell.toml`)

| Token | Was | Now |
|---|---|---|
| `island.gap` | 6 | 3 (island height 38) |
| `island.radius` | 14 | 9 |
| `island.padding-x` | 12 | 10 |
| `island.font-size` | — | 16 (new) |
| `island.quiet-alpha` | — | 0.72 (new) |
| `battery.bar-width` | 26 | 52 |
| `battery.bar-height` | 9 | 22 |
| `battery.pulse-ms` | — | 1800 (new) |
| `toast.gap` | — | 8 (new) |
| `agents.ids` | — | `claude,opencode,grok` (new) |
| `agents.near-limit` | — | 0.85 (new) |
| `fullscreen.debounce-ms` | — | 50 (new) |
| `bar.height` | 44 | 44 (unchanged; moved into the stock `[bar]` table, see below) |

**Fix:** Stage 0 left `shell.toml` with two `[bar]` tables, which is invalid TOML (the shell's reader tolerated it). They are merged now; the file parses with Python's `tomllib`.

## Verified live

| Check | Result |
|---|---|
| Layers and reserve | `jimmy-bar` 0,0 1728 × 44; reserve strip at y 32; monitor reserve top 44, bottom 0 |
| Islands | centred in their ears; larger text; squarer corners (screenshots) |
| Battery | "79%" inside the pill, fill to 79 %, charging pulse visible |
| Toast | `omarchy-osd -i keyboard -p 30` → card under the right island, launcher glass, grown from the island |
| Panels | `omarchy-shell shell toggle` (exactly what the Super+Ctrl binds run) for audio, Bluetooth, network, power, monitor, clock and agents: each opened a panel and closed again; the audio panel screenshot shows it dropping from the right island |
| Weather | icon live (partly cloudy, day); stock panel opened from the island with Berkeley, 57 °F, forecast |
| Stay-awake light | on during the build (stay awake on); **off** after `allow-idle` |
| Mic light | on (red) during a 3 s `pw-record /dev/null`, off after |
| Screen-record path | `omarchy-shell -q omarchy.indicators refresh` → exit 0, status check ran, not recording |
| Fullscreen | Lua `hl.dsp.window.fullscreen` on Helium: the islands layer unmounted (zero draw) and returned when fullscreen ended |
| Theme switch | `afterburn-cyber`: islands, light and toast re-tinted to its green; back to `afterburn`, `shell.json` identical after the round trip |
| Pickers | emoji picker still opens after the changes |
| Journal | the final shell instance: no errors from any changed file |

**Also fixed while interrogating the rest of the UI:** the emoji picker's chip model (my Stage 3b-era code) could pass an undefined entry to its delegate during a data reload (`Emojis.qml` 502–503 TypeErrors). It now filters to real categories.

## Judged live vs not

- **Judged by me from screenshots:** positions, sizes, colours and states as listed above.
- **For your eye:**
  - Whether 38 px islands at 16 px text are large enough.
  - Whether radius 9 reads as "rounded square, not pill".
  - Whether the charging pulse feels like flow and not a gimmick.
  - Whether the toast's grow-from-island reads right.

  Raising the reserve above 44 stays your call after looking, per the brief.

## Still open

- **`notch.width` 174 is still provisional.** Your ruler read with `jimmy.notch-ruler` is still needed.
- **#12 and #13,** as above. **The hook contract needs an `account` field** before Stage 6.
- **Stock open-meteo 403** (upstream bug; worked around in the island).
- **Not exercised:**
  - A real remote session.
  - A real screen recording; only the push path was tested.
  - Low and critical battery colours (on AC at 79 %).
  - Hovering every hosted panel's controls.
- **Leader `Super+D`** and the hold-Super cheat sheet: Stage 4.
- **The `hideTooltip` warning:** hosted widgets' WidgetButton logged `hideTooltip … is not a function` once in an intermediate shell instance during development. It did not recur in the final instance after all the tests. If it appears again, the `PluginBarApi` tooltip hooks need real functions instead of the defaults.

## Files

**Live:**
- **Plugins:** `jimmy.bar/Bar.qml` (rewritten); `jimmy.osd/` (new clone); `jimmy.shared/BarGeometry.js` and `Staleness.qml` (new); `jimmy.emojis/Emojis.qml` (chip guard).
- **Config:** `hypr/menu-glass.lua` (blur rule); `shell.toml` (tokens); `shell.json` (OSD clone switch).
- **State:** `~/.local/state/omarchy/settings/weather.json` (Berkeley; a state file, not in git).

**Repo:** the matching snapshot under `plugins/` and `config/`, plus `docs/omarchy-bar-refined-brief.md`, `docs/omarchy-bar-stage-3-brief.md` and `docs/omarchy-bar-restructure-design-brief.md` (the source briefs, committed now).
