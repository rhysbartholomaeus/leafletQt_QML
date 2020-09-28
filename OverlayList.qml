import QtQuick 2.0
import QtQml 2.12
import QtQuick.Controls 2.5

import CustomListModel 1.0

Rectangle {

    signal overlayIdAdded(string id)
    onOverlayIdAdded: {
        CustomListModel.overlayListModel.append({name: id})
    }

    signal overlayIdRemoved(string id)
    onOverlayIdRemoved:{
        var itemIndex = findItem(id)
        if(itemIndex > -1){
            CustomListModel.overlayListModel.remove(itemIndex)
        }
    }

    signal clearOverlayIds()
    onClearOverlayIds:{
        CustomListModel.overlayListModel.clear()
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

    function findItem(itemId){
        if(CustomListModel.overlayListModel.count > 0){
            for(var i = 0 ; i < CustomListModel.overlayListModel.count; ++i){
                if(CustomListModel.overlayListModel.get(i)["name"] === itemId){
                    return i;
                }
            }
        }
        return -1
    }
}
