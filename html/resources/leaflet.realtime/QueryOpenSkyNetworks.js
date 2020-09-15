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
        // style the aeroplane loction markers with L.DivIcons
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
            // and as we're already here, bind a tooltip based on feature
            // property values
            '<b>'+ feature.properties['callsign'] 
                +'</b><br>Altitude: '+ feature.properties['geo_altitude'] +' m <br>' 
                + 'Speed: ' + feature.properties['velocity'] + ' m/s',
            {
                permanent: false, opacity: 0.7}
        );
        return marker;
    }
    }).addTo(trackLayer);
 }
 