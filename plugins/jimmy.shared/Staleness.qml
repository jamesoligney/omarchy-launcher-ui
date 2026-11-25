import QtQuick

// Three-state freshness for remote data (weather, agents, updates):
//   fresh   — updated within 2 x interval
//   stale   — older than that: dim, "updated N min ago"
//   offline — the last fetch failed, or older than 4 x interval: dim + mark,
//             the last value stays visible.
// Re-evaluates on its own minute tick; no polling of the source.
QtObject {
  id: staleness
  property real updatedAt: 0       // ms epoch of the last good data; 0 = none yet
  property real intervalMs: 15 * 60000
  property bool failing: false
  property date now: new Date()

  readonly property real ageMs: updatedAt > 0 ? Math.max(0, now.getTime() - updatedAt) : -1
  readonly property string state: updatedAt <= 0 ? (failing ? "offline" : "fresh")
    : (failing || ageMs > 4 * intervalMs) ? "offline"
    : ageMs > 2 * intervalMs ? "stale" : "fresh"
  readonly property string ageText: ageMs < 0 ? "not updated yet"
    : ageMs < 60000 ? "updated just now"
    : "updated " + Math.round(ageMs / 60000) + " min ago"

  property Timer tick: Timer {
    interval: 60000; running: true; repeat: true
    onTriggered: staleness.now = new Date()
  }
}
