import QtQuick
import QtQuick.Shapes
import qs.Commons as Commons
import "../jimmy.shared/Tokens.js" as Tokens

// Electric sparks off the battery number while charging: now and then a
// small glowing particle leaves a random point anywhere on the edge of the
// number (uniform around the whole perimeter), drifts outward from that
// side, and fades; for its first moments it crackles, with a few tiny jagged
// filaments flickering round it. Random gap between battery.spark-min-ms and
// battery.spark-max-ms; a fixed pool of two, nothing created at runtime.
// Fills its parent (the number's Text).
Item {
  id: sparks
  property bool running: false
  // Per-side origin counts since start (status: proves the spread).
  property var sides: ({ top: 0, right: 0, bottom: 0, left: 0 })
  signal fired()
  anchors.fill: parent

  readonly property var tokens: Commons.Color.shellValues
  readonly property real size: Tokens.num(tokens, "battery.spark-size", 3)
  readonly property real glow: Tokens.num(tokens, "battery.spark-glow", 8)
  readonly property real drift: Tokens.num(tokens, "battery.spark-drift", 9)
  readonly property int lifeMs: Tokens.num(tokens, "battery.spark-ms", 650)
  readonly property int minMs: Tokens.num(tokens, "battery.spark-min-ms", 750)
  readonly property int maxMs: Tokens.num(tokens, "battery.spark-max-ms", 1500)
  readonly property color accent: Commons.Color.accent

  Timer {
    running: sparks.running
    repeat: true
    interval: sparks.minMs
    onTriggered: {
      interval = sparks.minMs + Math.random() * (sparks.maxMs - sparks.minMs)
      for (var i = 0; i < pool.count; i++) {
        var s = pool.itemAt(i)
        if (!s.flying) { s.launch(); sparks.fired(); return }
      }
    }
  }

  // A tiny jagged filament: from radius 2 outward, one kink.
  function filament() {
    var a = Math.random() * 2 * Math.PI, k = (Math.random() < 0.5 ? -1 : 1) * 0.6
    var p = function(r, t) { return Qt.point(Math.cos(t) * r, Math.sin(t) * r) }
    return [p(2, a), p(3.6, a + k), p(5.2 + Math.random() * 1.5, a - k * 0.3)]
  }

  Repeater {
    id: pool
    model: 2
    Item {
      id: spark
      readonly property bool flying: life.running
      width: 0
      height: 0
      opacity: 0
      property var f0: []
      property var f1: []
      property var f2: []

      function launch() {
        var text = sparks.parent
        // The number's ink box: its advance width, cap height about the
        // middle. Pick a point uniformly along the whole perimeter.
        var w = text.contentWidth, h = text.font.pixelSize * 0.72
        var top = text.height / 2 - h / 2 + 1
        var t = Math.random() * 2 * (w + h), x, y, n, side
        if (t < w) { x = t; y = top; n = -Math.PI / 2; side = "top" }
        else if ((t -= w) < h) { x = w; y = top + t; n = 0; side = "right" }
        else if ((t -= h) < w) { x = w - t; y = top + h; n = Math.PI / 2; side = "bottom" }
        else { t -= w; x = 0; y = top + h - t; n = Math.PI; side = "left" }
        var counts = sparks.sides; counts[side]++; sparks.sides = counts
        // Outward from that side, anywhere within ±60° of its normal.
        var a = n + (Math.random() * 2 - 1) * 1.05
        var d = sparks.drift * (0.7 + Math.random() * 0.6)
        moveX.from = x; moveX.to = x + Math.cos(a) * d
        moveY.from = y; moveY.to = y + Math.sin(a) * d
        f0 = sparks.filament(); f1 = sparks.filament(); f2 = sparks.filament()
        life.restart()
      }

      // Ember: a soft glow round a bright core.
      Rectangle {
        anchors.centerIn: parent
        width: sparks.glow; height: width; radius: width / 2
        color: Qt.rgba(sparks.accent.r, sparks.accent.g, sparks.accent.b, 0.28)
      }
      Rectangle {
        anchors.centerIn: parent
        width: sparks.size; height: width; radius: width / 2
        color: Qt.lighter(sparks.accent, 1.25)
      }
      // Lightning: tiny jagged filaments that crackle, then go.
      Shape {
        id: crackle
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
          strokeColor: sparks.accent
          strokeWidth: 1
          fillColor: "transparent"
          capStyle: ShapePath.RoundCap
          PathPolyline { path: spark.f0 }
          PathPolyline { path: spark.f1 }
          PathPolyline { path: spark.f2 }
        }
      }

      ParallelAnimation {
        id: life
        NumberAnimation { id: moveX; target: spark; property: "x"; duration: sparks.lifeMs; easing.type: Easing.OutQuad }
        NumberAnimation { id: moveY; target: spark; property: "y"; duration: sparks.lifeMs; easing.type: Easing.OutQuad }
        NumberAnimation { target: spark; property: "scale"; from: 1; to: 0.55; duration: sparks.lifeMs }
        SequentialAnimation {
          PropertyAction { target: spark; property: "opacity"; value: 1 }
          PauseAnimation { duration: sparks.lifeMs * 0.12 }
          NumberAnimation { target: spark; property: "opacity"; to: 0.45; duration: sparks.lifeMs * 0.06 }
          NumberAnimation { target: spark; property: "opacity"; to: 1; duration: sparks.lifeMs * 0.06 }
          NumberAnimation { target: spark; property: "opacity"; to: 0; duration: sparks.lifeMs * 0.76; easing.type: Easing.InQuad }
        }
        SequentialAnimation {
          PropertyAction { target: crackle; property: "opacity"; value: 1 }
          PauseAnimation { duration: sparks.lifeMs * 0.1 }
          PropertyAction { target: crackle; property: "opacity"; value: 0.2 }
          PauseAnimation { duration: sparks.lifeMs * 0.05 }
          PropertyAction { target: crackle; property: "opacity"; value: 1 }
          NumberAnimation { target: crackle; property: "opacity"; to: 0; duration: sparks.lifeMs * 0.2 }
        }
      }
    }
  }
}
