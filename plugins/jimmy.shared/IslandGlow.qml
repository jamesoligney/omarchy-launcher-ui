import QtQuick
import QtQuick.Effects
import qs.Commons as Commons
import "Tokens.js" as Tokens

// The islands' faint accent glow, for every surface in the island language
// (islands, toasts, notifications, attached panels): one look, one token
// pair. A halo outside the outline only: the glow is masked out under the
// surface itself, so its glass stays neutral and see-through.
//
// A child of the surface it lights, drawn behind it (z -1), so it follows the
// surface's motion and opacity. `cutouts` lists the shapes to keep dark
// (default: the parent); a joined pair of islands glows as one, from an item
// spanning both, with both cut out. Static: no animation.
Item {
  id: glow
  property var cutouts: [parent]
  property real radius: parent && parent.radius !== undefined ? parent.radius : Tokens.num(tokens, "island.radius", 13)

  readonly property var tokens: Commons.Color.shellValues
  readonly property real alpha: Tokens.num(tokens, "island.glow-alpha", 0.32)
  readonly property real blur: Tokens.num(tokens, "island.glow-blur", 20)
  readonly property real pad: blur + 2

  anchors.fill: parent
  z: -1
  visible: alpha > 0

  Item {
    id: light
    visible: false
    layer.enabled: true
    x: -glow.pad; y: -glow.pad
    width: glow.width + 2 * glow.pad; height: glow.height + 2 * glow.pad
    RectangularShadow {
      x: glow.pad; y: glow.pad
      width: glow.width; height: glow.height
      radius: glow.radius
      blur: glow.blur
      color: Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, glow.alpha)
    }
  }

  Item {
    id: cut
    visible: false
    layer.enabled: true
    x: light.x; y: light.y; width: light.width; height: light.height
    Repeater {
      model: glow.cutouts
      Rectangle {
        required property var modelData
        readonly property bool self: modelData === glow.parent
        x: glow.pad + (self ? 0 : modelData.x - glow.parent.x)
        y: glow.pad + (self ? 0 : modelData.y - glow.parent.y)
        width: modelData.width
        height: modelData.height
        radius: modelData.radius
        topLeftRadius: modelData.topLeftRadius !== undefined ? modelData.topLeftRadius : modelData.radius
        topRightRadius: modelData.topRightRadius !== undefined ? modelData.topRightRadius : modelData.radius
        bottomLeftRadius: modelData.bottomLeftRadius !== undefined ? modelData.bottomLeftRadius : modelData.radius
        bottomRightRadius: modelData.bottomRightRadius !== undefined ? modelData.bottomRightRadius : modelData.radius
        color: "black"
      }
    }
  }

  MultiEffect {
    x: light.x; y: light.y; width: light.width; height: light.height
    source: light
    maskEnabled: true
    maskSource: cut
    maskInverted: true
  }
}
