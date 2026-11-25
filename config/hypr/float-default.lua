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

-- Floating is the default on every workspace (Stage 19): every new window
-- opens floating at the default size, centred; tiling is the opt-in (Super+T).
-- Left alone: modal dialogs and windows Hyprland already floats (transient
-- dialogs, popups), which keep the size their app asks for, and apps with
-- float rules of their own (Omarchy's o.floating_apps: About, the
-- calculator...), which keep theirs. Rules apply as a window opens, so
-- windows already open are never moved.
local function own_floaters(list)
  local alternatives = {}
  for _, pattern in ipairs(list) do table.insert(alternatives, "(?:" .. pattern .. ")") end
  return #alternatives > 0 and "negative:" .. table.concat(alternatives, "|") or nil
end
o.window({
  float = false,
  modal = false,
  class = own_floaters(o.floating_apps.class),
  title = own_floaters(o.floating_apps.title),
}, { float = true, size = size, center = true })

-- On a workspace in Omarchy's floating mode (Super+L) the mode's own open
-- rule is registered at runtime, after this one, so it would win (its stock
-- size and a cascade). The default wins there too: a window that rule opened
-- (it carries the rule's tag) is set to the default size, centred.
hl.on("window.open", function(window)
  for _, tag in ipairs(window.tags or {}) do
    if tag == "omarchy-mode-opened*" or tag == "omarchy-mode-opened" then
      local target = "address:" .. window.address
      hl.dispatch(hl.dsp.window.resize({ x = size[1], y = size[2], relative = false, window = target }))
      hl.dispatch(hl.dsp.window.center({ window = target }))
      return
    end
  end
end)

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
