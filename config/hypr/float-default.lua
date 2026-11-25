-- Floating default (bar brief Q8, Stage 18): a window that floats starts at
-- this size, centred on the monitor's usable area (below the bar's reserve).
-- Change the size here, in one place.
o.float_default = { width = 1100, height = 700 }

local size = { o.float_default.width, o.float_default.height }

-- Windows that open floating: Omarchy's floating-window tag (its terminals,
-- btop, file pickers, previews, mpv, imv...). Loaded after Omarchy's
-- defaults, so it replaces the stock 875x600. A rule matching `float = true`
-- does not fire for windows floated by another rule, so the tag is the
-- match; dialogs an app floats itself keep the size the app asks for.
o.window({ tag = "floating-window" }, { size = size, center = true })

-- Super+T (bindings.lua): floating a window gives it the default size,
-- centred, the first time; after that it returns to the floating size and
-- place it last had (Hyprland keeps the size but not the place), so a
-- position the user set survives tiling and floating again.
local last = {}  -- address -> { x, y, width, height } of its last float
function o.float_toggle()
  local window = hl.get_active_window()
  if not window then return end
  local address = window.address
  if window.floating then
    last[address] = { window.at.x, window.at.y, window.size.x, window.size.y }
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    return
  end
  hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
  local g = last[address]
  if g then
    hl.dispatch(hl.dsp.window.resize({ x = g[3], y = g[4] }))
    hl.dispatch(hl.dsp.window.move({ x = g[1], y = g[2] }))
  else
    hl.dispatch(hl.dsp.window.resize({ x = size[1], y = size[2] }))
    hl.dispatch(hl.dsp.window.center())
  end
end
