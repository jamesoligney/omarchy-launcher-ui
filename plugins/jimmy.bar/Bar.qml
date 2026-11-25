import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.UPower
import Quickshell.Networking
import Quickshell.Bluetooth
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "../jimmy.shared"
import "../jimmy.shared/Tokens.js" as Tokens
import "../jimmy.shared/AppName.js" as AppName
import "../jimmy.shared/BarGeometry.js" as BarGeometry
// The stock weather glyph set (9 conditions, day/night), reused as-is.
import "../jimmy.shared/WeatherIcons.js" as WeatherIcons
import "/usr/share/omarchy/shell/plugins/panels/network/Model.js" as NetworkModel

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
  // Letters and numbers, and glyphs, sized apart (island.text-size,
  // island.glyph-size). The status island's lights have their own size.
  readonly property int textSize: num("island.text-size", 18)
  readonly property int glyphSize: num("island.glyph-size", 20)
  readonly property real quietAlpha: num("island.quiet-alpha", 0.72)
  readonly property int appMaxWidth: num("island.app-max-width", 200)
  readonly property int batteryLow: num("battery.low", 20)
  readonly property int batteryCritical: num("battery.critical", 10)
  readonly property real nearLimit: num("agents.near-limit", 0.85)
  readonly property int fullscreenDebounce: num("fullscreen.debounce-ms", 50)
  readonly property string clockFormat: Tokens.str(tokens, "clock.format", "h:mm")
  // Qt reads "h" as 0-23 unless the format also has AP. So a format without
  // AP is formatted with one (12-hour) and the AM/PM text dropped again:
  // "h:mm" gives 1:05, never 13:05. "HH:mm" stays 24-hour; a format with AP
  // keeps it.
  function clockText(date) {
    var f = root.clockFormat
    if (/ap/i.test(f) || f.indexOf("H") >= 0) return Qt.formatTime(date, f)
    return Qt.formatTime(date, f + " AP").replace(/\s*\S+$/, "")
  }
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
  // Plugged in (charging, or held at its charge limit): the number turns accent.
  readonly property bool pluggedIn: !UPower.onBattery
  // Sparks fired since start (status only: proves they run while charging).
  property int sparks: 0
  property var sparkSides: ({})
  // Low on battery: amber, mixed from the theme's accent toward its urgent
  // red (battery.low-mix), so it reads apart from the plugged-in accent.
  readonly property color lowTone: Qt.tint(root.accent, Util.alpha(root.urgent, num("battery.low-mix", 0.45)))

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
  // Status island. Network: Wi-Fi by signal, ethernet, down (urgent) or
  // Wi-Fi off (dim). Bluetooth: off (dim), on, or a device connected (accent).
  readonly property var netDevices: Networking.devices ? Networking.devices.values : []
  function netDevice(type) {
    var fallback = null
    for (var i = 0; i < netDevices.length; i++) {
      var d = netDevices[i]
      if (!d || d.type !== type) continue
      if (d.connected) return d
      if (!fallback) fallback = d
    }
    return fallback
  }
  readonly property var wifiDevice: netDevice(DeviceType.Wifi)
  readonly property var wiredDevice: netDevice(DeviceType.Wired)
  readonly property var wifiNetwork: {
    var nets = wifiDevice && wifiDevice.networks ? wifiDevice.networks.values : []
    for (var i = 0; i < nets.length; i++) if (nets[i] && nets[i].connected) return nets[i]
    return null
  }
  readonly property string netState: wiredDevice && wiredDevice.connected ? "wired"
    : (wifiNetwork || (wifiDevice && wifiDevice.connected)) ? "wifi"
    : Networking.wifiEnabled ? "down" : "off"
  readonly property string netIcon: netState === "wired" ? "󰈀"
    : netState === "wifi" ? NetworkModel.wifiIconFor(wifiNetwork && wifiNetwork.signalStrength > 0 ? Math.round(wifiNetwork.signalStrength * 100) : 100)
    : netState === "down" ? "󰤮" : "󰤭"
  readonly property var btAdapter: Bluetooth.defaultAdapter
  readonly property bool btOn: !!btAdapter && btAdapter.enabled
  readonly property bool btConnected: {
    var ds = btOn && Bluetooth.devices ? Bluetooth.devices.values : []
    for (var i = 0; i < ds.length; i++) if (ds[i] && ds[i].connected) return true
    return false
  }
  readonly property string btIcon: !btOn ? "󰂲" : btConnected ? "󰂱" : "󰂯"
  readonly property bool micMuted: !!hosts["omarchy.microphone"] && hosts["omarchy.microphone"].muted === true
  readonly property bool micInUse: !!hosts["omarchy.microphone"] && hosts["omarchy.microphone"].inUse === true
  property bool recording: false
  // Super+D leader (Hyprland submap "bar", bindings.lua): while it is held,
  // every element shows its letter.
  property bool leaderActive: false
  // leader.hints = false turns the letters (and the band they need) off.
  readonly property bool showHints: Tokens.str(tokens, "leader.hints", "true") !== "false"
  readonly property int hintSize: num("leader.hint-size", 11)
  readonly property int glowBlur: num("island.glow-blur", 20)
  readonly property int jointGap: num("island.joint-gap", 4)
  readonly property int jointRadius: num("island.joint-radius", 2)
  // Optical: shifts a capital so the edge crosses its middle (leader.hint-nudge).
  readonly property real hintNudge: num("leader.hint-nudge", -1)

  // Weather: the hosted stock weather widget fetches (stock source and
  // interval); the island reads its loaded panel.
  // The weather widget's panel Loader, found once when the widget loads;
  // Loader.item notifies, so this follows it without re-scanning.
  property var weatherLoader: null
  readonly property var weatherData: weatherLoader ? weatherLoader.item : null
  // The panel's own icon comes only from open-meteo once coordinates are set,
  // and open-meteo refuses curl's default User-Agent on that request (403), so
  // derive it from the current conditions, which fall back to wttr.in.
  // The island's own icon set (WeatherIcons.js): a condition key from the
  // same current reading the stock icon uses.
  readonly property string weatherIcon: weatherData ? WeatherIcons.key(weatherData.current) : ""
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

  function peakOf(record) {
    var peak = -1, limits = record && record.limits
    for (var i = 0; limits && i < limits.length; i++) peak = Math.max(peak, Number(limits[i].percent) || 0)
    return peak
  }
  // The one AI mark's state, worst first: over a limit, near one, an agent
  // window running, or idle. Only what the data can say.
  readonly property string agentState: {
    var worst = -1
    for (var id in agentRecords) worst = Math.max(worst, peakOf(agentRecords[id]))
    if (worst >= 1) return "over"
    if (worst >= nearLimit) return "near"
    return agentRunning ? "running" : "idle"
  }
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
    function quick(): void { if (root.quickOpen && root.quickKeyboard) root.closeQuick(); else root.openQuick(true) }
    // What the islands are showing, for checking from a terminal.
    function status(): string {
      return JSON.stringify({
        hosted: Object.keys(root.hosts),
        weather: { panel: !!root.weatherData, icon: root.weatherIcon, state: weatherStaleness.state, age: weatherStaleness.ageText,
          retries: root.weatherData ? [root.weatherData.forecastRetries, root.weatherData.dailyForecastRetries] : null },
        battery: { percent: root.batteryPercent, charging: root.charging, pluggedIn: root.pluggedIn, sparks: root.sparks, sides: root.sparkSides },
        lights: { stayAwake: root.stayAwake, remote: root.remoteActive, recording: root.recording, mic: root.micInUse },
        status: { net: root.netState, netIcon: root.netIcon, bluetooth: root.btOn ? (root.btConnected ? "connected" : "on") : "off", micMuted: root.micMuted, micInUse: root.micInUse },
        agents: { state: root.agentState, running: root.agentRunning,
          peaks: Object.keys(root.agentRecords).map(function(id) { return id + " " + root.peakOf(root.agentRecords[id]) }) },
        leader: root.leaderActive,
        silenced: root.silenced,
        quick: { open: root.quickOpen, keyboard: root.quickKeyboard, index: root.quickIndex, hovered: root.quickHovered },
        adopted: adopter.adoptedIds,
        lastAdopt: adopter.lastAttempt
      })
    }
  }

  // --------------------------------------------------- hosted panel widgets
  readonly property var hostIds: ["omarchy.audio", "omarchy.bluetooth", "omarchy.network", "omarchy.power",
    "omarchy.monitor", "omarchy.clock", root.weatherId, "omarchy.agents", "omarchy.microphone",
    "io.github.cwilliams5.locus"]
  // Weather: the user clone (jimmy.weather: the bar's own icon set in its
  // panel) when installed, else stock. Either way it also answers to
  // "omarchy.weather", so leader W and `shell toggle omarchy.weather` work.
  readonly property string weatherId: barWidgetRegistry && barWidgetRegistry.widgets["jimmy.weather"] ? "jimmy.weather" : "omarchy.weather"
  // Panels for the status island's lights drop from the status island.
  readonly property var statusHostIds: ["omarchy.network", "omarchy.bluetooth", "omarchy.microphone", "omarchy.agents"]
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
  // An island. joinLeft / joinRight square the corners on that side to
  // island.joint-radius, for two islands that read as one divided in two;
  // such a pair glows as one (glow: false here, see rightPair).
  component Island: Rectangle {
    default property alias content: row.data
    property real centerX: 0
    property int maxWidth: 10000
    property int padding: root.islandPadding
    property bool joinLeft: false
    property bool joinRight: false
    property bool glow: true
    width: Math.min(maxWidth, row.implicitWidth + 2 * padding)
    height: root.islandHeight
    x: Math.round(centerX - width / 2)
    y: root.islandGap
    radius: root.islandRadius
    topLeftRadius: joinLeft ? root.jointRadius : radius
    bottomLeftRadius: joinLeft ? root.jointRadius : radius
    topRightRadius: joinRight ? root.jointRadius : radius
    bottomRightRadius: joinRight ? root.jointRadius : radius
    color: root.islandColor
    border.width: 1
    border.color: root.islandBorder
    IslandGlow { visible: parent.glow && alpha > 0 }
    Row {
      id: row
      anchors.verticalCenter: parent.verticalCenter
      x: parent.padding
      spacing: root.islandSpacing
    }
  }

  // A status light in the status island: an island element like any other,
  // at the glyph size, laid out by the island's row. It spans the island's
  // height so its leader letter lands on the outline like the rest.
  component StatusLight: Item {
    property alias text: glyph.text
    property alias color: glyph.color
    property alias dim: glyph.opacity
    property string target: ""
    signal tapped()
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
    implicitWidth: glyph.implicitWidth
    implicitHeight: root.islandHeight
    Text {
      id: glyph
      anchors.verticalCenter: parent.verticalCenter
      font.family: root.iconFamily
      font.pixelSize: root.glyphSize
      textFormat: Text.PlainText
    }
    MouseArea {
      anchors.fill: glyph
      anchors.margins: -3
      cursorShape: Qt.PointingHandCursor
      onClicked: parent.target ? root.toggleBarWidget(parent.target) : parent.tapped()
    }
  }

  component Label: Text {
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
    color: root.quiet
    font.family: root.fontFamily
    font.pixelSize: root.textSize
    font.features: { "tnum": 1 }
    textFormat: Text.PlainText
  }

  // The leader key for an element: a small letter centred on the island's
  // bottom outline under the element, so the edge cuts through it. Same line
  // for every element; only while the leader is active. The parent must be
  // vertically centred on the island (every island element is).
  component Hint: Text {
    visible: root.showHints && root.leaderActive && text !== ""
    anchors.horizontalCenter: parent.horizontalCenter
    y: Math.round((root.islandHeight + parent.height) / 2 - height / 2 + root.hintNudge)
    z: 10
    color: root.accent
    font.family: root.fontFamily
    font.pixelSize: root.hintSize
    font.features: { "tnum": 1 }
  }

  component Light: Label {
    property bool on: false
    visible: on
    font.family: root.iconFamily
    font.pixelSize: root.glyphSize
  }

  // Click an element to toggle its hosted panel.
  component Tap: MouseArea {
    property string target: ""
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: root.toggleBarWidget(target)
  }

  // ------------------------------------------------- quick toggles strip
  // The stock pop-out, in the island language: hovering the time slides the
  // icons out to the left of the right island, outside it, so the island
  // never moves. Icons only, grey when off, accent when on; a lit one stays
  // in the bar beside the island until clicked off.
  // Q (Super+Ctrl+Q, or Super+D then Q) opens the same strip with focus:
  // Left/Right, Enter, Esc. The calendar drops below the island, so the two
  // never meet. Items: the stock list minus passwordless sudo and screen
  // recording (dropped in the refined brief).
  readonly property var quickItems: [
    { key: "reminder", icon: "\udb80\udc20", on: false },
    { key: "night", icon: "\udb81\udd94", on: false },
    { key: "silence", icon: "\udb80\udc9b", on: root.silenced },
    { key: "stay", icon: "\udb80\udd76", on: root.stayAwake }
  ]
  property bool quickOpen: false
  property bool quickKeyboard: false
  property bool hoverTime: false
  property bool hoverStrip: false
  readonly property bool quickHovered: hoverTime || hoverStrip
  onQuickHoveredChanged: quickHoverTimer.restart()
  property int quickIndex: 0
  readonly property int quickSlideMs: num("quick.slide-ms", 160)

  function runQuick(key) {
    if (key === "stay") root.toggleStayAwake()
    else if (key === "silence") root.toggleSilence()
    else {
      root.closeQuick()
      if (key === "reminder") Quickshell.execDetached(["omarchy-shell", "shell", "summon", "jimmy.reminders", "{}"])
      else if (key === "night") root.toggleBarWidget("io.github.cwilliams5.locus")
    }
  }
  function openQuick(keyboard) {
    root.quickKeyboard = keyboard
    root.quickIndex = root.quickItems.length - 1
    root.quickOpen = true
  }
  function closeQuick() { root.quickOpen = false; root.quickKeyboard = false }
  Timer {
    id: quickHoverTimer
    interval: root.quickOpen ? 300 : 180
    onTriggered: {
      if (root.quickHovered && !root.quickOpen) root.openQuick(false)
      else if (!root.quickHovered && root.quickOpen && !root.quickKeyboard) root.closeQuick()
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
        // Taller than the bar by the leader letters' overhang below the
        // islands; the input region stays the bar itself.
        // Taller than the bar by the larger of the letters' overhang and the
        // islands' glow, so neither is cut off.
        implicitHeight: root.barHeight + Math.max(root.showHints ? root.hintSize : 0, root.glowBlur)
        mask: Region { item: barInput }
        Item { id: barInput; width: window.width; height: root.barHeight }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "jimmy-bar"
        WlrLayershell.keyboardFocus: root.quickOpen && root.quickKeyboard ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        // Keys for the strip while it has focus.
        Item {
          id: quickKeys
          focus: root.quickOpen && root.quickKeyboard
          onFocusChanged: if (focus) forceActiveFocus()
          Keys.onPressed: function(event) {
            var n = root.quickItems.length
            if (event.key === Qt.Key_Escape) root.closeQuick()
            else if (event.key === Qt.Key_Left) root.quickIndex = (root.quickIndex + n - 1) % n
            else if (event.key === Qt.Key_Right) root.quickIndex = (root.quickIndex + 1) % n
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) root.runQuick(root.quickItems[root.quickIndex].key)
            else return
            event.accepted = true
          }
        }
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
            var name = event ? String(event.name) : ""
            if (name === "fullscreen") Hyprland.refreshToplevels()
            else if (name === "submap") root.leaderActive = String(event.data) === "bar"
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
                Hint { text: parent.modelData.slot <= 9 ? String(parent.modelData.slot) : "" }
                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: Hyprland.dispatch('hl.dsp.focus({ workspace = "' + parent.modelData.id + '" })')
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
          id: rightIsland
          centerX: window.ears.rightCenter
          maxWidth: window.ears.maxIslandWidth
          joinRight: true
          glow: false

          // Time, nearest the notch. Click: calendar. Hover: the quick strip.
          Label {
            height: root.islandHeight
            verticalAlignment: Text.AlignVCenter
            text: root.clockText(clock.date)
            HoverHandler { onHoveredChanged: root.hoverTime = hovered }
            Tap { target: "omarchy.clock" }
            Hint { text: "C" }
          }

          // Battery: the number only. Accent while plugged in, neutral on
          // battery, amber at battery.low and red at battery.critical.
          Label {
            visible: root.batteryPercent >= 0
            text: Math.max(0, root.batteryPercent) + "%"
            color: root.pluggedIn ? root.accent
              : root.batteryPercent <= root.batteryCritical ? root.urgent
              : root.batteryPercent <= root.batteryLow ? root.lowTone
              : root.quiet
            Tap { target: "omarchy.power" }
            Hint { text: "B" }
            Sparks { running: root.charging && window.visible; onFired: { root.sparks++; root.sparkSides = sides } }
          }

          // Weather, icon only. Fresh / stale (dim) / offline (dim + mark).
          Item {
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: weatherGlyph.width + (offlineMark.visible ? offlineMark.implicitWidth : 0)
            implicitHeight: weatherGlyph.height
            visible: root.weatherIcon !== ""
            WeatherIcon {
              id: weatherGlyph
              key: root.weatherIcon
              size: root.glyphSize
              color: root.quiet
              opacity: weatherStaleness.state === "fresh" ? 1 : 0.5
            }
            Label {
              id: offlineMark
              anchors.verticalCenter: undefined
              x: weatherGlyph.width
              visible: weatherStaleness.state === "offline"
              text: "·"
              color: root.urgent
            }
            Tap { target: "omarchy.weather" }
            Hint { text: "W" }
          }

          // Contextual lights: only while on (the mic lives in the status
          // island now, persistent).
          Light { on: root.remoteActive; text: "󰢹"; color: root.urgent }
          Light {
            on: root.recording; text: "󰻂"; color: root.urgent
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: Quickshell.execDetached(["omarchy-capture-screenrecording", "--stop-recording"])
            }
          }

        }

        // ------------------------------------------------- status island
        // Wi-Fi, Bluetooth, mic, agents: persistent status lights, the same
        // size, padding and spacing as every island element. Joined to the
        // right island across island.joint-gap, the facing corners square,
        // so the two read as one island divided; the right island keeps its
        // centre in the ear, this one hangs off its right.
        Island {
          id: statusIsland
          x: rightIsland.x + rightIsland.width + root.jointGap
          joinLeft: true
          glow: false
          StatusLight {
            target: "omarchy.network"
            text: root.netIcon
            color: root.netState === "down" ? root.urgent : root.quiet
            dim: root.netState === "off" ? 0.45 : 1
            Hint { text: "N" }
          }
          StatusLight {
            target: "omarchy.bluetooth"
            text: root.btIcon
            color: root.btConnected ? root.accent : root.quiet
            dim: root.btOn ? 1 : 0.45
            Hint { text: "T" }
          }
          StatusLight {
            text: root.micMuted ? "󰍭" : "󰍬"
            color: root.micInUse ? root.accent : root.quiet
            dim: root.micInUse ? 1 : 0.45
            onTapped: { var mic = root.hosts["omarchy.microphone"]; if (mic && mic.toggleMute) mic.toggleMute() }
            Hint { text: "M" }
          }
          // Agents: plain for now, like the other lights at rest: quiet at
          // 60%, always. Running and limits show in the agents panel and in
          // status until model activity gets its own design.
          StatusLight {
            target: "omarchy.agents"
            text: "\udb81\ude74"
            color: root.quiet
            dim: 0.6
            Hint { text: "A" }
          }
        }
        // One glow for the joined pair, the gap between them included.
        Item {
          z: -1
          x: rightIsland.x
          y: rightIsland.y
          width: statusIsland.x + statusIsland.width - rightIsland.x
          height: rightIsland.height
          IslandGlow { cutouts: [rightIsland, statusIsland]; radius: root.islandRadius }
        }

        // Quick strip: outside the island, its right edge on the island's left
        // edge, so opening it never moves the island. Items grow from zero
        // width (slide out leftward); the zone reaches over the island's
        // padding to the time, so the pointer never crosses a gap.
        Item {
          x: rightIsland.x - stripRow.width
          y: root.islandGap
          width: stripRow.width + root.islandPadding
          height: root.islandHeight
          HoverHandler { onHoveredChanged: root.hoverStrip = hovered }
          Row {
            id: stripRow
            height: parent.height
            Repeater {
              model: root.quickItems
              Item {
                required property var modelData
                required property int index
                readonly property bool shown: root.quickOpen || modelData.on
                readonly property bool current: root.quickKeyboard && index === root.quickIndex
                width: shown ? icon.implicitWidth + root.islandSpacing : 0
                height: parent.height
                clip: true
                opacity: shown ? 1 : 0
                Behavior on width { NumberAnimation { duration: root.quickSlideMs; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: root.quickSlideMs } }
                Rectangle {
                  visible: parent.current
                  anchors.centerIn: icon
                  width: icon.implicitWidth + 10
                  height: root.islandHeight - 8
                  radius: root.islandRadius - 3
                  color: "transparent"
                  border.width: 1
                  border.color: root.accent
                }
                Label {
                  id: icon
                  x: root.islandSpacing / 2
                  text: modelData.icon
                  font.family: root.iconFamily
                  font.pixelSize: root.glyphSize
                  color: modelData.on ? root.accent : root.quiet
                  opacity: modelData.on ? 1 : 0.45
                }
                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.runQuick(modelData.key)
                }
              }
            }
          }
          // Q: on stay awake's place (last, nearest the island), whether or
          // not it is showing; same line as every other letter.
          Item {
            x: stripRow.width - width - root.islandSpacing / 2
            width: stayMetrics.advanceWidth
            height: parent.height
            Hint { text: "Q" }
          }
          TextMetrics {
            id: stayMetrics
            font.family: root.iconFamily
            font.pixelSize: root.glyphSize
            text: root.quickItems[root.quickItems.length - 1].icon
          }
        }

        // Hosted stock panel widgets: invisible, under the island that holds
        // their element, so a panel drops from the island its icon lives in.
        Hosts {
          x: Math.round(window.ears.rightCenter)
          ids: root.hostIds.filter(function(id) { return root.statusHostIds.indexOf(id) < 0 })
        }
        Hosts {
          x: Math.round(statusIsland.x + statusIsland.width / 2)
          ids: root.statusHostIds
        }
      }
    }
  }

  // An invisible home for hosted stock bar widgets: their panels drop from
  // its x. One sits under the right island, one under the status island.
  component Hosts: Item {
    property var ids: []
    width: 1
    height: root.barHeight
    opacity: 0
    enabled: false
    Repeater {
      model: parent.ids
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
          if (modelData === root.weatherId) root.weatherLoader = root.loaderIn(item)
          var next = Object.assign({}, root.hosts)
          next[modelData] = item
          if (modelData === root.weatherId) next["omarchy.weather"] = item
          root.hosts = next
        }
      }
    }
  }
}
