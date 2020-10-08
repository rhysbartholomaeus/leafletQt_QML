import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.0
import QtQml 2.12

import CustomListModel 1.0

Rectangle {

    color: "#26314c"
    radius: 5

    property var currentlySelectedValue

    signal createAircraft() //(string routeId)

    signal startSITL()

    signal moveDrone()

    signal moveSITLDrone()

    signal setupDrone()

    signal followRoute(string routeId)

    function emitFollowRouteSignal(routeId){
        console.log('Emit route ')
        console.log('Using route: ' + routeId)
        if(routeId === undefined){

            // If no id present but we have a route to choose from, default to it.
            if(CustomListModel.overlayListModel.count > 0){
                var defaultId = CustomListModel.overlayListModel.get(0)['name']
                followRoute(defaultId)
            }
        }
        else{
            followRoute(routeId)
        }
    }

    GridLayout {
        id : grid
        anchors.fill: parent
        anchors.margins: 5
        rows    : 4
        columns : 2
        columnSpacing: 5
        property double colMulti : grid.width / grid.columns
        property double rowMulti : grid.height / grid.rows
        function prefWidth(item){
            return colMulti * item.Layout.columnSpan
        }
        function prefHeight(item){
            return rowMulti * item.Layout.rowSpan
        }

        Rectangle{
            id: jsDroneControlsLabels
            color: "#202941"
            Layout.rowSpan   : 1
            Layout.columnSpan: 2
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : 20
            radius: 5
            Label {
                text: "JS Drone Controls"
                color: "#F0F3F4"
                font.pixelSize: 12
                anchors.centerIn: parent
            }
        }
        // Button used to create a Moving Marker representing an aircraft following
        // a polyline.
        RoundButton {
            text: "Create Aircraft"
            onClicked: {
                createAircraft()
                followRouteBtn.enabled = true
                droneMoveBtn.enabled = true
                this.enabled = false
            }
            Layout.fillWidth: true
            Layout.preferredWidth  : grid.prefWidth(this)
            radius: 5
        }

        RoundButton {
            id: followRouteBtn
            text: "Follow Route"
            enabled: false
            onClicked: {
                routeSelectionDialog.open()
            }
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.fillWidth: true
            radius: 5

        }

        RoundButton {
            id: droneMoveBtn
            text: "Move Drone"
            enabled: false
            onClicked: {
                // Fire signal to be picked up by MapDisplay which interacts
                // with the HTML
                moveDrone()
            }
            Layout.fillWidth: true
            Layout.preferredWidth  : grid.prefWidth(this)
            radius: 5
        }

        // SITL Controls label
        Rectangle{
            id: sitlControlsLabel
            color: "#202941"
            Layout.rowSpan   : 1
            Layout.columnSpan: 2
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : 20
            radius: 5
            Label {
                text: "SITL Controls"
                color: "#F0F3F4"
                font.pixelSize: 12
                anchors.centerIn: parent
            }
        }

        // Invokes MapDisplay to call the Python flask server to start the SITL process.
        RoundButton {
            id: sitlBtn
            text: "Start SITL"
            onClicked: {
                startSITL()
                sitlDroneSetupBtn.enabled = true
                this.enabled = false
            }
            Layout.fillWidth: true
            radius: 5
        }

        RoundButton {
            id: sitlDroneSetupBtn
            text: "Setup SITL Drone"
            enabled: false
            onClicked: {
                setupDrone()
                // Ideally there would be a callback to wait until the drone is at
                // a suitable height etc
                this.enabled = false
                sitlDroneMoveBtn.enabled = true
            }
            Layout.fillWidth: true
            radius: 5
        }

        RoundButton {
            id: sitlDroneMoveBtn
            text: "Move SITL Drone"
            enabled: false
            onClicked: {
                moveSITLDrone()
            }
            Layout.fillWidth: true
            radius: 5
        }
    }

    Dialog {
        id: routeSelectionDialog
        modality: Qt.WindowModal
        title: "Select a route for aircraft to follow:"
        onAccepted: {
            emitFollowRouteSignal(dialogOverlayList.selectedValue)
            this.close()
        }
        onRejected:{
            this.close()
        }
        contentItem:
            Rectangle{
                //anchors.fill: parent
                anchors.margins: 5
                color: "#0f1524"
                implicitWidth: 250
                implicitHeight: 310
                GridLayout{
                    anchors.fill: parent
                    anchors.margins: 5
                    rows    : 2
                    columns : 2
                    columnSpacing: 5
                    OverlayList{
                        id: dialogOverlayList
                        Layout.fillWidth: true
                        //Layout.fillHeight: true
                        Layout.row: 0
                        Layout.columnSpan: 2
                        Layout.preferredHeight: 250
                        Layout.preferredWidth: 250
                        radius: 5
                        color: "#26314c"
                    }
                    RoundButton {
                        id: okBtn
                        text: "OK"
                        Layout.row: 1
                        Layout.column: 0
                        Layout.fillWidth: true
                        onClicked: {
                            routeSelectionDialog.accepted()
                        }
                        radius: 5
                    }
                    RoundButton {
                        id: cancelBtn
                        text: "Cancel"
                        onClicked: {
                            routeSelectionDialog.rejected()
                        }
                        //Layout.fillWidth: true
                        Layout.row: 1
                        Layout.column: 1
                        Layout.fillWidth: true
                        radius: 5
                    }
                }
            }
        }
}
