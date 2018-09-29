//https://developer.here.com/api-explorer/geovisualization/technology_markers/markers-csv-provider

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
            center: new H.geo.Point(52.3, 13.34),
            zoom: 10
        }
    );

    // make the map interactive
    const behavior = new H.mapevents.Behavior(new H.mapevents.MapEvents(map));
    let ui = H.ui.UI.createDefault(map, layers);
    ui.removeControl('mapsettings');

    // resize map on window resize
    window.addEventListener('resize', function () {
        map.getViewPort().resize();
    });

    // data from the Open Berlin Data
    // https://www.berlin.de/sen/kultur/kulturpolitik/statistik-open-data/orte-geodaten/
    // download link:
    // https://www.berlin.de/sen/kultur/_assets/statistiken/kultureinrichtungen_alle.xlsx
    let provider = new H.datalens.RawDataProvider({
        dataUrl: 'data.csv',
        dataToFeatures: (data) => {
            let parsed = helpers.parseCSV(data);
            let features = [];
            let row = null;
            let feature = null;

            for (let i = 1, l = parsed.length; i < l; i++) {
                row = parsed[i];
                feature = {
                    'type': 'Feature',
                    'geometry': {
                        'type': 'Point',
                        'coordinates': [Number(row[3]), Number(row[2])]
                    },
                    'properties': {
                        'facility': row[0],
                        'address': row[1],
                        'SUBahn': row[4],
                        'type': row[5]
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
                feature.properties.SUBahn,
                feature.properties.type
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
            if (!venueIcons[data[4]]) { return }
            let icon = H.datalens.ObjectLayer.createIcon(venueIcons[data[4]],
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
        }

        hoveredObject = e.target;
        if (hoveredObject.icon) {
            let row = hoveredObject.getData();
            if (row) {
                let facility = row[1];
                let address = row[2];
                let SUBahn = row[3];

                let pos = map.screenToGeo(
                    e.currentPointer.viewportX,
                    e.currentPointer.viewportY);
                infoBubble.setPosition(pos);
                infoBubble.setContent(`
                <div class="info-bubble-title">${facility}</div>
                <div class="info-bubble-label">
                    ${address} <br />
                    ${SUBahn}
                </div>`);
                infoBubble.open();
            }
        }
    });

}());