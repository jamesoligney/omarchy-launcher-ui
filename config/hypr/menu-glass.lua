-- Frosted glass for the Omarchy launcher and its sibling pickers.
-- The launcher (jimmy.menu clone) and the emoji/clipboard clones keep the
-- stock "omarchy-*" layer namespaces, and their card backgrounds come from the
-- theme at 84% alpha. Hyprland blurs what is behind those layers; no keybinds
-- are involved. The clones animate internally in QML, so the stock `no_anim`
-- layer rule does not interfere with the open/close motion.
require("default.hypr.glass")()

hl.layer_rule({
  match = { namespace = "^(omarchy-menu|omarchy-emojis|omarchy-clipboard)$" },
  blur = true,
  ignore_alpha = 0.2,
})
