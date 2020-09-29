// This file creates a webchannel, globally accessible through the window.commObject parameter

function initaliseWebchannel(){
    window.webChannel = new QWebChannel(qt.webChannelTransport, function(channel)
    {
        var qmlObj = channel.objects.qmlLeaflet;
        window.commObject = qmlObj;
        // Connect our QML object to the setOverlayText signal
        commObject.setOverlayText.connect(function(layerId, titleText, descriptionText) {
            if (typeof commObject !== 'undefined') {
                console.log('Got signal for setOverlayText');
                uiSetShapePropertiesCallback(layerId, titleText , descriptionText);
            }
        });
        commObject.moveDroneSignal.connect(function() {
            if (typeof commObject !== 'undefined') {
                console.log('Moving drone enabled');
                moveDrone = true;
            }
        });
        commObject.moveSITLDroneSignal.connect(function() {
            if (typeof commObject !== 'undefined') {
                console.log('Moving SITL drone enabled');
                moveSITLDrone = true;
            }
        });
        commObject.createDroneSignal.connect(function() {
            if (typeof commObject !== 'undefined') {
                console.log('Creating drone');
                createDrone = true;
                alert('Select anywhere on map to place drone.');
            }
        });
        commObject.followRouteSignal.connect(function(routeId) {
            if (typeof commObject !== 'undefined') {
                // Call the test_aircraft.js followRoute method
                // Yes this is bad design - Sue me.
                followRoute(routeId);
            }
        });
        commObject.createSITLDroneSignal.connect(function() {
            if (typeof commObject !== 'undefined') {
                console.log('Creating SITL drone');
                createSITLDrone = true;
                alert('Select anywhere on map to place the SITL drone.');
            }
        });
    });
}