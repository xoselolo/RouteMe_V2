import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import '../model_stop.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class NavigationManager{

  static final String NAVIGATION_URL_BASE = "https://api.mapbox.com/directions/v5/mapbox/walking/";
  static final String NAVIGATION_LAST_PART = "?alternatives=true&geometries=polyline&steps=true&";
  static final String MAPBOX_PUBLIC_TOKEN = "access_token=pk.eyJ1IjoieG9zZWxvbG8zOCIsImEiOiJjazV6dHIwcnQwMHprM25vYWNqMGNwaGUyIn0.HLAQdycXW-AJT8Hc0wi1ag";

  // https://api.mapbox.com/directions/v5/mapbox/walking/
  // 2.1719086110892363%2C41.405941421575534
  // %3B
  // 2.1739052685871343%2C41.406529753110334
  // ?alternatives=true&geometries=polyline&steps=true&
  // access_token=pk.eyJ1IjoieG9zZWxvbG8zOCIsImEiOiJjazV6dHIwcnQwMHprM25vYWNqMGNwaGUyIn0.HLAQdycXW-AJT8Hc0wi1ag



  // https://api.mapbox.com/directions/v5/mapbox/walking/
  // -74.00275269581756%2C40.7446754272157
  // %3B
  // -73.99698466329299%2C40.74223568399697
  // %3B
  // -74.00052333355349%2C40.73231492724946
  // %3B
  // -73.98548398494601%2C40.73580076712645
  // %3B
  // -73.99011964298747%2C40.7409219390409
  // ?alternatives=true&geometries=geojson&steps=true&access_token=pk.eyJ1IjoieG9zZWxvbG8zOCIsImEiOiJjazV6dHIwcnQwMHprM25vYWNqMGNwaGUyIn0.HLAQdycXW-AJT8Hc0wi1ag


  static Future<StepManeuver> request(List<Stop> stops, Position initialPosition, int i, Position actualPosition, double previousDistance) async {
    // Construim la url de la request curta
    String urlShort = NAVIGATION_URL_BASE;
    urlShort += actualPosition.longitude.toString() + "%2C" + actualPosition.latitude.toString();
    urlShort += "%3B" + stops.elementAt(i).longitude.toString() + "%2C" + stops.elementAt(i).latitude.toString();
    urlShort += NAVIGATION_LAST_PART + MAPBOX_PUBLIC_TOKEN;
    var responseShort = await http.get(urlShort);

    // Construim la url de la request llarga
    String urlLong = NAVIGATION_URL_BASE;
    urlLong += initialPosition.longitude.toString() + "%2C" + initialPosition.latitude.toString();
    int numStops = stops.length;
    for(int i = 0; i < numStops; i++){
      urlLong += "%3B" + stops.elementAt(i).longitude.toString() + "%2C" + stops.elementAt(i).latitude.toString();
    }
    urlLong += "%3B" + stops.elementAt(i).longitude.toString() + "%2C" + stops.elementAt(i).latitude.toString();
    urlLong += NAVIGATION_LAST_PART + MAPBOX_PUBLIC_TOKEN;
    var responseLong = await http.get(urlLong);

    if (responseShort.statusCode == 200 && responseLong.statusCode == 200) {
      print("Both responses OK!");

      print("Short:");
      print(responseShort.request.url.toString());
      print("Long:");
      print(responseLong.request.url.toString());

      //print(responseShort.body);

      Map bodyShort = convert.json.decode(responseShort.body);
      Map bodyLong = convert.json.decode(responseLong.body);

      // get the actual step
      StepManeuver step = new StepManeuver(null, null, 0, 0, null, null, 0, 0, 0, null, false);

      step.placeStreetName = bodyShort['routes'][0]['legs'][0]['steps'][0]['name'];
      step.type = bodyShort['routes'][0]['legs'][0]['steps'][1]['maneuver']['type'];
      step.latitude = bodyShort['routes'][0]['legs'][0]['steps'][0]['maneuver']['location'][1];
      step.longitude = bodyShort['routes'][0]['legs'][0]['steps'][0]['maneuver']['location'][0];
      step.instruction = bodyShort['routes'][0]['legs'][0]['steps'][1]['maneuver']['instruction'];

      if(step.type != StepManeuver.ARRIVE_TAG){
        step.modifier = bodyShort['routes'][0]['legs'][0]['steps'][1]['maneuver']['modifier'];
      }
      step.stepDistance = bodyShort['routes'][0]['legs'][0]['steps'][0]['distance'];

      step.toStopDistance = bodyShort['routes'][0]['distance'];
      step.toStopDuration = bodyShort['routes'][0]['duration'];

      step.polyline = bodyLong['routes'][0]['geometry'];

      if(bodyLong['routes'][0]['distance'] > previousDistance){
        step.routeIsLarger = true;
      }else{
        step.routeIsLarger = false;
      }

      if(step.type == StepManeuver.ARRIVE_TAG){
        if(step.toStopDistance < 150){
          step.finish = true;
          step.instruction = "You have arrived to " + stops.elementAt(i).name;
        }else{
          step.instruction = "You are arriving to " + stops.elementAt(i).name;
        }
      }

      return step;

    }else{
      return null;
    }
  }

}

class StepManeuver{

  static final String DEPART_TAG = "depart";
  static final String ARRIVE_TAG = "arrive";

  String placeStreetName;
  String type;
  double latitude;
  double longitude;
  String instruction;
  String modifier;
  dynamic stepDistance;

  dynamic toStopDistance;
  dynamic toStopDuration;

  String polyline;

  bool finish;
  bool routeIsLarger;

  StepManeuver(this.placeStreetName, this.type, this.latitude, this.longitude,
      this.instruction, this.modifier, this.stepDistance, this.toStopDistance,
      this.toStopDuration, this.polyline, this.finish);

}