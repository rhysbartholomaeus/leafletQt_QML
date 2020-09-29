import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.0
import QtQml 2.12

import CustomListModel 1.0

Rectangle {

    property var currentlySelectedValue

    signal createAircraft() //(string routeId)

    signal startSITL()

    signal moveDrone()

    signal moveSITLDrone()

    signal setupDrone()

    signal followRoute(string routeId)

    function emitFollowRouteSignal(routeId){
        if(routeId === undefined){
            // If no id present but we have a route to choose from, default to it.
            if(CustomListModel.overlayListModel.count > 0){
                var defaultId = CustomListModel.overlayListModel.get(0).name
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
            color: "#5D6D7E"
            Layout.rowSpan   : 1
            Layout.columnSpan: 2
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : 12
            anchors.horizontalCenter: parent.verticalCenter
            Label {
                text: "JS Drone Controls"
                color: "#F0F3F4"
                font.pixelSize: 12
                anchors.verticalCenter: jsDroneControlsLabels.verticalCenter
            }
        }
        // Button used to create a Moving Marker representing an aircraft following
        // a polyline.
        Button {
            text: "Create Aircraft"
            onClicked: {
                createAircraft()
                followRouteBtn.enabled = true
                droneMoveBtn.enabled = true
                this.enabled = false
            }//routeSelectionDialog.open()
        }
        Button {
            id: followRouteBtn
            text: "Follow Route"
            enabled: false
            onClicked: {
                // Fire signal to be picked up by MapDisplay which interacts
                // with the HTML
                routeSelectionDialog.open()
            }
        }
        Button {
            id: droneMoveBtn
            text: "Move Drone"
            enabled: false
            onClicked: {
                // Fire signal to be picked up by MapDisplay which interacts
                // with the HTML
                moveDrone()
            }
        }
        Rectangle{
            id: sitlControlsLabel
            color: "#5D6D7E"
            Layout.rowSpan   : 1
            Layout.columnSpan: 2
            Layout.preferredWidth  : grid.prefWidth(this)
            Layout.preferredHeight : 12

            //anchors.horizontalCenter: parent.horizontalCenter
            Label {
                text: "SITL Controls"
                color: "#F0F3F4"
                font.pixelSize: 12
                anchors.verticalCenter: sitlControlsLabel.verticalCenter
            }
        }
        // Invokes MapDisplay to call the Python flask server to start the SITL process.
        Button {
            id: sitlBtn
            text: "Start SITL"
            onClicked: {
                startSITL()
                console.log("Sent starting SITL")
                sitlDroneSetupBtn.enabled = true
                this.enabled = false
            }
        }
        Button {
            id: sitlDroneSetupBtn
            text: "Setup SITL Drone"
            enabled: false
            onClicked: {
                setupDrone()
                console.log("set up drone")
                // Ideally there would be a callback to wait until the drone is at
                // a suitable height etc
                this.enabled = false
                sitlDroneMoveBtn.enabled = true
            }
        }
        Button {
            id: sitlDroneMoveBtn
            text: "Move SITL Drone"
            enabled: false
            onClicked: {
                moveSITLDrone()
            }
        }
    }

    Dialog {
        id: routeSelectionDialog
        modality: Qt.WindowModal
        title: "Select a route for aircraft to follow:"
        onButtonClicked: {
            emitFollowRouteSignal(currentlySelectedValue);
        }

        Rectangle{
            anchors.margins: 5
            implicitWidth: 300
            implicitHeight: 200

            // This is dumb - Why can't you just initalise another OverlayList object?
            //OverlayList{}

            Component {
                id: overlayNameDelegate
                Rectangle {
                    id: top
                    color: ListView.isCurrentItem ? "#F5B041" : "transparent"
                    height: text.implicitHeight
                    anchors { left: parent.left; right: parent.right }
                    Text {
                        anchors.fill: parent
                        id: text
                        text: model.name
                        color: parent.ListView.isCurrentItem ? "white" : "black"
                        font.pixelSize: 24
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                top.ListView.view.currentIndex = model.index;
                                currentlySelectedValue = CustomListModel.overlayListModel.get(model.index).name
                            }
                        }
                    }
                }
            }

            ListView {
                id: primaryListView
                anchors.fill: parent
                model: CustomListModel.overlayListModel
                delegate: overlayNameDelegate
                clip: true
            }
            }
        }

}
