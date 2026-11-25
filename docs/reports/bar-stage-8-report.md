# Bar Stage 8: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-8-brief.md`. I downloaded the brief from the given URL into `docs/` first and committed it with this report.

These locks are untouched: radius 9, bar height 44 and its reserve, SF Compact Display Medium with no bold, `toast.gap` 0, the battery as a number only, C for the calendar leader, the quick strip outside the island, `Super+D` showing hints only, and the letters dissecting the bottom outline.

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261125-125250-bar-stage-8`** (mode 700, 195 files), taken before any edit. It covers the full behaviour set: every `jimmy.*` plugin, `hypr/*.lua`, `shell.json`, `shell.toml`, hooks, theme files, extensions, the Vicinae settings, the paste and backlight helpers, and the systemd unit. Checksums: live before = backup = live after. Excluded: runtime state, because nothing here touches it |
| Reload | `omarchy restart shell` run twice, each time on its own; never `refresh`, never combined with a summon. Token edits reload live from `shell.toml` |
| Debug / temporary code | None. `console.log` = 0 in `jimmy.bar`. The shell log shows no errors from the bar or `Sparks` |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced: `Bar.qml`, `shell.toml`, new `Sparks.qml`, and `Embers.qml` removed. Live checksums are identical before and after, and the snapshot equals live. No runtime state in git |

## 1. Battery: electric sparks, not embers

- **Removed:** `Embers.qml` and its `battery.ember-*` tokens.
- **New:** `Sparks.qml`, a pool of 2 `Shape` arcs (nothing created at runtime) and one timer, running only while the battery is charging.
- **The arc:**
  - **Shape:** a jagged 3-segment zigzag, about 12 px long (±20 %), with strong side kinks (30 % of its length).
  - **Fork:** half the time, a short 2-segment fork splits off the first kink.
  - **Stroke:** a 1.2 px accent core over a 3.6 px accent glow at 30 %.
  - **Origin:** off the number's edge. Three times in four it leaves the top of the figures and leaps up (±50°); otherwise it leaves the right side, outward. It never lies over the glyphs.
  - **Life:** about 300 ms. It strikes at full opacity, flickers once (down to 25 % and back), then fades out fast.
  - **Timing:** a random gap of 0.75–1.5 s.
  - **Colour:** theme accent, the same as the charging number.
- **Colour rule unchanged:** accent when plugged in, neutral on battery, amber ≤ 20 %, red ≤ 10 %. Sparks follow `charging` and stop when it ends.
- **Tuned live:**
  - **First pass:** 9 px, 4 short segments, origin anywhere on the number. The arcs sat on the digits and read as smudges.
  - **Fix:** the origin moved to the number's edge, and the arc got 3 longer, sharper segments at 12 px. Frame captures now show clear jagged arcs jumping off the top of the 7/9 and off the % sign (screenshots).
- **Verified live:**
  - **Rate:** `status.battery.sparks` counted about one per second while charging at 79 %.
  - **Stopping when unplugged** is by construction (`running: charging`). I could not test it live because the machine stayed plugged in.
- **Subtlety:** only one tiny arc for about 0.3 s, roughly once a second, is visible for well under half the time. I made no sparser pass. If it is too busy at 80 % all day, raise `spark-min-ms` / `spark-max-ms` first.

## 2. Islands: bigger and airier, in the same 44

| Token | Was | Now | Effect |
|---|---|---|---|
| `island.gap` | 3 | **2** | island height 38 → **40** (bar height stays 44) |
| `island.font-size` | 16 | **19** | text **and** icons |
| `island.padding-x` | 16 | **20** | |
| `island.spacing` | 18 | **22** | |
| `leader.hint-size` | 11 | **12** | |

- **Text size:** 19 px, judged live. It fills the 40 px island without crowding its top and bottom edges. 20 began to look heavy beside the notch.
- **Icons:** weather, lights, AI mark, quick icons and the stay-awake cup all use the same `Label` size. They scale together with the text, and no single icon dominates (screenshot).
- **Workspace chips:** they are sized from the island height and grew with it.
- **Islands:** still centred in their ears, growing symmetrically. Radius stays 9, and the reserve stays 44 (the reserve layer is unchanged).
- **No deeper reserve was taken.**
- **Rest of the UI:**
  - Toasts, notifications, reminders and adopted panels all compute the island's bottom edge from `bar.height − island.gap`. They stay attached at the new edge with no change.
  - Toast padding has its own token (`toast.padding-x`), so toasts look as before.
  - The quick strip grew with the font, still outside the island, and the island stays fixed.
  - The calendar still drops below the island, clear of the strip (screenshot).
  - **Nothing broke.**

## 3. Leader letters: legible at the new size, and switchable

- **Size:** 12 px; the nudge stays −1 px. A zoom shows the outline still crossing the middle of each letter at the new island edge.
- **Switch:** `leader.hints = false` in `shell.toml` turns them off cleanly.
  - The letters are not drawn.
  - The bar layer stops reserving the overhang band.
  - The leader keys keep working.
- **Verified live:**
  - With `false`, `hyprctl layers` shows the bar layer at **44** px and no letters appear in the leader (screenshot).
  - Switched back to `true`, the layer is **56** px and the letters return.
  - Left on `true`.

## Fixed along the way

- My first token edit matched the wrong `hint-size`, the launcher's `[launcher]` key, setting it from 13 to 12. I caught it in the diff against the snapshot and restored it to 13 before verifying anything. The leader's own key is set as intended.

## Still open

- **Real mouse:** hover over the time and click the quick icons; there is no uinput tool here.
- **On battery:** confirm the sparks stop and the number turns neutral.
- **For your eye:**
  - text at 19 px;
  - spark length, rate and glow (all `battery.spark-*` tokens);
  - turning the letters off once they are learned (`leader.hints = false`).
- **Still pending:** `notch.width` (ruler), the broken `notify-send`, and #12. The AI mark is still red because OpenCode's monthly limit is at 100 %.
