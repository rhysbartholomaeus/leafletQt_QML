import QtQuick 2.0
import QtQml 2.12
import QtQuick.Controls 2.5

import CustomListModel 1.0

Rectangle {

    property var currentIndexItem

    signal overlayIdAdded(string id)
    onOverlayIdAdded: {
        CustomListModel.overlayListModel.append({name: id})
    }

    signal clearOverlayIds()
    onClearOverlayIds:{
        CustomListModel.overlayListModel.clear()
    }

    ListModel {
        id: overlayNameModel
    }

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
                        currentIndexItem = model.get(model.index);
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
