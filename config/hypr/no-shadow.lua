-- No window shadow at all (the Afterburn halo and Omarchy's default shadow).
-- Loaded from hyprland.lua after Omarchy's defaults and the theme.
-- Omarchy's floating-workspace setup can turn shadows back on when a floating
-- workspace starts; that is Omarchy's code, not this file.
hl.config({
  decoration = {
    shadow = { enabled = false },
  },
})
