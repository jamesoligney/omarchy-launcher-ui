import QtQuick
import QtQuick.Effects
import qs.Commons as Commons
import "Tokens.js" as Tokens

// The islands' faint accent glow, for every surface in the island language
// (islands, toasts, notifications, attached panels): one look, one token
// pair. A child of the surface it lights, drawn behind it (z -1), so it
// follows the surface's radius, motion and opacity. Static: no animation.
RectangularShadow {
  readonly property var tokens: Commons.Color.shellValues
  readonly property real alpha: Tokens.num(tokens, "island.glow-alpha", 0.14)
  anchors.fill: parent
  z: -1
  visible: alpha > 0
  radius: parent ? parent.radius : 0
  blur: Tokens.num(tokens, "island.glow-blur", 10)
  spread: 0
  color: Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, alpha)
}
