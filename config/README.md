# Hyprland binds snapshot (fallback point)

Copy of `~/.config/hypr/bindings.lua`, taken 2026-11-23.

**The live source is `~/.config/hypr/bindings.lua`.** That file is the single source of truth for binds; edit there, not here. This copy drifts as soon as the live file changes.

## Restore

```bash
cp -p config/bindings.lua ~/.config/hypr/bindings.lua
hyprctl reload
```

Back up the current live file first if it has binds you want to keep, for example `cp ~/.config/hypr/bindings.lua ~/.config/hypr/bindings.lua.bak.$(date +%s)`.
