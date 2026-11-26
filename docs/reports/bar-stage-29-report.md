# Bar Stage 29: the frame reads, the top row is centred (2026-11-26)

Built from `docs/omarchy-bar-refined-brief.md` and `docs/omarchy-bar-stage-29-brief.md`. The brief was downloaded into `docs/` first (4,868 bytes) and is committed with this report.

**Not touched:** depths (top 75 / left 30 / right 15 / bottom 15), radii (outer 20 / inner 16), reserves, the element homes/order/x, the float default, Super+L, Super+T, the leader keys, the launcher / emoji / clipboard pickers. **No notch disguise, no black top, no pills, no new elements.**

## Build checklist

| Step | Result |
|---|---|
| Build start | `omarchy-kbd-backlight hold` (saved 0) and `omarchy toggle idle stay-awake` |
| **Backup at build start** | **`~/.local/state/omarchy-launcher-backups/20261126-113334-bar-stage-29`** — mode **700**, **2,405 files**, **872 MB**, local only, before any edit. Same complete scope as Stage 28: every `~/.config/hypr/*.lua`/`.conf`, every `~/.config/omarchy` file (plugins, themes, themed, hooks, extensions, tweaks, defaults, backgrounds, branding, lock-*, matrix-screens, `shell.json`, `shell.toml`), `~/.config/systemd`, `~/.config/vicinae`, `~/.local/bin`, the saved `~/.local/state/omarchy/toggles` + `workspace-layouts`. Checksums: **live before = backup = live after**. Excluded and named: old `*.bak*` snapshots, runtime state (clipboard history/images/pins, emoji pins/recents, notifications, agents usage, indicators, scratchpad, current/done, generated theme backgrounds, logs), and symlinks (not in the checksum manifest). No runtime state in git |
| Reload | **Two `omarchy restart shell`**, each on its own and only for QML changes: the first loaded the fill and the first optical nudges, the second the refined nudges. The tint/edge token tuning and the theme switch hot-reloaded live — no restart for those. Never `refresh`, never combined with a summon loop |
| Debug / temporary code | None. `console.log` = 0. No test windows. The theme switch to Afterburn Lite and back was the theme-follow check (restored, `omarchy theme current` = Afterburn). The stay-awake cup visible in the build screenshots disappears at build end. Focus returned to Orca |
| Build end | `omarchy toggle idle allow-idle`, `omarchy-kbd-backlight release` (restored level 0, `mode: auto`, service active) → `omarchy-shell idle status`: **`"enabled": true, "stayAwake": false`** |
| Snapshot | Resynced: `config/omarchy/shell.toml`, `plugins/jimmy.frame/Frame.qml`, `plugins/jimmy.bar/Bar.qml`. Snapshot equals live; no runtime state in git |

## The frame fill: from near-invisible to accent glass

Stage 28's hull was `background` at **0.70** with an accent edge at **0.16**; over the dark wallpaper it measured **(9, 11, 10)** — invisible. Stage 29 derives the fill from the **theme accent**:

```qml
glass = Qt.tint(Commons.Color.background,
                Util.alpha(Commons.Color.accent, frame.tint))   // tint
        with alpha = launcher.panel-background-alpha (0.70)
```

No literal orange in the code: a theme switch changes `Commons.Color.accent` / `background` and the Canvas repaints through `onGlassChanged`.

Tried live, one step at a time (dark Afterburn wallpaper, measured at the top band):

| `frame.tint` | Mixed fill (at 0.70) | Measured frame pixel | Judgement |
|---|---|---|---|
| **0.14** | `rgba(46, 32, 19, 0.70)` | **(33, 24, 15)** | Still too subtle |
| **0.18 — shipped** | `rgba(54, 37, 21, 0.70)` | **(39, 28, 17)** | Reads as a warm glass frame at a glance; not solid |
| **0.22** | `rgba(65, 42, 24, 0.70)` | **(45, 31, 19)** | Stronger; heading toward a solid brown bar |

**Edge:** the Stage 28 1px edge at 0.16 was tried against the new fill; it read as a separate orange line around the opening, so it was **dropped** (`frame.edge = 0`). The fill edge itself is the hull boundary — no line, no 2px underline. The notch remains a hole, never an outlined shape.

## Theme switch: the fill follows the accent

`omarchy theme set afterburn-lite` → the frame fill became a light peach; `omarchy theme set afterburn` → it returned to the dark warm glass. The reserves stayed `[30, 75, 15, 15]` throughout.

| Theme | Accent | Background | Frame fill measured |
|---|---|---|---|
| **Afterburn** (current) | **#f59145** | **#0c0d0b** | **(39, 28, 17)** dark warm glass |
| **Afterburn Lite** (test) | **#c2410c** | **#f5efe4** | **(240, 218, 201)** light peach glass |

The Lite switch also served as the light / busy wallpaper check: the frame reads on the light peach background, the elements go dark (`foreground #1f1b16`), the active workspace number is the Lite accent, and the notch is high-contrast black. The theme was restored; the current theme is **Afterburn**.

## Top row: measured ink centres, then fixed

The Stage 28 report's 37.5 was the **container**, not the visible ink. I measured the actual glyph/text ink from screenshots (2× physical, thresholded, bounding box per element; battery sparks excluded; status/quick after the build-end cup disappears). Target: **37.5** in the 75px frame.

| Element | Before (Stage 28) | After Stage 29 | Nudge applied |
|---|---|---|---|
| Window title | **38.0** | **37.5** | −0.5 |
| Time | 37.5 | **37.5** | none |
| Battery % | 37.5 | **37.5** | −0.5 (the Stage 29 live text sat at 38.0) |
| Weather glyph | **38.75** | **37.5** | −1.25 then −1.0 |
| Status glyphs (Wi‑Fi/BT/mic/agents) | **37.0** | **37.5** | +0.5 then +0.75 |
| Quick / stay icon (visible while stay-awake was on) | **36.75** | **37.75** (0.25 low; hidden at build end) | +0.75 |

Final live measurement after build end (stay-awake off): **title 37.5, time 37.5, battery 37.5, weather 37.5, status 37.5** — all five on the 37.5 line. The fixes are optical offsets on the glyphs/items (`anchors.verticalCenterOffset`), not a change to the container or the geometry.

## Left numbers and the notch

- **Left numbers:** the strip surface is unchanged. With the workspaces present during the build (1 and 3 — the user's workspace 2 window was closed mid-build) the numbers measured **540.75** and **577.0**, pair centre **558.875** vs the left frame's **558.5** (+0.375). The code centres any count. The active number stays accent on both fills — **#f59145 on the dark brown glass** and **#c2410c on the light peach** — and does not wash out; the quiet numbers stay foreground.
- **Notch:** the 174 × 32 cutout at x 777–951 remains. On the dark fill it is subtle; on the Lite light fill it is high-contrast. No disguise, no black top, no workaround.

## No geometry change

`hyprctl monitors` remains **`[30, 75, 15, 15]`**; the frame depths and radii are the Stage 28 values; the bar/strip still reserve nothing; the window opening, floating default (1100 × 619 at (322, 279)), Super+L/Super+T and the leader keys are untouched. The only visual geometry change is the top-row ink alignment (≤1.25px optical).

## Verified live

| Check | Result |
|---|---|
| Frame fill, dark | Warm accent glass, measured **(39, 28, 17)** at `frame.tint = 0.18`; reads as a frame at a glance, not solid |
| Fill steps | 0.14 / 0.18 / 0.22 screenshots; 0.18 shipped; no overshoot |
| Edge | 0.16 line tried; read as a separate line; **dropped (0)**; the fill edge is the hull boundary |
| Theme follow | Afterburn → Afterburn Lite → Afterburn; frames dark warm ↔ light peach; reserves unchanged; theme restored |
| Light / busy wallpaper | Afterburn Lite: frame reads on the light peach background; dark elements; notch high-contrast |
| Top row | ink centres all **37.5** after the optical nudges (before: title 38.0, weather 38.75, status 37.0) |
| Left numbers | centred as a group (pair centre 558.875 vs 558.5); active accent visible on dark and light fill |
| Notch | black cutout 174 × 32; subtle on dark, high-contrast on Lite; no disguise |
| Geometry | reserved **`[30, 75, 15, 15]`**; depths/radii unchanged; no step/split; float unchanged |
| Health | `hyprctl configerrors` empty; no QML errors from `jimmy.frame` / `jimmy.bar`; no debug code; focus Orca |

## Files changed

- `~/.config/omarchy/plugins/jimmy.frame/Frame.qml` — accent-tinted fill derived from `Commons.Color` (`frame.tint`), edge conditional on `frame.edge`.
- `~/.config/omarchy/plugins/jimmy.bar/Bar.qml` — optical y-offsets on the title, battery, weather, status glyphs and quick/stay icon; no geometry/layout change.
- `~/.config/omarchy/shell.toml` — `[frame] tint = 0.18`, `edge = 0.0`; depths/radii untouched.
- `plugins/jimmy.frame/Frame.qml`, `plugins/jimmy.bar/Bar.qml`, `config/omarchy/shell.toml` — repo snapshots, equal to live.
- `docs/omarchy-bar-stage-29-brief.md`, `docs/reports/bar-stage-29-report.md`.
- No theme file edits: the Afterburn Lite switch was a live test and the theme was restored.

## Still open / for your eye

- **Fill strength:** `frame.tint = 0.18` is the shipped step; 0.14 was too subtle, 0.22 stronger. It is one token to raise or lower.
- **Edge:** dropped at 0. If you want a defined opening line, `frame.edge` brings it back (0.10–0.16 tried as a line at 0.16; deliberately not shipped).
- **The top row:** the measured ink is now exactly 37.5 across title, time, battery, weather and status. If your eye still reads it high or low, that is now an optical judgement about the fill/frame, not the glyph positions — the numbers are on the line.
- **Left numbers:** shown as 1 and 3 because workspace 2's window was closed during the build; any count re-centres. The active accent held on both themes.
- **No geometry, float or bind changes.** The light/busy-wallpaper check used Afterburn Lite and was restored to Afterburn.
