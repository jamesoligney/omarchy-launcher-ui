# Bar restructure, Stages 0–2: Claude report (2026-11-25)

Status: **Stages 0, 1 and 2 built and live.** The new bar (`jimmy.bar`) is the active bar now. The stock bar is one command away. No panels, no drawer, no mission control.

## Read this first: the brief file was missing

The task named `docs/omarchy-bar-refined-brief.md`. **It does not exist**: not in the repo, not on `origin`, and not in the recent Orca attachments. I built from the task message itself, which spells out Stages 0–2, plus brief v2 (`docs/omarchy-bar-restructure-design-brief-v2.md`). Every value the refined brief might have decided differently is a **token**, so changing it is a one-line edit in `shell.toml`, not code. The assumptions are listed under "Open / assumed" below.

## Stage 0: tokens and contracts frozen

**Tokens** live in the theme file the launcher already uses, `~/.config/omarchy/shell.toml` (user file; it survives theme switches and wins over the theme's). New sections, all logical px unless stated:

| Token | Value | Source / meaning |
|---|---|---|
| `notch.height` | 32 | 64 physical rows from `/usr/share/omarchy-platform/display-cutouts.json`; also the monitor reserve in `hypr/monitors.lua` |
| `notch.width` | 174 | **Provisional.** 348 physical columns, the value the installed notch-bar plugin calibrated by eye for this camera module. Confirm with the Stage 1 ruler |
| `notch.inset` | 10 | Clear space between an island and the notch edge |
| `notch.corner-inset` | 18 | Content kept clear of the rounded top corners |
| `bar.height` | 44 | Total top reserve while `jimmy.bar` is active |
| `island.gap` | 6 | Space above/below an island inside `bar.height` (island height = 32) |
| `island.radius` | 14 | |
| `island.padding-x`, `island.spacing` | 12, 12 | |
| `island.app-max-width` | 200 | Widest the focused app's name gets before it elides |
| `battery.low` | 20 | Battery bar tints accent at or below this % |
| `battery.critical` | 10 | Tints urgent; also the low-battery notification threshold |
| `battery.bar-width`, `battery.bar-height` | 26, 9 | The progress bar |
| `clock.format` | `h:mm` | "3:04", no AM/PM (v1). **Q4 is still open** |
| `motion.*` | x 0.80/24/0.40, y 0.70/20/0.46, fade 160, settle 700, close 100 → 0.97 | The `CardMotion` values, now tokens |

**Code reads tokens, not literals:**
- **`jimmy.shared/Tokens.js`:** `num()` and `str()` readers over `Commons.Color.shellValues`, with fallbacks so a bad token never breaks a surface.
- **`jimmy.shared/CardMotion.qml`:** reads `motion.*`. It also exposes `closeHoldMs` (close + 15 ms), which replaced the `115` literal in the launcher, emoji, clipboard, apps and reminders close timers.
- **`jimmy.battery`:** reads its threshold from `battery.critical` (was a literal 10).

**Contract frozen, not implemented:**
- `docs/contracts/agent-hook-payload.schema.json` (JSON Schema).
- `docs/contracts/agent-hook-payload.md`. Required fields: `v`, `agent.id`, `session.id`, `event`, `state`, `at`. The events are `session_start`, `prompt`, `working`, `tool`, `waiting`, `done`, `error` and `session_end`. `agent.id` joins to the existing usage records, and `session.window` lets mission control focus the agent's window. It also sets the rules for the future receiver: fire-and-forget IPC under 100 ms, drop invalid payloads silently, no prompt text or secrets, no persistence. Limits never come from hooks.

## Stage 1: notch calibration (needs James's eye)

- **New overlay `jimmy.notch-ruler`**, enabled; summon with `omarchy-shell shell summon jimmy.notch-ruler`, Esc closes. It draws:
  - **Notch rows:** alternating 10 px segments across the top 32 rows.
  - **Ticks:** every 2 px, labelled every 20 px, as the distance from the centre.
  - **Token guides:** solid lines at the current `notch.width`, dashed lines at width + `notch.inset`.
  - **Corners:** radius arcs of 8–24 px in both top corners, plus the `corner-inset` line.
- **Why this needs you:** the cutout's pixels exist in the framebuffer but not on the glass. A screenshot shows every segment, so only an eye on the real display can see which ones disappear. I verified the overlay renders correctly (screenshot); I cannot read the measurement.
- **To finish Stage 1:**
  1. Open the ruler and read the first fully visible number on each side of the centre. That number is the half-width.
  2. Note which arc matches the glass corner.
  3. Set `notch.width` (2 × half-width) and, if needed, `notch.corner-inset`.
  4. The bar and the ruler re-read the tokens live.

## Stage 2: the islands, live at the top

**New bar plugin `jimmy.bar`** (`kind: bar`), next to the stock bar, not a clone of it.

- **Left island**, its right edge at the notch minus `notch.inset`: workspaces (occupied plus active on this monitor, numbered 1–10 in the monitor's block, active one highlighted, click to switch), then the focused app's name.
- **Right island**, its left edge at the notch plus `notch.inset`: time (nearest the notch, tabular figures), the weather icon, the battery progress bar, and the agents icon.
- **Data:**
  - **Live:** workspaces (Hyprland), app name (`ToplevelManager` plus desktop entries, so web apps get their own name), battery (UPower), time (`MinuteClock`, ticking on the minute).
  - **Placeholders in this stage:** the weather icon (the stock weather data lives only inside its panel) and the agents icon.
- **Glass:** the islands use the same background and border alpha as the launcher (`[launcher]` tokens), with blur. `jimmy-bar` was added to the existing layer rule in `hypr/menu-glass.lua`.
- **Shared, not copied:**
  - `jimmy.shared/AppName.js`: one app-name resolver. `jimmy.active-window` now uses it too.
  - `jimmy.shared/MinuteClock.qml`: armed from epoch ms like the stock clock, avoiding `SystemClock`'s daylight-saving problem.

### Reserve: what had to change, and why

The first live run put the islands **32 px too low** (layer at y = 32–76, overlapping window tops). Hyprland places a top-anchored layer *below* the monitor's own reserve, and `hypr/monitors.lua` reserves the 32 notch rows. Fix, without touching `monitors.lua`:
- **Visible layer:** the islands use `ExclusionMode.Ignore`, so they sit at y = 0–44, in the ears.
- **Reserve layer:** an invisible, click-through 1-px strip (`jimmy-bar-reserve`, empty input mask) reserves `bar.height − notch.height` = 12 px.
- **Result:** switching bars never needs a Hyprland config edit.

## Verified live

| Check | Result |
|---|---|
| Reserve | `hyprctl monitors`: **top 44, bottom 0** (was top 32, bottom 32 with the stock bar) |
| Layers | `jimmy-bar` at x 0, y 0, 1728 × 44; `jimmy-bar-reserve` at y 32, 1 px |
| Windows | topmost window now starts at y = 46 (44 plus the gap) |
| Island positions | left island ends at x = 767 = notch edge 777 − 10; right island starts at x = 961 = 951 + 10 |
| Workspaces | showed `2 8` with 8 active, then `2 3 8` once workspace 3 gained a window |
| App name | "Orca" for the focused Orca window |
| Clock | 8:43 at load, **8:44 after the minute boundary** (screenshot at 08:44:14) |
| Battery bar | filled at about 79 %, accent while charging |
| Glyphs | the agents placeholder was first a colour emoji (✳, ignored the theme); replaced with a Nerd Font glyph that follows the theme |
| Pickers after the motion tokens | emoji picker opens; its layer stays through the close and is gone after `closeHoldMs` |
| Ruler | renders segments, labels, token lines and corner arcs (screenshot) |
| Journal | no errors from any changed file after each restart |

Restarts were `omarchy restart shell`, each run on its own (never in the same command as a summon). No `omarchy refresh shell`. No debug `console.log` was added at any point: a grep found none in the `jimmy.*` QML and JS before each restart. The one hit is `jimmy.idle`'s own event log, unchanged from stock, and that plugin is disabled.

## Switching, backups, rollback

- **Before each switch,** `shell.json` was backed up with a timestamp:
  - `shell.json.bak.bar-stage-*` (before any change)
  - `shell.json.bak.ruler-*` (before enabling the ruler)
  - `shell.json.bak.baruse-*` (before switching bars)
- **Commands used:** `omarchy plugin enable jimmy.notch-ruler`, `omarchy plugin enable jimmy.bar`, `omarchy bar use jimmy.bar`.
- **Back to the stock bar:** `omarchy bar use omarchy.bar`. The stock bar returns at the bottom with its 32-px reserve; `monitors.lua` was never changed.
- **Full backup before any edit:** `~/.local/state/omarchy-launcher-backups/20261125-083853-bar-stage-0-2` (mode 700, 49 files, checksums verified against live). It holds every `jimmy.*` plugin, all of `~/.config/hypr`, `shell.json`, `shell.toml` and the paste helper. No runtime state.
- **Repo snapshot resynced:** 172 live source files, checksums identical before and after the copy, and the snapshot equals live. New in the repo: `plugins/jimmy.bar/`, `plugins/jimmy.notch-ruler/`, `plugins/jimmy.shared/{Tokens.js,AppName.js,MinuteClock.qml}`, `docs/contracts/`. Updated: the snapshot copies of `shell.toml`, `shell.json` and `menu-glass.lua`, and the picker and launcher QML (close-hold timer).

## What the new bar does not do yet (by design, Stage 3+)

While `jimmy.bar` is active, these stock bar features are gone:
- **Indicators**, including the privacy ones: screen recording, mic, screen share.
- **The tray** and its drawer.
- **The bar-widget panels.** `Super+Ctrl+A/B/N/P/D` (audio, Bluetooth, network, power, display) have no host bar to open in. The shell's calls into the bar are guarded, so nothing errors; the keys just do nothing.

Brief v2 R2 still applies: **the privacy lights must land on the new bar before it becomes the daily bar.** Until then, switch back to the stock bar for any session where they matter.

## Open / assumed (because the refined brief was missing)

- **`notch.width` = 174** is provisional until you read the ruler.
- **`clock.format` = `h:mm`** (v1's "3:04"). Q4, 12-hour vs 24-hour, is still open.
- **Island order and contents** follow your message: left is workspaces + app; right is time, weather icon, battery bar, agents.
- **The `island.*` and `battery.*` sizes** are my starting values for judging live.
- **The agent hook contract fields** are my design. Review them before Stage 5 builds against them.

## Not verified

- The physical notch width and corner radius (needs your eye on the ruler).
- An external monitor. The bar lays out without a notch there, with no cutout and the full reserve, but none was connected.
- Fullscreen windows covering the bar.
- Battery tint changes at the low or critical thresholds (on AC at 79 %).
- The feel of the whole thing, which is your call.

## Not committed

`docs/omarchy-bar-restructure-design-brief.md` (v1) was never committed. It sits untracked in the working tree, so I left it for you rather than committing someone else's file.
