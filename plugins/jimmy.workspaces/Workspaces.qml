import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons
import qs.Ui

// Workspace indicators, AeroSpace style: the focused workspace is lifted out of
// the row and parked at the front in a filled block, a separator follows, and
// behind it come the other occupied workspaces in ascending order. An empty
// workspace is not drawn at all, so the row is only ever as long as the work
// that is actually open, and the one you are on never moves.
//
// The delegates are never rebuilt as that order changes: every workspace this
// monitor can show keeps an item of its own, which slides to its new place and
// fades away when its workspace empties. Rebuilding would teleport them, and
// the whole point of this row is that you can follow it with your eye.
//
// Settings, in this widget's entry in ~/.config/omarchy/shell.json:
//   animate      bool    true     slide the numbers to their new places
//   separator    string  "line"   "line", "pipe" or "none"
//   urgentPulse  bool    true     breathe a workspace that wants attention
BarWidget {
  id: root
  moduleName: "jimmy.workspaces"

  readonly property bool animate: root.setting("animate", true) !== false
  readonly property bool urgentPulse: root.setting("urgentPulse", true) !== false
  readonly property string separatorStyle: String(root.setting("separator", "line"))
  // Stock cycles the focused workspace's layout when its number is clicked.
  // The glyph that showed which layout you were in is gone from this row, so
  // that click would rearrange the windows and say nothing about why. Off
  // unless "blockClick" asks for it; Super + L does the same thing.
  readonly property string blockClick: String(root.setting("blockClick", "none"))

  // Every monitor has workspaces 1-10 of its own, which Hyprland numbers in a
  // block of ten per monitor: 1-10, 11-20, and so on (see
  // default/hypr/monitor-workspaces.lua). Each bar shows its own monitor's
  // block, numbered 1-10, and the one that monitor shows.
  readonly property int slots: 10

  readonly property var monitor: {
    var window = root.QsWindow.window
    var screen = window ? window.screen : null
    return screen ? Hyprland.monitorFor(screen) : Hyprland.focusedMonitor
  }
  readonly property string monitorName: root.monitor ? root.monitor.name : ""

  // Connector -> block, from the file Hyprland keeps them in.
  property var blocks: ({})

  function readBlocks(text) {
    var next = {}
    var lines = String(text || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var fields = lines[i].split("\t")
      if (fields.length >= 3 && fields[1] !== "") next[fields[1]] = parseInt(fields[0], 10)
    }
    root.blocks = next
  }

  FileView {
    path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/omarchy/monitor-workspaces"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.readBlocks(text())
    onLoadFailed: root.readBlocks("")
  }

  function blockOf(id) { return Math.floor((id - 1) / root.slots) }
  function slotOf(id) { return (id - 1) % root.slots + 1 }

  readonly property int activeId: root.monitor && root.monitor.activeWorkspace
    ? root.monitor.activeWorkspace.id : -1

  // Until Hyprland has written the file, the workspace a monitor shows is in
  // its own block.
  readonly property int block: {
    var block = root.blocks[root.monitorName]
    if (block !== undefined) return block
    return root.activeId > 0 ? root.blockOf(root.activeId) : 0
  }

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }
    return null
  }

  function occupied(id) {
    var workspace = root.workspaceById(id)
    return workspace !== null && workspace.toplevels.values.length > 0
  }

  // ---- the stable set of items
  //
  // Every workspace this monitor can show: its own block of ten, plus any
  // visiting from a monitor that was unplugged. Held as a string and only
  // turned back into a model when it actually changes, so the Repeater keeps
  // its items — and their positions to animate from — across a focus change.
  function candidateIds() {
    var base = root.block * root.slots
    var ids = []
    for (var slot = 1; slot <= root.slots; slot++) ids.push(base + slot)

    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id <= 0 || ids.indexOf(id) !== -1) continue
      if (values[i].monitor && values[i].monitor.name === root.monitorName) ids.push(id)
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  readonly property string modelKey: root.candidateIds().join(",")
  property var modelIds: []
  onModelKeyChanged: root.modelIds = root.modelKey === "" ? [] : root.modelKey.split(",").map(Number)
  Component.onCompleted: root.modelIds = root.candidateIds()

  // ---- the order on the bar: focused first, then whatever else is occupied
  readonly property var order: {
    var out = []
    if (root.activeId > 0) out.push(root.activeId)
    var ids = root.modelIds
    for (var i = 0; i < ids.length; i++) {
      if (ids[i] === root.activeId) continue
      if (root.occupied(ids[i])) out.push(ids[i])
    }
    return out
  }
  readonly property bool hasRest: root.order.length > 1

  // ---- urgency
  //
  // Hyprland names the window, not its workspace, so the address is looked up
  // among the toplevels. A workspace stops being urgent once it is looked at.
  property var urgentMap: ({})
  property string pendingUrgent: ""

  function normalizeAddress(value) {
    var text = String(value === undefined || value === null ? "" : value).trim().toLowerCase()
    return text.indexOf("0x") === 0 ? text.substring(2) : text
  }

  function workspaceForAddress(address) {
    var target = root.normalizeAddress(address)
    if (target === "") return -1
    var tops = Hyprland.toplevels.values
    for (var i = 0; i < tops.length; i++) {
      if (root.normalizeAddress(tops[i].address) !== target) continue
      var workspace = tops[i].workspace
      return workspace ? workspace.id : -1
    }
    return -1
  }

  function markUrgent(address) {
    var id = root.workspaceForAddress(address)
    if (id <= 0) {
      // The window may be newer than the toplevel list; ask, then try once more.
      if (root.pendingUrgent !== "") return
      root.pendingUrgent = String(address)
      Hyprland.refreshToplevels()
      Qt.callLater(function() {
        var pending = root.pendingUrgent
        root.pendingUrgent = ""
        if (pending !== "") root.markUrgent(pending)
      })
      return
    }
    if (id === root.activeId || root.urgentMap[id] === true) return
    var next = {}
    for (var key in root.urgentMap) next[key] = true
    next[id] = true
    root.urgentMap = next
  }

  function clearUrgent(id) {
    if (root.urgentMap[id] !== true) return
    var next = {}
    for (var key in root.urgentMap) {
      if (Number(key) !== id) next[key] = true
    }
    root.urgentMap = next
  }

  function isUrgent(id) { return root.urgentMap[id] === true }

  onActiveIdChanged: root.clearUrgent(root.activeId)

  // ---- clicking and scrolling, as the stock widget does it
  function dispatch(expression) {
    if (root.bar) root.bar.run("hyprctl dispatch " + Util.shellQuote(expression))
  }

  function focusWorkspace(id) {
    if (root.blockOf(id) === root.block) {
      root.dispatch("o.workspaces.focus(" + root.slotOf(id) + ", \"" + root.monitorName + "\")")
    } else {
      root.dispatch("hl.dsp.focus({ workspace = \"" + id + "\" })")
    }
  }

  // The layout commands act on the focused workspace, so a click on another
  // monitor's bar focuses that monitor first.
  function cycleLayout() {
    if (!root.bar) return
    var command = "omarchy-hyprland-workspace-layout-toggle"
    if (root.monitor && !root.monitor.focused) {
      command = "hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ monitor = \"" + root.monitorName + "\" })") + " >/dev/null && " + command
    }
    root.bar.run(command)
  }

  // A wheel notch moves one entry along the row, and a touchpad adds up its
  // smaller deltas until they make a notch's worth. The row it walks is the
  // one on screen, so scrolling never lands on an empty workspace.
  property real wheelAccumulator: 0

  function scrollWorkspaces(delta) {
    var wheel = Util.wheelSteps(root.wheelAccumulator, delta)
    root.wheelAccumulator = wheel.remainder
    if (wheel.steps === 0) return

    var ids = root.order.slice()
    ids.sort(function(left, right) { return left - right })
    var index = ids.indexOf(root.activeId)
    if (index === -1) return
    var target = ids[Util.clamp(index - wheel.steps, 0, ids.length - 1)]
    if (target !== ids[index]) root.focusWorkspace(target)
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      var name = event ? String(event.name) : ""
      if (name === "urgent") {
        root.markUrgent(event && event.data !== undefined ? event.data : "")
        return
      }
      // Quickshell credits every workspace switch to the focused monitor, as
      // the event doesn't say which one switched, and misses the workspace a
      // monitor falls back to when its own is moved away. Moving workspaces
      // between monitors switches the others, so ask Hyprland for the truth.
      var switched = name === "workspacev2" && root.monitor !== null && root.monitor.focused
      if (switched || name === "moveworkspacev2" || name === "changeworkspaceid") {
        Hyprland.refreshMonitors()
        Hyprland.refreshWorkspaces()
      }
    }
  }

  // ---- geometry
  //
  // Each entry keeps the stock slot size, so this row lines up with the rest
  // of the bar. Positions are worked out here rather than by a layout: a
  // layout would re-place its children instantly, and these slide.
  readonly property real slotLength: root.vertical ? root.barSize : Style.space(20)
  readonly property real gap: root.vertical ? Style.space(2) : Style.space(1)
  readonly property real separatorLength: root.separatorStyle === "none" ? 0 : Style.space(7)
  // The block is wider than a bare number, so the separator needs more air
  // around it than the gap that sets two numbers apart.
  readonly property real separatorPad: root.separatorStyle === "none" ? root.gap : Style.space(4)
  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)
  readonly property real restOrigin: root.slotLength + root.separatorPad * 2 + root.separatorLength

  function offsetFor(position) {
    if (position <= 0) return 0
    return root.restOrigin + (position - 1) * (root.slotLength + root.gap)
  }

  readonly property real contentLength: root.order.length === 0 ? 0
    : root.order.length === 1 ? root.slotLength
    : root.offsetFor(root.order.length - 1) + root.slotLength

  implicitWidth: root.vertical ? root.barSize : root.contentLength + root.trailingGap
  implicitHeight: root.vertical ? root.contentLength : root.barSize

  Behavior on implicitWidth {
    enabled: root.animate && !root.vertical && !Style.reduceMotion
    NumberAnimation { duration: Style.duration(260); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
  }
  Behavior on implicitHeight {
    enabled: root.animate && root.vertical && !Style.reduceMotion
    NumberAnimation { duration: Style.duration(260); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
  }

  // The block takes the theme's own highlight (Matte Black's accent is the
  // orange on the window borders), which leaves the theme's red to mean
  // urgent and nothing else. "highlight": "bar" in the settings takes the
  // bar's active colour instead, which is that red.
  readonly property string highlightSource: String(root.setting("highlight", "accent"))
  readonly property color highlight: root.highlightSource === "bar"
    ? (root.bar ? root.bar.urgent : Color.bar.active)
    : Color.accent
  readonly property color urgentColor: root.bar ? root.bar.urgent : Color.urgent
  readonly property color onHighlight: Color.bar.background
  readonly property color plain: root.bar ? root.bar.barForeground : Color.foreground

  // ---- the separator
  Item {
    id: separator
    width: root.vertical ? root.barSize : root.separatorLength
    height: root.vertical ? root.separatorLength : root.barSize
    x: root.vertical ? 0 : root.slotLength + root.separatorPad
    y: root.vertical ? root.slotLength + root.separatorPad : 0
    opacity: root.hasRest && root.separatorStyle !== "none" ? 1 : 0
    visible: opacity > 0.01

    Behavior on opacity {
      enabled: root.animate && !Style.reduceMotion
      NumberAnimation { duration: Style.duration(160); easing.type: Easing.OutCubic }
    }

    Rectangle {
      visible: root.separatorStyle !== "pipe"
      anchors.centerIn: parent
      width: root.vertical ? Math.round(parent.width * 0.4) : Math.max(1, Style.space(1.5))
      height: root.vertical ? Math.max(1, Style.space(1.5)) : Math.round(parent.height * 0.42)
      radius: width / 2
      color: root.plain
      opacity: 0.35
    }

    Text {
      visible: root.separatorStyle === "pipe"
      anchors.centerIn: parent
      textFormat: Text.PlainText
      text: "|"
      color: root.plain
      opacity: 0.45
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.body
      renderType: Text.NativeRendering
    }
  }

  // ---- the workspaces
  Repeater {
    model: root.modelIds

    Item {
      id: slot
      required property int modelData

      readonly property int position: root.order.indexOf(modelData)
      readonly property bool shown: position >= 0
      readonly property bool focused: modelData === root.activeId
      readonly property bool urgent: !focused && root.isUrgent(modelData)
      // On its way out it keeps its last place rather than flying to the end.
      property real resting: 0
      readonly property real offset: shown ? root.offsetFor(position) : resting
      onOffsetChanged: if (shown) resting = offset

      width: root.vertical ? root.barSize : root.slotLength
      height: root.vertical ? root.slotLength : root.barSize
      x: root.vertical ? 0 : offset
      y: root.vertical ? offset : 0
      z: focused ? 2 : 1
      opacity: shown ? 1 : 0
      scale: shown ? 1 : 0.72
      visible: opacity > 0.01

      // The slide. A touch of overshoot so the row settles with some life in
      // it, which is as far as Omarchy's motion rules bend.
      Behavior on x {
        enabled: root.animate && !root.vertical && !Style.reduceMotion
        NumberAnimation { duration: Style.duration(280); easing.type: Easing.OutBack; easing.overshoot: 1.1 }
      }
      Behavior on y {
        enabled: root.animate && root.vertical && !Style.reduceMotion
        NumberAnimation { duration: Style.duration(280); easing.type: Easing.OutBack; easing.overshoot: 1.1 }
      }
      Behavior on opacity {
        enabled: root.animate && !Style.reduceMotion
        NumberAnimation { duration: Style.duration(170); easing.type: Easing.OutCubic }
      }
      Behavior on scale {
        enabled: root.animate && !Style.reduceMotion
        NumberAnimation { duration: Style.duration(220); easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut }
      }

      // The block behind the focused number.
      Rectangle {
        anchors.centerIn: parent
        width: Math.round(parent.width)
        height: Math.round(Math.min(parent.width, parent.height) - Style.space(2))
        // A block, not a capsule: soft corners, but corners.
        radius: Math.round(Math.min(height * 0.3, Style.cornerRadius > 0 ? Style.cornerRadius : height * 0.3))
        color: root.highlight
        opacity: slot.focused ? 1 : 0
        scale: slot.focused ? 1 : 0.86

        Behavior on opacity {
          enabled: root.animate && !Style.reduceMotion
          NumberAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic }
        }
        Behavior on scale {
          enabled: root.animate && !Style.reduceMotion
          NumberAnimation { duration: Style.duration(240); easing.type: Easing.OutBack; easing.overshoot: 1.2 }
        }
      }

      // Breathing, for a workspace whose window wants you.
      Item {
        id: pulse
        anchors.fill: parent

        SequentialAnimation on opacity {
          running: slot.urgent && root.urgentPulse && !Style.reduceMotion
          loops: Animation.Infinite
          alwaysRunToEnd: true
          NumberAnimation { from: 1.0; to: 0.4; duration: Style.duration(760); easing.type: Easing.InOutSine }
          NumberAnimation { from: 0.4; to: 1.0; duration: Style.duration(760); easing.type: Easing.InOutSine }
          onRunningChanged: if (!running) pulse.opacity = 1
        }

        WidgetButton {
          anchors.fill: parent
          bar: root.bar
          text: root.slotOf(slot.modelData) === root.slots ? "0" : String(root.slotOf(slot.modelData))
          foreground: slot.focused ? root.onHighlight : slot.urgent ? root.urgentColor : root.plain
          useActiveColor: false
          horizontalMargin: 6
          verticalPadding: 6
          onPressed: function() {
            if (!slot.focused) root.focusWorkspace(slot.modelData)
            else if (root.blockClick === "layout") root.cycleLayout()
          }
          onWheelMoved: function(delta) { root.scrollWorkspaces(delta) }
        }
      }
    }
  }
}
