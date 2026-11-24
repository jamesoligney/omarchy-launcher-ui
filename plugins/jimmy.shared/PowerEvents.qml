import QtQuick
import Quickshell.Services.UPower

// One signal for "something about the battery or power source changed", driven
// by UPower's own property signals. Replaces a timer that re-read the battery
// every few seconds: nothing runs between changes, and a change lands at once.
// Shared so the bar's power widgets and services read power the same way.
Item {
  id: root

  signal changed()

  Connections {
    target: UPower
    function onOnBatteryChanged() { root.changed() }
  }

  // The display device can come and go (hot-plug), so this follows whichever is current.
  Connections {
    target: UPower.displayDevice
    function onPercentageChanged() { root.changed() }
    function onStateChanged() { root.changed() }
  }
}
