import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

ShellRoot {
    Theme { id: theme }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                required property var modelData
                screen: modelData

                anchors {
                    top: true
                    left: true
                    right: true
                }

                margins {
                    top: 10
                    left: 14
                    right: 14
                }

                implicitHeight: 54
                exclusiveZone: 64
                aboveWindows: true
                focusable: false
                color: "transparent"

                Rectangle {
                    anchors.fill: parent
                    radius: 18
                    color: theme.surface
                    opacity: 0.94
                    border.width: 1
                    border.color: theme.outline

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 14

                        Item {
                            Layout.preferredWidth: 166
                            height: parent.height

                            Row {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 9

                                Rectangle {
                                    width: 30
                                    height: 30
                                    radius: 10
                                    color: theme.primaryContainer
                                    border.width: 1
                                    border.color: theme.outline

                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        source: Qt.resolvedUrl("assets/calypso-mark.svg")
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 0

                                    Text {
                                        text: "CALYPSO"
                                        color: theme.surfaceContent
                                        font.pixelSize: 11
                                        font.bold: true
                                        font.letterSpacing: 1.8
                                    }

                                    Text {
                                        text: "AURORA DOTFILES"
                                        color: theme.primary
                                        font.pixelSize: 8
                                        font.bold: true
                                        font.letterSpacing: 2.2
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: Quickshell.execDetached({ command: ["fuzzel"] })
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            height: parent.height

                            Row {
                                anchors.centerIn: parent
                                spacing: 5

                                Repeater {
                                    model: Hyprland.workspaces

                                    delegate: Rectangle {
                                        required property var modelData

                                        width: modelData.focused ? 30 : 26
                                        height: 30
                                        radius: 10
                                        color: modelData.focused ? theme.primaryContainer : "transparent"
                                        border.width: modelData.focused ? 1 : 0
                                        border.color: theme.outline

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.name
                                            color: modelData.focused ? theme.primaryContent : theme.surfaceContentVariant
                                            font.pixelSize: 10
                                            font.bold: modelData.focused
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: modelData.activate()
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.preferredWidth: 280
                            height: parent.height

                            Row {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 12

                                Text {
                                    width: 160
                                    text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : "CALYPSO"
                                    color: theme.surfaceContentVariant
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignRight
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Rectangle {
                                    width: 1
                                    height: 22
                                    color: theme.outline
                                    opacity: 0.6
                                }

                                SystemClock {
                                    id: clock
                                    precision: SystemClock.Minutes
                                }

                                Text {
                                    text: Qt.formatDateTime(clock.date, "HH:mm")
                                    color: theme.surfaceContent
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
