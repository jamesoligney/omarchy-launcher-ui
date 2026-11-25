import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import "Tokens.js" as Tokens
import "BarGeometry.js" as BarGeometry

// One panel shell for everything that drops from an island: anchored under
// its island and attached to it, island glass, thin island outline, island
// radius, island padding, and the shared CardMotion in and out.
//
//   anchor    "right" | "left" island (the enum also reserves "top", "free")
//   keyboard  opened from a key: takes keyboard focus and an outside click
//             closes; opened by hover: no focus, clicks pass around it
//   opened    drive this; the layer outlives it for the close motion
// Content goes in as children; size the shell with contentWidth/Height.
PanelWindow {
  id: shell

  property bool opened: false
  property bool keyboard: false
  property string anchor: "right"
  property real contentWidth: 240
  property real contentHeight: 120
  property alias card: card
  // True while the pointer is anywhere over the card (padding included).
  readonly property bool hovered: cardHover.hovered
  default property alias content: holder.data
  signal dismissed()

  readonly property var tokens: Commons.Color.shellValues
  readonly property int pad: Tokens.num(tokens, "island.padding-x", 10)
  readonly property bool notched: screen ? String(screen.name).indexOf("eDP") === 0 : true
  readonly property var ears: BarGeometry.ears(width, notched, tokens)
  readonly property real islandBottom: Tokens.num(tokens, "island.gap", 3)
    + Tokens.num(tokens, "bar.height", 44) - 2 * Tokens.num(tokens, "island.gap", 3)

  property bool closing: false
  onOpenedChanged: {
    if (opened) {
      closing = false
      closeTimer.stop()
      motion.play()
    } else if (visible) {
      closing = true
      closeTimer.restart()
      motion.hide()
    }
  }
  Timer { id: closeTimer; interval: motion.closeHoldMs; onTriggered: shell.closing = false }

  visible: opened || closing
  anchors { top: true; left: true; right: true; bottom: true }
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.namespace: "jimmy-panel"
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.keyboardFocus: opened && keyboard ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
  // Hover-opened: only the card takes the pointer. Key-opened: the whole
  // screen does, so a click outside dismisses.
  mask: keyboard ? null : cardRegion
  Region { id: cardRegion; item: card }

  MouseArea {
    anchors.fill: parent
    enabled: shell.keyboard
    onClicked: shell.dismissed()
  }

  Item { id: noScrim }

  Rectangle {
    id: card
    width: shell.contentWidth + 2 * shell.pad
    height: shell.contentHeight + 2 * shell.pad
    x: Math.round((shell.anchor === "left" ? shell.ears.leftCenter : shell.ears.rightCenter) - width / 2)
    y: shell.islandBottom
    radius: Tokens.num(shell.tokens, "island.radius", 9)
    color: Util.alpha(Commons.Color.background, Tokens.num(shell.tokens, "launcher.panel-background-alpha", 0.70))
    border.width: 1
    border.color: Util.alpha(Commons.Color.accent, Tokens.num(shell.tokens, "launcher.panel-border-alpha", 0.16))
    transform: Scale {
      origin.x: card.width / 2
      origin.y: 0
      xScale: motion.xScale
      yScale: motion.yScale
    }
    // Clicks on the card stay on the card.
    MouseArea { anchors.fill: parent }
    HoverHandler { id: cardHover }
    Item {
      id: holder
      x: shell.pad
      y: shell.pad
      width: shell.contentWidth
      height: shell.contentHeight
    }
  }

  CardMotion { id: motion; card: card; scrim: noScrim }
}
