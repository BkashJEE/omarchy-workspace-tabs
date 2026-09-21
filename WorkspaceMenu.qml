import QtQuick
import QtQuick.Controls as C
import QtQuick.Layouts
import qs.Commons

Item {
  id: menu
  implicitWidth: body.implicitWidth
  implicitHeight: body.implicitHeight

  property int workspaceId: 1
  property string workspaceName: "Workspace 1"
  property string workspaceDescription: ""
  property var windows: []

  signal focusRequested()
  signal windowSelected(var window)
  signal dismissed()

  focus: true
  Keys.onEscapePressed: dismissed()

  readonly property string liveLine: windows.length + (windows.length === 1 ? " window" : " windows") + " open"

  Rectangle {
    anchors.fill: parent
    anchors.margins: -14
    radius: 9
    color: "#f019191d"
    border.width: 1
    border.color: "#3fffffff"
  }

  ColumnLayout {
    id: body
    anchors.fill: parent
    spacing: 4

    Text {
      text: menu.workspaceName.toUpperCase()
      color: Color.accent
      font.pixelSize: 11
      font.letterSpacing: 1.6
      Layout.leftMargin: 9
      Layout.topMargin: 5
    }

    Text {
      text: menu.workspaceDescription
      color: "#f5f5f7"
      font.pixelSize: 12
      Layout.leftMargin: 9
      Layout.rightMargin: 9
      Layout.fillWidth: true
      elide: Text.ElideRight
    }

    Text {
      text: menu.liveLine
      color: Color.accent
      font.pixelSize: 11
      Layout.leftMargin: 9
      Layout.bottomMargin: 3
    }

    component MenuRow: C.Button {
      id: row
      property string description: ""
      property string marker: "↗"
      Layout.fillWidth: true
      implicitHeight: 36
      hoverEnabled: true
      background: Rectangle {
        radius: 3
        color: row.hovered || row.activeFocus ? Util.alpha(Color.accent, .16) : "transparent"
      }
      contentItem: RowLayout {
        spacing: 8
        Text {
          text: row.marker
          color: Color.accent
          font.pixelSize: 13
          Layout.preferredWidth: 20
          horizontalAlignment: Text.AlignHCenter
        }
        ColumnLayout {
          Layout.fillWidth: true
          spacing: 1
          Text {
            text: row.text
            textFormat: Text.PlainText
            color: "#f5f5f7"
            font.pixelSize: 12
            font.weight: Font.Medium
            Layout.fillWidth: true
            elide: Text.ElideRight
          }
          Text {
            text: row.description
            textFormat: Text.PlainText
            visible: text.length > 0
            color: "#a6a6af"
            font.pixelSize: 10
            Layout.fillWidth: true
            elide: Text.ElideRight
          }
        }
      }
    }

    MenuRow {
      text: "Focus this workspace"
      marker: "→"
      description: "Switch to workspace " + menu.workspaceId
      onClicked: menu.focusRequested()
    }

    Rectangle {
      Layout.fillWidth: true
      implicitHeight: 1
      color: "#20ffffff"
      Layout.topMargin: 5
      Layout.bottomMargin: 5
    }

    Text {
      text: "OPEN HERE · " + menu.windows.length
      color: "#a6a6af"
      font.pixelSize: 10
      Layout.leftMargin: 9
    }

    Repeater {
      model: menu.windows.slice(0, 3)
      MenuRow {
        required property var modelData
        text: modelData.title || modelData.wayland?.appId || "Window"
        marker: "↗"
        implicitHeight: 27
        onClicked: menu.windowSelected(modelData)
      }
    }

    Text {
      visible: !menu.windows.length
      text: "Nothing open on this workspace"
      color: "#a6a6af"
      font.pixelSize: 11
      Layout.leftMargin: 9
      Layout.bottomMargin: 3
    }
  }
}
