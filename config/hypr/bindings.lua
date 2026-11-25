-- Keep only your personal keybinding overrides here. Add new bindings with
-- o.bind or replace defaults with o.rebind.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding. o.rebind takes the same arguments as o.bind.
-- This example replaces the default file manager with Flea.
-- o.rebind("SUPER + SHIFT + F", "File manager", { launch = "flea" })

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, { panel = "omarchy.emojis" })
hl.unbind("ALT + SPACE")
o.bind("ALT + SPACE", "Vicinae", "/usr/bin/vicinae toggle")

-- klack (keyboard sound) volume, independent of system volume.
-- Plain volume keys = system volume; add SUPER = klack only.
-- Absolute path: Hyprland's exec does not always inherit ~/.local/bin on PATH.
o.bind("SUPER + XF86AudioRaiseVolume", "klack volume up", "/home/jimmy/.local/bin/klack-volume up")
o.bind("SUPER + XF86AudioLowerVolume", "klack volume down", "/home/jimmy/.local/bin/klack-volume down")
o.bind("SUPER + XF86AudioMute", "klack mute", "/home/jimmy/.local/bin/klack-volume mute")

-- App launches: Alt+<letter>. Single source of truth (migrated from Vicinae 2026-11-23).
-- Super+Return stays the default terminal; Alt+G is the Ghostty-specific bind.
o.bind("ALT + M", "Muse.AI", { webapp = "https://muse.ai/" })
o.bind("ALT + G", "Ghostty", { launch = "ghostty --gtk-single-instance=true" })
o.bind("ALT + H", "Helium", { launch = "helium-browser" })
o.bind("ALT + F", "Floorp", { launch = "flatpak run one.ablaze.floorp" })
o.bind("ALT + O", "Orca", { launch = "/home/jimmy/Applications/Orca.AppImage" })
o.bind("ALT + Z", "Zen", { launch = "/opt/zen-browser-bin/zen-bin" })

-- Summarize the YouTube link on the clipboard with Claude.
o.bind("SUPER + ALT + Y", "Summarize YouTube", "/home/jimmy/.local/bin/yt-summary")

-- Toggle chrome-free 16:9 mini video mode on a floating window.
o.bind("SUPER + ALT + V", "Mini video", "/home/jimmy/.local/bin/yt-mini")

-- Center the focused floating window (no-op when tiled).
o.bind("SUPER + ALT + C", "Center window", hl.dsp.window.center())

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

-- flea --default: begin. Written by `flea --default`; `flea --default off` removes the block whole.
hl.unbind("SUPER + SHIFT + F")
o.bind("SUPER + SHIFT + F", "File manager", { launch = 'flea --gui' })
hl.unbind("SUPER + ALT + SHIFT + F")
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)", { launch = 'flea --gui "$(omarchy-cmd-terminal-cwd)"' })
-- flea --default: end.

-- flea --picker: begin. Written by `flea --picker`; `flea --picker off` removes the block whole.
o.window("com.thisisgm.flea.picker", { tag = "+floating-window" })
-- flea --picker: end.

-- scratchpad-hotkey: begin
-- Toggle the Scratchpad note panel (acooper.scratchpad plugin). The
-- { panel = ... } form compiles to `omarchy-shell shell toggle <id>`, which
-- the shell routes to whichever bar instance holds the widget.
-- SUPER + S is Hyprland's own scratchpad (the hidden workspace) and has
-- nothing to do with this; SUPER + CTRL + N and SUPER + SHIFT + N are
-- Omarchy's Network and Editor.
o.bind("SUPER + N", "Scratchpad", { panel = "acooper.scratchpad" })
-- scratchpad-hotkey: end

-- close-window-or-tab: begin
-- SUPER + W closes a browser tab (sends Ctrl+W, so the last tab closes the window).
-- Any other window: closes the window as before.
-- Browsers get Ctrl+W sent with hl.dsp.send_key_state, not wtype: wtype merges
-- with the physically held SUPER and the browser sees Super+Ctrl+W.
local tab_close_browsers = {
  chromium = true, ["google-chrome"] = true, chrome = true, ["brave-browser"] = true,
  ["microsoft-edge"] = true, ["vivaldi-stable"] = true, helium = true,
  firefox = true, zen = true, librewolf = true, ["one.ablaze.floorp"] = true,
}
local function send_ctrl_w()
  hl.dispatch(hl.dsp.send_key_state({ mods = "CTRL", key = "W", state = "down" }))
  hl.timer(function()
    hl.dispatch(hl.dsp.send_key_state({ mods = "CTRL", key = "W", state = "up" }))
  end, { timeout = 50, type = "oneshot" })
end
o.rebind("SUPER + W", "Close window or browser tab", function()
  local window = hl.get_active_window()
  local class = ((window and window.class) or ""):lower()
  if tab_close_browsers[class] then
    send_ctrl_w()
  else
    hl.dispatch(hl.dsp.window.close())
  end
end)
-- close-window-or-tab: end

-- App shortcut, made from the Omarchy menu
o.bind("ALT + K", "Keep", { launch = "gtk-launch 'Keep.desktop'" })

-- kbd-backlight: begin
-- Keyboard backlight up/down, through omarchy-kbd-backlight so a press pauses
-- the ambient-light daemon (omarchy-kbd-auto.service) for 10 minutes. Same
-- 10 % step and OSD as stock. Ctrl + display-brightness keys (Ctrl+F1/F2) is
-- Omarchy's MacBook convention and always reaches Hyprland; the dedicated
-- backlight keysyms are rebound too, in case this keyboard's F5/F6 send them.
o.rebind("CTRL + XF86MonBrightnessDown", "Keyboard brightness down", "omarchy-kbd-backlight down", { locked = true, repeating = true })
o.rebind("CTRL + XF86MonBrightnessUp", "Keyboard brightness up", "omarchy-kbd-backlight up", { locked = true, repeating = true })
o.rebind("XF86KbdBrightnessDown", "Keyboard brightness down", "omarchy-kbd-backlight down", { locked = true, repeating = true })
o.rebind("XF86KbdBrightnessUp", "Keyboard brightness up", "omarchy-kbd-backlight up", { locked = true, repeating = true })
-- kbd-backlight: end

-- bar-quick: begin
-- Quick toggles (stay awake, set reminder, night light, silence) from the
-- right island of jimmy.bar, keyboard path: Up/Down, Enter, Esc. Hovering the
-- time opens the same pop-out.
o.bind("SUPER + CTRL + Q", "Quick toggles", "omarchy-shell jimmy.bar quick")
-- bar-quick: end

-- bar-leader: begin
-- Super+D, then one key: the bar's leader (refined brief). 1-9 workspace,
-- W weather, T calendar, B battery / power, A agents, Q quick toggles, Esc
-- leave. One key and the submap resets; the bar shows each letter meanwhile.
o.bind("SUPER + D", "Bar leader", hl.dsp.submap("bar"))
pcall(hl.define_submap, "bar", "reset", function()
  for slot = 1, 9 do
    o.bind("code:" .. tostring(slot + 9), "Workspace " .. slot, o.workspaces.focus(slot))
  end
  o.bind("W", "Weather", "omarchy-shell shell toggle omarchy.weather")
  o.bind("C", "Calendar", "omarchy-shell shell toggle omarchy.clock")
  o.bind("B", "Battery and power", "omarchy-shell shell toggle omarchy.power")
  o.bind("A", "Agents", "omarchy-shell shell toggle omarchy.agents")
  o.bind("Q", "Quick toggles", "omarchy-shell jimmy.bar quick")
  o.bind("Escape", "Leave the leader", hl.dsp.submap("reset"))
end)
-- bar-leader: end
