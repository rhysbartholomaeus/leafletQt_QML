# This is a simple flask server that converts OpenSky Networks JSON into GEOJSON
# Adapted from: https://tkardi.ee/writeup/post/2019/04/27/building-a-totally-useless-map/

import requests
from flask import Flask, request, jsonify, Response, json
from flask_cors import CORS
from collections import OrderedDict

app = Flask("openskynetworks")
CORS(app)

url = 'https://opensky-network.org/api/states/all'
keys = [
    'icao24', 'callsign', 'origin_country', 'time_position', 'last_contact',
    'longitude', 'latitude', 'baro_altitude', 'on_ground', 'velocity',
    'true_track', 'vertical_rate', 'sensors', 'geo_altitude', 'squawk',
    'spi', 'position_source'
]

def get_flight_radar_data():
    r = requests.get(url)
    r.raise_for_status()
    return to_geojson(r.json())

def to_geojson(data):
    f = [
        OrderedDict(
            type='Feature',
            id=ac[0],
            geometry=OrderedDict(type='Point', coordinates=[ac[5],ac[6]]),
            properties=OrderedDict(zip(keys, ac))
        ) for ac in data.get('states', [])
    ]

    return dict(
        type='FeatureCollection',
        features=f
    )

@app.route('/flightradar')
def flightradar():
    tempResponse = Response()
    # This is to overcome issues with the QRC cross origin issues
    tempResponse.headers.add('Access-Control-Allow-Origin', '*')

    return Response(
        response=json.dumps(get_flight_radar_data()),
        status=200,
        headers=tempResponse.headers,
        mimetype='application/json'
    )