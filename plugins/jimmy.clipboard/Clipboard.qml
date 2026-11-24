import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "../jimmy.shared"
import "ClipboardHistory.js" as ClipboardHistory

Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  // Shared paste helper. Firefox-family apps get Ctrl+V (Floorp does not
  // implement Shift+Insert). Terminals get Ctrl+Shift+V (Shift+Insert there
  // is the primary selection). Everything else keeps stock Shift+Insert.
  property string pasteCmd: Quickshell.env("HOME") + "/.local/bin/omarchy-launcher-paste"
  property var shell: null
  property var manifest: null

  property bool opened: false
  // The layer outlives `opened` by the close animation; keyboard focus does
  // not, so a paste fired on dismiss reaches the app underneath at once.
  property bool closing: false
  onOpenedChanged: {
    if (opened) {
      if (closing) { closing = false; closeTimer.stop(); motion.play() }
    } else {
      closing = true
      closeTimer.restart()
      motion.hide()
    }
  }
  Timer { id: closeTimer; interval: 115; onTriggered: root.closing = false }
  property string filterText: ""
  property string typeFilter: "all"
  readonly property var typeFilters: [
    { id: "all", label: "All" },
    { id: "text", label: "Text" },
    { id: "image", label: "Images" },
    { id: "file", label: "Files" }
  ]
  property int selectedIndex: 0
  property bool cursorActive: false
  property bool clearConfirmOpen: false
  property var history: []
  property var pins: []
  property bool paused: false

  readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/omarchy"
  property string historyPath: stateDir + "/clipboard-history.json"
  property string pinsPath: stateDir + "/clipboard-pins.json"
  property string pausedPath: stateDir + "/clipboard-paused"
  property string captureScript: root.omarchyPath + "/shell/plugins/clipboard/capture.sh"

  // ------------------------------------------------------------ design tokens
  // Same [launcher] token block the launcher reads, so the picker shares the
  // launcher's theme-aware glass, radius and typography and re-tints on a
  // theme switch.
  readonly property var launcherTokens: Commons.Color.shellValues

  function tokenRaw(key, fallback) {
    var value = launcherTokens["launcher." + key]
    if (value === undefined || value === null || String(value).length === 0) return fallback
    return value
  }
  function tokenNum(key, fallback) {
    var value = Number(tokenRaw(key, ""))
    return isFinite(value) ? value : fallback
  }
  function tokenAlpha(key, fallback) {
    var value = Number(tokenRaw(key, ""))
    return isFinite(value) ? Util.clampAlpha(value) : fallback
  }
  function tokenFallbackColor(role) {
    if (role === "accent") return Commons.Color.accent
    if (role === "urgent") return Commons.Color.urgent
    if (role === "muted") return Commons.Color.muted
    if (role === "background") return Commons.Color.background
    return Commons.Color.foreground
  }
  function tokenColor(key, fallbackRole) {
    return Commons.Color.flatColor(tokenRaw(key, fallbackRole), tokenFallbackColor(fallbackRole))
  }

  property color background: Util.alpha(tokenColor("panel-background", "background"), tokenAlpha("panel-background-alpha", 0.84))
  property color foreground: tokenColor("text", "foreground")
  property color border: tokenColor("panel-border", "accent")
  property var borderSpec: Border.surfaceSpec("launcher", "panel-border", border, 1)
  property color scrim: Util.alpha(tokenColor("scrim", "background"), tokenAlpha("scrim-alpha", 0.35))
  property color selectedBackground: Util.alpha(tokenColor("selected-background", "accent"), tokenAlpha("selected-background-alpha", 0.16))
  property color selectedText: tokenColor("selected-text", "foreground")
  property color mutedText: Util.alpha(tokenColor("muted", "foreground"), tokenAlpha("muted-alpha", 0.55))
  property color hintText: Util.alpha(foreground, tokenAlpha("hint-alpha", 0.62))

  readonly property int cornerRadius: tokenNum("panel-radius", 16)
  readonly property int rowRadius: tokenNum("row-radius", 10)
  property int contentMargin: tokenNum("panel-padding", 12)
  property int searchPaddingX: tokenNum("search-padding-x", 16)
  property int searchPaddingY: tokenNum("search-padding-y", 12)
  property int searchSize: tokenNum("search-size", 20)
  property string fontFamily: Style.font.menuFamily

  property int headerHeight: Math.round(searchSize * 1.35) + searchPaddingY * 2
  property int filterHeight: Style.space(30)
  property int footerHeight: Style.space(20)
  property int cardWidth: Math.min(Style.space(920), panel.width - Style.gapsOut * 2)
  property int cardHeight: Math.min(Style.space(600), panel.height - Style.gapsOut * 2)
  property int rowHeight: Math.max(Style.space(50), Style.font.body + Style.font.caption + Style.spacing.rowPaddingX * 2)
  property int historyLimit: 500

  // --------------------------------------------------------------- lifecycle
  function open(payloadJson) {
    root.opened = true
    root.filterText = ""
    root.typeFilter = "all"
    root.selectedIndex = 0
    root.cursorActive = true
    root.disarmPointer()
    root.rebuildDisplay()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.cancelClearHistory()
    root.opened = false
  }

  function dismiss() {
    root.opened = false
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "omarchy.clipboard")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  // ----------------------------------------------------------------- history
  function loadHistory(raw) {
    root.history = ClipboardHistory.parseHistory(raw)
    if (root.opened) root.rebuildDisplay()
  }

  function saveHistory() {
    historyFile.setText(JSON.stringify(root.history.slice(0, root.historyLimit), null, 2) + "\n")
  }

  function addClipboardEntry(entry) {
    var normalized = ClipboardHistory.normalizeEntry(entry)
    if (!normalized) return
    if (!normalized.capturedAtMs) normalized.capturedAtMs = Date.now()
    root.history = ClipboardHistory.addEntry(root.history, normalized, root.historyLimit)
    root.saveHistory()
    if (root.opened) root.rebuildDisplay()
  }

  function addClipboardJson(line) {
    root.addClipboardEntry(ClipboardHistory.parseEntryJson(line))
  }

  function requestClearHistory() {
    if (root.history.length === 0) return
    clearConfirm.selectedIndex = 1
    root.clearConfirmOpen = true
  }

  function cancelClearHistory() {
    root.clearConfirmOpen = false
    root.disarmPointer()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function confirmClearHistory() {
    root.history = ClipboardHistory.clearHistory()
    root.saveHistory()
    root.selectedIndex = 0
    root.cursorActive = false
    root.disarmPointer()
    root.clearConfirmOpen = false
    root.rebuildDisplay()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function removeDisplayIndex(index) {
    if (index < 0 || index >= displayModel.count) return
    var row = displayModel.get(index)
    root.history = ClipboardHistory.removeEntryAt(root.history, row.historyIndex)
    root.saveHistory()
    if (displayModel.count <= 1) {
      root.selectedIndex = 0
      root.cursorActive = false
    } else if (root.selectedIndex >= displayModel.count - 1) {
      root.selectedIndex = displayModel.count - 2
    }
    root.disarmPointer()
    root.rebuildDisplay()
  }

  // ------------------------------------------------------------------- pins
  function togglePinSelected() {
    var row = root.currentRow()
    if (!row) return
    var idx = root.pins.indexOf(row.pinKey)
    var next = root.pins.slice()
    if (idx >= 0) next.splice(idx, 1)
    else next.push(row.pinKey)
    root.pins = next
    pinsFile.setText(JSON.stringify(next) + "\n")
    root.rebuildDisplay()
  }

  function currentRow() {
    return displayModel.count > 0 && root.selectedIndex >= 0 && root.selectedIndex < displayModel.count ? displayModel.get(root.selectedIndex) : null
  }

  // ------------------------------------------------------------------ pause
  function togglePause() {
    root.setPaused(!root.paused)
  }

  function setPaused(value) {
    root.paused = value
    pausedFile.setText(value ? "1\n" : "0\n")
    applyPause()
  }

  function applyPause() {
    if (root.paused) {
      watchRestartTimer.stop()
      textWatchProc.running = false
      imageWatchProc.running = false
    } else {
      if (!textWatchProc.running) textWatchProc.running = true
      if (!imageWatchProc.running) imageWatchProc.running = true
    }
  }

  function rebuildDisplay() {
    var rows = ClipboardHistory.displayRows(root.history, root.filterText, root.typeFilter, 200, Commons.I18n.t, Commons.I18n.tn, Commons.I18n.formatNumber)
    rows = ClipboardHistory.orderByPins(rows, root.pins)

    displayModel.clear()
    for (var i = 0; i < rows.length; i++) {
      var row = rows[i]
      displayModel.append({
        entryType: row.entryType,
        fullText: row.fullText,
        previewText: row.previewText,
        previewImage: row.previewImage ? Util.fileUrl(row.previewImage) : "",
        path: row.path,
        mime: row.mime,
        pinKey: row.pinKey,
        pinned: row.pinned === true,
        timeText: row.timeText,
        sizeText: row.sizeText,
        historyIndex: row.index
      })
    }

    if (displayModel.count === 0) selectedIndex = 0
    else if (selectedIndex >= displayModel.count) selectedIndex = displayModel.count - 1
    else if (selectedIndex < 0) selectedIndex = 0

    Qt.callLater(function() {
      if (displayModel.count > 0) resultList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
    })
  }

  Connections {
    target: Commons.I18n
    function onStringsChanged() { if (root.opened) root.rebuildDisplay() }
  }

  function select(delta) {
    if (displayModel.count === 0) return
    root.disarmPointer()
    if (!cursorActive) {
      cursorActive = true
      selectedIndex = delta < 0 ? displayModel.count - 1 : 0
    } else {
      selectedIndex = (selectedIndex + delta + displayModel.count) % displayModel.count
    }
    resultList.positionViewAtIndex(selectedIndex, ListView.Contain)
  }

  function selectAbsolute(index) {
    if (displayModel.count === 0) return
    root.disarmPointer()
    root.cursorActive = true
    root.selectedIndex = Math.max(0, Math.min(index, displayModel.count - 1))
    resultList.positionViewAtIndex(root.selectedIndex, ListView.Contain)
  }

  function setFilter(nextFilter) {
    root.filterText = nextFilter
    root.selectedIndex = 0
    root.cursorActive = true
    root.disarmPointer()
    root.rebuildDisplay()
  }

  // Alt (Option) +1..4 jump to a chip; Tab / Left / Right (and the shifted forms) step.
  function stepTypeFilter(delta) {
    var n = root.typeFilters.length
    for (var i = 0; i < n; i++) if (root.typeFilters[i].id === root.typeFilter) break
    root.setTypeFilter(root.typeFilters[(i + delta + n) % n].id)
  }

  function setTypeFilter(t) {
    root.typeFilter = t
    root.selectedIndex = 0
    root.cursorActive = true
    root.disarmPointer()
    root.rebuildDisplay()
  }

  function disarmPointer() {
    pointerGate.reset()
  }

  function selectFromPointer(index, item, mouse) {
    if (!pointerGate.moved(item, mouse)) return
    root.cursorActive = true
    root.selectedIndex = index
  }

  function activateIndex(index) {
    if (index < 0 || index >= displayModel.count) return
    var row = displayModel.get(index)
    root.applySelected(row)
  }

  function copyIndex(index) {
    if (index < 0 || index >= displayModel.count) return
    var row = displayModel.get(index)
    root.copySelected(row)
  }

  function openIndex(index) {
    if (index < 0 || index >= displayModel.count) return
    var row = displayModel.get(index)
    root.openSelected(row)
  }

  function applySelected(row) {
    if (!row) return
    root.dismiss()
    if (row.entryType === "image") {
      Quickshell.execDetached([root.pasteCmd, "file", row.mime, row.path])
    } else if (row.fullText) {
      Quickshell.execDetached([root.pasteCmd, "text", "--history-index", String(row.historyIndex)])
    }
  }

  function copySelected(row) {
    if (!row) return
    root.dismiss()
    if (row.entryType === "image") {
      Quickshell.execDetached([root.omarchyPath + "/bin/omarchy-clipboard-paste-file", "--copy-only", row.mime, row.path])
    } else if (row.fullText) {
      Quickshell.execDetached([root.omarchyPath + "/bin/omarchy-clipboard-paste-text", "--copy-only", "--history-index", String(row.historyIndex)])
    }
  }

  function openSelected(row) {
    if (!row) return
    root.dismiss()
    Quickshell.execDetached([root.omarchyPath + "/bin/omarchy-clipboard-open", "--history-index", String(row.historyIndex)])
  }

  Component.onCompleted: initProc.running = true

  ListModel { id: displayModel }

  PointerMoveGate {
    id: pointerGate
    referenceItem: card
  }

  FileView {
    id: historyFile
    path: root.historyPath
    watchChanges: true
    atomicWrites: true
    printErrors: false
    onLoaded: root.loadHistory(text())
    onLoadFailed: root.loadHistory("[]")
    onFileChanged: reload()
  }

  FileView {
    id: pinsFile
    path: root.pinsPath
    watchChanges: false
    atomicWrites: true
    printErrors: false
    onLoaded: {
      try { root.pins = JSON.parse(text()) || [] } catch (e) { root.pins = [] }
      if (!Array.isArray(root.pins)) root.pins = []
    }
    onLoadFailed: root.pins = []
  }

  FileView {
    id: pausedFile
    path: root.pausedPath
    watchChanges: false
    atomicWrites: true
    printErrors: false
    onLoaded: { root.paused = String(text()).trim() === "1"; root.applyPause() }
    onLoadFailed: root.paused = false
  }

  // Reap watchers left behind by a previous shell instance, then start our
  // own. The pdeathsig on the watchers makes the kernel kill them whenever
  // the shell exits, however it exits, so no further lifecycle management.
  Process {
    id: initProc
    command: ["pkill", "-f", "wl-paste .*--watch .*/shell/plugins/clipboard/capture\\.sh"]
    onExited: {
      currentProc.running = true
      if (!root.paused) {
        textWatchProc.running = true
        imageWatchProc.running = true
      }
    }
  }

  Process {
    id: currentProc
    command: [root.captureScript]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.addClipboardJson(text)
    }
  }

  Process {
    id: textWatchProc
    command: ["setpriv", "--pdeathsig", "TERM", "wl-paste", "--type", "text", "--watch", root.captureScript, "text"]
    onExited: watchRestartTimer.restart()
    stdout: SplitParser {
      onRead: function(data) { root.addClipboardJson(data) }
    }
  }

  Process {
    id: imageWatchProc
    command: ["setpriv", "--pdeathsig", "TERM", "wl-paste", "--type", "image/png", "--watch", root.captureScript, "image/png"]
    onExited: watchRestartTimer.restart()
    stdout: SplitParser {
      onRead: function(data) { root.addClipboardJson(data) }
    }
  }

  Timer {
    id: watchRestartTimer
    interval: 1000
    repeat: false
    onTriggered: {
      if (root.paused) return
      if (!textWatchProc.running) textWatchProc.running = true
      if (!imageWatchProc.running) imageWatchProc.running = true
    }
  }

  OverlayWindow {
    id: panel
    shown: root.opened || root.closing
    shownKeyboardFocus: root.opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "omarchy-clipboard"

    Rectangle {
      id: scrimRect
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismiss()
    }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: root.cardHeight
      radius: root.cornerRadius
      anchors.centerIn: parent
      color: root.background
      borderSpec: root.borderSpec
      padding: root.contentMargin
      transformOrigin: Item.Center
      transform: Scale {
        origin.x: card.width / 2
        origin.y: card.height / 2
        xScale: motion.xScale
        yScale: motion.yScale
      }

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        z: root.clearConfirmOpen ? 20 : 0
        focus: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          if (root.clearConfirmOpen) {
            if (clearConfirm.handleKey(event)) event.accepted = true
            return
          }

          if (event.key === Qt.Key_Escape) {
            if (root.filterText) root.setFilter("")
            else root.dismiss()
            event.accepted = true
          } else if (event.modifiers === Qt.AltModifier && event.key >= Qt.Key_1 && event.key < Qt.Key_1 + root.typeFilters.length) {
            root.setTypeFilter(root.typeFilters[event.key - Qt.Key_1].id)
            event.accepted = true
          } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab
                     || ((event.key === Qt.Key_Left || event.key === Qt.Key_Right) && !(event.modifiers & ~Qt.KeypadModifier))) {
            root.stepTypeFilter(event.key === Qt.Key_Backtab || event.key === Qt.Key_Left || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier)) ? -1 : 1)
            event.accepted = true
          } else if (Util.editsFilter(event, root.filterText)) {
            root.setFilter(Util.editedFilter(event, root.filterText))
            event.accepted = true
          } else if (event.modifiers === Qt.AltModifier && event.key === Qt.Key_P) {
            root.togglePinSelected()
            event.accepted = true
          } else if (event.modifiers === Qt.AltModifier && event.key === Qt.Key_S) {
            root.togglePause()
            event.accepted = true
          } else if (event.key === Qt.Key_Delete) {
            if (event.modifiers & Qt.ShiftModifier) root.requestClearHistory()
            else root.removeDisplayIndex(root.selectedIndex)
            event.accepted = true
          } else if (event.key === Qt.Key_Up) {
            root.select(-1)
            event.accepted = true
          } else if (event.key === Qt.Key_Down) {
            root.select(1)
            event.accepted = true
          } else if (event.key === Qt.Key_PageUp) {
            root.select(-6)
            event.accepted = true
          } else if (event.key === Qt.Key_PageDown) {
            root.select(6)
            event.accepted = true
          } else if (event.key === Qt.Key_Home) {
            root.selectAbsolute(0)
            event.accepted = true
          } else if (event.key === Qt.Key_End) {
            root.selectAbsolute(displayModel.count - 1)
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (root.cursorActive && (event.modifiers & Qt.AltModifier)) root.openIndex(root.selectedIndex)
            else if (root.cursorActive && (event.modifiers & Qt.ShiftModifier)) root.copyIndex(root.selectedIndex)
            else if (root.cursorActive) root.activateIndex(root.selectedIndex)
            else if (displayModel.count > 0) root.cursorActive = true
            event.accepted = true
          } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127) {
            root.setFilter(root.filterText + event.text)
            event.accepted = true
          }
        }

        ConfirmDialog {
          id: clearConfirm

          anchors.fill: parent
          opened: root.clearConfirmOpen
          z: 10
          message: "Clear the entire clipboard history?"
          confirmText: "Delete"
          background: root.background
          foreground: root.foreground
          scrim: root.scrim
          selectedBackground: root.selectedBackground
          selectedText: root.selectedText
          fontFamily: root.fontFamily
          cornerRadius: root.cornerRadius
          onCanceled: root.cancelClearHistory()
          onConfirmed: root.confirmClearHistory()
        }
      }

      Column {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: Style.space(8)

        // Header: search + pause
        Row {
          width: parent.width
          height: root.headerHeight
          spacing: Style.space(8)

          Rectangle {
            width: parent.width - pauseBtn.width - parent.spacing
            height: root.headerHeight
            radius: root.rowRadius
            color: Util.alpha(root.foreground, 0.06)

            Text {
              textFormat: Text.PlainText
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.leftMargin: root.searchPaddingX
              anchors.rightMargin: root.searchPaddingX
              anchors.verticalCenter: parent.verticalCenter
              text: root.filterText || "Browse clipboard history…"
              color: root.foreground
              opacity: root.filterText ? 1 : 0.55
              font.family: root.fontFamily
              font.pixelSize: root.searchSize
              elide: Text.ElideRight
            }
          }

          Rectangle {
            id: pauseBtn
            width: pauseContent.implicitWidth + Style.space(28)
            height: root.headerHeight
            radius: root.rowRadius
            color: root.paused ? root.selectedBackground : "transparent"
            border.color: root.paused ? root.border : root.mutedText
            border.width: 1

            Row {
              id: pauseContent
              anchors.centerIn: parent
              spacing: Style.space(6)
              Text {
                id: pauseText
                text: root.paused ? "▶ Resume" : "⏸ Pause"
                color: root.paused ? root.selectedText : root.mutedText
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
              }
              Text {
                anchors.baseline: pauseText.baseline
                text: "\u2325S"
                color: root.hintText
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption - 1
              }
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: root.togglePause()
            }
          }
        }

        // Type filter chips
        Row {
          id: filterRow
          width: parent.width
          height: root.filterHeight
          spacing: Style.space(8)

          Repeater {
            model: root.typeFilters
            // Chips carry their Option+number so the shortcut is learned by looking.

            delegate: Rectangle {
              required property var modelData
              required property int index
              readonly property string filterId: modelData.id
              readonly property string filterLabel: modelData.label

              width: chipContent.implicitWidth + Style.space(24)
              height: root.filterHeight
              radius: root.filterHeight / 2
              color: root.typeFilter === filterId ? root.selectedBackground : "transparent"
              border.color: root.typeFilter === filterId ? root.border : "transparent"
              border.width: 1

              Row {
                id: chipContent
                anchors.centerIn: parent
                spacing: Style.space(6)
                Text {
                  id: chipText
                  text: filterLabel
                  color: root.typeFilter === filterId ? root.selectedText : root.mutedText
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                }
                Text {
                  anchors.baseline: chipText.baseline
                  text: "\u2325" + (index + 1)
                  color: root.hintText
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption - 1
                }
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.setTypeFilter(filterId)
              }
            }
          }
        }

        // List + detail
        Item {
          width: parent.width
          height: parent.height - root.headerHeight - root.filterHeight - root.footerHeight - Style.space(8) * 3

          Row {
            anchors.fill: parent
            spacing: 0

            Item {
              width: parent.width / 2
              height: parent.height
              clip: true

              ListView {
                id: resultList
                anchors.fill: parent
                anchors.rightMargin: root.contentMargin
                model: displayModel
                clip: true
                spacing: Style.space(4)
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                  id: row
                  required property int index
                  required property string entryType
                  required property string previewText
                  required property string fullText
                  required property string previewImage
                  required property string timeText
                  required property bool pinned

                  readonly property bool hasCursor: root.cursorActive && index === root.selectedIndex

                  width: ListView.view.width
                  height: root.rowHeight
                  radius: root.rowRadius
                  color: hasCursor ? root.selectedBackground : "transparent"

                  Row {
                    anchors.fill: parent
                    anchors.leftMargin: Style.space(12)
                    anchors.rightMargin: Style.space(12)
                    anchors.topMargin: Style.space(8)
                    anchors.bottomMargin: Style.space(8)
                    spacing: Style.space(10)

                    SizedImage {
                      visible: row.previewImage.length > 0
                      width: visible ? parent.height : 0
                      height: parent.height
                      url: row.previewImage
                      asynchronous: true
                      smooth: true
                    }

                    Column {
                      width: parent.width - (row.previewImage.length > 0 ? parent.height + parent.spacing : 0)
                      height: parent.height
                      spacing: Style.space(1)

                      Text {
                        textFormat: Text.PlainText
                        width: parent.width
                        text: row.previewText
                        color: row.hasCursor ? root.selectedText : root.foreground
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.title
                        opacity: row.entryType === "image" || row.entryType === "file" ? 0.72 : 1.0
                        elide: Text.ElideRight
                      }

                      Text {
                        textFormat: Text.PlainText
                        width: parent.width
                        text: (row.pinned ? "📌 " : "") + row.timeText
                        color: root.mutedText
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.caption
                        elide: Text.ElideRight
                      }
                    }
                  }

                  MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPositionChanged: function(mouse) {
                      root.selectFromPointer(row.index, row, mouse)
                    }
                    onClicked: {
                      root.cursorActive = true
                      root.selectedIndex = row.index
                      root.activateIndex(row.index)
                    }
                  }
                }
              }
            }

            Item {
              id: detailPane
              width: parent.width / 2
              height: parent.height
              clip: true

              property var activeRow: root.currentRow()

              Rectangle {
                visible: displayModel.count > 0
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Style.normalBorderWidth
                color: Util.alpha(root.border, 0.28)
              }

              Column {
                anchors.fill: parent
                anchors.leftMargin: root.contentMargin
                spacing: Style.space(8)

                Row {
                  width: parent.width - root.contentMargin
                  height: Style.space(24)
                  spacing: Style.space(8)

                  Text {
                    textFormat: Text.PlainText
                    width: parent.width - pinButton.width - parent.spacing
                    height: parent.height
                    text: detailPane.activeRow
                      ? (detailPane.activeRow.entryType === "file" ? "File" : (detailPane.activeRow.entryType === "image" ? "Image" : "Text"))
                        + "   ·   " + detailPane.activeRow.sizeText
                        + (detailPane.activeRow.timeText ? "   ·   " + detailPane.activeRow.timeText : "")
                      : ""
                    color: root.mutedText
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                  }

                  Rectangle {
                    id: pinButton
                    width: pinContent.implicitWidth + Style.space(20)
                    height: parent.height
                    radius: parent.height / 2
                    visible: detailPane.activeRow !== null
                    color: detailPane.activeRow && detailPane.activeRow.pinned ? root.selectedBackground : "transparent"
                    border.color: detailPane.activeRow && detailPane.activeRow.pinned ? root.border : root.mutedText
                    border.width: 1

                    Row {
                      id: pinContent
                      anchors.centerIn: parent
                      spacing: Style.space(6)
                      Text {
                        id: pinText
                        text: detailPane.activeRow && detailPane.activeRow.pinned ? "📌 Pinned" : "📌 Pin"
                        color: detailPane.activeRow && detailPane.activeRow.pinned ? root.selectedText : root.mutedText
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.caption
                      }
                      Text {
                        anchors.baseline: pinText.baseline
                        text: "\u2325P"
                        color: root.hintText
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.caption - 1
                      }
                    }

                    MouseArea {
                      anchors.fill: parent
                      cursorShape: Qt.PointingHandCursor
                      onClicked: root.togglePinSelected()
                    }
                  }
                }

                Text {
                  textFormat: Text.PlainText
                  visible: detailPane.activeRow && !detailPane.activeRow.previewImage
                  width: parent.width - root.contentMargin
                  height: parent.height - Style.space(24) - Style.space(8)
                  text: detailPane.activeRow ? detailPane.activeRow.fullText : ""
                  color: root.foreground
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.title
                  wrapMode: Text.WrapAnywhere
                  elide: Text.ElideRight
                  verticalAlignment: Text.AlignTop
                }

                SizedImage {
                  visible: detailPane.activeRow && detailPane.activeRow.previewImage
                  width: parent.width - root.contentMargin
                  height: parent.height - Style.space(24) - Style.space(8)
                  url: detailPane.activeRow ? detailPane.activeRow.previewImage : ""
                  verticalAlignment: Image.AlignTop
                  asynchronous: true
                  smooth: true
                }
              }
            }
          }

          Column {
            anchors.centerIn: parent
            width: parent.width - 2 * root.contentMargin
            spacing: Style.space(8)
            visible: displayModel.count === 0

            Text {
              text: "󰅌"
              color: root.selectedText
              opacity: 0.8
              font.family: root.fontFamily
              font.pixelSize: Style.font.displayLarge
              horizontalAlignment: Text.AlignHCenter
              anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
              textFormat: Text.PlainText
              text: root.history.length === 0 ? "Clipboard is empty" : "No matches for \"" + root.filterText + "\""
              color: root.foreground
              opacity: 0.7
              font.family: root.fontFamily
              font.pixelSize: Style.font.title
              horizontalAlignment: Text.AlignHCenter
              width: parent.width
              elide: Text.ElideRight
            }
          }
        }

        // Footer hint
        Text {
          textFormat: Text.PlainText
          width: parent.width
          text: "Enter paste   ·   ⇧Enter copy   ·   ⌥Enter open   ·   ⌥P pin   ·   ⌥S pause   ·   Del remove   ·   ⇧Del clear   ·   Esc close"
          color: root.mutedText
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          horizontalAlignment: Text.AlignRight
        }
      }
    }
  }

  CardMotion { id: motion; card: card; scrim: scrimRect }

  Connections {
    target: panel
    function onShownChanged() {
      if (panel.shown) motion.play()
      else motion.stop()
    }
  }
}
