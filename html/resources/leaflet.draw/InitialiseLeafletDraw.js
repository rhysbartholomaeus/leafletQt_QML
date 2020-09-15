function initialiseLeafletDraw(drawnItemsLayer, map){

    window.webChannel = new QWebChannel(qt.webChannelTransport, function(channel)
    {
        var qmlObj = channel.objects.qmlLeaflet;
        window.commObject = qmlObj;
    });

    var _round = function(num, len) {
        return Math.round(num*(Math.pow(10, len)))/(Math.pow(10, len));
    };
    // Helper method to format LatLng object (x.xxxxxx, y.yyyyyy)
    var strLatLng = function(latlng) {
        return "("+_round(latlng.lat, 6)+", "+_round(latlng.lng, 6)+")";
    };

    // Generate popup content based on layer type
    // - Returns HTML string, or null if unknown object
    var getPopupContent = function(layer) {
        // Marker - add lat/long
        if (layer instanceof L.Marker || layer instanceof L.CircleMarker) {
            return strLatLng(layer.getLatLng());
        // Circle - lat/long, radius
        } else if (layer instanceof L.Circle) {
            var center = layer.getLatLng(),
                radius = layer.getRadius();
            return "Center: "+strLatLng(center)+"<br />"
                +"Radius: "+_round(radius, 2)+" m";
        // Rectangle/Polygon - area
        } else if (layer instanceof L.Polygon) {
            var latlngs = layer._defaultShape ? layer._defaultShape() : layer.getLatLngs(),
                area = L.GeometryUtil.geodesicArea(latlngs);
            return "Area: "+L.GeometryUtil.readableArea(area, true);
        // Polyline - distance
        } else if (layer instanceof L.Polyline) {
            var latlngs = layer._defaultShape ? layer._defaultShape() : layer.getLatLngs(),
                distance = 0;
            if (latlngs.length < 2) {
                return "Distance: N/A";
            } else {
                for (var i = 0; i < latlngs.length-1; i++) {
                    distance += latlngs[i].distanceTo(latlngs[i+1]);
                }
                return "Distance: "+_round(distance, 2)+" m";
            }
        }
        return null;
    };

    // Object created - bind popup to layer, add to feature group
    map.on(L.Draw.Event.CREATED, function(event) {
        var layer = event.layer;
        var content = getPopupContent(layer);
        if (content !== null) {
            layer.bindPopup(content);
        }
        drawnItemsLayer.addLayer(layer);
        commObject.overlayAdded(layer._leaflet_id);
        // new QWebChannel(qt.webChannelTransport, function(channel)
        //     {
        //         var qmlObj = channel.objects.qmlLeaflet;
        //         qmlObj.logStr('ID: ' + layer._leaflet_id);
        //     });
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
        });
    });
}