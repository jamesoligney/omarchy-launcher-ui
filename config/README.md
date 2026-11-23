# Config snapshot (fallback point)

Copies of the config that shapes the launcher, emoji and clipboard pickers, the bar, the animation and the binds. Taken 2026-11-23.

**The live sources are `~/.config/hypr/` (binds: `bindings.lua`, the single source of truth), `~/.config/omarchy/` and `~/.config/vicinae/`.** Edit there, not here; these are snapshots and drift as soon as the live files change. `docs/reports/iteration-3b-claude-report.md` has the full audit of what is and is not included.

| Folder | Live source | What it holds |
|---|---|---|
| `hypr/` | `~/.config/hypr/` | `bindings.lua`, `hyprland.lua` (loader), `menu-glass.lua` (blur for the three pickers), `looknfeel.lua`, `monitors.lua`, `input.lua`, `autostart.lua`, `tricky-tiles.lua` (window animation, generated), `border-fx.lua`, `omarchy_fx.lua`, `no-shadow.lua`, others |
| `omarchy/` | `~/.config/omarchy/` | `shell.json` (bar layout, plugin settings, disabled stock plugins), `shell.toml` (launcher design tokens), `tricky-tiles.json`, `omarchy-fx.conf`, `extensions/omarchy-menu.jsonc` (launcher menu rows), `hooks/`, `tweaks/` (notes), `themes/` (small theme files only), `third-party-plugins.tsv` |
| `vicinae/` | `~/.config/vicinae/` | `settings.json` (the six app binds were removed from it) |

## Restore

Back up whatever is live first if it holds anything you want to keep (for example `cp ~/.config/omarchy/shell.json ~/.config/omarchy/shell.json.bak.$(date +%s)`). `cp -a src/. dest/` merges: it overwrites same-named files and leaves everything else.

```bash
# Hyprland (binds, glass rules, animation, loader)
cp -a config/hypr/. ~/.config/hypr/
hyprctl reload

# Omarchy shell: bar, tokens, menu rows, hooks, notes, theme files
cp -p config/omarchy/shell.json config/omarchy/shell.toml config/omarchy/tricky-tiles.json config/omarchy/omarchy-fx.conf ~/.config/omarchy/
mkdir -p ~/.config/omarchy/extensions && cp -p config/omarchy/extensions/omarchy-menu.jsonc ~/.config/omarchy/extensions/
cp -a config/omarchy/hooks/. ~/.config/omarchy/hooks/
cp -a config/omarchy/tweaks/. ~/.config/omarchy/tweaks/
cp -a config/omarchy/themes/. ~/.config/omarchy/themes/

# Vicinae
cp -p config/vicinae/settings.json ~/.config/vicinae/settings.json

omarchy restart shell
```

**Never run `omarchy refresh shell`**: it resets `shell.json` to Omarchy defaults. Copying `shell.json` back reloads the shell by itself. Third-party plugins are listed in `omarchy/third-party-plugins.tsv` and must be reinstalled from their sources; their settings live in `shell.json`.
