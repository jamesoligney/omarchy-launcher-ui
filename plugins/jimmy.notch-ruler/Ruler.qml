import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "../jimmy.shared/Tokens.js" as Tokens

// Stage 1 calibration. The notch's pixels exist in the framebuffer but not on
// the glass, so no screenshot can measure it: only an eye on the real display
// can. Segments under the cutout simply disappear. Read the first number that
// is fully visible on each side of the centre: that is the notch half-width in
// logical px. Corner arcs show which radius matches the rounded top corners.
// Esc or a click closes. Summon: omarchy-shell shell summon jimmy.notch-ruler
Item {
  id: root

  property var shell: null
  property var manifest: null
  property bool opened: false

  readonly property var tokens: Commons.Color.shellValues
  readonly property real notchWidth: Tokens.num(tokens, "notch.width", 174)
  readonly property real notchHeight: Tokens.num(tokens, "notch.height", 32)
  readonly property real notchInset: Tokens.num(tokens, "notch.inset", 10)
  readonly property real cornerInset: Tokens.num(tokens, "notch.corner-inset", 18)

  function open(payloadJson) { root.opened = true; Qt.callLater(function() { keys.forceActiveFocus() }) }
  function close() { root.opened = false }
  function dismiss() {
    root.opened = false
    if (root.shell && typeof root.shell.hide === "function") root.shell.hide((root.manifest && root.manifest.id) || "jimmy.notch-ruler")
  }

  OverlayWindow {
    id: panel
    shown: root.opened
    WlrLayershell.namespace: "jimmy-notch-ruler"

    Rectangle { anchors.fill: parent; color: Qt.rgba(0, 0, 0, 0.55) }

    MouseArea { anchors.fill: parent; onClicked: root.dismiss() }

    Item {
      id: keys
      anchors.fill: parent
      focus: true
      Keys.onEscapePressed: root.dismiss()
    }

    Canvas {
      id: ruler
      anchors.fill: parent
      readonly property color ink: Commons.Color.foreground
      readonly property color hot: Commons.Color.accent
      onWidthChanged: requestPaint()
      onInkChanged: requestPaint()
      Connections {
        target: root
        function onNotchWidthChanged() { ruler.requestPaint() }
        function onNotchInsetChanged() { ruler.requestPaint() }
        function onCornerInsetChanged() { ruler.requestPaint() }
      }

      onPaint: {
        var ctx = getContext("2d")
        var w = width, cx = w / 2, band = root.notchHeight
        ctx.reset()

        // Alternating 10 px segments across the notch rows: the ones under
        // the cutout vanish on the real display.
        for (var d = 0; d < cx; d += 10) {
          var shade = (d / 10) % 2 === 0 ? hot : ink
          ctx.fillStyle = shade
          ctx.fillRect(cx + d, 0, 10, band)
          ctx.fillRect(cx - d - 10, 0, 10, band)
        }

        // Ticks below the band: every 2 px short, every 10 px long, labelled
        // with the distance from the centre.
        ctx.fillStyle = ink
        ctx.font = "10px monospace"
        ctx.textAlign = "center"
        for (var t = 0; t <= cx; t += 2) {
          var long = t % 10 === 0
          var h = long ? 10 : 4
          ctx.fillRect(cx + t, band, 1, h)
          ctx.fillRect(cx - t, band, 1, h)
          if (t % 20 === 0) {
            ctx.fillText(String(t), cx + t, band + 22)
            if (t > 0) ctx.fillText(String(t), cx - t, band + 22)
          }
        }

        // Current tokens: notch edges (solid) and island start (dashed).
        var half = root.notchWidth / 2
        ctx.fillStyle = hot
        ctx.fillRect(cx - half, band, 1, 44)
        ctx.fillRect(cx + half, band, 1, 44)
        var edge = half + root.notchInset
        for (var y = band; y < band + 44; y += 4) {
          ctx.fillRect(cx - edge, y, 1, 2)
          ctx.fillRect(cx + edge, y, 1, 2)
        }

        // Corner radius guides, both top corners.
        ctx.strokeStyle = ink
        ctx.lineWidth = 1
        var radii = [8, 12, 16, 20, 24]
        for (var i = 0; i < radii.length; i++) {
          var r = radii[i]
          ctx.beginPath(); ctx.arc(r, r, r, Math.PI, 1.5 * Math.PI); ctx.stroke()
          ctx.beginPath(); ctx.arc(w - r, r, r, 1.5 * Math.PI, 2 * Math.PI); ctx.stroke()
        }
        ctx.fillStyle = hot
        ctx.fillRect(root.cornerInset, band, 1, 44)
        ctx.fillRect(w - root.cornerInset, band, 1, 44)
      }
    }

    Column {
      anchors.horizontalCenter: parent.horizontalCenter
      y: root.notchHeight + 64
      spacing: 6
      Repeater {
        model: [
          "Notch: read the first fully visible number on each side of the centre = half-width (logical px).",
          "Solid accent lines: notch.width = " + root.notchWidth + "  ·  dashed: + notch.inset " + root.notchInset,
          "Corners: which arc matches the glass edge?  ·  accent line: notch.corner-inset " + root.cornerInset,
          "Esc closes"
        ]
        Text {
          required property string modelData
          anchors.horizontalCenter: parent.horizontalCenter
          text: modelData
          color: Commons.Color.foreground
          font.family: Style.font.family
          font.pixelSize: Style.font.body
        }
      }
    }
  }
}
