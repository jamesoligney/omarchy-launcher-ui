-- Afterburn: three-stop gradient on the focused window, plus a soft glow in the theme accent.
local active_border_color = "rgba(00000000)" -- ember border off: Border FX draws the shimmer instead
local inactive_border_color = "rgba(2b2a28aa)"

hl.config({
  general = {
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },

  decoration = {
    shadow = {
      enabled = false, -- halo off
      range = 14,
      render_power = 3,
      color = "rgba(f5914555)",
      color_inactive = "rgba(00000066)",
    },
  },
})
