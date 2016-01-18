var applyToObject = function(object, applyThis) {
    $.each(applyThis, function(key, value) {
        object[key] = value;
    });
    return object;
};

var geocodeAddress = function(address, options) {
    options = options || {};
    var geocoder = new google.maps.Geocoder(); 
    geocoder.geocode(
        {
            address: address, 
            region: 'no' 
        },
        function(results, status) {
            if (status.toLowerCase() == 'ok') {
                if (typeof(options['success'] == 'function')) {
                    options['success']({
                        'latitude': results[0]['geometry']['location'].lat(),
                        'longitude': results[0]['geometry']['location'].lng()
                    });
                }
            } else {
                if (typeof(options['failure'] == 'function')) {
                    options['failure']();
                }
            }
              
            if (typeof(options['complete'] == 'function')) {
                options['complete']();
            }
        }
    );
};

var navigatorPosition = function(options) {
    options = options || {};
    var success = options['success'] || function(position){};
    var failure = options['failure'] || function(){};
    navigator.geolocation.getCurrentPosition(
        function(position){
            success(position);
        }, 
        function(){
            failure()
        }
    );
};




var geoMap = function(locations, init) {
    init = init || {};
    var cssId = init['cssId'] || '#map';
    delete(init['cssId']);
    var firstLocation = locations.shift();
    var options = {'div':cssId};
    options = applyToObject(options, initMap(firstLocation, init));
    var map = new GMaps(options);
    addMarkers(map, locations);
};
var initMap = function(location, init) {
    init = init || {};
    var options = {
        'zoom': init['zoom'] || 6,
        'scaleControl': (init['scale_control'] ? init['scale_control'] : true),
        'rotateControl': (init['rotate_control'] ? init['rotate_control'] : true),
        'panControl': (init['pan_control'] ? init['pan_control'] : true),
        'navigationControl': (init['navigation_control'] ? init['navigation_control'] : true),
        'mapTypeId': google.maps.MapTypeId.ROADMAP, //HYBRID, ROADMAP, SATELLITE, TERRAIN
        'mapTypeControl': (init['map_type_control'] ? init['map_type_control'] : true),
        'overviewMapControl': (init['overview_map_control'] ? init['overview_map_control'] : true),
        'streetViewControl': (init['street_view_control'] ? init['street_view_control'] : true),
        'zoomControl': (init['zoom_control'] ? init['zoom_control'] : true)
    };
    return applyToObject(options, getMarkerPosition(location));
};
var addMarkers = function(map, locations) {
    var markers = [];
    $.each(locations, function(index, location) {
        markers.push(addMarker(map, location));
    });
    return markers;
};
var addMarker = function(map, location) {
   var options = getMarkerPosition(location);
   options = applyToObject(options, getMarkerTitle(location));
   options = applyToObject(options, getMarkerIcon(location));
   options = applyToObject(options, getMarkerInfoWindow(location));
   return map.addMarker(options);
};
  
var getMarkerPosition = function(options) {
    return {'lat':options['lat'], 'lng': options['lng']};
};
  
var getMarkerTitle = function(location) {
    return {'title': location['title']};
};
  
var getMarkerIcon = function(location) {
    return {
        'icon':{
            'url':location['icon']['url'],
            'scaledSize':new google.maps.Size(32,32)
        }
    };
};
  
var getMarkerInfoWindow = function(location) {
    var ret = {}
    if (location['info_window']) {
        ret = {'infoWindow': {'content': location['info_window']['content']}};
    }
    return ret;
};




var showLocationDirections = function(options) {
    var currentPosition = options['currentPosition'];
    var locationPosition = options['locationPosition'];
    var mapSelector = options['mapSelector'] || ".directions-map";
    var panelSelector = options['panelSelector'] || ".directions-panel";    
    var modeOfTravel = modesOfTravel[options['modeOfTravel']] || modesOfTravel['WALKING'];
    var parentEl = $(mapSelector + ', ' + panelSelector).parent().first();
    
    var directionsDisplay;
    var directionsService = new google.maps.DirectionsService();
    var map;

    var initialize = function() {
        directionsDisplay = new google.maps.DirectionsRenderer();
        var mapOptions = {
            zoom:4,
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            center: currentPosition
        }
        map = new google.maps.Map($(mapSelector)[0], mapOptions);
        directionsDisplay.setMap(map);
        directionsDisplay.setPanel($(panelSelector)[0]);
    };

    var calcRoute = function () {
        var request = {
            origin: currentPosition,
            destination: locationPosition,
            travelMode: modeOfTravel
        };
        directionsService.route(request, function(response, status) {
            if (status == google.maps.DirectionsStatus.OK) {
                directionsDisplay.setDirections(response);
            }
        });
    };

    initialize();
    calcRoute();

    $(mapSelector + ', ' + panelSelector).css('height', parentEl.width()+'px');
};