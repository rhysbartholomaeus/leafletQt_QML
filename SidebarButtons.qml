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

    function emitCreateAircraftSignal(routeId){
        if(routeId === undefined){
            console.log('No ID provided')
        }
        else{
            console.log('Using ID: ', routeId )
            createAircraft(routeId)
        }
    }


    GridLayout {
        id : grid
        anchors.fill: parent
        anchors.margins: 5
        rows    : 6
        columns : 6
        columnSpacing: 5
        property double colMulti : grid.width / grid.columns
        property double rowMulti : grid.height / grid.rows
        function prefWidth(item){
            return colMulti * item.Layout.columnSpan
        }
        function prefHeight(item){
            return rowMulti * item.Layout.rowSpan
        }

        Button {
            text: "Create Aircraft"
            onClicked: routeSelectionDialog.open()
        }
        Button {
            text: "Unmapped Function"
            onClicked: console.log("Unmapped...")
        }
    }

    Dialog {
        id: routeSelectionDialog
        modality: dialogModal.checked ? Qt.WindowModal : Qt.NonModal
        title: "Select a route for aircraft to follow:"
        onButtonClicked: emitCreateAircraftSignal(currentlySelectedValue);
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
