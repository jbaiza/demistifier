//https://developer.here.com/api-explorer/geovisualization/technology_markers/markers-csv-provider
/** Config **/
var startPosition = new H.geo.Point(56.962526, 24.097702);
var departureTime = '2018-09-28T08:00:00';

var SECONDS = 1;
var MINUTES = 60 * SECONDS;
var timeRange = 15 * MINUTES;

var dataEndpoint = 'data.csv'; //'https://demistifier.ngrok.io/institutions.csv';
///////////////////////////////////////////////////////////////////////////
var hoveringInfo = false;

(function () {
    'use strict';
    
    var app_id = 'Wdwou7J9CcHwv9JKHUWp';      // <- replace with your own from 
    var app_code = 'ZhWENaBcff6Kuu5QWWhYsQ';  // <- https://developer.here.com
    // Initialize communication with the platform, to access your own data, change the values below
    // https://developer.here.com/documentation/geovisualization/topics/getting-credentials.html

    // We recommend you use the CIT environment. Find more details on our platforms below
    // https://developer.here.com/documentation/map-tile/common/request-cit-environment-rest.html

    const platform = new H.service.Platform({
        app_id,
        app_code,
        useCIT: true,
        useHTTPS: true
    });

    const pixelRatio = devicePixelRatio > 1 ? 2 : 1;
    let defaultLayers = platform.createDefaultLayers({
        tileSize: 256 * pixelRatio
    });
    const layers = platform.createDefaultLayers({
        tileSize: 256 * pixelRatio,
        ppi: pixelRatio > 1 ? 320 : 72
    });

    // initialize a map  - not specifying a location will give a whole world view.
    let map = new H.Map(
        document.getElementsByClassName('dl-map')[0],
        defaultLayers.normal.base,
        {
            pixelRatio,
            center: startPosition,
            zoom: 13
        }
    );

    // make the map interactive
    const behavior = new H.mapevents.Behavior(new H.mapevents.MapEvents(map));
    let ui = H.ui.UI.createDefault(map, layers);
    ui.removeControl('mapsettings');

    // Get an instance of the routing service
    var router = platform.getRoutingService();

    // Set a new starting position (departure) when the user clicks the map
    map.addEventListener('tap', function (evt) {
        if (!hoveringInfo) {
            var coord = map.screenToGeo(evt.currentPointer.viewportX, evt.currentPointer.viewportY);
            startPosition = coord.lat + ',' + coord.lng;
            startIsolineRouting();
        } else if (hoveredObject.icon) {
            let row = hoveredObject.getData();
            if (row) {
                let mailto = row[5];
                window.location.href = mailto;
            }
        }
    });
    function startIsolineRouting() {
        // Set up the Routing API parameters
        var routingParams = {
            'mode': 'fastest;car;traffic:enabled', // car, truck (only with type fastest), pedestrian
            'start': startPosition,
            'departure': departureTime,	// can also use 'arrival' or both
            'rangetype': 'time', // distance (meters), time (seconds)
            'range': timeRange
        };

        // Call the Routing API to calculate an isoline
        router.calculateIsoline(
            routingParams,
            onResult,
            function (error) {
                alert(error.message);
            });
    }
    
    var onResult = function (result) {
        var center = new H.geo.Point(result.response.center.latitude, result.response.center.longitude),
            isolineCoords = result.response.isoline[0].component[0].shape,
            linestring = new H.geo.LineString(),
            isolinePolygon,
            isolineCenter;

        // Add the returned isoline coordinates to a linestring
        isolineCoords.forEach(function (coords) {
            linestring.pushLatLngAlt.apply(linestring, coords.split(','));
        });

        // Create a polygon and a marker representing the isoline
        isolinePolygon = new H.map.Polygon(linestring);
        isolineCenter = new H.map.Marker(center);

        // Add the polygon and marker to the map
        map.addObjects([isolineCenter, isolinePolygon]);

        // Center and zoom the map so that the whole isoline polygon is in the viewport:
        map.setViewBounds(isolinePolygon.getBounds());
    };


    // resize map on window resize
    window.addEventListener('resize', function () {
        map.getViewPort().resize();
    });

    // data from the Open Berlin Data
    // https://www.berlin.de/sen/kultur/kulturpolitik/statistik-open-data/orte-geodaten/
    // download link:
    // https://www.berlin.de/sen/kultur/_assets/statistiken/kultureinrichtungen_alle.xlsx
    let provider = new H.datalens.RawDataProvider({
        dataUrl: dataEndpoint,
        dataToFeatures: (data) => {
            let parsed = helpers.parseCSV(data);
            let features = [];
            let row = null;
            let feature = null;

            function map_range(value, low1, high1, low2, high2) {
                return low2 + (high2 - low2) * (value - low1) / (high1 - low1);
            }

            function heat(q) {
                var clamp = 500;
                var r = Math.floor(map_range(Math.min(q, clamp), 1, clamp, 1, 255));
                var g = Math.floor(map_range(Math.min(q, clamp), 1, clamp, 255, 1));
                var b = 55;
                return `#${r.toString(16).padStart(2, '0')}${g.toString(16).padStart(2, '0')}${b.toString(16).padStart(2, '0')}`;;
            }

            for (let i = 1, l = parsed.length; i < l; i++) {
                row = parsed[i];
                feature = {
                    'type': 'Feature',
                    'geometry': {
                        'type': 'Point',
                        'coordinates': [Number(row[8]), Number(row[7])]
                    },
                    'properties': {
                        'facility': row[0],
                        'address': row[3],
                        'email': row[5],
                        'type': row[4],
                        'mailto': 'mailto:' + row[5],
                        'language': row[10],
                        'startingAge': row[11],
                        'queueSize': row[12],
                        'queueHeat': heat(Number(row[12]))
                    }
                };
                features.push(feature);
            }
            return features;
        },
        featuresToRows: (features) => {
            let rows = [], feature;
            for (let i = 0, l = features.length; i < l; i++) {
                feature = features[i];
                rows.push([{
                    lat: feature.geometry.coordinates[1],
                    lng: feature.geometry.coordinates[0]
                },
                feature.properties.facility,
                feature.properties.address,
                feature.properties.email,
                feature.properties.type,
                feature.properties.mailto,
                feature.properties.language,
                feature.properties.startingAge,
                feature.properties.queueSize,
                feature.properties.queueHeat
                ]);
            }
            return rows;
        }
    });

    let layer = new H.datalens.ObjectLayer(provider, {
        pixelRatio: window.devicePixelRatio,

        // accepts data row and returns map object
        rowToMapObject: function (data) {
            let coordinates = data[0];
            let facility = data[1];
            return new H.map.Marker(coordinates);
        },

        rowToStyle: function (data, zoom) {
            let icon = H.datalens.ObjectLayer.createIcon(`<svg version="1.0" xmlns="http://www.w3.org/2000/svg"  width="50.000000pt" height="50.000000pt" viewBox="0 0 50.000000 50.000000"  preserveAspectRatio="xMidYMid meet"><metadata>Created by potrace 1.15, written by Peter Selinger 2001-2017</metadata><g transform="translate(0.000000,50.000000) scale(0.100000,-0.100000)" fill="${data[9]}" stroke="none"><path d="M169 479 c-48 -28 -73 -73 -72 -129 0 -35 14 -74 62 -169 33 -68 61 -134 61 -147 0 -19 5 -24 24 -24 19 0 25 7 30 33 3 18 33 89 66 157 34 69 60 138 60 155 0 43 -39 105 -80 126 -46 25 -106 24 -151 -2z"/></g></svg>`,
                { size: 30 * pixelRatio });
            return { icon };
        }
    });

    // add layer to map
    map.addLayer(layer);

    // show info bubble on hover
    const format = d3.format('.2f');
    let hoveredObject;
    let infoBubble = new H.ui.InfoBubble({ lat: 0, lng: 0 }, {});
    infoBubble.addClass('info-bubble');
    infoBubble.close();
    ui.addBubble(infoBubble);

    map.addEventListener('pointermove', (e) => {
        if (hoveredObject && hoveredObject !== e.target) {
            infoBubble.close();
            hoveringInfo = false;
        }

        hoveredObject = e.target;
        if (hoveredObject.icon) {
            let row = hoveredObject.getData();
            if (row) {
                let facility = row[1];
                let address = row[2];
                let email = row[3];
                let language = row[6];
                let startingAge = row[7];
                let queueSize = row[8];

                let pos = map.screenToGeo(
                    e.currentPointer.viewportX,
                    e.currentPointer.viewportY);
                infoBubble.setPosition(pos);
                infoBubble.setContent(`
                <div class="info-bubble-title">${facility}</div>
                <div class="info-bubble-label">
                    ${address} <br />
                    Apmācības valoda: ${language} <br />
                    Rindas garums: ${queueSize} <br />
                    Uzņemšanas vecums: ${startingAge} <br />
                    ${email}
                </div>`);
                infoBubble.open();
                hoveringInfo = true;
            }
        }
    });

}());