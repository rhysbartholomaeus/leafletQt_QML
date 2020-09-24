import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.0
import QtQml 2.12

import CustomListModel 1.0

Rectangle {

    property var currentlySelectedValue

    signal createAircraft(string routeId)

    signal startSITL()

    signal moveDrone()

    signal setupDrone()

    function emitCreateAircraftSignal(routeId){
        if(routeId === undefined){
            // If no id present but we have a route to choose from, default to it.
            if(CustomListModel.overlayListModel.count > 0){
                var defaultId = CustomListModel.overlayListModel.get(0).name
                createAircraft(defaultId)
            }
        }
        else{
            createAircraft(routeId)
        }
    }

    GridLayout {
        id : grid
        anchors.fill: parent
        anchors.margins: 5
        rows    : 3
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

        // Button used to create a Moving Marker representing an aircraft following
        // a polyline.
        Button {
            text: "Create Aircraft"
            onClicked: routeSelectionDialog.open()
        }

        // Invokes the MapDisplay GET request
        Button {
            id: sitlBtn
            text: "Start SITL"
            onClicked: {
                startSITL()
                console.log("Sent starting SITL")
                droneSetupBtn.enabled = true
                sitlBtn.enabled = false
            }
        }
        Button {
            id: droneSetupBtn
            text: "Setup Drone"
            enabled: false
            onClicked: {
                setupDrone()
                console.log("set up drone")
                // Ideally there would be a callback to wait until the drone is at
                // a suitable height etc
                droneSetupBtn.enabled = false
                droneMoveBtn.enabled = true
            }
        }
        Button {
            id: droneMoveBtn
            text: "Move Drone"
            enabled: false
            onClicked: {
                moveDrone()
                console.log("MoveToLocation")
                //droneSetupBtn.enabled = false
            }
        }
    }

    Dialog {
        id: routeSelectionDialog
        modality: Qt.WindowModal
        title: "Select a route for aircraft to follow:"
        onButtonClicked: {
            emitCreateAircraftSignal(currentlySelectedValue);
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
                                // TacSit will grab this signal and run the corresponding
                                // JS on the index.html
                                currentlySelectedValue = CustomListModel.overlayListModel.get(parent.ListView.currentIndex).name
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
