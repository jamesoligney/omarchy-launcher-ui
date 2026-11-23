# Border FX needs the Rust toolchain

**Added:** 2026-11-12

The Border FX plugin (`wmfeht.border-fx` 0.2.1) draws animated rings of light
around windows and shell chrome. It was installed and enabled, but only half
of it worked: panels and notification toasts had the effect, windows did not,
and the plugin posted a notification about needing Rust.

Source: https://github.com/wmfeht/omarchy-border-fx

## Why only half of it ran

The plugin has two renderers sharing one config:

| Half | Needs | State before this fix |
|---|---|---|
| Chrome (panels, toasts) | nothing — shaders ship pre-baked (`shaders/*.qsb`) | working |
| Windows (Hyprland ring) | `gcc`, `pkgconf`, `hyprland` headers, **`rust`** | never built |

Four build dependencies; three were already on the machine. Only `rust` was
missing, so `scripts/border-fx` hit its `find_cargo()` fallback and bailed
with the notification, leaving the chrome half running. The giveaways:
`~/.cache/omarchy-border-fx/bin/` held nothing but a zero-byte `.build.lock`,
`~/.local/lib/hypr/hypr-shiny-border.so` did not exist, and
`~/.config/hypr/border-fx.lua` had never been written.

**This is the plugin behaving as designed, not a bug.** It degrades to the
chrome effect rather than failing to load.

## What changed

**1. Installed the Rust toolchain** (`rust` 1:1.99.1-1 from `extra`, 57 MiB
download / 250 MiB installed — brings in `compiler-rt`, `lld`, `libgit2`):

```bash
omarchy pkg add rust
```

**2. Re-enabled the plugin** so the build ran:

```bash
omarchy plugin enable wmfeht.border-fx
omarchy restart shell
```

`omarchy plugin enable` returns immediately and the build happens in the
shell service. To build in the foreground and actually see the cargo output:

```bash
~/.config/omarchy/plugins/wmfeht.border-fx/scripts/border-fx --bootstrap
```

That takes the same `flock`, so it is safe to run alongside the service and
prints the binary path on success. Useful for diagnosing a failed build.

**3. The plugin wrote its own control plane** — not hand-edited:

- `~/.config/hypr/border-fx.lua` (2.3 KB, generated; **do not edit** — its
  source of truth is the `shell.json` `plugins[]` entry)
- `pcall(require, "hypr.border-fx")` appended to `~/.config/hypr/hyprland.lua`
  at lines 50–51, with a comment above it. `pcall` makes it a no-op if the
  lua file ever goes missing.

The `~/.config/omarchy/shell.json` entry was bare at install time —
`{ "id": "wmfeht.border-fx" }` — so the whole look followed the Matte Black
theme preset. It has since been given two shape keys; see **Look settings**
below.

## Look settings

Set on the `plugins[]` entry in `~/.config/omarchy/shell.json`, inline, no
wrapper. Settled on 2026-11-12:

```json
{
  "id": "wmfeht.border-fx",
  "mirror": true,
  "lobe": 0.3,
  "shimmer": true,
  "shimmerDeg": 35,
  "shimmerHz": 0.45,
  "shimmerScaleMin": 0.75,
  "shimmerScaleMax": 1.45
}
```

Only these seven look keys. Every other key is omitted **on purpose** so it
follows the current theme — set a key and it stops following and survives a
theme change.

| Key | Matte Black preset | Plugin default | Set to | Why |
|---|---|---|---|---|
| `mirror` | `false` | `true` | `true` | Second comet head on the far side of the light axis. The preset pins light at 90°, so the axis is vertical and the heads sit top and bottom. |
| `lobe` | `0.16` | `0.16` | `0.3` | Lit-band half-width. Two bands of 0.3 light ~60% of the ring against ~16% before. `0.5` joins them into a continuous ring; Hyprland clamps `0.04…0.5`. |
| `shimmer` | `true` (but `false` on three themes, see below) | `true` | `true` | Pinned so the motion is not switched off by a theme preset. |
| `shimmerDeg` | `10` | `22` | `35` | Heading swing either side of 90°, so a 70° arc. Clamp `0…180`; past ~90 the sense of a fixed light direction is lost. |
| `shimmerHz` | `0.25` | `0.28` | `0.45` | Retargets per second. Clamp `0…4`; above ~1.5 it flickers rather than drifts, since it is a random walk and not a smooth oscillation. |
| `shimmerScaleMin/Max` | `0.9`–`1.2` | `0.8`–`1.4` | `0.75`–`1.45` | Size walk; also fattens and thins the stroke by ~35% of the deviation from 1. Clamp `0.2…3`. |

**`shimmer` is the drifting/breathing motion, not `pulse`.** Shimmer is a
random walk of heading and highlight size. `pulse` is a different renderer
that oscillates alpha, is off here, and loses to shimmer if both are on.

### The scale/lobe interaction

Scale multiplies the lit band, so the effective maximum is
`lobe × shimmerScaleMax` = `0.3 × 1.45 ≈ 0.44`, still under the `0.5` clamp —
nothing is being clipped. **If `lobe` ever goes to `0.5`, the top of the size
walk gets clamped away and the breathing looks lopsided.** Drop `lobe` to
about `0.34` at that point to keep headroom.

### What a theme change does

Colours (`gradient`, `baseColor`), `pinDeg`, `specularHalo` and `effect` are
all unset here, so they repaint from the new theme live. The six keys above
stay put. All 22 stock themes ship a preset; **a theme you make yourself has
none and falls back to the shared default — a white-to-transparent-teal glint
with a teal wrap stroke**, which is not theme-aware at all.

Three presets turn shimmer off. **`shimmer: true` is pinned in the entry
above specifically to override them**, so the motion survives every theme.
Without that key, the four shimmer dials would go inert on these:

| Theme | Preset's motion | Effect on these settings |
|---|---|---|
| Lumon | `shimmer: false`, `pulse: true` @ 0.15 Hz | breathes; shimmer dials ignored |
| Flexoki Light | `shimmer: false`, `pulse: true` @ 0.25 Hz | breathes; shimmer dials ignored |
| Vantablack | `shimmer: false`, `pulse: false` | fully static; dials ignored |
| Retro-82 | `effect: "ripple"` | dials still apply — ripple honours them |

`shimmer: true` was added on 2026-11-12 for exactly this reason. The
trade-off accepted knowingly: those three presets are making a deliberate
choice (a static ring suits Vantablack), and pinning the key overrides it.
Delete `"shimmer": true` to let each theme decide again. The resolution order
is asserted in the
plugin's own tests — *user key wins over the preset*, *keys the preset omits
stay shared* (`cli/src/theme/mod.rs`).

Preset data lives in `cli/src/theme/presets.rs`, one function per theme —
read it there rather than guessing. Incidentally **Lumon's preset is
`lobe: 0.3, mirror: true`**, the same shape arrived at independently here.

### Settings apply live — no shell restart

This plugin is an **exception** to the rule that shell changes need
`omarchy restart shell`. `Service.qml` watches `shell.json` with
`FileView { watchChanges: true }` on a 150 ms debounce. Save and it applies:
chrome immediately, windows a moment later. Verified 2026-11-12 by reading
values back with `hyprctl getoption` straight after a write.

### Reading the live values

The key names differ between the two places: **`shell.json` is camelCase**
(`shimmerHz`), **Hyprland's options are snake_case** (`shimmer_hz`).

```bash
hyprctl getoption plugin:shiny_border:lobe
hyprctl getoption plugin:shiny_border:mirror
grep -E 'gradient|base_color' ~/.config/hypr/border-fx.lua   # resolved colours
```

`omarchy bar set` does **not** work on this plugin — it is a `service`, not a
bar widget. Edit `shell.json`.

### Undo the look, keep the plugin

Reduce the entry back to `{ "id": "wmfeht.border-fx" }` and everything returns
to the theme preset. Backups from the 2026-11-12 session:
`~/.config/omarchy/shell.json.bak.1794505569` (bare entry, before any look
keys).

## Check it is working

```bash
ls ~/.cache/omarchy-border-fx/bin/border-fx     # the Rust controller, ~1.4 MB
ls ~/.local/lib/hypr/hypr-shiny-border.so       # the compiled ring, ~7.8 MB
hyprctl plugin list | grep -A3 shiny            # loaded in the compositor
hyprctl getoption plugin:shiny_border:effect    # str: shiny, set: true
hyprctl configerrors                            # must be empty
```

Verified 2026-11-12: all four artifacts present, `hypr-shiny-border by wmfeht`
0.1.0 loaded in Hyprland 0.56.2-7, options live, no config errors. The theme
preset resolved to the expected amber ramp (`ffc107` → `f59e0b` → `e68e0d`,
which is the Matte Black accent) with light pinned at 90° and specular halo on.

## Undo

Removing the toolchain is separate from removing the plugin; do either alone.

```bash
# the plugin (chrome and windows both off, clone deleted)
omarchy plugin remove wmfeht.border-fx --yes

# if the shell was down during the remove, the Hyprland copy can survive:
~/.config/omarchy/plugins/wmfeht.border-fx/scripts/border-fx teardown --purge
```

`--purge` deletes `~/.local/lib/hypr/hypr-shiny-border.so` and
`~/.config/hypr/border-fx.lua`. It does **not** remove the two
`border-fx` lines from `hyprland.lua` — harmless, since `pcall` does nothing
once the file is gone, but delete them by hand for a clean file.

The toolchain, only if nothing else wants it (`rust` is a common dependency —
check before removing):

```bash
sudo pacman -Rs rust
```

Neither undo was run on 2026-11-12. The teardown path is from the plugin's
own README, not tested here.

## Worth knowing

- **After a Hyprland upgrade, re-enable the plugin** or run
  `omarchy restart shell`. The ring is compiled against the running
  compositor's headers; the build check notices a version change and
  recompiles rather than loading a stale `.so`. Skipping this is how you get
  a ring that silently stops drawing.
- Later enables reuse the cached build and draw immediately. Only the first
  one pays the compile.
- Hyprland's own 2px border is still painting underneath the ring. The plugin
  recommends `general = { border_size = 0 }` and `decoration = { rounding = 8 }`
  — it reserves its own padding, so zeroing the stock border does not shift
  the layout. **Those keys live inside the Omaland managed block** in
  `looknfeel.lua`, which Omaland rewrites every time it opens, so change them
  through Omaland's panel, not by editing the file.
- Source checked before compiling: `cli/` depends only on `clap`, `serde`,
  `serde_json` and `toml` — no HTTP client in the tree and no socket calls.
  The subprocesses it spawns are `hyprctl`, `make`, `pkg-config`, `g++` and
  `notify-send`. Writes stay inside `~/.cache/omarchy-border-fx`, the session
  `.so`, and the generated lua. The 7.8 MB C++ ring itself was not read
  line by line.
