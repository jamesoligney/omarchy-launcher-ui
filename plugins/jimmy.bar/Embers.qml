import QtQuick
import qs.Commons as Commons
import "../jimmy.shared/Tokens.js" as Tokens

// Embers off the battery number while charging: now and then a small accent
// spark leaves a random point on the number, floats up and fades. Random gap
// between battery.ember-min-ms and battery.ember-max-ms; a small fixed pool,
// nothing created at runtime. Fills its parent (the number's Text).
Item {
  id: embers
  property bool running: false
  signal fired()
  anchors.fill: parent

  readonly property var tokens: Commons.Color.shellValues
  readonly property int size: Tokens.num(tokens, "battery.ember-size", 3)
  readonly property int rise: Tokens.num(tokens, "battery.ember-rise", 16)
  readonly property int lifeMs: Tokens.num(tokens, "battery.ember-ms", 1100)
  readonly property int minMs: Tokens.num(tokens, "battery.ember-min-ms", 750)
  readonly property int maxMs: Tokens.num(tokens, "battery.ember-max-ms", 1500)

  Timer {
    running: embers.running
    repeat: true
    interval: embers.minMs
    onTriggered: {
      interval = embers.minMs + Math.random() * (embers.maxMs - embers.minMs)
      for (var i = 0; i < pool.count; i++) {
        var e = pool.itemAt(i)
        if (!e.flying) { e.fly(); embers.fired(); return }
      }
    }
  }

  Repeater {
    id: pool
    model: 2
    Rectangle {
      id: spark
      readonly property bool flying: flight.running
      width: embers.size
      height: embers.size
      radius: embers.size / 2
      color: Commons.Color.accent
      opacity: 0
      function fly() {
        var text = embers.parent
        // Anywhere on the ink of the number: across its width, in the lower
        // two thirds of its cap height.
        x = Math.random() * Math.max(1, text.contentWidth - width)
        y = text.height / 2 - embers.size / 2 + (Math.random() - 0.2) * text.font.pixelSize * 0.4
        drift.to = x + (Math.random() - 0.5) * 6
        up.from = y
        up.to = y - embers.rise * (0.8 + Math.random() * 0.4)
        flight.restart()
      }
      ParallelAnimation {
        id: flight
        NumberAnimation { id: up; target: spark; property: "y"; duration: embers.lifeMs; easing.type: Easing.OutQuad }
        NumberAnimation { id: drift; target: spark; property: "x"; duration: embers.lifeMs; easing.type: Easing.InOutSine }
        NumberAnimation { target: spark; property: "opacity"; from: 0.9; to: 0; duration: embers.lifeMs; easing.type: Easing.InQuad }
        NumberAnimation { target: spark; property: "scale"; from: 1; to: 0.5; duration: embers.lifeMs }
      }
    }
  }
}
