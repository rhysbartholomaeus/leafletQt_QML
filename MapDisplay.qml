import QtQuick 2.0
import QtQuick.Window 2.0
import QtWebEngine 1.8
import QtWebChannel 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    id: pageChannel
    WebChannel.id: "qmlLeaflet"

    property double latitude : 0
    property double longitude : 0

    signal setCenterMap(double lat,double lng)

    signal setOverlayText(string layerId, string titleText, string descriptionText)

    signal gotShapeId(string id)

    signal removedOverlayId(string id)

    signal mapLoad()

    function updateCenterMap (lat,lng) {
        console.log('Successfully executed callback.');
        setCenterMap(lat,lng);
    }

    function logStr(str){
        console.log(str);
    }

    function overlayAdded(overlayId){
        // Emit the overlay ID
        gotShapeId(overlayId)
    }

    function overlayRemoved(overlayId){
        // Emit the removed overlay ID
        removedOverlayId(overlayId)
    }

    WebChannel {
        id: webChannel
        registeredObjects: [pageChannel]
    }

    WebEngineView {
        id: webview
        url: "qrc:/html/index.html"
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.topMargin: 0
        webChannel: webChannel
        settings.localContentCanAccessRemoteUrls: true
        onLoadingChanged: {
            if(loadRequest.status === WebEngineView.LoadStartedStatus){
                // emit the page load signal
                mapLoad()
            }
        }
    }

    function initAircraft(overlayId){
        if(overlayId !== ""){
            webview.runJavaScript("initAircraft(drawnItems ," + overlayId +");");
        }
    }

    function startSITL(){
        var cmd = "fetch('http://127.0.0.1:5005/startSITL', {mode: 'cors'})
        .then(function(response) {
          return response.text();
        })
        .then(function(text) {
          console.log('Request successful', text);
        })
        .catch(function(error) {
          log('Request failed', error)
        });"
        webview.runJavaScript(cmd);
        //console.log('Not currently implemented')
    }

    function startMoving(){
        var cmd = "fetch('http://127.0.0.1:5005/goToLocation', {mode: 'cors'})
        .then(function(response) {
          return response.text();
        })
        .then(function(text) {
          console.log('Request successful', text);
        })
        .catch(function(error) {
          log('Request failed', error)
        });"
        webview.runJavaScript(cmd);

        var cmd2 = "initiateArdupilotQuery(trackLayer);"
        webview.runJavaScript(cmd2);
    }

    Dialog{
        id: overlayTextEditor
        // Layer ID gleaned from the invoking Javascript call
        property var layerId
        modality: Qt.WindowModal
        title: "Edit layer " + layerId

        contentItem: Rectangle{
            color: "#2C3E50"
            anchors.margins: 5
            implicitWidth: overlayTitle.width + 10
            implicitHeight: grid.grid.height
            GridLayout {
                id : grid
                anchors.fill: parent
                anchors.margins: 5
                rows    : 3
                columns : 1
                TextField{
                   id: overlayTitle
                   placeholderText: qsTr("Enter overlay title")
                }
                TextField{
                   id: overlayDescription
                   placeholderText: qsTr("Enter overlay description")
                }
                Button{
                    anchors.verticalCenter: parent
                    id: setOverlayProperties
                    text: "Ok"
                    onClicked:{
                            // Emit the signal for capture on the javascript side
                            overlayTextEditor.close()
                            setOverlayText(overlayTextEditor.layerId, overlayTitle.text, overlayDescription.text)
                            overlayTitle.clear()
                            overlayDescription.clear()
                        }
                }
            }
        }
    }

    function editPopupText(layerId){
        overlayTextEditor.layerId = layerId
        overlayTextEditor.open()
    }

}
