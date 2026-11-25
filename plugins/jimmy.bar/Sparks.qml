import QtQuick
import QtQuick.Shapes
import qs.Commons as Commons
import "../jimmy.shared/Tokens.js" as Tokens

// Electric sparks off the battery number while charging: now and then a
// tiny jagged arc (sometimes forked) jumps off a random point on the number,
// flickers once and is gone. Random gap between battery.spark-min-ms and
// battery.spark-max-ms; a fixed pool of two, nothing created at runtime.
// Fills its parent (the number's Text).
Item {
  id: sparks
  property bool running: false
  signal fired()
  anchors.fill: parent

  readonly property var tokens: Commons.Color.shellValues
  readonly property real length: Tokens.num(tokens, "battery.spark-length", 12)
  readonly property real stroke: Tokens.num(tokens, "battery.spark-width", 1.2)
  readonly property int lifeMs: Tokens.num(tokens, "battery.spark-ms", 300)
  readonly property int minMs: Tokens.num(tokens, "battery.spark-min-ms", 750)
  readonly property int maxMs: Tokens.num(tokens, "battery.spark-max-ms", 1500)

  Timer {
    running: sparks.running
    repeat: true
    interval: sparks.minMs
    onTriggered: {
      interval = sparks.minMs + Math.random() * (sparks.maxMs - sparks.minMs)
      for (var i = 0; i < pool.count; i++) {
        var s = pool.itemAt(i)
        if (!s.flying) { s.strike(); sparks.fired(); return }
      }
    }
  }

  // A jagged run of `steps` segments from (x, y) along angle a, jitter j.
  function bolt(x, y, a, len, steps, j) {
    var dx = Math.cos(a), dy = Math.sin(a), pts = [Qt.point(x, y)]
    for (var i = 1; i <= steps; i++) {
      var t = len * i / steps, k = i < steps ? (Math.random() * 2 - 1) * j : 0
      pts.push(Qt.point(x + dx * t - dy * k, y + dy * t + dx * k))
    }
    return pts
  }

  Repeater {
    id: pool
    model: 2
    Shape {
      id: spark
      readonly property bool flying: flicker.running
      anchors.fill: parent
      opacity: 0
      preferredRendererType: Shape.CurveRenderer
      property var main: []
      property var fork: []
      function strike() {
        var text = sparks.parent
        // Off the number's edge, leaping outward so the arc clears the
        // glyphs: mostly from the top of the figures, now and then the side.
        var cap = text.font.pixelSize * 0.36, x, y, a
        if (Math.random() < 0.75) {
          x = Math.random() * text.contentWidth
          y = text.height / 2 - cap
          a = -Math.PI / 2 + (Math.random() * 2 - 1) * 0.9
        } else {
          x = text.contentWidth
          y = text.height / 2 + (Math.random() * 2 - 1) * cap
          a = (Math.random() * 2 - 1) * 0.9 - 0.4
        }
        var len = sparks.length * (0.8 + Math.random() * 0.4)
        main = sparks.bolt(x, y, a, len, 3, len * 0.3)
        var p = main[1]
        fork = Math.random() < 0.5
          ? sparks.bolt(p.x, p.y, a + (Math.random() < 0.5 ? -0.7 : 0.7), len * 0.45, 2, len * 0.15)
          : []
        flicker.restart()
      }
      // Glow under, core over: same paths.
      ShapePath {
        strokeColor: Qt.rgba(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 0.3)
        strokeWidth: sparks.stroke * 3
        fillColor: "transparent"
        capStyle: ShapePath.RoundCap
        joinStyle: ShapePath.RoundJoin
        PathPolyline { path: spark.main }
      }
      ShapePath {
        strokeColor: Commons.Color.accent
        strokeWidth: sparks.stroke
        fillColor: "transparent"
        capStyle: ShapePath.RoundCap
        joinStyle: ShapePath.MiterJoin
        PathPolyline { path: spark.main }
        PathMove { x: spark.fork.length ? spark.fork[0].x : 0; y: spark.fork.length ? spark.fork[0].y : 0 }
        PathPolyline { path: spark.fork }
      }
      // Strike, one flicker, gone.
      SequentialAnimation {
        id: flicker
        PropertyAction { target: spark; property: "opacity"; value: 1 }
        PauseAnimation { duration: sparks.lifeMs * 0.18 }
        NumberAnimation { target: spark; property: "opacity"; to: 0.25; duration: sparks.lifeMs * 0.1 }
        NumberAnimation { target: spark; property: "opacity"; to: 0.9; duration: sparks.lifeMs * 0.1 }
        NumberAnimation { target: spark; property: "opacity"; to: 0; duration: sparks.lifeMs * 0.62; easing.type: Easing.OutQuad }
      }
    }
  }
}
