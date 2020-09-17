import QtQuick 2.0
import QtQuick.Window 2.0
import QtWebEngine 1.8
import QtWebChannel 1.0

Item {
    id: pageChannel
    WebChannel.id: "qmlLeaflet"

    property double latitude : -37.823494
    property double longitude : 144.913341

    signal setCenterMap(double lat,double lng)

    signal gotShapeId(string id)

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
}

