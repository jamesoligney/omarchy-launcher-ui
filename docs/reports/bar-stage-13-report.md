# Bar Stage 13: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-13-brief.md`. I downloaded the brief from the given URL into `docs/` first and committed it with this report.

These locks are untouched: island height 44, radius 13 (joint 2, gap 4), bar 48, SF Compact Display Medium with no bold, text 20 px, `toast.gap` 0, the battery as a number only, C for the calendar leader, the quick strip outside the island, `Super+D` showing hints only, the letters on the outline, `leader.hints`, the sparks, the width (44 / 48), and the glow masked outside with dark glass. No `shell.toml` token changed.

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261125-135323-bar-stage-13`** (mode 700, 196 files), taken before any edit. It covers the full behaviour set: every `jimmy.*` plugin, `hypr/*.lua`, `shell.json`, `shell.toml`, hooks, theme files, extensions, the Vicinae settings, the paste and backlight helpers, and the systemd unit. Checksums: live before = backup = live after. Excluded: runtime state, because nothing here touches it |
| Reload | `omarchy restart shell` three times, each on its own; never `refresh`, never combined with a summon. The weather-icon module needed a restart to reload |
| Debug / temporary code | None. `console.log` = 0 in `jimmy.bar` and `jimmy.shared`. The shell log shows no errors from the bar or the weather icon |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced: `Bar.qml`, plus the new `WeatherIcon.qml` and `WeatherIcons.js`. Live checksums are identical before and after, and the snapshot equals live. No runtime state in git |

**Not this build's change, but in the snapshot:**
- **Theme:** you switched it again during the build, this time to a **cyan** accent.
- **Effect:** border-fx rewrote its colours in `shell.json` and `hypr/border-fx.lua`. Both are committed because the snapshot must equal live.
- **Bar:** it followed the new accent on its own.

## 1. The AI mark is now status light 4

- **Moved** from the main right island into the status island as the **4th staggered light**.
  - **Same pattern as the others:** 13 px, slot 3, which is the down row, 15 px step and the same padding.
  - **Layout:** Wi-Fi up, Bluetooth down, mic up, AI down, i.e. **2 up / 2 down** (screenshot).
- **Same colour rule:** red over a limit, accent near one, full foreground while an agent window runs, quiet at 60 % when idle. The dimming applies to the glyph only, so its letter stays full.
  - **Right now it is red,** truthfully: OpenCode's monthly limit is at 100 % (`agents.state: over`).
- **Click** opens the agents panel; **leader A** sits on the status island's outline.
  - **Collisions:** none. A was already agents. The `bar` submap lists A, B, C, Escape, M, N, Q, T, W and the digits, exactly as before.
- **Main island re-centred:** it lays out its row from its own content, and `Island` centres itself on the ear's centre (`x = centerX − width/2`). Removing the mark shrank it symmetrically about the same centre, with no gap left behind (screenshot).
  - **The status island** joins its new right edge across the 4 px joint.
  - **The quick strip** is still anchored to its new left edge.
- **Not built:** the agent side panel.

## 2. Panels drop from the island that holds the icon

- **Rule applied:** the panels for **network, Bluetooth, mic and agents** now drop from the **status island's centre**.
  - **How:** the bar hosts the stock widgets in two invisible `Hosts` homes. One sits under the main island's centre and one under the status island's centre (`statusHostIds`). A stock panel opens from its widget's position.
- **Everything else** stays on the main island: calendar, weather, power, audio, monitor and Locus. The toast is still attached under the main island.
- **Verified live:**
  - **Network and agents panels:** they open centred under the status island (screenshots). They are wide (about 380 px) and still fit inside the screen edge.
  - **Calendar:** it opens centred under the main island (screenshot).
  - **Adopter:** it restyled all three (`adopted: network, agents, clock`).
  - **Nothing broke.**

## 3. Weather: a new grayscale icon set

- **Source:** **Lucide** (`lucide-static` 0.460.0, **ISC licence**, Feather portions MIT; https://lucide.dev). The licence notice is in `WeatherIcons.js`.
- **Why Lucide:** refined outline shapes with a consistent **2 px stroke on a 24 grid** and round caps and joins.
  - **Not thinner:** at the island's 20 px, the stroke is 1.67 px, which is not thinner than the Nerd Font glyphs.
  - **Style:** not filled and not cartoon.
- **How it is drawn:** no icon font and no image files.
  - **Paths:** the 12 SVGs were converted once into path strings in `WeatherIcons.js`.
  - **Renderer:** `WeatherIcon.qml` strokes them with a `Shape` (CurveRenderer) in the island's quiet ink, so they stay grayscale and theme-aware.
  - **Size:** about 6 KB of path data.
- **Coverage:** `WeatherIcons.key()` reads the same current reading the stock icon used (the Open-Meteo WMO code with its day/night flag, else the wttr.in code) and maps **every code the stock set handled**:

| Condition | Icon |
|---|---|
| clear (day / night) | `sun` / `moon` |
| partly cloudy (day / night) | `cloud-sun` / `cloud-moon` |
| cloudy, overcast, unknown | `cloud` |
| fog, mist | `cloud-fog` |
| drizzle, light rain | `cloud-drizzle` |
| rain | `cloud-rain` |
| heavy rain, showers | `cloud-rain-wind` |
| sleet, freezing rain, ice pellets | `cloud-hail` |
| snow | `cloud-snow` |
| thunderstorm | `cloud-lightning` |

- **No old glyphs remain:** the stock Nerd Font weather glyphs are gone from the island. The stock `Model.js` import was removed.
- **Unchanged:** size 20 px, click (weather panel), leader W, and the staleness dimming and offline dot.
- **Fixed live, twice:**
  - **The bug:** the sun's rays first drew in the wrong places. Lucide writes some subpaths as `m x y dx dy`, a relative move followed by an implicit relative line.
  - **First fix:** joining the paths made the `m` relative to the previous subpath. Making it `M` then also turned the implicit line absolute.
  - **Final conversion:** `M x y l dx dy`, which is exact.
  - **Checked:** all 12 icons were rendered to a contact sheet from the generated paths and checked by eye, then checked live in the bar.
- **Out of scope:** the stock **weather panel** itself (the drop-down) still uses its own glyphs. The brief covered the island icon. Say if the panel should match.

## 4. Main island order: time, battery, weather

- **Order:** time nearest the notch, then battery, then weather, left to right (screenshot).
- **Letters move with their elements:** C on the time, B on the battery, W on the weather, on the outline (leader screenshot).
- **Rest of the UI:**
  - The quick strip is still left of the island.
  - The toast and the calendar still hang from the main island's centre.
  - The sparks still come off the battery number in its new place.
  - **No breaks.**

## Still open

- **Real mouse:** clicks on the four status lights (no uinput tool here).
- **For your eye:**
  - the Lucide weather set at 20 px;
  - whether the weather panel's own glyphs should match.
- **Still pending:** `notch.width` (ruler), the broken `notify-send`, and #12.
