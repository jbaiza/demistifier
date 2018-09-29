// 99.5% copy-paste : https://medium.com/@sueselbeck/find-your-dream-home-using-the-here-isoline-routing-api-7c4d32095c55

// Where is our departure point?
var startPosition = '56.924012,24.137290';
var departureTime = '2018-09-28T07:00:00';

var SECONDS = 1;
var MINUTES = 60 * SECONDS;
var timeRange = 15 * MINUTES;

// Setting up the map platform
var platform = new H.service.Platform({
  app_id: 'Wdwou7J9CcHwv9JKHUWp',      // <- replace with your own from 
  app_code: 'ZhWENaBcff6Kuu5QWWhYsQ',  // <- https://developer.here.com
  useHTTPS: true
});

// Setting up the map (with default layers, behaviour and UI)
var defaultLayers = platform.createDefaultLayers();

var map = new H.Map(document.getElementById('map'),
  defaultLayers.normal.map, {
    center: {lat: 56.924012, lng: 24.137290 },
    zoom: 15
  });

var behavior = new H.mapevents.Behavior(new H.mapevents.MapEvents(map));

var ui = H.ui.UI.createDefault(map, defaultLayers);


// Get an instance of the routing service
var router = platform.getRoutingService();

// Set a new starting position (departure) when the user clicks the map
map.addEventListener('tap', function (evt) {    
  var coord = map.screenToGeo(evt.currentPointer.viewportX, evt.currentPointer.viewportY);  
  startPosition = coord.lat + ',' + coord.lng;
  startIsolineRouting();
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
    function(error) {
    alert(error.message);
    });
}

var onResult = function(result) {
  var center = new H.geo.Point(result.response.center.latitude, result.response.center.longitude),
    isolineCoords = result.response.isoline[0].component[0].shape,
    linestring = new H.geo.LineString(),
    isolinePolygon,
    isolineCenter;

  // Add the returned isoline coordinates to a linestring
  isolineCoords.forEach(function(coords) {
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