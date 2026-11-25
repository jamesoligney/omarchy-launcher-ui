import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.UPower
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "../jimmy.shared"
import "../jimmy.shared/Tokens.js" as Tokens
import "../jimmy.shared/AppName.js" as AppName
import "../jimmy.shared/BarGeometry.js" as BarGeometry
// The stock weather glyph set (9 conditions, day/night), reused as-is.
import "/usr/share/omarchy/shell/plugins/panels/weather/Model.js" as WeatherModel

// Islands bar, Stage 3: islands live.
// Left island (centred in the left ear): workspaces + focused app.
// Right island (centred in the right ear): time, weather, battery, contextual
// lights (stay awake, remote, screen record, mic), agents.
// The stock panel widgets (audio, Bluetooth, network, power, display, clock,
// weather, agents, microphone) are hosted here, invisible, so their panels and
// keys (Super+Ctrl+A/B/N/P/D, Super+Ctrl+Alt+D) work and drop from the right
// island. Every size is a token in ~/.config/omarchy/shell.toml.
Item {
  id: root

  // Set by the shell (configureBar).
  property string omarchyPath: ""
  property var shell: null
  property var manifest: null
  property var barConfig: null
  property var barWidgetRegistry: null

  // Read back by the shell and other plugins.
  readonly property int barSize: barHeight
  property bool barHidden: false
  readonly property string position: "top"
  readonly property var screenBarSizes: ({})

  // ---------------------------------------------------------------- tokens
  readonly property var tokens: Commons.Color.shellValues
  function num(key, fallback) { return Tokens.num(tokens, key, fallback) }

  readonly property int barHeight: num("bar.height", 44)
  readonly property int notchHeight: num("notch.height", 32)
  readonly property int islandGap: num("island.gap", 3)
  readonly property int islandRadius: num("island.radius", 9)
  readonly property int islandPadding: num("island.padding-x", 10)
  readonly property int islandSpacing: num("island.spacing", 12)
  readonly property int fontSize: num("island.font-size", 16)
  readonly property real quietAlpha: num("island.quiet-alpha", 0.72)
  readonly property int appMaxWidth: num("island.app-max-width", 200)
  readonly property int batteryLow: num("battery.low", 20)
  readonly property int batteryCritical: num("battery.critical", 10)
  readonly property int batteryWidth: num("battery.bar-width", 52)
  readonly property int batteryHeight: num("battery.bar-height", 22)
  readonly property int pulseMs: num("battery.pulse-ms", 1800)
  readonly property real nearLimit: num("agents.near-limit", 0.85)
  readonly property int fullscreenDebounce: num("fullscreen.debounce-ms", 50)
  readonly property string clockFormat: Tokens.str(tokens, "clock.format", "h:mm")
  readonly property var agentIds: Tokens.str(tokens, "agents.ids", "claude,opencode,grok").split(",").map(function(s) { return s.trim() }).filter(function(s) { return s !== "" })
  readonly property int islandHeight: barHeight - 2 * islandGap

  // Same glass as the launcher and pickers ([launcher] tokens).
  readonly property color islandColor: Util.alpha(Commons.Color.background, num("launcher.panel-background-alpha", 0.70))
  readonly property color islandBorder: Util.alpha(Commons.Color.accent, num("launcher.panel-border-alpha", 0.16))
  readonly property color ink: Commons.Color.foreground
  readonly property color quiet: Util.alpha(Commons.Color.foreground, quietAlpha)
  readonly property color accent: Commons.Color.accent
  readonly property color urgent: Commons.Color.urgent
  readonly property string fontFamily: Tokens.str(tokens, "ui.font", Style.font.family)
  // Icon glyphs (weather, lights, agents) stay on the Nerd Font.
  readonly property string iconFamily: Style.font.family

  // ----------------------------------------------------------------- data
  MinuteClock { id: clock }

  readonly property var battery: UPower.displayDevice
  readonly property int batteryPercent: battery && battery.isPresent ? Math.round(battery.percentage * 100) : -1
  readonly property bool charging: battery ? (battery.state === UPowerDeviceState.Charging
    || battery.state === UPowerDeviceState.PendingCharge) : false

  readonly property string appName: {
    var top = ToplevelManager.activeToplevel
    return AppName.resolve(top ? top.appId : "", function(id) { return DesktopEntries.heuristicLookup(id) })
  }

  // First-party services open to bar plugins.
  readonly property var idleService: shell ? shell.firstPartyServiceFor("omarchy.idle") : null
  readonly property var remoteService: shell ? shell.firstPartyServiceFor("omarchy.remote-session") : null
  readonly property var notificationService: shell ? shell.firstPartyServiceFor("omarchy.notifications") : null
  readonly property bool stayAwake: !!idleService && idleService.stayAwake === true
  readonly property bool silenced: !!notificationService && notificationService.doNotDisturb === true
  function toggleStayAwake() { if (idleService) idleService.setIdleEnabled(root.stayAwake) }
  function toggleSilence() { if (notificationService) notificationService.setDoNotDisturb(!root.silenced) }
  readonly property bool remoteActive: !!remoteService && remoteService.active === true
  readonly property bool micInUse: !!hosts["omarchy.microphone"] && hosts["omarchy.microphone"].inUse === true
  property bool recording: false

  // Weather: the hosted stock weather widget fetches (stock source and
  // interval); the island reads its loaded panel.
  // The weather widget's panel Loader, found once when the widget loads;
  // Loader.item notifies, so this follows it without re-scanning.
  property var weatherLoader: null
  readonly property var weatherData: weatherLoader ? weatherLoader.item : null
  // The panel's own icon comes only from open-meteo once coordinates are set,
  // and open-meteo refuses curl's default User-Agent on that request (403), so
  // derive it from the current conditions, which fall back to wttr.in.
  readonly property string weatherIcon: weatherData
    ? String(weatherData.label || WeatherModel.currentIcon(weatherData.current, "")) : ""
  Staleness {
    id: weatherStaleness
    intervalMs: (root.weatherData ? root.weatherData.refreshMinutes : 15) * 60000
    // Offline only when the primary source (wttr.in) is failing too.
    failing: !!root.weatherData && root.weatherData.forecastRetries > 0
  }
  Connections {
    target: root.weatherData
    ignoreUnknownSignals: true
    function onLabelChanged() { weatherStaleness.updatedAt = Date.now() }
    function onReportChanged() { weatherStaleness.updatedAt = Date.now() }
  }
  function loaderIn(item) {
    var kids = item ? item.data || [] : []
    for (var i = 0; i < kids.length; i++)
      if (kids[i] && kids[i].sourceComponent !== undefined && kids[i].item !== undefined) return kids[i]
    return null
  }

  // Agents: usage records (watched files) for the near-limit dot; running =
  // an Omarchy agent window is open. "Waiting" needs the hook (contract only).
  property var agentRecords: ({})
  Variants {
    model: root.agentIds
    FileView {
      required property string modelData
      path: Quickshell.env("HOME") + "/.local/state/omarchy/agents/usage/" + modelData + ".json"
      watchChanges: true
      printErrors: false
      onFileChanged: reload()
      onLoaded: {
        var next = Object.assign({}, root.agentRecords)
        try { next[modelData] = JSON.parse(text()) } catch (e) { delete next[modelData] }
        root.agentRecords = next
      }
    }
  }
  readonly property real agentPeak: {
    var peak = 0
    for (var id in agentRecords) {
      var limits = agentRecords[id] && agentRecords[id].limits
      for (var i = 0; limits && i < limits.length; i++) peak = Math.max(peak, Number(limits[i].percent) || 0)
    }
    return peak
  }
  readonly property bool agentNearLimit: agentPeak >= nearLimit

  // Which Claude account the single claude.json usage record belongs to: the
  // active one in accounts/claude.json. The other account has no record of
  // its own (open investigation #13), so its capsule shows "no data".
  property string claudeActive: "main"
  FileView {
    path: Quickshell.env("HOME") + "/.local/state/omarchy/agents/accounts/claude.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: { try { root.claudeActive = String(JSON.parse(text()).active || "main") } catch (e) {} }
  }
  function peakOf(record) {
    var peak = -1, limits = record && record.limits
    for (var i = 0; limits && i < limits.length; i++) peak = Math.max(peak, Number(limits[i].percent) || 0)
    return peak
  }
  // One capsule per model, fixed order. peak = highest limit used (0-1),
  // -1 = no data. Colour = state: over limit, near limit, or calm.
  readonly property var agentModels: [
    { id: "claude-main", label: "Claude Personal", peak: claudeActive === "main" ? peakOf(agentRecords["claude"]) : -1 },
    { id: "claude-teams", label: "Claude Teams", peak: claudeActive === "teams" ? peakOf(agentRecords["claude"]) : -1 },
    { id: "opencode", label: "OpenCode", peak: peakOf(agentRecords["opencode"]) },
    { id: "grok", label: "Grok", peak: peakOf(agentRecords["grok"]) }
  ]
  readonly property bool agentRunning: {
    var tops = ToplevelManager.toplevels.values
    for (var i = 0; i < tops.length; i++) if (tops[i].appId === "org.omarchy.agent") return true
    return false
  }

  // Screen recording: the recorder pushes `omarchy-shell omarchy.indicators
  // refresh` on start and stop; answer it with one status check (no polling).
  Process {
    id: recordingProbe
    command: ["omarchy-capture-screenrecording", "--status"]
    onExited: function(exitCode) { root.recording = exitCode === 0 }
  }
  function refreshIndicators() { if (!recordingProbe.running) recordingProbe.running = true }
  Component.onCompleted: refreshIndicators()

  ShellIpc {
    target: "omarchy.indicators"
    function refresh(): void { root.refreshIndicators() }
  }

  ShellIpc {
    target: "jimmy.bar"
    function refreshWeather(): void { if (root.weatherData && root.weatherData.refresh) root.weatherData.refresh() }
    function toggle(id: string): bool { return root.toggleBarWidget(id) }
    // Super+Ctrl+Q: the quick-toggles pop-out, from the keyboard.
    function quick(): void { root.openQuick(!(quick.opened && quick.keyboard)) }
    // What the islands are showing, for checking from a terminal.
    function status(): string {
      return JSON.stringify({
        hosted: Object.keys(root.hosts),
        weather: { panel: !!root.weatherData, icon: root.weatherIcon, state: weatherStaleness.state, age: weatherStaleness.ageText,
          retries: root.weatherData ? [root.weatherData.forecastRetries, root.weatherData.dailyForecastRetries] : null },
        battery: { percent: root.batteryPercent, charging: root.charging },
        lights: { stayAwake: root.stayAwake, remote: root.remoteActive, recording: root.recording, mic: root.micInUse },
        agents: { models: root.agentModels, running: root.agentRunning, claudeActive: root.claudeActive },
        silenced: root.silenced,
        quick: { opened: quick.opened, keyboard: quick.keyboard },
        adopted: adopter.adoptedIds,
        lastAdopt: adopter.lastAttempt
      })
    }
  }

  // --------------------------------------------------- hosted panel widgets
  readonly property var hostIds: ["omarchy.audio", "omarchy.bluetooth", "omarchy.network", "omarchy.power",
    "omarchy.monitor", "omarchy.clock", "omarchy.weather", "omarchy.agents", "omarchy.microphone",
    "io.github.cwilliams5.locus"]
  property var hosts: ({})
  property var activePopout: null
  // Hosted panels open in the shared panel language (PanelShell family).
  PanelAdopter { id: adopter }

  function entrySettings(id) {
    var layout = barConfig && barConfig.layout ? barConfig.layout : {}
    for (var section in layout) {
      var list = layout[section] || []
      for (var i = 0; i < list.length; i++) {
        var entry = list[i]
        if (entry && typeof entry === "object" && entry.id === id) {
          var copy = {}
          for (var key in entry) if (key !== "id") copy[key] = entry[key]
          return copy
        }
      }
    }
    return {}
  }

  // Called by the shell for Super+Ctrl+... and `omarchy-shell shell toggle <id>`.
  function summonBarWidget(id) {
    var item = hosts[id]
    if (!item || typeof item.open !== "function") return false
    item.open()
    return true
  }
  function hideBarWidget(id) {
    var item = hosts[id]
    if (!item || typeof item.close !== "function") return false
    item.close()
    return true
  }
  function isBarWidgetOpen(id) {
    var item = hosts[id]
    return !!item && item.opened === true
  }
  function toggleBarWidget(id) {
    return isBarWidgetOpen(id) ? hideBarWidget(id) : summonBarWidget(id)
  }

  Component {
    id: apiComponent
    PluginBarApi {}
  }

  function apiFor(id) {
    var api = apiComponent.createObject(root, {
      pluginId: id,
      moduleName: id,
      shell: root.shell ? root.shell.pluginShellForBarEntry(root.manifest ? root.manifest.id : "jimmy.bar", id) : null,
      position: "top",
      vertical: false,
      _requestPopout: function(owner) {
        if (root.activePopout && root.activePopout !== owner && typeof root.activePopout.close === "function")
          root.activePopout.close()
        root.activePopout = owner
        quick.opened = false
        adopter.adopt(owner, id)
      },
      _releasePopout: function(owner) {
        adopter.release(owner)
        if (root.activePopout === owner) root.activePopout = null
      },
      _popoutCardFor: function(owner) { return null },
      _switchPanelFrom: function(owner, direction) { return false },
      _targetBelongsToWindow: function(target, window) { return false },
      _moduleWidgets: function(requested) { return root.hosts[requested] ? [root.hosts[requested]] : [] },
      _run: function(command) { Quickshell.execDetached(["bash", "-c", String(command)]) }
    })
    api.foreground = Qt.binding(function() { return root.ink })
    api.barForeground = Qt.binding(function() { return root.ink })
    api.background = Qt.binding(function() { return root.islandColor })
    api.urgent = Qt.binding(function() { return root.urgent })
    api.fontFamily = Qt.binding(function() { return root.fontFamily })
    api.barSize = Qt.binding(function() { return root.barHeight })
    api.activePopout = Qt.binding(function() { return root.activePopout })
    return api
  }

  // ------------------------------------------------------------- pieces
  component Island: Rectangle {
    default property alias content: row.data
    property real centerX: 0
    property int maxWidth: 10000
    width: Math.min(maxWidth, row.implicitWidth + 2 * root.islandPadding)
    height: root.islandHeight
    x: Math.round(centerX - width / 2)
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
    color: root.quiet
    font.family: root.fontFamily
    font.pixelSize: root.fontSize
    font.features: { "tnum": 1 }
    textFormat: Text.PlainText
  }

  component Light: Label {
    property bool on: false
    visible: on
    font.family: root.iconFamily
  }

  // Click an element to toggle its hosted panel.
  component Tap: MouseArea {
    property string target: ""
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: root.toggleBarWidget(target)
  }

  // ------------------------------------------------- quick toggles pop-out
  // The stock hover pop-out by the time, in the new language: drops from the
  // right island (PanelShell). Hover the time to open it; Super+Ctrl+Q opens it
  // with keyboard focus (Up/Down, Enter, Esc). Items: the stock list minus the
  // dropped ones (passwordless sudo, screen recording).
  readonly property var quickItems: [
    { key: "stay", icon: "\udb80\udd76", label: "Stay awake", on: root.stayAwake },
    { key: "reminder", icon: "\udb80\udc20", label: "Set reminder", on: false },
    { key: "night", icon: "\udb81\udd94", label: "Night light", on: false },
    { key: "silence", icon: "\udb80\udc9b", label: "Silence notifications", on: root.silenced }
  ]
  property int quickIndex: 0
  property bool quickHoverTime: false
  property bool quickHoverCard: false

  function runQuick(key) {
    if (key === "stay") root.toggleStayAwake()
    else if (key === "silence") root.toggleSilence()
    else {
      quick.opened = false
      if (key === "reminder") Quickshell.execDetached(["omarchy-shell", "shell", "summon", "jimmy.reminders", "{}"])
      else if (key === "night") root.toggleBarWidget("io.github.cwilliams5.locus")
    }
  }
  function openQuick(keyboard) {
    if (root.activePopout && typeof root.activePopout.close === "function") root.activePopout.close()
    quick.keyboard = keyboard
    root.quickIndex = 0
    quick.opened = true
    if (keyboard) Qt.callLater(function() { quickKeys.forceActiveFocus() })
  }
  function hoverQuick(inside) { root.quickHoverTime = inside; quickHoverTimer.restart() }
  Timer {
    id: quickHoverTimer
    interval: quick.opened ? 300 : 180
    onTriggered: {
      var want = root.quickHoverTime || root.quickHoverCard
      if (want && !quick.opened) root.openQuick(false)
      else if (!want && quick.opened && !quick.keyboard) quick.opened = false
    }
  }

  PanelShell {
    id: quick
    screen: Quickshell.screens.length ? Quickshell.screens[0] : null
    anchor: "right"
    contentWidth: 230
    contentHeight: quickColumn.implicitHeight
    onDismissed: quick.opened = false

    Item {
      id: quickKeys
      anchors.fill: parent
      focus: true
      Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) quick.opened = false
        else if (event.key === Qt.Key_Down) root.quickIndex = (root.quickIndex + 1) % root.quickItems.length
        else if (event.key === Qt.Key_Up) root.quickIndex = (root.quickIndex + root.quickItems.length - 1) % root.quickItems.length
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) root.runQuick(root.quickItems[root.quickIndex].key)
        else return
        event.accepted = true
      }
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onContainsMouseChanged: { root.quickHoverCard = containsMouse; quickHoverTimer.restart() }
      }
      Column {
        id: quickColumn
        width: parent.width
        spacing: 2
        Repeater {
          model: root.quickItems
          Rectangle {
            required property var modelData
            required property int index
            width: quickColumn.width
            height: 34
            radius: root.islandRadius - 3
            readonly property bool current: quick.keyboard && index === root.quickIndex
            color: current || rowMouse.containsMouse ? Util.alpha(root.accent, 0.16) : "transparent"
            Row {
              anchors.verticalCenter: parent.verticalCenter
              x: 8
              spacing: 10
              Text {
                text: modelData.icon
                color: modelData.on ? root.accent : root.quiet
                font.family: root.iconFamily
                font.pixelSize: root.fontSize
              }
              Text {
                text: modelData.label
                color: modelData.on ? root.ink : root.quiet
                font.family: root.fontFamily
                font.pixelSize: root.fontSize - 2
              }
            }
            Text {
              anchors.verticalCenter: parent.verticalCenter
              anchors.right: parent.right
              anchors.rightMargin: 8
              visible: modelData.key === "stay" || modelData.key === "silence"
              text: modelData.on ? "On" : "Off"
              color: modelData.on ? root.accent : root.quiet
              font.family: root.fontFamily
              font.pixelSize: root.fontSize - 4
            }
            MouseArea {
              id: rowMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.runQuick(modelData.key)
            }
          }
        }
      }
    }
  }

  // ------------------------------------------------------------- windows
  Variants {
    model: Quickshell.screens

    Scope {
      id: screenScope
      required property var modelData
      readonly property bool notched: String(modelData.name).indexOf("eDP") === 0
      readonly property var monitor: Hyprland.monitorFor(modelData)

      // Fullscreen = a real fullscreen window (Hyprland flag bit 2) on this
      // screen's active workspace. The bar unmounts after a short debounce so
      // a toggle never flickers; the ears go black.
      readonly property bool underFullscreen: {
        var ws = monitor ? monitor.activeWorkspace : null
        if (!ws) return false
        var tops = Hyprland.toplevels.values
        for (var i = 0; i < tops.length; i++) {
          var t = tops[i]
          if (t && t.workspace && t.workspace.id === ws.id && t.lastIpcObject && (Number(t.lastIpcObject.fullscreen) & 2) !== 0) return true
        }
        return false
      }
      property bool hidden: false
      onUnderFullscreenChanged: fullscreenTimer.restart()
      property Timer fullscreenTimer: Timer {
        interval: root.fullscreenDebounce
        onTriggered: screenScope.hidden = screenScope.underFullscreen
      }

      // Hyprland places a top-anchored layer below the monitor's own reserve
      // (the notch rows from hypr/monitors.lua). The islands sit in those rows,
      // so they ignore reserved space, and this invisible, click-through strip
      // reserves the rest of bar.height. monitors.lua stays the same whichever
      // bar is active.
      PanelWindow {
        screen: screenScope.modelData
        anchors { top: true; left: true; right: true }
        implicitHeight: 1
        color: "transparent"
        mask: Region {}
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: Math.max(0, root.barHeight - (screenScope.notched ? root.notchHeight : 0))
        WlrLayershell.namespace: "jimmy-bar-reserve"
        WlrLayershell.layer: WlrLayer.Bottom
      }

      PanelWindow {
        id: window
        screen: screenScope.modelData
        visible: !screenScope.hidden
        readonly property var ears: BarGeometry.ears(width, screenScope.notched, root.tokens)
        readonly property var monitor: screenScope.monitor

        anchors { top: true; left: true; right: true }
        implicitHeight: root.barHeight
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "jimmy-bar"
        WlrLayershell.layer: WlrLayer.Top

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

        Connections {
          target: Hyprland
          function onRawEvent(event) {
            if (event && String(event.name) === "fullscreen") Hyprland.refreshToplevels()
          }
        }

        // ---------------------------------------------------- left island
        Island {
          centerX: window.ears.leftCenter
          maxWidth: window.ears.maxIslandWidth

          Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Repeater {
              model: window.workspaces
              Rectangle {
                required property var modelData
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(root.islandHeight - 8, slotText.implicitWidth + 12)
                height: root.islandHeight - 8
                radius: root.islandRadius - 3
                color: modelData.active ? Util.alpha(root.accent, 0.22) : "transparent"
                Label {
                  id: slotText
                  anchors.centerIn: parent
                  text: String(parent.modelData.slot)
                  color: parent.modelData.active ? root.accent : root.quiet
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
            color: root.ink
          }
        }

        // --------------------------------------------------- right island
        Island {
          centerX: window.ears.rightCenter
          maxWidth: window.ears.maxIslandWidth

          // Stay awake, while on: lives left of the time; click turns it off.
          Light {
            on: root.stayAwake
            text: "\udb80\udd76"
            color: root.accent
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: root.toggleStayAwake()
            }
          }

          // Time, nearest the notch. Click: calendar. Hover: quick toggles.
          Label {
            text: Qt.formatTime(clock.date, root.clockFormat)
            Tap {
              target: "omarchy.clock"
              hoverEnabled: true
              onContainsMouseChanged: root.hoverQuick(containsMouse)
            }
          }

          // Weather, icon only. Fresh / stale (dim) / offline (dim + mark).
          Item {
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: weatherGlyph.implicitWidth + (offlineMark.visible ? offlineMark.implicitWidth : 0)
            implicitHeight: weatherGlyph.implicitHeight
            visible: root.weatherIcon !== ""
            Label {
              id: weatherGlyph
              anchors.verticalCenter: undefined
              font.family: root.iconFamily
              text: root.weatherIcon
              opacity: weatherStaleness.state === "fresh" ? 1 : 0.5
            }
            Label {
              id: offlineMark
              anchors.verticalCenter: undefined
              x: weatherGlyph.implicitWidth
              visible: weatherStaleness.state === "offline"
              text: "·"
              color: root.urgent
            }
            Tap { target: "omarchy.weather" }
          }

          // Battery: fixed-width pill, % inside, fill = charge.
          Item {
            id: batteryPill
            visible: root.batteryPercent >= 0
            anchors.verticalCenter: parent.verticalCenter
            width: root.batteryWidth
            height: root.batteryHeight
            readonly property color tone: root.batteryPercent <= root.batteryCritical ? root.urgent
              : (root.batteryPercent <= root.batteryLow ? root.accent : root.ink)
            Rectangle {
              anchors.fill: parent
              radius: height / 2
              color: "transparent"
              border.width: 1
              border.color: Util.alpha(batteryPill.tone, 0.55)
            }
            Rectangle {
              x: 2; y: 2
              height: parent.height - 4
              width: Math.max(height, (parent.width - 4) * Math.max(0, root.batteryPercent) / 100)
              radius: height / 2
              color: Util.alpha(batteryPill.tone, root.batteryPercent <= root.batteryLow ? 0.55 : 0.28)
              Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
            }
            // Charging: the outline pulses in the system accent, one slow
            // loop; the pill and the number stay calm.
            Rectangle {
              visible: root.charging
              anchors.fill: parent
              anchors.margins: -2
              radius: height / 2
              color: "transparent"
              border.width: 2
              border.color: root.accent
              SequentialAnimation on opacity {
                running: root.charging && !screenScope.hidden
                loops: Animation.Infinite
                NumberAnimation { from: 0.25; to: 1.0; duration: root.pulseMs / 2; easing.type: Easing.InOutSine }
                NumberAnimation { from: 1.0; to: 0.25; duration: root.pulseMs / 2; easing.type: Easing.InOutSine }
              }
            }
            Text {
              anchors.centerIn: parent
              text: Math.max(0, root.batteryPercent) + "%"
              color: root.ink
              font.family: root.fontFamily
              font.pixelSize: Math.round(root.batteryHeight * 0.6)
              font.features: { "tnum": 1 }
            }
            Tap { target: "omarchy.power" }
          }

          // Contextual lights: never hidden while on. Mic is primary and sits
          // rightmost; the others stack to its left.
          Light { on: root.remoteActive; text: "󰢹"; color: root.urgent }
          Light { on: root.recording; text: "󰻂"; color: root.urgent }
          Light { on: root.micInUse; text: "󰍬"; color: root.urgent }

          // Agents: one slim capsule per model (Claude Personal, Claude Teams,
          // OpenCode, Grok). Fill = highest limit used; colour = state (red
          // over limit, accent near limit, calm otherwise); a dim empty
          // outline = no data. Click: the agents panel, per-model detail.
          Item {
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: agentRow.implicitWidth
            implicitHeight: root.islandHeight
          Row {
            id: agentRow
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            Label {
              text: "\udb81\udea9"
              font.family: root.iconFamily
              opacity: root.agentRunning ? 1 : 0.6
            }
            Repeater {
              model: root.agentModels
              Item {
                required property var modelData
                anchors.verticalCenter: parent.verticalCenter
                width: 6
                height: Math.round(root.islandHeight * 0.5)
                readonly property real peak: modelData.peak
                readonly property color tone: peak >= 1 ? root.urgent : (peak >= root.nearLimit ? root.accent : root.ink)
                opacity: peak < 0 ? 0.35 : 1
                Rectangle {
                  anchors.fill: parent
                  radius: width / 2
                  color: "transparent"
                  border.width: 1
                  border.color: Util.alpha(parent.tone, 0.55)
                }
                Rectangle {
                  visible: parent.peak > 0
                  anchors.bottom: parent.bottom
                  anchors.horizontalCenter: parent.horizontalCenter
                  width: parent.width
                  height: Math.max(width, parent.height * Math.min(1, parent.peak))
                  radius: width / 2
                  color: Util.alpha(parent.tone, parent.peak >= root.nearLimit ? 0.85 : 0.45)
                  Behavior on height { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
                }
              }
            }
          }
            Tap { target: "omarchy.agents" }
          }
        }

        // Hosted stock panel widgets: invisible, under the right island, so
        // their panels drop from it.
        Item {
          x: Math.round(window.ears.rightCenter)
          y: 0
          width: 1
          height: root.barHeight
          opacity: 0
          enabled: false
          Repeater {
            model: root.hostIds
            Loader {
              required property string modelData
              width: 1
              height: root.barHeight
              active: !!root.barWidgetRegistry && !!root.barWidgetRegistry.widgets[modelData]
              sourceComponent: active ? root.barWidgetRegistry.widgets[modelData].component : null
              onLoaded: {
                if ("bar" in item) item.bar = root.apiFor(modelData)
                if ("moduleName" in item) item.moduleName = modelData
                if ("settings" in item) item.settings = root.entrySettings(modelData)
                if (modelData === "omarchy.weather") root.weatherLoader = root.loaderIn(item)
                var next = Object.assign({}, root.hosts)
                next[modelData] = item
                root.hosts = next
              }
            }
          }
        }
      }
    }
  }
}
