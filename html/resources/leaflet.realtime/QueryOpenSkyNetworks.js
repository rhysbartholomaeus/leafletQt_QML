// WARNING! Requires the leaflet track marker library.  
 
 function initiateTrackQuery(trackLayer){   
    var realtime = L.realtime({
        // This is a Python server that returns GEOJSON formatted packets for aircraft data obtained
        // from the OpenSky Networks system.
        url: 'http://127.0.0.1:5002/flightradar',
    crossOrigin: true,
    type: 'json'
        // function(success, error){
        //     var flightData = httpGet('https://opensky-network.org/api/states/all').then(function(result){return result});
        //     console.log("Have features");
        //     console.log(flightData);
        //     success(flightData);
    }, {
    interval: 10 * 1000,
    getFeatureId: function(feature) {
        // required for L.Realtime to track which feature is which
        // over consecutive data requests.
        return feature.id;
    },
    pointToLayer: function(feature, latlng) {
        var marker = L.trackSymbol(latlng, {
        trackId: feature.id,
        fill: true,
        fillColor: '#0000ff',
        fillOpacity: 1.0,
        stroke: true,
        color: '#000000',
        opacity: 1.0,
        weight: 1.0,
        speed: feature.properties['velocity'],
        course: feature.properties['true_track'],
        heading: feature.properties['true_track']
    }).bindTooltip(
            '<b>'+ feature.properties['callsign'] 
                +'</b><br>Altitude: '+ feature.properties['geo_altitude'] +' m <br>' 
                + 'Speed: ' + feature.properties['velocity'] + ' m/s',
            {
                permanent: false, opacity: 0.7}
        );
        return marker;
    }
    }).addTo(trackLayer);

        // Update the track/popup with the current speed, heading, course and altitude.
    // This will update the underlying icon. (It's pretty janky though)
    realtime.on('update', function(e) {
        Object.keys(e.update).forEach(function(id) {
        var feature = e.update[id];
        this.getLayer(id)._heading = feature.properties['true_track']; // Using heading causes the symbol to freak out
        this.getLayer(id)._course = feature.properties['true_track']; 
        this.getLayer(id)._speed = feature.properties['velocity'];
          this.getLayer(id).bindTooltip(   '<b>'+ feature.properties['callsign'] 
          +'</b><br>Heading: ' + feature.properties['true_track'] +' Degrees <br>' 
          +'</b><br>Altitude: '+ feature.properties['geo_altitude'] +' m <br>' 
          + 'Speed: ' + feature.properties['velocity'] + ' m/s',
          );
        }.bind(this));
      });
 }
 
// - ARDUPILOT

function initiateArdupilotQuery(trackLayer, map){   
      
    function onEachFeature(feature, layer) {
        layer.on('click', function (e) {
            console.log(e);
            });
        }
    var realtime = L.realtime({
        // Local python server running an ArduPilot SITL drone
        url: 'http://127.0.0.1:5005/getVehicleStatus',
    crossOrigin: true,
    type: 'json'
    }, {
    interval: 1 * 1000,
    getFeatureId: function(feature) {
        // required for L.Realtime to track which feature is which
        // over consecutive data requests.
        return feature.id;
    },
  
    // Create the feature to display the track
    pointToLayer: function(feature, latlng) {
        var marker = L.trackSymbol(latlng, {
        trackId: feature.id,
        fill: true,
        fillColor: '#F32B2B',
        fillOpacity: 1.0,
        stroke: true,
        color: '#000000',
        opacity: 1.0,
        weight: 1.0,
        speed: feature.properties['velocity'],
        course: feature.properties['heading'], 
        heading: feature.properties['heading'],
        interactive: true
    }).bindTooltip(
            '<b>'+ feature.id
            +'</b><br>Heading: ' + feature.properties['heading'] +' Degrees <br>' 
            +'</b><br>Altitude: '+ feature.properties['geo_altitude'] +' m <br>' 
            + 'Speed: ' + feature.properties['velocity'] + ' m/s', 
            {
                permanent: false, opacity: 0.7}
        );
        return marker;
    },
    // GeoJSON - How to attach events to the layer - L.RealTime doesn't support direct interaction...
    onEachFeature: onEachFeature
    }).addTo(trackLayer);

    // Update the track/popup with the current speed, heading, course and altitude.
    // This will update the underlying icon. (It's pretty janky though)
    realtime.on('update', function(e) {
        Object.keys(e.update).forEach(function(id) {
        var feature = e.update[id];
        this.getLayer(id)._heading = feature.properties['course']; // Using heading causes the symbol to freak out
        this.getLayer(id)._course = feature.properties['course']; 
        this.getLayer(id)._speed = feature.properties['velocity'];
          this.getLayer(id).bindTooltip(   '<b>'+ feature.id
          +'</b><br>Heading: ' + feature.properties['heading'] +' Degrees <br>' 
          +'</b><br>Altitude: '+ feature.properties['geo_altitude'] +' m <br>' 
          + 'Speed: ' + feature.properties['velocity'] + ' m/s',
          );
        }.bind(this));
      });      
}
