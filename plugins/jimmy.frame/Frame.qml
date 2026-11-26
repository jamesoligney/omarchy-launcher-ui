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
  // Bevel (Stage 34): the hull surface is high at the screen edge, ridges a
  // quarter of the way in and slopes gently down to the opening. High catches
  // light (foreground: the glass lit, never a coloured molding), low falls to
  // background. frame.bevel-light / -dark are how far the ridge and the foot
  // move toward them; the narrow bands run at frame.bevel-sides of that, so
  // the frame reads from the top.
  readonly property color bevelLight: Commons.Color.foreground
  readonly property color bevelDark: Commons.Color.background
  readonly property real bevelLightMix: num("frame.bevel-light", 0.15)
  readonly property real bevelDarkMix: num("frame.bevel-dark", 0.30)
  readonly property real bevelSides: num("frame.bevel-sides", 0.5)
  // The hull's boundary: one crisp 1px accent line around the opening, on
  // the hull side (frame.edge = alpha, 0 drops it).
  readonly property color edge: Util.alpha(Commons.Color.accent, num("frame.edge", 0.85))

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
          property real bevelLightMix: root.bevelLightMix
          property real bevelDarkMix: root.bevelDarkMix
          property real bevelSides: root.bevelSides
          property color edge: root.edge
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
          onBevelLightMixChanged: requestPaint()
          onBevelDarkMixChanged: requestPaint()
          onBevelSidesChanged: requestPaint()
          onEdgeChanged: requestPaint()
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
          // Surface height across a band, t = 0 at the screen edge, 1 at the
          // opening: 0.8 at the edge, ridge 1.0 at t 0.25, a long slope to 0
          // at the opening. Returned as a shade in -1..1 (0 = flat glass).
          function shade(t) {
            var h = t <= 0.25 ? 0.8 + 0.8 * t : (1 - t) / 0.75
            return 2 * h - 1
          }
          function tone(s, k) {
            return rgba(s >= 0 ? mix(glass, bevelLight, s * bevelLightMix * k)
                               : mix(glass, bevelDark, -s * bevelDarkMix * k))
          }
          function mix(a, b, k) {
            return Qt.rgba(a.r + (b.r - a.r) * k, a.g + (b.g - a.g) * k,
              a.b + (b.b - a.b) * k, a.a)
          }
          onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var iw = width - frameLeft - frameRight, ih = height - frameTop - frameBottom
            var steps = Math.max(frameTop, frameLeft, frameRight, frameBottom)
            // Rings from the outer edge inward, each filling everything from
            // its rounded edge to the opening. "copy" replaces what the
            // previous ring left, so rings meet without seams or stacked alpha.
            ctx.fillRule = Qt.OddEvenFill
            ctx.globalCompositeOperation = "copy"
            for (var k = 0; k < steps; k++) {
              var t = k / steps, s = shade((k + 0.5) / steps)
              ctx.beginPath()
              rounded(ctx, frameLeft * t, frameTop * t,
                width - (frameLeft + frameRight) * t, height - (frameTop + frameBottom) * t,
                outerRadius + (innerRadius - outerRadius) * t)
              rounded(ctx, frameLeft, frameTop, iw, ih, innerRadius)
              // Full strength across the top band, easing to the side
              // strength through the opening's top corners.
              var g = ctx.createLinearGradient(0, frameTop, 0, frameTop + 2 * innerRadius)
              g.addColorStop(0, tone(s, 1))
              g.addColorStop(1, tone(s, bevelSides))
              ctx.fillStyle = g
              ctx.fill()
            }
            ctx.globalCompositeOperation = "source-over"
            if (edge.a > 0) {
              ctx.beginPath()
              rounded(ctx, frameLeft - 0.5, frameTop - 0.5, iw + 1, ih + 1, innerRadius + 0.5)
              ctx.strokeStyle = rgba(edge)
              ctx.lineWidth = 1
              ctx.stroke()
            }
            // The notch is a hole through the top band.
            if (notchW > 0 && notchH > 0)
              ctx.clearRect(Math.round((width - notchW) / 2), 0, notchW, notchH)
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
