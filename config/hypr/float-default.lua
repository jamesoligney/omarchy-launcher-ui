-- Floating default (bar brief Q8, Stage 18): a window that floats starts at
-- this size, centred on the monitor's usable area (below the bar's reserve).
-- Change the size here, in one place. 1100x619 is measured from the Zen
-- window James sized by hand (Stage 20); centred, it lands at (314, 273).
o.float_default = { width = 1100, height = 619 }

local size = { o.float_default.width, o.float_default.height }
-- Windows the default sizes carry this tag, so a workspace switched to
-- floating can tell them from dialogs and apps that size themselves.
local TAG = "float-default"

-- Plain hl.window_rule, not o.window: o.window would file these matches in
-- Omarchy's o.floating_apps, whose patterns its floating mode builds on.

-- Windows that open floating: Omarchy's floating-window tag (its terminals,
-- btop, file pickers, previews, mpv, imv...). Loaded after Omarchy's
-- defaults, so it replaces the stock 875x600. A rule matching `float = true`
-- does not fire for windows floated by another rule, so the tag is the
-- match; dialogs an app floats itself keep the size the app asks for.
hl.window_rule({ match = { tag = "floating-window" }, size = size, center = true, tag = "+" .. TAG })

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
hl.window_rule({
  match = {
    float = false,
    modal = false,
    class = own_floaters(o.floating_apps.class),
    title = own_floaters(o.floating_apps.title),
  },
  float = true,
  size = size,
  center = true,
  tag = "+" .. TAG,
})

local function place(window)
  local target = "address:" .. window.address
  hl.dispatch(hl.dsp.window.resize({ x = size[1], y = size[2], relative = false, window = target }))
  hl.dispatch(hl.dsp.window.center({ window = target }))
end

local function has_tag(window, name)
  for _, tag in ipairs(window.tags or {}) do
    if tag == name or tag == name .. "*" then return true end
  end
  return false
end

-- On a workspace in Omarchy's floating mode (Super+L) the mode's own open
-- rule is registered at runtime, after this one, so it would win (its stock
-- size and a cascade). The default wins there too: a window that rule opened
-- (it carries the rule's tag) is set to the default size, centred.
hl.on("window.open", function(window)
  if has_tag(window, "omarchy-mode-opened") then place(window) end
end)

-- Switching a workspace to floating (Stage 21) resets its windows to the
-- default size, centred, every time: Super+L / the layout toggle (both
-- o.workspace_mode) and a changed default applied on reload (the module's
-- apply). Omarchy marks every window on a floating workspace with a tag that
-- survives reloads, so the windows that just gained it are the ones that
-- just switched; a reload that only restores saved modes resets nothing.
-- Reset: windows the mode just floated from tiled, and windows the default
-- sized; dialogs, apps that size themselves and fullscreen windows are left.
local FLOATING_WS = "omarchy-floating-workspace"

local function on_floating()
  local seen = {}
  for _, window in ipairs(hl.get_windows({ tag = FLOATING_WS })) do seen[window.address] = true end
  return seen
end

local function reset_switched(before)
  for _, window in ipairs(hl.get_windows({ tag = FLOATING_WS })) do
    if not before[window.address] and (window.fullscreen or 0) == 0
        and (has_tag(window, TAG) or has_tag(window, "omarchy-mode-floated")) then
      place(window)
    end
  end
end

local function resetting(fn)
  return function(...)
    local before = on_floating()
    local result = fn(...)
    reset_switched(before)
    return result
  end
end

-- The module defines o.workspace_mode when it loads, so load it first.
local modes = require("default.hypr.workspace-modes")
o.workspace_mode = resetting(o.workspace_mode)
modes.apply = resetting(modes.apply)

-- Super+T (bindings.lua): floating a window gives it the default size,
-- centred, the first time; after that it returns to the floating size and
-- place it last had (Hyprland keeps the size but not the place), so a
-- position the user set survives tiling and floating again. Per window, and
-- separate from the workspace reset above.
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
    place(window)
  end
end
