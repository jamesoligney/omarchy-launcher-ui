# Bar Stage 14: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-14-brief.md`. I downloaded the brief from the given URL into `docs/` first and committed it with this report.

These locks are untouched: island height 44, radius 13 (joint 2, gap 4), bar 48, SF Compact Display Medium with no bold, text 20 px, `toast.gap` 0, the battery as a number only, C for the calendar leader, the quick strip outside the island, `Super+D` showing hints only, the letters on the outline, `leader.hints`, the sparks, the width (44 / 48), the glow masked outside with dark glass, and the main island order time, battery, weather.

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261125-142014-bar-stage-14`** (mode 700, 198 files, plus a copy of the stock weather plugin, which this stage clones). It was taken before any edit and covers the full behaviour set: every `jimmy.*` plugin, `hypr/*.lua`, `shell.json` (rewritten by the clone this round), `shell.toml`, hooks, theme files, extensions, the Vicinae settings, the paste and backlight helpers, and the systemd unit. Checksums: live before = backup = live after. Excluded: runtime state, because nothing here touches it |
| Reload | `omarchy restart shell` twice, each on its own; never `refresh`, never combined with a summon |
| Debug / temporary code | None. `console.log` = 0 in `jimmy.bar`, `jimmy.shared` and `jimmy.weather`. The shell log shows no errors |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced; it now includes the new `jimmy.weather` plugin. The weather icon files moved from `jimmy.bar` to `jimmy.shared`. Live checksums are identical before and after, and the snapshot equals live. No runtime state in git |
| Reference image | Saved to `docs/reference/weather-style-reference.png` as asked, **not committed**: it is a watermarked stock image. It is listed in `.git/info/exclude`, so it stays local. I copied no shapes from it |

## 1. AI mark: no red

- **New rule:**
  - **Agent window running:** **accent**, full.
  - **Otherwise:** quiet neutral at **60 %**.
- **What changed:** over-limit and near-limit no longer change the mark; there is no red at all. The limits stay visible in the agents panel and in `omarchy-shell jimmy.bar status` (`agents.state`).
- **Why it keys on running:** the old precedence ranked "over" above "running". Under it, a running agent would have stayed quiet, because OpenCode's monthly limit sits at 100 %. The colour now follows the running state directly.
- **Verified live:** `agents: {state: over, running: true}` → the mark is accent, not red (screenshot).
- **Unchanged:** click (agents panel, dropping from the status island), leader A, 13 px.

## 2. Status island: in a line

- **Layout:** all four lights (Wi-Fi N, Bluetooth T, mic M, AI A) are 13 px **in one row**, centred vertically in the 44 px island.
- **Step:** `status.step` 15 → **20** px.
- **Stagger removed:** the `status.stagger` token and its code are gone, not just set to zero.
- **Live:** the row reads calm and even, with four lights about 6 px apart edge to edge (screenshot).
- **Leader letters:** N T M A sit on one line, on the outline, each under its light (leader screenshot).
- **Tightness:** it does not feel cramped. If it should go tighter, the next step is `status.step` 18.
- **Unchanged:** height, radii, joint, glass and glow.

## 3. Weather: a custom filled set, in the island and the panel

- **Custom, not off the shelf.** The set is drawn for this bar in the reference's language (solid, bold, distinctive), not copied from it:
  - **Sun:** a scalloped outer ring around a solid disc, with a gap between them.
  - **Clear night:** a crescent with a five-point star.
  - **Clouds:** solid lumps.
  - **Partly cloudy (day and night):** the sun or moon behind the cloud, **knocked out** by a gap so the cloud reads in front.
  - **Overcast:** two clouds, the front one cutting the back one.
  - **Fog:** a cloud over two rounded bars.
  - **Drizzle:** a cloud with three round dots.
  - **Rain:** a cloud with three teardrops.
  - **Heavy rain and showers:** a double cloud with four teardrops.
  - **Sleet:** drops plus an ice pellet.
  - **Snow:** a chunky six-arm snowflake.
  - **Thunderstorm:** a bolt cut through its cloud.
- **How they were drawn:** generated once from simple geometry (circles, drops, bars, a polar scallop, unions and gap cut-outs) with `shapely`. The generator is `tools/weather-icons.py`, a build-time tool only; nothing ships with it.
  - **Output:** plain SVG path data in `jimmy.shared/WeatherIcons.js` (about 16 KB).
  - **Renderer:** `jimmy.shared/WeatherIcon.qml` fills them with a `Shape` using the odd-even rule, so gaps and rings are real holes and the glass shows through them.
- **Grayscale and theme-aware:** they use the quiet ink in the island and the panel's foreground in the panel. They are filled, so they are not thinner than before.
- **Coverage:** every condition the stock widget maps (both sources, Open-Meteo WMO and wttr.in codes) has a custom icon, the same mapping as Stage 13: clear day/night, partly cloudy day/night, cloudy/overcast/unknown, fog/mist, drizzle, rain, heavy rain/showers, sleet/freezing, snow, thunderstorm. **No Lucide and no Nerd Font weather glyphs remain** in the island or the panel. All 12 were checked on a rendered contact sheet, and live.
- **Panel, one system:** the stock weather panel was **cloned as a user plugin**, `jimmy.weather` (`omarchy plugin clone omarchy.weather`; the stock files are not edited).
  - **Edits to the clone:** only its two glyph Texts changed. The 64 px hero icon and the forecast day icons are now the shared `WeatherIcon` (`WeatherIcons.key()` for now, `dayKey()` for the forecast days).
  - **Verified live:** the panel shows the custom filled sun in the hero and solid clouds for Thursday and Friday (screenshot).
- **Bar wiring:** the bar hosts whichever weather widget is installed (`weatherId`: the clone if present, else stock). It also registers the clone under `omarchy.weather`.
  - **Effect:** leader W, the click, and `omarchy-shell shell toggle omarchy.weather` keep working unchanged; verified, the toggle opened and closed the clone's panel.
  - **To revert to stock exactly:** remove the clone (`omarchy plugin remove jimmy.weather`). The bar falls back to `omarchy.weather` on its own.
- **Unchanged:** island size 20 px, click, leader W, staleness dimming and the offline dot.

## Rest of the UI

- **Panels:** the calendar, weather, toast and quick strip still hang from the main island. The status lights' panels still drop from the status island.
- **Sparks:** still come off the battery number.
- **Theme:** still cyan; every new element follows it.

## Still open

- **For your eye:**
  - the custom set at 20 px, especially overcast and heavy rain, the two busiest;
  - the AI mark in accent while agents run all day;
  - status step 20 against 18.
- **Real mouse:** clicks on the status lights (no uinput tool here).
- **Still pending:** `notch.width` (your ruler), the broken `notify-send`, and #12.
