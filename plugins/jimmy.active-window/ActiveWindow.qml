import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.active-window"


  readonly property var toplevel: ToplevelManager.activeToplevel
  readonly property string appId: toplevel ? (toplevel.appId || "") : ""
  readonly property string windowTitle: toplevel ? (toplevel.title || "") : ""
  // Friendly app name from the desktop entry; fall back to the app id.
  readonly property string appName: {
    if (appId === "") return ""
    var entry = DesktopEntries.heuristicLookup(appId)
    if (entry && entry.name) return entry.name
    var last = appId.split(".").pop()
    return last.charAt(0).toUpperCase() + last.slice(1)
  }
  // Tooltip / fallback text.
  readonly property string title: appName !== "" && windowTitle !== "" && windowTitle !== appName
    ? appName + " \u2014 " + windowTitle : (windowTitle || appName)
  readonly property int maxLabelWidth: Number(setting("maxWidth", 460))

  visible: title !== "" && !vertical
  implicitWidth: visible ? Math.min(maxLabelWidth, appText.implicitWidth + (titleText.visible ? sep.implicitWidth + titleText.implicitWidth : 0)) + Style.spacing.controlPaddingX * 2 : 0
  implicitHeight: barSize

  Behavior on implicitWidth {
    NumberAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic }
  }

  Item {
    anchors.fill: parent
    anchors.leftMargin: Style.space(8)
    anchors.rightMargin: Style.space(8)
    clip: true

    Row {
      anchors.top: parent.top
      anchors.left: parent.left
      width: parent.width
      height: parent.height
      spacing: 0

      Text {
        id: appText
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        textFormat: Text.PlainText
        text: root.appName
        color: root.bar ? root.bar.barForeground : Commons.Color.foreground
        font.family: root.bar ? root.bar.fontFamily : Style.font.family
        font.pixelSize: Style.font.body
        font.bold: true
        elide: Text.ElideRight
        width: Math.min(implicitWidth, parent.width)
      }
      Text {
        id: sep
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        visible: titleText.visible
        textFormat: Text.PlainText
        text: "  \u00b7  "
        color: root.bar ? root.bar.barForeground : Commons.Color.foreground
        font.family: appText.font.family
        font.pixelSize: Style.font.body
        opacity: 0.4
      }
      Text {
        id: titleText
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        visible: root.windowTitle !== "" && root.windowTitle !== root.appName
        textFormat: Text.PlainText
        text: root.windowTitle
        color: root.bar ? root.bar.barForeground : Commons.Color.foreground
        font.family: appText.font.family
        font.pixelSize: Style.font.body
        elide: Text.ElideRight
        opacity: 0.85
        width: Math.max(0, parent.width - appText.width - sep.width)
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor

    onClicked: function(mouse) {
      if (!root.toplevel) return
      if (mouse.button === Qt.MiddleButton) {
        root.toplevel.close()
      } else if (mouse.button === Qt.RightButton) {
        root.toplevel.close()
      } else {
        root.toplevel.activate()
      }
    }
    onEntered: if (root.bar) root.bar.showTooltip(root, root.title)
    onExited: if (root.bar) root.bar.hideTooltip(root)
  }
}
