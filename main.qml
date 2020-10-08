import QtQuick 2.0
import QtQuick.Window 2.0
import QtWebEngine 1.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQml 2.12

Window {
    width: 1024
    height: 760
    visible: true
    title: qsTr("Map Display")

    // Background
    Rectangle {
        anchors.fill: parent
        color: "#161d31"
    }

    // Primary content layout
    GridLayout {
        id : grid
        anchors.fill: parent
        anchors.margins: 5
        rows    : 12
        columns : 14
        columnSpacing: 5
        property double colMulti : grid.width / grid.columns
        property double rowMulti : grid.height / grid.rows
        function prefWidth(item){
            return colMulti * item.Layout.columnSpan
        }
        function prefHeight(item){
            return rowMulti * item.Layout.rowSpan
        }

        // Side panel
        Rectangle {
            id: sidePanel
            color: "transparent"
            Layout.rowSpan   : 12
            Layout.columnSpan: 3
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)
            radius: 5

            GridLayout {
                id : sidebarGrid
                rows    : 5
                columns : 1
                anchors.fill: parent
                anchors.margins: 5

                // Controls label
                Rectangle{
                    id: controlsLabel
                    color: "#202941"
                    Layout.preferredHeight: 25
                    Layout.fillWidth: true
                    radius: 5

                    Label {
                        text: "Controls"
                        color: "#F0F3F4"
                        font.pixelSize: 18
                        anchors.centerIn: parent
                    }
                }

                SidebarButtons{
                    id: sideBar
                    Layout.preferredHeight: 250
                    Layout.fillWidth: true
                }

                // Overlay list label
                Rectangle{
                    id: overlayLabel
                    color: "#202941"
                    //Layout.fillHeight: true
                    Layout.preferredHeight: 25
                    Layout.fillWidth: true
                    radius: 5

                    Label {
                        text: "Overlays"
                        color: "#F0F3F4"
                        font.pixelSize: 18
                        anchors.centerIn: parent
                    }
                }

                OverlayList{
                    id: overlayList
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    radius: 5
                    color: "#26314c"
                    Connections {
                        target: mapDisplay
                        onGotShapeId: overlayList.overlayIdAdded(id)
                    }
                    Connections {
                        target: mapDisplay
                        onRemovedOverlayId: overlayList.overlayIdRemoved(id)
                    }
                    Connections {
                        target: mapDisplay
                        onMapLoad: overlayList.clearOverlayIds()
                    }
                }
            }
       }

        // Main map display
        MapDisplay{
            id: mapDisplay

            Layout.rowSpan   : 12
            Layout.columnSpan: 11
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)
            ColumnLayout {
                anchors.fill: parent
                //width: parent.width
                anchors.centerIn: parent
            }
            Connections {
                target: sideBar
                onCreateAircraft: mapDisplay.initAircraft() //(routeId)
            }
            Connections {
                target: sideBar
                onStartSITL: mapDisplay.createSITLDroneSignal()
            }
            Connections {
                target: sideBar
                onMoveDrone: mapDisplay.moveDrone()
            }
            Connections {
                target: sideBar
                onSetupDrone: mapDisplay.setupDrone()
            }
            Connections {
                target: sideBar
                onFollowRoute: mapDisplay.followRouteSignal(routeId)
            }
            Connections {
                target: sideBar
                onMoveSITLDrone: mapDisplay.moveSITLDroneSignal()
            }
        }
    }
}

