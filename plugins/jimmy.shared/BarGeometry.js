.pragma library
// Where the two ears are, for the bar and for anything anchored to an island
// (toasts, panels). An ear is the strip between a screen edge and the notch;
// each island is centred in its ear and grows both ways from that centre.
// tokens: Commons.Color.shellValues. notched: the screen has the cutout.
function num(t, key, fallback) {
  var v = t ? Number(t[key]) : NaN
  return isFinite(v) ? v : fallback
}

function ears(screenWidth, notched, t) {
  var cutout = notched ? num(t, "notch.width", 174) : 0
  var inset = notched ? num(t, "notch.inset", 10) : 0
  var corner = num(t, "notch.corner-inset", 18)
  var half = screenWidth / 2
  var earWidth = half - cutout / 2
  var room = Math.max(0, earWidth - 2 * Math.max(inset, corner))
  return {
    leftCenter: earWidth / 2,
    rightCenter: screenWidth - earWidth / 2,
    maxIslandWidth: room
  }
}
