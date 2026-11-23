import QtQuick

// The launcher's card motion, shared by the launcher and both pickers.
// Open: exact damped oscillators (squash and stretch: X leads, Y lags and
// overshoots later), evaluated from elapsed time. 160ms fade. Close: 100ms.
// The card applies xScale/yScale through a Scale transform and keeps
// card.scale for the close.
Item {
  id: motion
  property Item card
  property Item scrim
  property real t: 0
  readonly property real xScale: spring(t, 0.80, 24, 0.40)
  readonly property real yScale: spring(t, 0.70, 20, 0.46)

  function spring(t, from, w, z) {
    var wd = w * Math.sqrt(1 - z * z)
    return 1 - (1 - from) * Math.exp(-z * w * t) * (Math.cos(wd * t) + z * w / wd * Math.sin(wd * t))
  }

  function stop() { openAnim.stop(); closeAnim.stop() }

  function play() {
    stop()
    card.scale = 1
    t = 0
    card.opacity = 0
    scrim.opacity = 0
    openAnim.start()
  }

  function hide() {
    openAnim.stop()
    closeAnim.start()
  }

  ParallelAnimation {
    id: openAnim
    NumberAnimation { target: motion; property: "t"; from: 0; to: 0.7; duration: 700 }
    NumberAnimation { target: motion.card; property: "opacity"; to: 1.0; duration: 160; easing.type: Easing.OutCubic }
    NumberAnimation { target: motion.scrim; property: "opacity"; to: 1.0; duration: 160; easing.type: Easing.OutCubic }
  }

  ParallelAnimation {
    id: closeAnim
    NumberAnimation { target: motion.card; property: "scale"; to: 0.97; duration: 100; easing.type: Easing.InCubic }
    NumberAnimation { target: motion.card; property: "opacity"; to: 0.0; duration: 100; easing.type: Easing.InCubic }
    NumberAnimation { target: motion.scrim; property: "opacity"; to: 0.0; duration: 100; easing.type: Easing.InCubic }
  }
}
