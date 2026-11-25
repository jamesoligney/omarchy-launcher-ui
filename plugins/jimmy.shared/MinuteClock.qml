import QtQuick

// A clock that wakes once a minute, on the minute. Armed from epoch
// milliseconds (like the stock WallClock) rather than Quickshell's
// SystemClock, which misbehaves in the hour repeated when daylight saving ends.
Timer {
  id: clock
  property date date: new Date()

  function arm() {
    interval = 60000 - (Date.now() % 60000) + 20
    restart()
  }

  onTriggered: {
    date = new Date()
    arm()
  }
  Component.onCompleted: arm()
}
