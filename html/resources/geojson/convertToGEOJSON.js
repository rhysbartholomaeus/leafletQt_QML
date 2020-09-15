
async function httpGet(url){
    let response = await fetch(url)
    console.log(response.status); // 200

    if (response.status === 200) {
        let data = await response.json();
        return convertJSONtoGEOJSON(data);
    }
}

function getOpenSkyJSON(url)
{
    fetch(url)
    .then(
        function(response){
            if (response.ok){
                
                console.log('Fetch for ' + url + ' successful');
                response.json().then(function(data){
                    console.log(data);
                    if(data.length != 0){
                        return convertJSONtoGEOJSON(data)
                    }
                    
                    
                });
                return;
            }
        }
    )
    .catch(function(err){
        console.log('Fetch error :-S', err);
    }); 
}

function convertJSONtoGEOJSON(json)
{    
    var geojson = {
            type: "FeatureCollection",
            features: [],
        };

    for (i = 0; i < json.states.length; i++) {

        geojson.features.push({
        "type": "Feature",
        "geometry": {
            "type": "Point",
            "coordinates": [json.states[i][5], json.states[i][6]]
        },
        "properties": {
            "id": json.states[i][0],
             "callsign": json.states[i][1],
             "altitude": json.states[i][7]
        }
        });
        console.log(geojson);
        return geojson;
    }
}