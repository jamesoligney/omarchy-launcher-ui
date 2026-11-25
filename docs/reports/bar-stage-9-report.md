# Bar Stage 9: report (2026-11-25)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-9-brief.md`. I downloaded the brief from the given URL into `docs/` first and committed it with this report.

These locks are untouched: island height 40, radius 9, bar height 44 and its reserve, SF Compact Display Medium with no bold, `toast.gap` 0, the battery as a number only, C for the calendar leader, the quick strip outside the island, `Super+D` showing hints only, the letters dissecting the outline, and `leader.hints`.

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261125-130146-bar-stage-9`** (mode 700, 195 files), taken before any edit. It covers the full behaviour set: every `jimmy.*` plugin, `hypr/*.lua`, `shell.json`, `shell.toml`, hooks, theme files, extensions, the Vicinae settings, the paste and backlight helpers, and the systemd unit. Checksums: live before = backup = live after. Excluded: runtime state, because nothing here touches it |
| Reload | `omarchy restart shell` once, on its own; never `refresh`, never combined with a summon |
| Debug / temporary code | None. `console.log` = 0 in `jimmy.bar`. The shell log shows no errors from the bar or `Sparks` |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced: `Bar.qml`, `Sparks.qml`, `shell.toml`. Live checksums are identical before and after, and the snapshot equals live. No runtime state in git |

## 1. Sparks: ember and lightning in one

- **Removed:** the zigzag bolt.
- **Now:** each spark is one particle with two parts.
  - **Ember:** a round 3 px core in a lighter accent, inside a soft 8 px accent glow at 28 %. It drifts outward about 9 px (±30 %), easing out, shrinks to 55 % and fades over 650 ms.
  - **Lightning:** for its first ~0.25 s, three tiny jagged filaments (about 2–6 px, each with one kink, 1 px accent) crackle round the core. They flicker off and on once, then go. The particle itself flickers once too.
  - **Timing and pool:** a random gap of 0.75–1.5 s, accent colour, charging only. The pool is 2 particles and nothing is created at runtime.
- **Origin all the way round.**
  - **Old origin:** the top edge or the right side, as you saw.
  - **New origin:** a point chosen **uniformly along the whole perimeter** of the number's ink box (its width × cap height).
  - **Direction:** outward along that side's normal, ±60°. A spark from the bottom drifts down, and one from the left drifts left.
- **How the distribution was checked:** `Sparks` counts the side of every origin, and `omarchy-shell jimmy.bar status` reports it (`battery.sides`).
  - **Counted live, 56 sparks:** top 19, bottom 21, left 10, right 6.
  - **Expected:** a uniform perimeter on a "79%" box about 2.5× wider than tall gives about 20 / 20 / 8 / 8, which matches.
  - **Frames:** a 2.4 s frame burst caught sparks leaving the bottom-left, the top, the right and below the number, each drifting away from its own side (screenshots).
- **Colour rule unchanged:** accent when plugged in, neutral on battery, amber ≤ 20 %, red ≤ 10 %. Sparks follow `charging` and stop when it ends. I could not test unplugged live because the machine stayed plugged in.
- **Subtlety:** one small particle for about 0.65 s, roughly once a second; the crackle lasts a fraction of that. I made no sparser pass.
- **Tokens:** `battery.spark-size` 3, `spark-glow` 8, `spark-drift` 9, `spark-ms` 650, `spark-min-ms` 750, `spark-max-ms` 1500. `spark-length` and `spark-width` were removed.

## 2. Islands: wider again

| Token | Was | Now |
|---|---|---|
| `island.padding-x` | 20 | **26** |
| `island.spacing` | 22 | **28** |

- **Unchanged:** height 40, radius 9, the 44 px reserve, and text at 19 px. The wider islands did not call for a larger size.
- **Islands:** still centred in their ears, growing symmetrically (screenshot).
- **Rest of the UI:**
  - The quick strip spaces its icons by the same `spacing`, so it widened with the island. It is still outside it, and the island stays fixed.
  - Leader letters stay centred under their elements on the outline (screenshot with the strip open and the leader active).
  - Toasts have their own padding token, so they are unchanged.

## 3. Clock: 12-hour again, and why it was 24-hour

- **Cause:** Qt's time format treats `h` as **0–23** unless the format also contains `AP`. The token has been `"h:mm"` since Stage 0, unchanged in every stage since (`git log -S'h:mm'` shows only Stage 0). No Stage 8 change touched the clock.
  - **So the bar has always formatted 24-hour.** It was invisible in the morning, and 12:xx looks the same in both formats. It showed only after 13:00.
  - **The old comment was wrong:** the token's comment claimed `"h:mm"` meant "3:04, no AM/PM".
- **Fix:** the bar's `clockText()` keeps `clock.format` as the source.
  - **Without `AP`:** a format like `"h:mm"` is formatted with `AP` appended (true 12-hour), and the AM/PM text is dropped again.
  - **With `AP`:** shown as written.
  - **With `H`:** stays 24-hour.
  - The token stays `"h:mm"` and its comment now says what it does.
- **Verified live:** at 13:02 the bar showed **`1:02`**, with no AM/PM (screenshot), and later `1:03`.
- **Rest of the UI:** nothing else in the `jimmy.*` plugins formats the time. The calendar panel is stock and shows dates, not this clock.

## Still open

- **Real mouse:** hover and click the quick icons (no uinput tool here).
- **On battery:** confirm the sparks stop and the number turns neutral.
- **For your eye:** spark glow and drift, and whether 19 px wants to go up in the wider islands.
- **Still pending:** `notch.width` (ruler), the broken `notify-send`, and #12. The AI mark is still red because OpenCode's monthly limit is at 100 %.
