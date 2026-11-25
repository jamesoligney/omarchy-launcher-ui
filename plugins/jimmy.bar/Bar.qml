import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.UPower
import qs.Commons
import qs.Commons as Commons
import "../jimmy.shared"
import "../jimmy.shared/Tokens.js" as Tokens
import "../jimmy.shared/AppName.js" as AppName

// Bar restructure, Stage 2: a static mock of the two islands, judged live.
// Left island: workspaces + focused app. Right island: time (nearest the
// notch), weather icon, battery bar, agents. Every size is a token in
// ~/.config/omarchy/shell.toml ([bar] [notch] [island] [battery] [clock]).
// Weather and agents are placeholders in this stage; the rest is live.
Item {
  id: root

  // Set by the shell (configureBar).
  property string omarchyPath: ""
  property var shell: null
  property var manifest: null
  property var barConfig: null

  // Read back by the shell and by other plugins.
  readonly property int barSize: barHeight
  property bool barHidden: false
  readonly property string position: "top"
  readonly property var screenBarSizes: ({})

  readonly property var tokens: Commons.Color.shellValues
  function num(key, fallback) { return Tokens.num(tokens, key, fallback) }

  readonly property int barHeight: num("bar.height", 44)
  readonly property int notchHeight: num("notch.height", 32)
  readonly property int notchWidth: num("notch.width", 174)
  readonly property int notchInset: num("notch.inset", 10)
  readonly property int cornerInset: num("notch.corner-inset", 18)
  readonly property int islandGap: num("island.gap", 6)
  readonly property int islandRadius: num("island.radius", 14)
  readonly property int islandPadding: num("island.padding-x", 12)
  readonly property int islandSpacing: num("island.spacing", 12)
  readonly property int appMaxWidth: num("island.app-max-width", 200)
  readonly property int batteryLow: num("battery.low", 20)
  readonly property int batteryCritical: num("battery.critical", 10)
  readonly property int batteryBarWidth: num("battery.bar-width", 26)
  readonly property int batteryBarHeight: num("battery.bar-height", 9)
  readonly property string clockFormat: Tokens.str(tokens, "clock.format", "h:mm")
  readonly property int islandHeight: barHeight - 2 * islandGap

  // Same glass as the launcher and pickers ([launcher] tokens).
  readonly property color islandColor: Util.alpha(Commons.Color.background, num("launcher.panel-background-alpha", 0.70))
  readonly property color islandBorder: Util.alpha(Commons.Color.accent, num("launcher.panel-border-alpha", 0.16))
  readonly property color ink: Commons.Color.foreground
  readonly property color muted: Util.alpha(Commons.Color.foreground, num("launcher.muted-alpha", 0.55))
  readonly property color accent: Commons.Color.accent
  readonly property string fontFamily: Style.font.family
  readonly property int fontSize: Style.font.body

  MinuteClock { id: clock }

  readonly property var battery: UPower.displayDevice
  readonly property int batteryPercent: battery && battery.isPresent ? Math.round(battery.percentage * 100) : -1
  readonly property bool charging: battery ? (battery.state === UPowerDeviceState.Charging
    || battery.state === UPowerDeviceState.FullyCharged || battery.state === UPowerDeviceState.PendingCharge) : false

  readonly property string appName: {
    var top = ToplevelManager.activeToplevel
    return AppName.resolve(top ? top.appId : "", function(id) { return DesktopEntries.heuristicLookup(id) })
  }

  component Island: Rectangle {
    default property alias content: row.data
    property int maxWidth: 10000
    width: Math.min(maxWidth, row.implicitWidth + 2 * root.islandPadding)
    height: root.islandHeight
    y: root.islandGap
    radius: root.islandRadius
    color: root.islandColor
    border.width: 1
    border.color: root.islandBorder
    clip: true
    Row {
      id: row
      anchors.verticalCenter: parent.verticalCenter
      x: root.islandPadding
      spacing: root.islandSpacing
    }
  }

  component Label: Text {
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
    color: root.ink
    font.family: root.fontFamily
    font.pixelSize: root.fontSize
    font.features: { "tnum": 1 }
    textFormat: Text.PlainText
  }

  Variants {
    model: Quickshell.screens

    Scope {
      id: screenScope
      required property var modelData
      readonly property bool notched: String(modelData.name).indexOf("eDP") === 0

    // Hyprland places a top-anchored layer below the monitor's own reserve
    // (the notch rows from hypr/monitors.lua). The islands must sit in those
    // rows, so they ignore reserved space and start at y = 0, and this
    // invisible, click-through strip reserves the rest of bar.height. The
    // monitor config stays the same whichever bar is active.
    PanelWindow {
      screen: screenScope.modelData
      anchors { top: true; left: true; right: true }
      implicitHeight: 1
      color: "transparent"
      mask: Region {}
      exclusionMode: root.barHidden ? ExclusionMode.Ignore : ExclusionMode.Normal
      exclusiveZone: Math.max(0, root.barHeight - (screenScope.notched ? root.notchHeight : 0))
      WlrLayershell.namespace: "jimmy-bar-reserve"
      WlrLayershell.layer: WlrLayer.Bottom
    }

    PanelWindow {
      id: window
      readonly property var modelData: screenScope.modelData
      screen: modelData

      // Only the built-in panel has a camera cutout; its rows are already
      // reserved by hypr/monitors.lua, so the bar reserves the remainder.
      readonly property bool notched: screenScope.notched
      readonly property int cutout: notched ? root.notchWidth : 0
      readonly property int aside: notched ? root.notchInset : root.islandGap
      readonly property var monitor: Hyprland.monitorFor(modelData)
      readonly property int sideRoom: width / 2 - cutout / 2 - aside - root.cornerInset

      anchors { top: true; left: true; right: true }
      implicitHeight: root.barHeight
      color: "transparent"
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.namespace: "jimmy-bar"
      WlrLayershell.layer: WlrLayer.Top

      // Occupied workspaces on this monitor plus the active one, in order,
      // numbered 1-10 within the monitor's block.
      readonly property var workspaces: {
        var out = []
        var values = Hyprland.workspaces.values
        var activeId = monitor && monitor.activeWorkspace ? monitor.activeWorkspace.id : -1
        for (var i = 0; i < values.length; i++) {
          var ws = values[i]
          if (ws.id <= 0 || !ws.monitor || !monitor || ws.monitor.name !== monitor.name) continue
          if (ws.id !== activeId && ws.toplevels.values.length === 0) continue
          out.push({ id: ws.id, slot: (ws.id - 1) % 10 + 1, active: ws.id === activeId })
        }
        out.sort(function(a, b) { return a.id - b.id })
        return out
      }

      Island {
        id: left
        maxWidth: window.sideRoom
        x: window.width / 2 - window.cutout / 2 - window.aside - width

        Row {
          anchors.verticalCenter: parent.verticalCenter
          spacing: 2
          Repeater {
            model: window.workspaces
            Rectangle {
              required property var modelData
              anchors.verticalCenter: parent.verticalCenter
              width: Math.max(root.islandHeight - 10, slotText.implicitWidth + 10)
              height: root.islandHeight - 10
              radius: height / 2
              color: modelData.active ? Util.alpha(root.accent, 0.22) : "transparent"
              Label {
                id: slotText
                anchors.centerIn: parent
                text: String(parent.modelData.slot)
                color: parent.modelData.active ? root.accent : root.muted
                font.bold: parent.modelData.active
              }
              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + parent.modelData.id)
              }
            }
          }
        }

        Label {
          visible: root.appName !== ""
          width: Math.min(implicitWidth, root.appMaxWidth)
          elide: Text.ElideRight
          text: root.appName
          font.bold: true
        }
      }

      Island {
        id: right
        maxWidth: window.sideRoom
        x: window.width / 2 + window.cutout / 2 + window.aside

        // Time sits nearest the notch.
        Label { text: Qt.formatTime(clock.date, root.clockFormat) }

        // Placeholder until the weather data source is wired (Stage 3+).
        Label { text: "󰖕"; color: root.muted }

        Item {
          visible: root.batteryPercent >= 0
          anchors.verticalCenter: parent.verticalCenter
          width: root.batteryBarWidth
          height: root.batteryBarHeight
          Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: "transparent"
            border.width: 1
            border.color: root.muted
          }
          Rectangle {
            x: 2; y: 2
            height: parent.height - 4
            width: Math.max(height, (parent.width - 4) * Math.max(0, root.batteryPercent) / 100)
            radius: height / 2
            color: root.batteryPercent <= root.batteryCritical ? Commons.Color.urgent
              : (root.batteryPercent <= root.batteryLow ? root.accent
              : (root.charging ? root.accent : root.ink))
          }
        }

        // Placeholder for mission control (Stage 5).
        Label { text: "\udb81\udea9"; color: root.muted }
      }
    }
    }
  }
}
