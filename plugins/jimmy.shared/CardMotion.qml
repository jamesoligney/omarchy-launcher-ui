import QtQuick
import qs.Commons as Commons
import "Tokens.js" as Tokens

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
  // Motion tokens ([motion] in shell.toml); fallbacks are the frozen values.
  readonly property var tokens: Commons.Color.shellValues
  readonly property real xFrom: Tokens.num(tokens, "motion.x-from", 0.80)
  readonly property real xOmega: Tokens.num(tokens, "motion.x-omega", 24)
  readonly property real xZeta: Tokens.num(tokens, "motion.x-zeta", 0.40)
  readonly property real yFrom: Tokens.num(tokens, "motion.y-from", 0.70)
  readonly property real yOmega: Tokens.num(tokens, "motion.y-omega", 20)
  readonly property real yZeta: Tokens.num(tokens, "motion.y-zeta", 0.46)
  readonly property int fadeMs: Tokens.num(tokens, "motion.fade-ms", 160)
  readonly property int settleMs: Tokens.num(tokens, "motion.settle-ms", 700)
  readonly property int closeMs: Tokens.num(tokens, "motion.close-ms", 100)
  // How long a closing layer stays up: the close plus a few ms of headroom.
  readonly property int closeHoldMs: closeMs + 15
  readonly property real closeScale: Tokens.num(tokens, "motion.close-scale", 0.97)
  readonly property real xScale: spring(t, xFrom, xOmega, xZeta)
  readonly property real yScale: spring(t, yFrom, yOmega, yZeta)

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
    NumberAnimation { target: motion; property: "t"; from: 0; to: motion.settleMs / 1000; duration: motion.settleMs }
    NumberAnimation { target: motion.card; property: "opacity"; to: 1.0; duration: motion.fadeMs; easing.type: Easing.OutCubic }
    NumberAnimation { target: motion.scrim; property: "opacity"; to: 1.0; duration: motion.fadeMs; easing.type: Easing.OutCubic }
  }

  ParallelAnimation {
    id: closeAnim
    NumberAnimation { target: motion.card; property: "scale"; to: motion.closeScale; duration: motion.closeMs; easing.type: Easing.InCubic }
    NumberAnimation { target: motion.card; property: "opacity"; to: 0.0; duration: motion.closeMs; easing.type: Easing.InCubic }
    NumberAnimation { target: motion.scrim; property: "opacity"; to: 0.0; duration: motion.closeMs; easing.type: Easing.InCubic }
  }
}
