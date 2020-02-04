import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import '../model_stop.dart';

import 'package:mapbox_gl/mapbox_gl.dart';

class NavigationManager{

  final String NAVIGATION_URL_BASE = "https://api.mapbox.com/directions/v5/mapbox/walking/";
  final String NAVIGATION_LAST_PART = "?alternatives=true&geometries=geojson&steps=true&";
  final String MAPBOX_PUBLIC_TOKEN = "access_token=pk.eyJ1IjoieG9zZWxvbG8zOCIsImEiOiJjazV6dHIwcnQwMHprM25vYWNqMGNwaGUyIn0.HLAQdycXW-AJT8Hc0wi1ag";

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


  Future<Map> request(List<Stop> stops, LatLng initialPosition) async {
    String url;
    var response = await http.get(url);
    if (response.statusCode == 200) {
      print("Response OK!");

      print(response.request.url.toString());
      print(response.body);

      return convert.json.decode(response.body);

    }else{
      return null;
    }
  }

}