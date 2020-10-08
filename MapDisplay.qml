import QtQuick 2.0
import QtQuick.Window 2.0
import QtWebEngine 1.8
import QtWebChannel 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    id: channel
    WebChannel.id: "qmlLeaflet"

    property double latitude : 0
    property double longitude : 0

    signal setCenterMap(double lat,double lng)

    signal setOverlayText(string layerId, string titleText, string descriptionText)

    signal gotShapeId(string id)

    signal removedOverlayId(string id)

    signal mapLoad()

    signal moveDroneSignal()

    signal moveSITLDroneSignal()

    signal createDroneSignal()

    signal createSITLDroneSignal()

    signal followRouteSignal(string overlayId)

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
        registeredObjects: [channel]
    }

    WebEngineView {
        backgroundColor: '#161d31'
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

    function initAircraft(){ //(overlayId){
        createDroneSignal()
//        if(overlayId !== ""){
//            webview.runJavaScript("initAircraft(drawnItems ," + overlayId +");");
//        }
    }

    function createGetRequest(url){
        return "fetch('"+ url +"', {mode: 'cors'})
        .then(function(response) {
          return response.text();
        })
        .then(function(text) {
          console.log('Request successful', text);
        })
        .catch(function(error) {
          log('Request failed', error)
        });"
    }

    function startSITL(lat, lng){
        var cmd = createGetRequest("http://127.0.0.1:5005/startSITL?lat="+lat+"&lng="+lng);
        console.log('Using cmd:', cmd);
        webview.runJavaScript(cmd);
    }

    function setupDrone(){
        var cmd = createGetRequest("http://127.0.0.1:5005/setupDrone");
        webview.runJavaScript(cmd);

        var cmd2 = "initiateArdupilotQuery(ardupilotLayer, map);"
        webview.runJavaScript(cmd2);
    }

    function moveDrone(){
        // Fire off moveDrone signal to the webpage
        moveDroneSignal();
    }

    function setDroneTargetPosition(lat,lng){
        console.log('Setting drone target');
        var cmd = createGetRequest("http://127.0.0.1:5005/goToLocation?lat="+lat+"&lon="+lng);
        webview.runJavaScript(cmd);
    }

    // Overlay ID dialog
    Dialog{
        id: overlayTextEditor
        // Layer ID gleaned from the invoking Javascript call
        property var layerId

        modality: Qt.WindowModal
        title: "Edit layer " + layerId

        contentItem: Rectangle{
            color: "#161d31"
            anchors.margins: 5
            implicitWidth: overlayTitle.width + 10
            implicitHeight: (overlayTitle.height +overlayDescription.height + setOverlayProperties.height) + 20
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
                   //Layout.preferredHeight: 100
                }
                Button{
                    id: setOverlayProperties
                    Layout.fillWidth: true
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
