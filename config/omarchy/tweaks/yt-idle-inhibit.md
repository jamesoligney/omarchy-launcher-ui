# YouTube idle inhibit (reverted)

- Had added to `~/.config/hypr/hyprland.lua`: `o.window({ title = ".*YouTube.*" }, { idle_inhibit = "focus" })`.
- Problem: it blocked the screensaver/lock for any focused YouTube window, even when the video was paused or no video was playing. Intended: block only while a video is actually playing.
- Reverted: the two lines were removed (backup `hyprland.lua.bak.*-revert-yt-idle`), then `hyprctl reload`.

## Undo of the revert
Re-add the two lines above to hyprland.lua and `hyprctl reload`.

## Open idea
A playing-aware version needs a Wayland idle inhibitor driven by playback state (for example MPRIS from Chromium), not a static window rule.
