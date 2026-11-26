pragma Singleton
import QtQuick

// The islands' live geometry, published by jimmy.bar for everything that
// hangs from them (toasts, notifications, the reminder card, panels), so
// they centre under the whole island they belong to: on the right, the main
// island and the status island joined to it. Screen x; -1 until the bar has
// laid out, and callers then fall back to the ear centres. One internal
// monitor, so one value per side.
QtObject {
  property real rightCenter: -1
  property real leftCenter: -1

  function right(fallback) { return rightCenter >= 0 ? rightCenter : fallback }
  function left(fallback) { return leftCenter >= 0 ? leftCenter : fallback }
}
