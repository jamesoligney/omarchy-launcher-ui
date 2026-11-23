# Glyph Menu replaces the launcher button

**Added:** 2026-11-12

The Omarchy logo at the far left of the bar is now a pickable glyph, from the
Glyph Menu plugin (`io.github.smoothpixels.glyph-menu`, 141+ Nerd Font marks
plus custom text). Currently set to the Arch Linux mark. Click behaviour is
unchanged: left click opens the Omarchy menu, right click opens a terminal.

Source: https://github.com/SmoothPixels/glyph-menu

## What changed

**1. Installed and enabled** — `omarchy plugin add` installs disabled on
purpose, so the source can be read before it runs in the shell:

```bash
omarchy plugin add https://github.com/SmoothPixels/glyph-menu --yes
omarchy plugin enable io.github.smoothpixels.glyph-menu --section left
```

**2. The stock button's layout entry removed** from `bar.layout.left` in
`~/.config/omarchy/shell.json`, with the glyph button put in its place.

**`omarchy.menu` was NOT disabled**, and must not be: that one plugin provides
both the launcher button (`bar-widget`) and the menu popup itself (`menu`),
and the glyph button opens the popup by calling back into it. Only its layout
entry is gone. `omarchy plugin list` consequently reports `omarchy.menu` as
*disabled* — that only reflects its absence from the bar layout. The popup
still loads on demand; verified below.

**3. The optional glyph picker** added to
`~/.config/omarchy/extensions/omarchy-menu.jsonc`, inside a
`// glyph-menu: begin` … `end` fence: 143 generated rows that put a
**Style → Menu Bar → Glyph Mark** submenu in the Omarchy menu, one row per
glyph with its real icon. The shell watches that file, so it applied without
a restart. The plugin does not write there itself — these were pasted from
`plugins/io.github.smoothpixels.glyph-menu/extensions/omarchy-menu.snippet.jsonc`.

Backups: `~/.config/omarchy/shell.json.bak.*` and
`~/.config/omarchy/extensions/omarchy-menu.jsonc.bak.*` (newest of each).

## The source, before enabling

No network calls, no install hooks, no sudo, no file writes. `Glyphs.js` is
pure data. The widget draws one `Text` and handles two clicks:
`omarchy-shell shell toggle omarchy.menu '{"menu":"root"}'` and
`xdg-terminal-exec`. It sets `textFormat: Text.PlainText` on the user-supplied
custom mark, which is the precaution Omarchy's own plugin guide asks for.
`tools/` holds the author's catalog generators; nothing there runs at runtime.

## Changing the mark

Menu: **Style → Menu Bar → Glyph Mark**, or `omarchy menu summon style.bar.glyph`.

CLI:

```bash
omarchy bar set io.github.smoothpixels.glyph-menu mark pacman
```

| Key | Default | Does |
|---|---|---|
| `mark` | `arch` | The glyph. `custom` uses `customText`. |
| `customText` | — | Any text, pasted glyph or emoji |
| `customFont` / `nerdFont` | — | Font families; empty follows the bar |
| `fontSize` | `0` | Pixel size; 0 follows the bar |
| `color` | — | Empty follows the theme; `accent` or `#rrggbb` |

## Check it is working

```bash
omarchy-shell shell toggle omarchy.menu '{"menu":"root"}'   # what a left click runs
omarchy menu summon style.bar.glyph                          # the picker
```

**The Omarchy menu opens in the CENTRE of the screen, not under the button.**
Worth knowing before concluding it is broken — that mistake cost a round of
debugging on 2026-11-12.

Verified that day, with the stock button out of the layout: the root menu
opened from the glyph button's own command, and the Glyph Mark submenu listed
its rows with real icons.

## Undo

```bash
omarchy plugin remove io.github.smoothpixels.glyph-menu
omarchy bar put omarchy.menu --section left
```

Then delete the `// glyph-menu: begin` … `end` block from
`~/.config/omarchy/extensions/omarchy-menu.jsonc`.

Partly tested on 2026-11-12: putting `omarchy.menu` back into
`bar.layout.left` was done and confirmed during debugging (the stock button
reappeared and `plugin list` showed it enabled again). A full
remove-and-reinstall cycle of the glyph plugin was not run.

## Worth knowing

- The generated picker rows go stale after `omarchy plugin update`: delete the
  fenced block and re-paste from the plugin's snippet file to pick up new
  glyphs. `omarchy plugin update` never touches the menu config.
- The menu config file tolerates a trailing comma before its closing brace —
  it is JSONC, and the klack-pack block already ended that way. Validating it
  with a strict JSON parser will report an error that is not real.
