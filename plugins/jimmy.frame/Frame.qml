import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "../jimmy.shared/Tokens.js" as Tokens

// The frame (Stage 28): one rounded glass hull around the desktop. It owns
// every reserve -- top 75, left 30, right 15, bottom 15 -- and draws the bands,
// the rounded inner opening and the camera notch as a hole. The bar and the
// left numbers are separate Top-layer drawings; nothing here takes the
// pointer. Fullscreen windows cover the hull; the reserves are ignored by
// fullscreen, so nothing has to hide.
Item {
  id: root

  property var shell: null

  readonly property var tokens: Commons.Color.shellValues
  function num(key, fallback) { return Tokens.num(tokens, key, fallback) }

  readonly property int frameTop: num("frame.top", 75)
  readonly property int frameLeft: num("frame.left", 30)
  readonly property int frameRight: num("frame.right", 15)
  readonly property int frameBottom: num("frame.bottom", 15)
  readonly property int outerRadius: num("frame.radius", 20)
  readonly property int innerRadius: num("frame.inner-radius", 16)
  readonly property int notchWidth: num("notch.width", 174)
  readonly property int notchHeight: num("notch.height", 32)

  // Frame fill: the theme accent mixed into the background glass. The mix is
  // a token (frame.tint), so a light accent tint reads as a frame on a dark
  // wallpaper without becoming a solid orange bar. The fill alpha stays the
  // launcher glass alpha; only the hue is tinted.
  readonly property real tint: num("frame.tint", 0.22)
  readonly property color glass: Util.alpha(
    Qt.tint(Commons.Color.background, Util.alpha(Commons.Color.accent, tint)),
    num("launcher.panel-background-alpha", 0.70))
  // Bevel (Stage 31): the opening's edge catches light on top and falls into
  // shadow at the bottom -- one stroke on the hull side of the edge, shaded
  // top to bottom: foreground highlight -> clear -> background shadow.
  // Alphas are tokens; 0 drops that side.
  readonly property color bevelLight: Util.alpha(Commons.Color.foreground, num("frame.bevel-light", 0.10))
  readonly property color bevelDark: Util.alpha(Commons.Color.background, num("frame.bevel-dark", 0.30))
  readonly property real bevelWidth: num("frame.bevel-width", 1)

  Variants {
    model: Quickshell.screens

    Scope {
      id: screenScope
      required property var modelData
      readonly property bool notched: String(modelData.name).indexOf("eDP") === 0

      // The hull: full screen on the bottom layer, click-through, so the
      // wallpaper shows in the opening and windows draw over the bands.
      PanelWindow {
        screen: screenScope.modelData
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        mask: Region {}
        WlrLayershell.namespace: "jimmy-frame"
        WlrLayershell.layer: WlrLayer.Bottom

        Canvas {
          id: hull
          anchors.fill: parent
          property color glass: root.glass
          property color bevelLight: root.bevelLight
          property color bevelDark: root.bevelDark
          property real bevelWidth: root.bevelWidth
          property int frameTop: root.frameTop
          property int frameLeft: root.frameLeft
          property int frameRight: root.frameRight
          property int frameBottom: root.frameBottom
          property int outerRadius: root.outerRadius
          property int innerRadius: root.innerRadius
          property int notchW: screenScope.notched ? root.notchWidth : 0
          property int notchH: screenScope.notched ? root.notchHeight : 0
          onGlassChanged: requestPaint()
          onBevelLightChanged: requestPaint()
          onBevelDarkChanged: requestPaint()
          onBevelWidthChanged: requestPaint()
          onFrameTopChanged: requestPaint()
          onFrameLeftChanged: requestPaint()
          onFrameRightChanged: requestPaint()
          onFrameBottomChanged: requestPaint()
          onOuterRadiusChanged: requestPaint()
          onInnerRadiusChanged: requestPaint()
          onNotchWChanged: requestPaint()
          onNotchHChanged: requestPaint()
          onWidthChanged: requestPaint()
          onHeightChanged: requestPaint()

          function rounded(ctx, x, y, w, h, r) {
            r = Math.max(0, Math.min(r, w / 2, h / 2))
            ctx.moveTo(x + r, y)
            ctx.lineTo(x + w - r, y)
            ctx.quadraticCurveTo(x + w, y, x + w, y + r)
            ctx.lineTo(x + w, y + h - r)
            ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h)
            ctx.lineTo(x + r, y + h)
            ctx.quadraticCurveTo(x, y + h, x, y + h - r)
            ctx.lineTo(x, y + r)
            ctx.quadraticCurveTo(x, y, x + r, y)
            ctx.closePath()
          }
          function rgba(c) {
            return "rgba(" + Math.round(c.r * 255) + "," + Math.round(c.g * 255) + ","
              + Math.round(c.b * 255) + "," + c.a.toFixed(3) + ")"
          }
          onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.beginPath()
            rounded(ctx, 0, 0, width, height, outerRadius)
            rounded(ctx, frameLeft, frameTop, width - frameLeft - frameRight,
              height - frameTop - frameBottom, innerRadius)
            if (notchW > 0 && notchH > 0) {
              var nx = Math.round((width - notchW) / 2)
              ctx.rect(nx, 0, notchW, notchH)
            }
            // QML's Context2D ignores fill("evenodd"); the rule is a property.
            // Odd-even makes the opening and the notch real holes.
            ctx.fillRule = Qt.OddEvenFill
            ctx.fillStyle = rgba(glass)
            ctx.fill()

            // The bevel sits just outside the opening, on the hull, so it
            // never draws over the desktop.
            if (bevelWidth > 0 && (bevelLight.a > 0 || bevelDark.a > 0)) {
              var b = bevelWidth / 2
              var top = frameTop - b, bottom = height - frameBottom + b
              var shade = ctx.createLinearGradient(0, top, 0, bottom)
              shade.addColorStop(0, rgba(bevelLight))
              shade.addColorStop(0.5, rgba(Qt.rgba(bevelLight.r, bevelLight.g, bevelLight.b, 0)))
              shade.addColorStop(0.5, rgba(Qt.rgba(bevelDark.r, bevelDark.g, bevelDark.b, 0)))
              shade.addColorStop(1, rgba(bevelDark))
              ctx.beginPath()
              rounded(ctx, frameLeft - b, top, width - frameLeft - frameRight + bevelWidth,
                bottom - top, innerRadius + b)
              ctx.strokeStyle = shade
              ctx.lineWidth = bevelWidth
              ctx.stroke()
            }
          }
        }
      }

      // The four reserves: one layer-shell surface per edge, each with a
      // single depth. Together they are the monitor's work-area inset. Empty
      // mask -- they never take the pointer.
      PanelWindow {
        screen: screenScope.modelData
        anchors { top: true; left: true; right: true }
        implicitHeight: 1
        color: "transparent"
        mask: Region {}
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: root.frameTop
        WlrLayershell.namespace: "jimmy-frame-top"
        WlrLayershell.layer: WlrLayer.Bottom
      }
      PanelWindow {
        screen: screenScope.modelData
        anchors { top: true; bottom: true; left: true }
        implicitWidth: 1
        color: "transparent"
        mask: Region {}
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: root.frameLeft
        WlrLayershell.namespace: "jimmy-frame-left"
        WlrLayershell.layer: WlrLayer.Bottom
      }
      PanelWindow {
        screen: screenScope.modelData
        anchors { top: true; bottom: true; right: true }
        implicitWidth: 1
        color: "transparent"
        mask: Region {}
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: root.frameRight
        WlrLayershell.namespace: "jimmy-frame-right"
        WlrLayershell.layer: WlrLayer.Bottom
      }
      PanelWindow {
        screen: screenScope.modelData
        anchors { bottom: true; left: true; right: true }
        implicitHeight: 1
        color: "transparent"
        mask: Region {}
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: root.frameBottom
        WlrLayershell.namespace: "jimmy-frame-bottom"
        WlrLayershell.layer: WlrLayer.Bottom
      }
    }
  }
}
