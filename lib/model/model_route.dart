class Route{
  final List<dynamic> geocoded_waypoints;
  final List<dynamic> routes;
  final String status;
  final List<dynamic> order;

  Route(this.geocoded_waypoints, this.routes, this.status, this.order);

  factory Route.fromJson(Map<String, dynamic> json){
    return new Route(
        json['geocoded_waypoints'],
        json['routes'],
        json['status'],
        json['routes'][0]['waypoint_order']
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'geocoded_waypoints': geocoded_waypoints,
        'routes': routes,
        'status' : status,
        'waypoint_order' : order
      };

}

class GeocodedWaypoint{
  final String geocoder_status;
  final String place_id;
  final List<String> types;

  GeocodedWaypoint(this.geocoder_status, this.place_id, this.types);

  factory GeocodedWaypoint.fromJson(Map<String, dynamic> json){
    return new GeocodedWaypoint(json['geocoder_status'], json['place_id'], json['types']);
  }

  Map<String, dynamic> toJson() =>
      {
        'geocoder_status': geocoder_status,
        'place_id': place_id,
        'types' : types
      };
}

class SubRoute{
  final Bounds bounds;
  final String copyrights;
  final List<Leg> legs;
  final String overview_polyline;
  final String summary;

  SubRoute(this.bounds, this.copyrights, this.legs, this.overview_polyline, this.summary);

  factory SubRoute.fromJson(Map<String, dynamic> json){
    return new SubRoute(
      json['bounds'],
      json['copyrights'],
      json['legs'],
      json['overview_polyline']['points'],
      json['summary']
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'bounds': bounds,
        'copyrights': copyrights,
        'legs' : legs,
        'overview_polyline' : overview_polyline,
        'summary' : summary
      };

}

class Bounds{
  final StartLocation northeast;
  final EndLocation southwest;

  Bounds(this.northeast, this.southwest);

  factory Bounds.fromJson(Map<String, dynamic> json){
    return new Bounds(json['northeast'], json['southwest']);
  }

  Map<String, dynamic> toJson() =>
      {
        'northeats': northeast,
        'southwest': southwest
      };

}

class Leg{
  final MyDistance distance;
  final Duration duration;
  final String end_address;
  final EndLocation end_location;
  final String start_address;
  final StartLocation start_location;
  final List<Step> steps;

  Leg(this.distance, this.duration, this.end_address, this.end_location,
      this.start_address, this.start_location, this.steps);

  factory Leg.fromJson(Map<String, dynamic> json){

    return new Leg(
        json['distance'],
        json['duration'],
        json['end_address'],
        json['end_location'],
        json['start_address'],
        json['start_location'],
        json['steps']
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'distance': distance,
        'duration': duration,
        'end_address' : end_address,
        'end_location' : end_location,
        'start_address' : start_address,
        'start_location' : start_location,
        'steps' : steps
      };

}

class Step{
  final MyDistance distance;
  final Duration duration;
  final EndLocation endLocation;
  final String html_instructions;
  final String maneuver;
  final String polyline;
  final StartLocation startLocation;
  final String travel_mode;

  Step(this.distance, this.duration, this.endLocation, this.html_instructions,
      this.maneuver, this.polyline, this.startLocation, this.travel_mode);

  factory Step.fromJson(Map<String, dynamic> json){
    return new Step(
        json['distance'],
        json['duration'],
        json['end_location'],
        json['html_instructions'],
        json['maneuver'] != null ? json['maneuver'] : "",
        json['polyline']['points'],
        json['start_location'],
        json['travel_mode']
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'distance': distance,
        'duration': duration,
        'end_location' : endLocation,
        'html_instructions' : html_instructions,
        'maneuver' : maneuver,
        'polyline' : polyline,
        'start_location' : startLocation,
        'travel_mode' : travel_mode
      };


}

class MyDistance{
  final String text;
  final int value;

  MyDistance(this.text, this.value);

  factory MyDistance.fromJson(Map<String, dynamic> json){
    return new MyDistance(json['text'], json['value']);
  }

  Map<String, dynamic> toJson() =>
      {
        'text': text,
        'value': value
      };
}

class Duration{
  final String text;
  final int value;

  Duration(this.text, this.value);

  factory Duration.fromJson(Map<String, dynamic> json){
    return new Duration(json['text'], json['value']);
  }

  Map<String, dynamic> toJson() =>
      {
        'text': text,
        'value': value
      };
}

class EndLocation{
  final double lat;
  final double lng;

  EndLocation(this.lat, this.lng);

  factory EndLocation.fromJson(Map<String, dynamic> json){
    return new EndLocation(json['lat'], json['lng']);
  }

  Map<String, dynamic> toJson() =>
      {
        'lat': lat,
        'lng': lng
      };
}

class StartLocation{
  final double lat;
  final double lng;

  StartLocation(this.lat, this.lng);

  factory StartLocation.fromJson(Map<String, dynamic> json){
    return new StartLocation(json['lat'], json['lng']);
  }

  Map<String, dynamic> toJson() =>
      {
        'lat': lat,
        'lng': lng
      };
}
