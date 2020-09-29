// This is a simple script to move a simple object from one position to another. 

var lat;
var lon;
var callsign = 'TestDrone01';
var position;
var waypoints = [];
var numWaypoints;
var numDeltas = 100;
var delay = 50; //milliseconds
var i = 0;
var wayPtIndex = 0;
var deltaLat;
var deltaLng;
var testDroneMarker;

function initAircraft(layer, latlng){
    var planeIcon = L.icon({
        iconUrl: './resources/images/DroneSymbol.png',    
        iconSize:     [32, 32], // size of the icon
        iconAnchor:   [16, 16], // point of the icon which will correspond to marker's location
        popupAnchor:  [-3, -76] // point from which the popup should open relative to the iconAnchor
    });

    testDroneMarker = L.marker(latlng,{
        title: callsign,
        icon: planeIcon
    }).addTo(layer);
    position = testDroneMarker.getLatLng();
}

function followRoute(routeId){
    var routeLayer = window.overlayItemsLayer.getLayer(routeId);
    if (routeLayer instanceof L.Polyline) {
        waypoints = routeLayer._latlngs;
        numWaypoints = waypoints.length
        // Kick off transition to first marker.
        transition(waypoints[0]);
        wayPtIndex ++;
        followWaypoints();
    }
    else{
        alert('Route following only works when a polyline shape is selected as the route.');
    }
}

// Intermediate location.
function transition(result){
    i = 0;
    // Calculate distance to determine number of deltas
    var distance = result.distanceTo(position);
    var speed = 15; // This isn't a real velocity, since the movement system is based on delay + delta increment.
                    // Want realism? Use the SITL drone.
    // Update deltas to ensure consistent speed between points.
    numDeltas = (distance / speed) ;
    deltaLat = (result.lat - position.lat)/numDeltas;
    deltaLng = (result.lng - position.lng)/numDeltas;
    moveMarker();
}

function moveMarker(){
    position.lat += deltaLat;
    position.lng += deltaLng;

    testDroneMarker.setLatLng(position);
    if(i < numDeltas){
        i++;
        setTimeout(moveMarker, delay);
    }
}

// A callback function that checks the state of the current leg with a waypoint mission.
function followWaypoints(){
    // One method to keep track of how our waypoint journey is going.
    if(i < numDeltas){
        setTimeout(followWaypoints, delay);   
    }
    else{
        // Verify our current waypoint index is within bounds
        if(wayPtIndex < numWaypoints){
            transition(waypoints[wayPtIndex]);
            ++wayPtIndex;
            // Kick off the callback again
            followWaypoints()
        }else{
            // Reset waypoint index - we've finished.
            wayPtIndex = 0;
        } 
    }
}
