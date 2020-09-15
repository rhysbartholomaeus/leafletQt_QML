import QtQuick 2.0
import QtQuick.Window 2.0
import QtWebEngine 1.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQml 2.12

Window {
    width: 1024
    height: 750
    visible: true
    title: qsTr("Tactical Map")

    // Background
    Rectangle {
        anchors.fill: parent
        color: "#2C3E50"
    }

    // Primary content
    GridLayout {
        id : grid
        anchors.fill: parent
        anchors.margins: 5
        rows    : 12
        columns : 12
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
            id: colsx
            color: "#212F3D"
            Layout.rowSpan   : 3
            Layout.columnSpan: 3
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)

            SidebarButtons{
                id: sideBar
            }
       }

        // Main map display
        MapDisplay{
            id: mapDisplay
            //anchors.fill:parent

            Layout.rowSpan   : 12
            Layout.columnSpan: 9
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)
            ColumnLayout {
                anchors.fill: parent
                //width: parent.width
                anchors.centerIn: parent
            }

            onGotShapeId:{
                console.log('Got shape id' + id)
            }



            Connections {
                target: sideBar
                onCreateAircraft: {
                    console.log('Got route id', routeId)
                    mapDisplay.initAircraft(routeId)
                }

            }

        }

        Rectangle{
            id: overlayLabel
            color: "#5D6D7E"
            Layout.rowSpan   : 1
            Layout.columnSpan: 3
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)
            Label {
                text: "Overlays"
                color: "#F0F3F4"
                font.pixelSize: 22
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        OverlayList{
            id: overlayList
            Layout.rowSpan   : 3
            Layout.columnSpan: 3
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : grid.prefHeight(this)
            Connections {
                target: mapDisplay
                onGotShapeId: overlayList.overlayIdAdded(id)
            }
        }
    }
}

