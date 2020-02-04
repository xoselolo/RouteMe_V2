import 'package:flutter_route_me/model/model_route.dart';
import 'package:flutter_route_me/model/model_stop.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class RouteManager{

  // https://maps.googleapis.com/maps/api/directions/json?
  // origin=41.4912978,2.158965
  // &destination=41.3912978,2.158945
  // &key=AIzaSyBu2_4IESvaFXrUEpe2HT3slLjmt7wlBhk

  // https://maps.googleapis.com/maps/api/directions/json?
  // origin=Adelaide,SA
  // &destination=Adelaide,SA
  // &waypoints=optimize:true
  // |Barossa+Valley,SA|Clare,SA|Connawarra,SA|McLaren+Vale,SA
  // &key=AIzaSyBu2_4IESvaFXrUEpe2HT3slLjmt7wlBhk


  final String ROUTE_BASE_URL = "https://maps.googleapis.com/maps/api/directions/json?";
  final String ROUTE_ORIGIN = "origin=";
  final String ROUTE_DESTINATION = "&destination=place_id:";
  final String ROUTE_WALKING_MODE = "&mode=walking";
  final String ROUTE_WAYPOINTS = "&waypoints=optimize:true";
  final String API_KEY = "&key=AIzaSyBu2_4IESvaFXrUEpe2HT3slLjmt7wlBhk";

  RouteManager();

  Future<Route> makeRoute(Position initialPosition, List<Stop> stops) async {


    String url = ROUTE_BASE_URL
        + ROUTE_ORIGIN
        + initialPosition.latitude.toString()
        + ","
        + initialPosition.longitude.toString()
        + ROUTE_DESTINATION
        + stops.elementAt(stops.length - 1).placeId
        + ROUTE_WALKING_MODE
        + ROUTE_WAYPOINTS;

    String waypointsStrings= "";
    for(int i = 0; i < stops.length - 1; i++){
      waypointsStrings = waypointsStrings + "|place_id:" + stops.elementAt(i).placeId;
    }

    url = url + waypointsStrings + API_KEY;
    print(url);


    var response = await http.get(url);
    if (response.statusCode == 200) {
      print("Response OK!");

      print(response.request.url.toString());
      print(response.body);

      final Map body = convert.json.decode(response.body);

      Route route = new Route.fromJson(body);

      return route;


    }else{
      print("Response KO");

      return null;
    }

  }

  Future<Route> makeAndGetRoutePolyline(double initialLatitude, double initialLongitude, List<Stop> stops) async {

    String url = ROUTE_BASE_URL
        + ROUTE_ORIGIN
        + initialLatitude.toString()
        + ","
        + initialLongitude.toString()
        + ROUTE_DESTINATION
        + stops.elementAt(stops.length - 1).placeId
        + ROUTE_WALKING_MODE
        + ROUTE_WAYPOINTS;

    String waypointsStrings= "";
    for(int i = 0; i < stops.length - 1; i++){
      waypointsStrings = waypointsStrings + "|place_id:" + stops.elementAt(i).placeId;
    }

    url = url + waypointsStrings + API_KEY;
    print(url);


    var response = await http.get(url);
    if (response.statusCode == 200) {
      print("Response OK! ESTA ES LA DE RUTA");

      print(response.request.url.toString());
      print(response.body);

      final Map body = convert.json.decode(response.body);
      return new Route.fromJson(body);
      //return getPolyline(body);

    }else{
      print("Response KO");

      return null;
    }

  }

  String getPolyline(Map<String, dynamic> json){
    return json['routes'][0] == null ? null : json['routes'][0]['overview_polyline']['points'];
  }

}