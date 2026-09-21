import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "community.workspace-tabs"

  // A useful default layout that stays fully local and can be renamed freely.
  readonly property var workspaceOrder: [6, 1, 2, 7, 3, 4, 5]
  readonly property var workspaceLabels: ({
    1: "Agents Lab",
    2: "Social Media",
    3: "Hermes OS",
    4: "Git",
    5: "Build",
    6: "Studio",
    7: "Messages"
  })
  readonly property var workspaceSymbols: ({
    1: "◆",
    2: "●",
    3: "◇",
    4: "⌁",
    5: "↗",
    6: "✦",
    7: "✉"
  })
  readonly property var workspaceDescriptions: ({
    1: "Coding agents and project work",
    2: "Posts, publishing and recordings",
    3: "Your local agent workspace",
    4: "Repositories, changes and pull requests",
    5: "Editor, terminal and app preview",
    6: "Mission control for your work",
    7: "Messaging apps and conversations"
  })

  property bool menuOpen: false
  property int menuWorkspaceId: 1
  property Item menuAnchor: null
  property var menuAnchors: ({})
  property var pendingWindow: null
  property int pendingWorkspaceId: -1

  function workspaceById(workspaceId) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === workspaceId) return values[i]
    }
    return null
  }

  function labelForWorkspace(workspaceId) {
    return root.workspaceLabels[workspaceId] || "Workspace " + workspaceId
  }

  function symbolForWorkspace(workspaceId) {
    return root.workspaceSymbols[workspaceId] || String(workspaceId)
  }

  function descriptionForWorkspace(workspaceId) {
    return root.workspaceDescriptions[workspaceId] || "Workspace " + workspaceId
  }

  function toggleMenu(workspaceId, anchor) {
    var wasOpen = root.menuOpen && root.menuWorkspaceId === workspaceId
    root.menuOpen = false
    root.menuWorkspaceId = workspaceId
    root.menuAnchor = anchor || root
    root.menuOpen = !wasOpen
  }

  function openMenu(workspaceId) {
    if (root.workspaceOrder.indexOf(workspaceId) === -1) return
    root.menuOpen = false
    root.toggleMenu(workspaceId, root.menuAnchors[workspaceId])
  }

  function focusWorkspace(workspaceId) {
    root.menuOpen = false
    root.bar.run("hyprctl eval " + Util.shellQuote("hl.dispatch(hl.dsp.focus({ workspace = \"" + workspaceId + "\" }))"))
  }

  readonly property var menuWindows: workspaceById(menuWorkspaceId) ? workspaceById(menuWorkspaceId).toplevels.values : []

  IpcHandler {
    target: "community.workspace-tabs"
    function open(workspaceId: int): void { root.openMenu(workspaceId) }
    function close(): void { root.menuOpen = false }
    function status(): string {
      return JSON.stringify({open: root.menuOpen, workspace: root.menuWorkspaceId, windows: root.menuWindows.length})
    }
  }

  KeyboardPanel {
    id: menuPanel
    anchorItem: root.menuAnchor || root
    bar: root.bar
    owner: root
    open: root.menuOpen
    contentWidth: menuPanel.fittedContentWidth(300)
    contentHeight: menuPanel.fittedContentHeight(workspaceMenu.implicitHeight, 500)
    focusTarget: workspaceMenu

    WorkspaceMenu {
      id: workspaceMenu
      width: parent.width
      workspaceId: root.menuWorkspaceId
      workspaceName: root.labelForWorkspace(root.menuWorkspaceId)
      workspaceDescription: root.descriptionForWorkspace(root.menuWorkspaceId)
      windows: root.menuWindows
      onDismissed: root.menuOpen = false
      onFocusRequested: {
        root.pendingWorkspaceId = root.menuWorkspaceId
        root.menuOpen = false
        actionDelay.restart()
      }
      onWindowSelected: function(window) {
        root.pendingWindow = window
        root.pendingWorkspaceId = root.menuWorkspaceId
        root.menuOpen = false
        actionDelay.restart()
      }
    }
  }

  Timer {
    id: actionDelay
    interval: 160
    onTriggered: {
      if (root.pendingWindow && root.pendingWindow.wayland) root.pendingWindow.wayland.activate()
      else if (root.pendingWorkspaceId > 0) root.focusWorkspace(root.pendingWorkspaceId)
      root.pendingWindow = null
      root.pendingWorkspaceId = -1
    }
  }

  implicitWidth: tabs.implicitWidth
  implicitHeight: tabs.implicitHeight

  GridLayout {
    id: tabs
    anchors.fill: parent
    columns: root.vertical ? 1 : root.workspaceOrder.length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceOrder

      RowLayout {
        id: workspaceRow
        required property int modelData
        readonly property string label: root.labelForWorkspace(modelData)
        readonly property string display: root.symbolForWorkspace(modelData) + "  " + label
        spacing: 0

        TextMetrics {
          id: labelMetrics
          font.family: "Google Sans Text"
          font.pixelSize: 13
          text: workspaceRow.display
        }

        Component.onCompleted: root.menuAnchors[modelData] = workspaceRow

        WidgetButton {
          readonly property var workspace: root.workspaceById(workspaceRow.modelData)
          readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
          readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === workspaceRow.modelData

          bar: root.bar
          text: root.vertical ? root.symbolForWorkspace(workspaceRow.modelData) : workspaceRow.display
          tooltipText: workspaceRow.label
          fontSize: 11
          fontFamily: "Google Sans Text"
          opacity: focused ? 1 : (occupied ? 0.88 : 0.72)
          horizontalMargin: 6
          verticalPadding: 6
          fixedWidth: root.vertical ? root.barSize : Math.max(70, Math.ceil(labelMetrics.advanceWidth) + 16)
          fixedHeight: root.barSize
          onPressed: root.focusWorkspace(workspaceRow.modelData)

          Rectangle {
            z: -1
            x: 0
            y: 3
            width: parent.width + 18
            height: parent.height - 6
            radius: 9
            color: "#36363d"
            border.width: 1
            border.color: "#63636d"
            opacity: parent.focused && !root.vertical ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
          }
        }

        WidgetButton {
          bar: root.bar
          text: root.menuOpen && root.menuWorkspaceId === workspaceRow.modelData ? "▴" : "▾"
          tooltipText: workspaceRow.label + " menu"
          fixedWidth: 20
          fixedHeight: root.barSize
          horizontalMargin: 0
          fontSize: 11
          onPressed: root.toggleMenu(workspaceRow.modelData, workspaceRow)
        }
      }
    }
  }
}
