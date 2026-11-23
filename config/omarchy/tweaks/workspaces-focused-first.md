# Workspaces: focused first, AeroSpace style

**Added:** 2026-11-11

The bar's workspace row shows the focused workspace first, in a filled block,
then a separator, then the other occupied workspaces in ascending order. Empty
workspaces are not drawn. The workspace you are on is therefore always in the
same place on the bar, which is what AeroSpace (the macOS tiler) did and what
Omarchy's stock row does not.

```
▇3▇ │ 1  2  5        focused 3; 1, 2 and 5 have windows
▇1▇ │ 2  3  5        after Super+1
▇4▇ │ 1  2  3  5     an empty workspace still shows while focused
▇4▇                  nothing else open: no separator
```

## What changed

A clone of the built-in widget, which is the supported way to customise one:

```bash
omarchy plugin clone omarchy.workspaces
```

That created `~/.config/omarchy/plugins/jimmy.workspaces/` and switched the bar
to `jimmy.workspaces` (the `left` section of `~/.config/omarchy/shell.json`).
Nothing in `/usr/share/omarchy/` was touched, so an `omarchy update` cannot
overwrite it and the stock widget is still there to go back to.

`Workspaces.qml` keeps the stock monitor/workspace plumbing — per-monitor
blocks of ten, click to focus, scroll to walk the row — and replaces the
layout and the delegate:

- **Order.** `order` puts the focused id first, then every other id with
  windows, ascending.
- **Positions, not a layout.** The stock widget uses a `GridLayout`, which
  re-places its children instantly. This one keeps one item per workspace alive
  the whole time (`modelIds`, which only changes when the monitor's set of
  workspaces changes) and animates each item's `x` to its place in the row, so
  the numbers slide instead of teleporting.
- **The block.** The focused number sits on a rounded rect in the theme's
  accent (`Color.accent` — Matte Black's `#e68e0d`), with the number in the
  bar's background colour.
- **Urgent.** A workspace whose window asks for attention draws its number in
  the theme's red (`Color.urgent`) and breathes. Hyprland's `urgent` event
  names the window, so the address is matched against `Hyprland.toplevels` to
  find its workspace; the flag clears when that workspace is focused.
- **The layout glyph is gone.** Stock shows the layout mode (dwindle, scrolling,
  floating) in place of the active workspace's number. This shows the number.
  Clicking the block used to cycle the layout as well; with no glyph to show
  what changed, that click would rearrange the windows and explain nothing, so
  it is off (`blockClick`). `Super + L` still cycles the layout.

## Settings

In the widget's entry in `~/.config/omarchy/shell.json`, all optional:

| Key | Default | Does |
|---|---|---|
| `animate` | `true` | Slide the numbers to their new places |
| `separator` | `"line"` | `"line"`, `"pipe"` (a `\|` character) or `"none"` |
| `urgentPulse` | `true` | Breathe an urgent workspace |
| `blockClick` | `"none"` | `"layout"` makes a click on the focused block cycle that workspace's layout, as the stock widget does |
| `highlight` | `"accent"` | `"accent"` for the theme accent, `"bar"` for the bar's own active colour (the theme red) |

```bash
omarchy bar set jimmy.workspaces separator pipe
omarchy restart shell     # settings need a restart; code changes hot-reload
```

## Check it is working

```bash
hyprctl dispatch 'o.workspaces.focus(5, "eDP-1")'   # plain `hyprctl dispatch workspace 5` does NOT work here
```

The block should jump to 5 and the rest re-sort behind it. Verified on
2026-11-11 by screenshotting the bar on workspaces 5, 2 and 3: focused-first
held, an empty focused workspace still showed, and workspaces with no windows
stayed out of the row. The urgent colour and its pulse were verified by forcing
the flag on in the source, screenshotting, and reverting; the event wiring that
sets the flag has **not** been seen firing on a real window yet.

## Undo

**Back to the stock widget**, keeping the clone on disk — point the bar's
`left` section back at `omarchy.workspaces`:

```bash
python3 - <<'PY'
import json, pathlib
p = pathlib.Path.home()/".config/omarchy/shell.json"
d = json.loads(p.read_text())
for w in d["bar"]["layout"]["left"]:
    if w["id"] == "jimmy.workspaces": w["id"] = "omarchy.workspaces"
p.write_text(json.dumps(d, indent=2, sort_keys=True) + "\n")
PY
omarchy restart shell
```

Swap the two ids the other way to come back. Both directions tested on
2026-11-11: stock returned with its 1-5 row and layout glyph, and the clone
came back with the focused block.

**Remove it entirely:** `omarchy plugin remove jimmy.workspaces` — which, as a
clone, puts `omarchy.workspaces` back on the bar by itself.

## Worth knowing

- Workspace Styler (`io.github.sanchokusika.workspace-styler`) was installed
  alongside this for a day and removed on 2026-11-11 in favour of it. It does
  blocks, animations and urgent breathing, but not the focused-first order.
  `omarchy plugin add https://github.com/SanchoKusika/omarchy-workspace-styler`
  brings it back.
- A code change under `~/.config/omarchy/plugins/` is supposed to hot-reload,
  and `omarchy-shell shell rescanPlugins` is supposed to force it. Neither
  reliably reloaded this widget: **`omarchy restart shell` is what actually
  applies a change.**
- Still to do, by request: window-count pips under each number, in place of the
  app icons the Spaces plugin used to show.
