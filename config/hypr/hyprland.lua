-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Frosted glass behind the launcher (jimmy.menu clone).
require("hypr.menu-glass")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- No titlebar on any floating window (hyprbars rule). Move with Super + left-drag.
o.window({ float = true }, { ["hyprbars:no_bar"] = true })

-- >>> omaland managed block >>>
-- Written by Omaland. Safe to hand-edit: Omaland re-reads this block
-- every time it opens, and only ever rewrites what's between the fences.
o.window(".*", { tag = "-omaland-opaque" })
if o.transparent_window then
  o.window({ tag = "negative:transparent-window" }, { tag = "+omaland-opaque" })
  o.window({ tag = "transparent-window" }, { tag = "-omaland-opaque" })
else
  o.window({ tag = "negative:default-opacity" }, { tag = "+omaland-opaque" })
  o.window({ tag = "chromium-based-browser" }, { tag = "-omaland-opaque" })
  o.window({ tag = "firefox-based-browser" }, { tag = "-omaland-opaque" })
end
-- <<< omaland managed block <<<

do local d = debug.getinfo(1, "S").source:match("^@(.*/)") or os.getenv("HOME") .. "/.config/hypr/"; local p = d .. "tricky-tiles.lua"; local f = io.open(p); if f then f:close(); dofile(p) end end -- Tricky Tiles (remove via its panel)

-- omarchy-fx: window effects
require("hypr.omarchy_fx")

-- wmfeht.border-fx (Omarchy plugin control plane; pcall if the file is missing)
pcall(require, "hypr.border-fx")

-- No window shadow (see hypr/no-shadow.lua)
require("hypr.no-shadow")

-- omacast launcher bindings
require("hypr.omacast")
