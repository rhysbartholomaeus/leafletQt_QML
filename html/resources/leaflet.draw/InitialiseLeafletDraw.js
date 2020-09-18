function initialiseLeafletDraw(drawnItemsLayer, map){

    window.webChannel = new QWebChannel(qt.webChannelTransport, function(channel)
    {
        var qmlObj = channel.objects.qmlLeaflet;
        window.commObject = qmlObj;
        commObject.setOverlayText.connect(function(layerId, titleText, descriptionText) {
            if (typeof commObject !== 'undefined') {
                console.log('Got signal for setOverlayText')
                uiSetShapePropertiesCallback(drawnItemsLayer, layerId, titleText , descriptionText)
            }
        });
    });

    // Object created - bind popup to layer, add to feature group
    map.on(L.Draw.Event.CREATED, function(event) {
        var layer = event.layer;
        // Initialise layer feature - This way we can add custom attributes
        var feature = layer.feature = layer.feature || {};
        // Initialise the feature type
        feature.type = feature.type || "Feature";
        // Initalise feature properties
        var featProps = feature.properties = feature.properties || {};
        // We'll set this on a callback from the UI if the user inputs a title for the layer
        featProps.title = "Undefined"
        featProps.description = "Undefined metadata"

        var content = getPopupContent(layer);
        if (content !== null) {
            layer.bindPopup(content);
        }
        drawnItemsLayer.addLayer(layer);
        // Callback to the UI to add the layer to the overlay list
        commObject.overlayAdded(layer._leaflet_id);
        // Callback to the UI to allow the user to modify the content
        commObject.editPopupText(layer._leaflet_id);
    });

    // Object(s) edited - update popups
    map.on(L.Draw.Event.EDITED, function(event) {
        var layers = event.layers,
            content = null;
        layers.eachLayer(function(layer) {
            content = getPopupContent(layer);
            if (content !== null) {
                layer.setPopupContent(content);
            }
            commObject.editPopupText(layer._leaflet_id);
        });
    });

    // Get the deleted event so we can update the GUI
    map.on(L.Draw.Event.DELETED, function(event) {
        var layers = event.layers
        layers.eachLayer(function(layer){
            commObject.overlayRemoved(layer._leaflet_id);
        });
    });
}

function _round(num, len) {
    return Math.round(num*(Math.pow(10, len)))/(Math.pow(10, len));
};
// Helper method to format LatLng object (x.xxxxxx, y.yyyyyy)
function strLatLng(latlng) {
    return "("+_round(latlng.lat, 6)+", "+_round(latlng.lng, 6)+")";
};

// Generate popup content based on layer type
// - Returns HTML string, or null if unknown object
function getPopupContent(layer, displayText = "") {
    
    // Custom text set by callback
    if(displayText == "") displayText = "Undefined"
    // Marker - add lat/long
    if (layer instanceof L.Marker || layer instanceof L.CircleMarker) {
        return  displayText + "<br/>" + strLatLng(layer.getLatLng());
    // Circle - lat/long, radius
    } else if (layer instanceof L.Circle) {
        var center = layer.getLatLng(),
            radius = layer.getRadius();
        return displayText + "<br/>" + "Center: "+strLatLng(center)+"<br />"
            +"Radius: "+_round(radius, 2)+" m";
    // Rectangle/Polygon - area
    } else if (layer instanceof L.Polygon) {
        var latlngs = layer._defaultShape ? layer._defaultShape() : layer.getLatLngs(),
            area = L.GeometryUtil.geodesicArea(latlngs);
        return displayText + "<br/>" + "Area: "+L.GeometryUtil.readableArea(area, true);
    // Polyline - distance
    } else if (layer instanceof L.Polyline) {
        var latlngs = layer._defaultShape ? layer._defaultShape() : layer.getLatLngs(),
            distance = 0;
        if (latlngs.length < 2) {
            return displayText + "<br/>" + "Distance: N/A";
        } else {
            for (var i = 0; i < latlngs.length-1; i++) {
                distance += latlngs[i].distanceTo(latlngs[i+1]);
            }
            return displayText + "<br/>" + "Distance: "+_round(distance, 2)+" m";
        }
    }
    return null;
};

function uiSetShapePropertiesCallback(drawnItemsLayer, layerId, layerTitle, layerText){
    if(layerTitle == "") 
        layerTitle = "Undefined";
    if(layerText == "") 
        layerText = "No data";
    var layer = drawnItemsLayer.getLayer(layerId);
    layer.feature.properties.title = layerTitle;
    layer.feature.properties.description = layerText;
    var content = getPopupContent(layer, layerTitle);
    layer.bindPopup(content);
    console.log(layer);
}