// This is a simple script to move a simple object from one position to another. 

var lat;
var lon;
var callsign;
//var waypoints = [];

function initAircraft(layer, routeId){

    var planeIcon = L.icon({
        iconUrl: './resources/images/DroneSymbol.png',    
        iconSize:     [32, 32], // size of the icon
        iconAnchor:   [16, 16], // point of the icon which will correspond to marker's location
        popupAnchor:  [-3, -76] // point from which the popup should open relative to the iconAnchor
    });

    // Get the starting position and assign to the global variables.
    callsign = "TAS";
    var waypoints = layer.getLayer(routeId)._latlngs;
    var aircraftMarker = L.Marker.movingMarker(waypoints,30000, {icon: planeIcon}).addTo(map);
    console.log(aircraftMarker);
    aircraftMarker.start();
}

function followRoute(layer,routeId){
    // Use a leaflet shape layer and route ID to shift the aircraft around. 
}