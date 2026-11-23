# Alt+Tab → Fathom

**Added:** 2026-11-10

Alt+Tab and Alt+Shift+Tab open the Fathom overlay (a window switcher with a
visible list) instead of Hyprland's default `cyclenext`. Hold Alt to keep
tabbing; let Alt go to commit.

## What changed

One block appended to `~/.config/hypr/bindings.lua`:

```lua
-- fathom: begin
do
  local fathom = os.getenv("HOME") .. "/.config/omarchy/plugins/io.github.mtolhuys.fathom/hypr/fathom.lua"
  local file = io.open(fathom, "r")
  if file then
    file:close()
    pcall(dofile, fathom)
  end
end
-- fathom: end
```

That is the whole edit. The block only loads the plugin's own
`hypr/fathom.lua`, which does the rest: it unbinds Omarchy's default Alt+Tab,
binds its own, and watches the raw key stream so releasing Alt commits.

Nothing was removed from `bindings.lua`, and no other config file was touched.
The plugin itself lives in
`~/.config/omarchy/plugins/io.github.mtolhuys.fathom/` and is listed in
`~/.config/omarchy/shell.json`.

Pre-edit backup: `~/.config/hypr/bindings.lua.bak.1794350099`

## Check it is working

```bash
hyprctl configerrors                    # should be empty
hyprctl binds | grep -i fathom          # should list the dive/rise binds
```

Expect `Fathom: dive one window deeper` (Alt+Tab) and `Fathom: rise one
window` (Alt+Shift+Tab). Each appears twice — once as the global bind, once in
Fathom's submap, which holds other Alt chords mid-switch. That is normal.

## Undo

**Keep Fathom installed, just stop it taking Alt+Tab.** The plugin checks
`shell.json` on every config load and bows out if it is disabled, before it
unbinds anything:

```bash
omarchy plugin disable io.github.mtolhuys.fathom
hyprctl reload
```

Omarchy's default Alt+Tab comes back (its four binds: cyclenext and
bring_to_top, both directions). Re-enable with
`omarchy plugin enable io.github.mtolhuys.fathom`.

Both directions of this were tested on 2026-11-10: `disable` takes the entry
out of the `plugins` array in `shell.json`, and `enable` puts it back. The
Lua block in `bindings.lua` stays put either way.

**Remove the tweak entirely.** Delete the `-- fathom: begin` … `-- fathom: end`
block from `~/.config/hypr/bindings.lua`, then:

```bash
hyprctl reload
hyprctl configerrors
```

Or restore the backup, which also drops any later edits to that file:

```bash
cp ~/.config/hypr/bindings.lua.bak.1794350099 ~/.config/hypr/bindings.lua
hyprctl reload
```

To remove the plugin too: `omarchy plugin remove io.github.mtolhuys.fathom`.

## Worth knowing

- The Lua block is guarded: if the plugin directory is gone, the block is a
  no-op and Alt+Tab keeps Omarchy's default. Removing the plugin without
  removing the block is safe.
- `fathom.lua` deliberately never tears down a keybind it created — doing so
  crashed Hyprland 0.56.2. To pick up changes, reload (fresh Lua state) rather
  than expecting a live swap.
- Undoing needs a reload, not just a save, when the change is a removal: the
  unbind lives in the old Lua state until Hyprland builds a new one.
