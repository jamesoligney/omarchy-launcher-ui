# Super + N opens the Scratchpad note

**Added:** 2026-11-12

`SUPER + N` toggles the note panel from the Scratchpad plugin
(`acooper.scratchpad`), so the whole loop is Super+N, type, Esc — the panel
takes keyboard focus on open with the cursor at the end of the note.

Before this, `SUPER + N` was unbound. Omarchy had taken both neighbours and
left the plain key free:

| Binding | What |
|---|---|
| `SUPER + N` | **Scratchpad** (this tweak) |
| `SUPER + CTRL + N` | Network (Omarchy default) |
| `SUPER + SHIFT + N` | Editor (Omarchy default) |

`SUPER + S` is **Hyprland's** scratchpad — the special hidden workspace — and
`SUPER + ALT + S` moves a window to it. Same word, unrelated feature, both
left alone.

## What changed

One fenced block appended to `~/.config/hypr/bindings.lua`:

```lua
-- scratchpad-hotkey: begin
o.bind("SUPER + N", "Scratchpad", { panel = "acooper.scratchpad" })
-- scratchpad-hotkey: end
```

The `{ panel = ... }` form is Omarchy's own helper: `helpers.lua:99` compiles
it to `omarchy-shell shell toggle acooper.scratchpad`. The shell's IPC
(`shell.qml:1918`) hands that to `Bar.findPanelWidget`, which routes it to
whichever per-monitor bar instance actually holds the widget — which is why
this works as a hotkey rather than needing the plugin to expose an IPC of its
own.

Pre-edit backup: `~/.config/hypr/bindings.lua.bak.*` (newest).

## Where the note is kept

Plain text at `~/.local/state/omarchy/scratchpad.txt`. Nothing else touches it;
it can be backed up, symlinked into a notes folder, or edited in `$EDITOR`
while the panel is closed (changes are picked up next time it opens). Move it
with `omarchy bar set acooper.scratchpad notePath ~/notes/scratch.txt`.

The widget sits in the bar's **tray** section, so its sticky-note icon is in
the tray drawer rather than on the bar itself; the hotkey opens the note
without touching the drawer. `omarchy bar move acooper.scratchpad --section
right` would put the icon on the bar instead. Right-clicking it swaps the note
for a width/height form.

One caveat found on 2026-11-12: this hotkey reaches the panel through the
bar's `findPanelWidget`, and a **bar forked from before Omarchy 4.5.0 has no
tray section at all**, so a widget parked in `tray` is unreachable — the key
silently does nothing. If a replacement bar is ever used, move this widget to
`right`. See the Notch Bar entry in
[plugins-to-revisit.md](plugins-to-revisit.md).

## Check it is working

```bash
hyprctl binds | grep -A3 Scratchpad     # should list SUPER + N
hyprctl configerrors                    # should be empty
omarchy-shell shell toggle acooper.scratchpad   # what the key runs
```

Verified on 2026-11-12: the IPC command opened the panel over the desktop with
the saved note in it, and closed it again on a second call.

## Undo

Delete the `-- scratchpad-hotkey: begin` … `end` block from
`~/.config/hypr/bindings.lua`, then:

```bash
hyprctl reload
hyprctl configerrors
```

Tested both directions on 2026-11-12: removing the block and reloading left
`SUPER + N` unbound, and restoring it brought the binding back with no config
errors. Or restore the backup, which also drops any later edits to that file:

```bash
cp ~/.config/hypr/bindings.lua.bak.<stamp> ~/.config/hypr/bindings.lua
hyprctl reload
```

To change the key, edit the one `o.bind` line — the second argument is just
the label shown in `omarchy menu keybindings --print`.

## Worth knowing

- The same `{ panel = "<plugin-id>" }` form binds a key to **any** shell panel
  or panel-capable bar widget, first-party or not. `{ menu = "<route>" }` does
  the same for menu routes.
- The plugin autosaves one second after typing stops, as well as on close, so
  a crash costs nothing.
