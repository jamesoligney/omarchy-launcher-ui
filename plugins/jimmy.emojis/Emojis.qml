import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "../jimmy.shared/Tokens.js" as Tokens
import "../jimmy.shared"
import "EmojiSearch.js" as EmojiSearch

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
  Timer { id: closeTimer; interval: motion.closeHoldMs; onTriggered: root.closing = false }
  property string filterText: ""
  property string selectedCategory: "all"
  // "All" is a chip of its own: Alt (Option) +1 All, +2..9 the categories, +0 the tenth.
  readonly property var chips: [{ id: "all", name: "All" }].concat(((root.data && root.data.categories) || []).filter(function(c) { return !!c && !!c.id }))
  readonly property var chipNames: ({
    "Smileys & Emotion": "Smileys", "People & Body": "People", "Animals & Nature": "Animals",
    "Food & Drink": "Food", "Travel & Places": "Travel"
  })
  function chipKey(i) { return i < 9 ? String(i + 1) : "0" }
  property int selectedIndex: 0
  property bool cursorActive: false
  property var data: ({ categories: [], items: [] })
  property var recents: []
  // Keyboard focus can sit in the Recently used strip (Up from the grid's first row).
  property bool stripFocus: false
  property int stripIndex: 0
  readonly property bool stripVisible: !filterText && recentModel.count > 0
  onStripVisibleChanged: if (!stripVisible) stripFocus = false
  // glyph -> its search words ("em dash mdash ..."), shown when a strip item is selected.
  property var glyphNames: ({})
  property var pins: []

  readonly property string sourceDir: manifest && manifest.__sourceDir ? String(manifest.__sourceDir) : ""
  readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/omarchy"
  readonly property string dataPath: sourceDir ? sourceDir + "/emoji-data.json" : ""
  readonly property string recentsPath: stateDir + "/emoji-recents.json"
  readonly property string pinsPath: stateDir + "/emoji-pins.json"

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
  // Text face: [ui] font in shell.toml (SF Compact Display), else the menu font.
  property string fontFamily: Tokens.str(Commons.Color.shellValues, "ui.font", Style.font.menuFamily)

  property int headerHeight: Math.round(searchSize * 1.35) + searchPaddingY * 2
  property int chipsHeight: Style.space(30)
  property int recentsHeight: cellSize + Style.space(24)
  property int cellSize: Style.space(46)
  property int footerHeight: Style.space(20)
  property int cardWidth: Math.min(Style.space(760), panel.width - Style.gapsOut * 2)
  property int cardHeight: Math.min(Style.space(560), panel.height - Style.gapsOut * 2)
  property int columns: Math.max(1, Math.floor((cardWidth - contentMargin * 2) / cellSize))

  // --------------------------------------------------------------- lifecycle
  function open(payloadJson) {
    root.opened = true
    root.stripFocus = false
    root.stripIndex = 0
    root.filterText = ""
    root.selectedCategory = "all"
    root.selectedIndex = 0
    root.cursorActive = true
    root.rebuildDisplay()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    root.opened = false
  }

  function dismiss() {
    root.opened = false
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "omarchy.emojis")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  function loadData(raw) {
    root.data = EmojiSearch.parseData(raw)
    var names = {}
    for (var i = 0; i < root.data.items.length; i++) names[root.data.items[i].e] = root.data.items[i].k
    root.glyphNames = names
    if (root.opened) root.rebuildDisplay()
  }

  function rebuildDisplay() {
    var results
    if (root.filterText.trim()) {
      results = EmojiSearch.orderByPinsAndRecents(EmojiSearch.search(root.data, root.filterText, 1000), root.pins, [])
    } else {
      results = EmojiSearch.byCategory(root.data, root.selectedCategory)
    }

    displayModel.clear()
    for (var i = 0; i < results.length; i++) {
      displayModel.append({ glyph: results[i].e, pinned: root.pins.indexOf(results[i].e) >= 0, index: i })
    }

    if (displayModel.count === 0) selectedIndex = 0
    else if (selectedIndex >= displayModel.count) selectedIndex = displayModel.count - 1
    else if (selectedIndex < 0) selectedIndex = 0
    cursorActive = displayModel.count > 0

    reloadRecents()
    Qt.callLater(function() {
      if (displayModel.count > 0) resultGrid.positionViewAtIndex(root.selectedIndex, GridView.Contain)
    })
  }

  // -------------------------------------------------------------- recents/pins
  function glyphAt(index) {
    if (index < 0 || index >= displayModel.count) return ""
    return displayModel.get(index).glyph
  }

  function recordRecent(glyph) {
    if (!glyph) return
    var next = [glyph]
    for (var i = 0; i < root.recents.length && next.length < 50; i++) {
      if (root.recents[i] !== glyph) next.push(root.recents[i])
    }
    root.recents = next
    recentsFile.setText(JSON.stringify(next) + "\n")
    reloadRecents()
  }

  function togglePinGlyph(glyph) {
    if (!glyph) return
    var idx = root.pins.indexOf(glyph)
    var next = root.pins.slice()
    if (idx >= 0) next.splice(idx, 1)
    else next.push(glyph)
    root.pins = next
    pinsFile.setText(JSON.stringify(next) + "\n")
    rebuildDisplay()
  }

  function togglePinIndex(index) {
    togglePinGlyph(glyphAt(index))
  }

  function stripGlyph() {
    return root.stripFocus && root.stripIndex < recentModel.count ? recentModel.get(root.stripIndex).glyph : ""
  }

  function stripSelect(delta) {
    root.stripIndex = Math.max(0, Math.min(root.stripIndex + delta, recentModel.count - 1))
    recentList.positionViewAtIndex(root.stripIndex, ListView.Contain)
  }

  // Name line for the selected strip item: first two words bold, the rest muted.
  function stripNameWords() {
    var words = String(root.glyphNames[root.stripGlyph()] || "").split(" ")
    var seen = {}, out = []
    for (var i = 0; i < words.length; i++) {
      if (words[i] && !seen[words[i]]) { seen[words[i]] = true; out.push(words[i]) }
    }
    return out
  }

  function reloadRecents() {
    recentModel.clear()
    var seen = {}
    var i
    for (i = 0; i < root.pins.length; i++) {
      if (seen[root.pins[i]]) continue
      seen[root.pins[i]] = true
      recentModel.append({ glyph: root.pins[i], pinned: true })
    }
    for (i = 0; i < root.recents.length; i++) {
      if (seen[root.recents[i]]) continue
      seen[root.recents[i]] = true
      recentModel.append({ glyph: root.recents[i], pinned: false })
    }
    if (root.stripIndex >= recentModel.count) root.stripIndex = Math.max(0, recentModel.count - 1)
    if (recentModel.count === 0) root.stripFocus = false
  }

  // ------------------------------------------------------------------ actions
  function select(delta) {
    if (displayModel.count === 0) return
    if (!cursorActive) {
      cursorActive = true
      selectedIndex = delta < 0 ? displayModel.count - 1 : 0
    } else {
      selectedIndex = (selectedIndex + delta + displayModel.count) % displayModel.count
    }
    resultGrid.positionViewAtIndex(selectedIndex, GridView.Contain)
  }

  function selectRow(delta) {
    if (displayModel.count === 0) return
    if (!cursorActive) { cursorActive = true; selectedIndex = 0 }
    var newIndex = selectedIndex + delta * columns
    newIndex = Math.max(0, Math.min(newIndex, displayModel.count - 1))
    selectedIndex = newIndex
    resultGrid.positionViewAtIndex(selectedIndex, GridView.Contain)
  }

  function selectPage(delta) {
    if (displayModel.count === 0) return
    if (!cursorActive) { cursorActive = true; selectedIndex = 0 }
    var visibleRows = Math.max(1, Math.floor(resultGrid.height / cellSize))
    var newIndex = selectedIndex + delta * columns * visibleRows
    newIndex = Math.max(0, Math.min(newIndex, displayModel.count - 1))
    selectedIndex = newIndex
    resultGrid.positionViewAtIndex(selectedIndex, GridView.Contain)
  }

  function setFilter(nextFilter) {
    root.stripFocus = false
    root.filterText = nextFilter
    root.selectedIndex = 0
    root.cursorActive = true
    root.rebuildDisplay()
  }

  // Categories only apply while browsing, so a chip key also ends a search.
  function stepCategory(delta) {
    var n = root.chips.length
    for (var i = 0; i < n; i++) if (root.chips[i].id === root.selectedCategory) break
    root.setCategory(root.chips[(i + delta + n) % n].id)
  }

  function setCategory(cat) {
    root.stripFocus = false
    root.filterText = ""
    root.selectedCategory = cat
    root.selectedIndex = 0
    root.cursorActive = true
    root.rebuildDisplay()
  }

  function activateIndex(index) {
    var glyph = glyphAt(index)
    if (!glyph) return
    root.recordRecent(glyph)
    root.dismiss()
    Quickshell.execDetached([root.pasteCmd, "emoji", glyph])
  }

  function activateGlyph(glyph) {
    if (!glyph) return
    root.recordRecent(glyph)
    root.dismiss()
    Quickshell.execDetached([root.pasteCmd, "emoji", glyph])
  }

  ListModel { id: displayModel }
  ListModel { id: recentModel }

  FileView {
    id: dataFile
    path: root.dataPath
    onLoaded: root.loadData(text())
    onLoadFailed: root.loadData("")
  }

  FileView {
    id: recentsFile
    path: root.recentsPath
    watchChanges: false
    atomicWrites: true
    printErrors: false
    onLoaded: {
      try { root.recents = JSON.parse(text()) || [] } catch (e) { root.recents = [] }
      if (!Array.isArray(root.recents)) root.recents = []
      reloadRecents()
    }
    onLoadFailed: root.recents = []
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
      reloadRecents()
    }
    onLoadFailed: root.pins = []
  }

  OverlayWindow {
    id: panel
    shown: (root.opened || root.closing) && root.data.items.length > 0
    shownKeyboardFocus: root.opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "omarchy-emojis"

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
        focus: true

        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function(event) {
          if (event.key === Qt.Key_Escape) {
            if (root.filterText) root.setFilter("")
            else root.dismiss()
            event.accepted = true
          } else if (event.modifiers === Qt.AltModifier && event.key >= Qt.Key_0 && event.key <= Qt.Key_9
                     && (event.key === Qt.Key_0 ? 10 : event.key - Qt.Key_0) <= root.chips.length) {
            root.setCategory(root.chips[event.key === Qt.Key_0 ? 9 : event.key - Qt.Key_1].id)
            event.accepted = true
          } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
            root.stepCategory(event.key === Qt.Key_Backtab || (event.modifiers & Qt.ShiftModifier) ? -1 : 1)
            event.accepted = true
          } else if (Util.editsFilter(event, root.filterText)) {
            root.setFilter(Util.editedFilter(event, root.filterText))
            event.accepted = true
          } else if (event.modifiers === Qt.AltModifier && event.key === Qt.Key_P) {
            if (root.stripFocus) root.togglePinGlyph(root.stripGlyph())
            else root.togglePinIndex(root.selectedIndex)
            event.accepted = true
          } else if (Util.readingKey(event) === Qt.Key_Left) {
            if (root.stripFocus) root.stripSelect(-1)
            else root.select(-1)
            event.accepted = true
          } else if (Util.readingKey(event) === Qt.Key_Right) {
            if (root.stripFocus) root.stripSelect(1)
            else root.select(1)
            event.accepted = true
          } else if (event.key === Qt.Key_Up) {
            // From the grid's first row, Up moves into the Recently used strip.
            if (root.stripFocus) { }
            else if (root.selectedIndex < root.columns && root.stripVisible) { root.stripFocus = true; root.stripSelect(0) }
            else root.selectRow(-1)
            event.accepted = true
          } else if (event.key === Qt.Key_Down) {
            if (root.stripFocus) root.stripFocus = false
            else root.selectRow(1)
            event.accepted = true
          } else if (event.key === Qt.Key_PageUp) {
            root.stripFocus = false
            root.selectPage(-1)
            event.accepted = true
          } else if (event.key === Qt.Key_PageDown) {
            root.stripFocus = false
            root.selectPage(1)
            event.accepted = true
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (root.stripFocus) root.activateGlyph(root.stripGlyph())
            else if (root.cursorActive) root.activateIndex(root.selectedIndex)
            else if (displayModel.count > 0) root.cursorActive = true
            event.accepted = true
          } else if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127) {
            root.setFilter(root.filterText + event.text)
            event.accepted = true
          }
        }
      }

      Column {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: Style.space(8)

        // Search field
        Rectangle {
          width: parent.width
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
            text: root.filterText || "Search for emojis and symbols…"
            color: root.foreground
            opacity: root.filterText ? 1 : 0.55
            font.family: root.fontFamily
            font.pixelSize: root.searchSize
            elide: Text.ElideRight
          }
        }

        // Category chips (browse mode only)
        Row {
          id: chipsRow
          visible: !root.filterText
          width: parent.width
          height: root.chipsHeight
          spacing: Style.space(8)

          Repeater {
            model: root.chips

            delegate: Rectangle {
              required property var modelData
              required property int index
              readonly property string catId: modelData.id
              readonly property string catName: modelData.name
              width: chipContent.implicitWidth + Style.space(10)
              height: root.chipsHeight
              radius: root.chipsHeight / 2
              color: root.selectedCategory === catId ? root.selectedBackground : "transparent"
              border.color: root.selectedCategory === catId ? root.border : "transparent"
              border.width: 1

              Row {
                id: chipContent
                anchors.centerIn: parent
                spacing: Style.space(4)
                Text {
                  id: chipText
                  text: root.chipNames[catName] || catName
                  color: root.selectedCategory === catId ? root.selectedText : root.mutedText
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                }
                Text {
                  anchors.baseline: chipText.baseline
                  text: "\u2325" + root.chipKey(index)
                  color: root.hintText
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption - 1
                }
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.setCategory(catId)
              }
            }
          }
        }

        // Recently used strip (browse mode only)
        Item {
          visible: !root.filterText && recentModel.count > 0
          width: parent.width
          height: root.recentsHeight

          Text {
            id: recentsLabel
            textFormat: Text.PlainText
            text: "Recently used"
            color: root.mutedText
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
          }

          // Name of the selected strip item, so a symbol like an em dash is legible.
          Row {
            visible: root.stripFocus
            anchors.left: recentsLabel.right
            anchors.leftMargin: Style.space(12)
            anchors.verticalCenter: recentsLabel.verticalCenter
            spacing: Style.space(5)
            Text {
              text: root.stripNameWords().slice(0, 2).join(" ")
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
            }
            Text {
              text: root.stripNameWords().slice(2).join(" ")
              color: root.mutedText
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
            }
          }

          ListView {
            id: recentList
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: recentsLabel.bottom
            anchors.bottom: parent.bottom
            anchors.topMargin: Style.space(4)
            orientation: ListView.Horizontal
            model: recentModel
            clip: true
            spacing: Style.space(6)
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
              required property int index
              required property string glyph
              required property bool pinned

              readonly property bool current: root.stripFocus && index === root.stripIndex

              width: root.cellSize
              height: root.cellSize
              radius: root.rowRadius
              color: current ? root.selectedBackground : Util.alpha(root.foreground, 0.07)
              border.width: 1
              border.color: current ? root.border : Util.alpha(root.foreground, pinned ? 0.35 : 0.14)

              Text {
                textFormat: Text.PlainText
                text: parent.glyph
                anchors.centerIn: parent
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.displayLarge
              }

              Text {
                textFormat: Text.PlainText
                text: "📌"
                visible: parent.pinned
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: Style.space(2)
                font.pixelSize: Style.font.caption
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.activateGlyph(parent.glyph)
              }
            }
          }
        }

        // Results grid
        Item {
          width: parent.width
          height: parent.height - root.headerHeight - Style.space(8)
            - (chipsRow.visible ? root.chipsHeight + Style.space(8) : 0)
            - (recentModel.count > 0 && !root.filterText ? root.recentsHeight + Style.space(8) : 0)
            - root.footerHeight - Style.space(8)

          GridView {
            id: resultGrid
            anchors.fill: parent
            model: displayModel
            clip: true
            cellWidth: root.cellSize
            cellHeight: root.cellSize
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
              required property int index
              required property string glyph
              required property bool pinned

              readonly property bool hasCursor: root.cursorActive && !root.stripFocus && index === root.selectedIndex

              width: root.cellSize
              height: root.cellSize
              radius: root.rowRadius
              color: hasCursor ? root.selectedBackground : "transparent"

              Text {
                textFormat: Text.PlainText
                text: parent.glyph
                anchors.centerIn: parent
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.display
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
              }

              Text {
                textFormat: Text.PlainText
                text: "📌"
                visible: parent.pinned
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: Style.space(3)
                anchors.topMargin: Style.space(1)
                font.pixelSize: Style.font.caption
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onContainsMouseChanged: if (containsMouse) {
                  root.stripFocus = false
                  root.cursorActive = true
                  root.selectedIndex = index
                }
                onClicked: {
                  root.cursorActive = true
                  root.selectedIndex = index
                  root.activateIndex(index)
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
              text: "󰈉"
              color: root.selectedText
              opacity: 0.8
              font.family: root.fontFamily
              font.pixelSize: Style.font.displayLarge
              horizontalAlignment: Text.AlignHCenter
              width: parent.width
            }

            Text {
              textFormat: Text.PlainText
              text: root.filterText ? "No matches for \"" + root.filterText + "\"" : "Nothing here yet"
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
          text: "Enter paste   ·   ⌥P pin   ·   ↑ recent   ·   ⌥1–0 or Tab category   ·   Esc close"
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
