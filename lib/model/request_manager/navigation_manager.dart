import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import '../model_stop.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class NavigationManager{

  static final String NAVIGATION_URL_BASE = "https://api.mapbox.com/directions/v5/mapbox/walking/";
  static final String NAVIGATION_LAST_PART = "?alternatives=true&geometries=geojson&steps=true&";
  static final String MAPBOX_PUBLIC_TOKEN = "access_token=pk.eyJ1IjoieG9zZWxvbG8zOCIsImEiOiJjazV6dHIwcnQwMHprM25vYWNqMGNwaGUyIn0.HLAQdycXW-AJT8Hc0wi1ag";

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


  static Future<Map> request(List<Stop> stops, LatLng initialPosition, int i) async {
    // Construim la url de la request
    String url = NAVIGATION_URL_BASE;
    url += initialPosition.latitude.toString() + "%2C" + initialPosition.longitude.toString();

    /*int numStops = stops.length;
    for(int i = 0; i < numStops; i++){
      url += "%3B" + stops.elementAt(i).latitude.toString() + "%2C" + stops.elementAt(i).longitude.toString();
    }*/

    url += "%3B" + stops.elementAt(i).latitude.toString() + "%2C" + stops.elementAt(i).longitude.toString();

    url += NAVIGATION_LAST_PART + MAPBOX_PUBLIC_TOKEN;

    var response = await http.get(url);
    if (response.statusCode == 200) {
      print("Response OK!");

      print(response.request.url.toString());
      print(response.body);

      /*  TODO
        TRATAR EL BODY:
            - coger la leg[0] -> porque solo hacemos la request hacia la stop que nos toca
            - la step[0]
            - la step[1]

            si la step[1] es del tipo arrive:
                si la distance es menor de 250 metros, mostrar el bottom sheet
                sino mostrar mensaje normal
            sino, mostrar mensaje normal
       */

      return convert.json.decode(response.body);

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
  double distance;

  StepManeuver(this.placeStreetName, this.type, this.latitude, this.longitude,
      this.instruction, this.modifier, this.distance);

}