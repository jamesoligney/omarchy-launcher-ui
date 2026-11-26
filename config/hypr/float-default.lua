-- Floating default (bar brief Q8, Stage 18): a window that floats starts at
-- this size, centred on the monitor's usable area (below the bar's reserve).
-- Change the size here, in one place. 1100x619 is measured from the Zen
-- window James sized by hand (Stage 20). Centred on the usable area (left
-- of it the 30px workspace strip, above it the 48px bar), it lands at
-- (329, 273) (Stage 24; it was (314, 273) before the strip).
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

-- Which windows keep their own size. Hyprland's Lua cannot ask a window
-- whether it is a dialog (no modal or parent field, and window queries take
-- no modal filter), so a window is classed as it opens, when the rules have
-- just fired: one that opened floating without the default rule or Omarchy's
-- floating-window tag floated on its own account (a dialog or popup Hyprland
-- floated, a modal, an app with its own float rule) and is tagged
-- SELF_FLOATED, for good. Every other window is a normal app window,
-- including ones open since before this existed. Apps with their own stock
-- float size are also recognised by o.floating_apps, for older windows.
local SELF_FLOATED = "self-floated"
local FLOATING_WS = "omarchy-floating-workspace"

local function own_float_size()
  local set = {}
  for key, list in pairs({ class = o.floating_apps.class, title = o.floating_apps.title }) do
    for _, pattern in ipairs(list or {}) do
      local ok, found = pcall(hl.get_windows, { [key] = pattern })
      if ok then for _, w in ipairs(found) do set[w.address] = true end end
    end
  end
  return set
end

local function keeps_own_size(window, own)
  return (window.fullscreen or 0) ~= 0 or has_tag(window, SELF_FLOATED) or own[window.address]
end

-- Every new app window ends at the default, however it mapped. The rules
-- above float it as it maps, but not every window lets them: one that asks
-- to open maximized (Helium remembers its last window as maximized) maps
-- tiled although Omarchy suppresses the maximize itself, and on a floating
-- workspace Omarchy's mode then floats it the stock way (its size, a
-- cascade), after this handler. So the window is classed at once, and a
-- moment later, once the mode has run, a normal app window on a regular
-- workspace is floated if it is still tiled and set to the default.
local function window_at(address)
  for _, w in ipairs(hl.get_windows()) do
    if w.address == address then return w end
  end
end

hl.on("window.open", function(window)
  if window.floating and not has_tag(window, TAG) and not has_tag(window, "floating-window")
      and not has_tag(window, "omarchy-mode-opened") then
    hl.dispatch(hl.dsp.window.tag({ tag = "+" .. SELF_FLOATED, window = "address:" .. window.address }))
    return
  end
  local address = window.address
  hl.timer(function()
    local w = window_at(address)
    local id = w and w.workspace and tonumber(w.workspace.id)
    if not id or id < 1 or keeps_own_size(w, own_float_size()) then return end
    if not w.floating then
      hl.dispatch(hl.dsp.window.float({ action = "on", window = "address:" .. address }))
    end
    place(w)
  end, { type = "oneshot", timeout = 30 })
end)

-- A workspace switching to floating resets its windows to the default size,
-- centred, every time (Stages 21-22): Super+L / the layout toggle (both
-- o.workspace_mode) and a changed default applied on reload (the module's
-- apply). Omarchy marks every window on a floating workspace with a tag that
-- survives reloads, so the windows that just gained it are the ones that
-- just switched; a reload that only restores saved modes resets nothing.
-- Every normal app window on the workspace is reset, whatever floated it.
local function on_floating()
  local seen = {}
  for _, window in ipairs(hl.get_windows({ tag = FLOATING_WS })) do seen[window.address] = true end
  return seen
end

local function reset_switched(before)
  local own = own_float_size()
  for _, window in ipairs(hl.get_windows({ tag = FLOATING_WS })) do
    if not before[window.address] and not keeps_own_size(window, own) then place(window) end
  end
end

-- The other way (Stage 24): a workspace switched to a tiled layout tiles
-- its normal app windows. Omarchy's mode only tiles windows it floated
-- itself, and since floating became the default every new window floats on
-- its own account, so without this Super+L changed the layout while every
-- window stayed floating: nothing visibly happened. Dialogs, apps that size
-- themselves, fullscreen and pinned windows are left as they are.
local function tile_switched(spec)
  if type(spec) ~= "table" or not spec.workspace or spec.mode == "floating" then return end
  local own = own_float_size()
  for _, window in ipairs(hl.get_windows({ workspace = tostring(spec.workspace) })) do
    if window.floating and not window.pinned and not keeps_own_size(window, own) then
      hl.dispatch(hl.dsp.window.float({ action = "off", window = "address:" .. window.address }))
    end
  end
end

local function resetting(fn)
  return function(spec, ...)
    local before = on_floating()
    local result = fn(spec, ...)
    reset_switched(before)
    tile_switched(spec)
    return result
  end
end

-- The module defines o.workspace_mode when it loads, so load it first.
local modes = require("default.hypr.workspace-modes")
o.workspace_mode = resetting(o.workspace_mode)
modes.apply = resetting(modes.apply)

-- The mode also floats a tiled window that arrives on a floating workspace,
-- by being moved there or by leaving fullscreen, and places it the stock way
-- one tick later. The default wins there too: a little after the mode, a
-- window that came in tiled and is now floating on a floating workspace is
-- set to the default.
local function after_mode(window)
  local was_floating, address = window.floating, window.address
  hl.timer(function()
    local now = hl.get_windows({ tag = FLOATING_WS })
    for _, w in ipairs(now) do
      if w.address == address and w.floating and not was_floating
          and not keeps_own_size(w, own_float_size()) then
        place(w)
      end
    end
  end, { type = "oneshot", timeout = 30 })
end
hl.on("window.move_to_workspace", function(window) after_mode(window) end)
hl.on("window.fullscreen", function(window) after_mode(window) end)

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
