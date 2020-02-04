import 'dart:collection';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/src/material/slider_theme.dart';
import 'package:flutter_route_me/model/model_filter_type.dart';
import 'package:flutter_route_me/model/model_stop.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:image_downloader/image_downloader.dart';
import 'package:location/location.dart';

class PlacesManager{



  // https://maps.googleapis.com/maps/api/place/nearbysearch/json?
  // location=41.3887901,2.1589899
  // &radius=1500
  // &type=park
  // &key=AIzaSyBu2_4IESvaFXrUEpe2HT3slLjmt7wlBhk

  final String PLACES_BASE_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?";
  final String PLACES_PARAMETER_LOCATION = "location=";
  final String PLACES_PARAMETER_RADIUS = "&radius=";
  final String PLACES_PARAMETER_TYPES = "&types=";
  final String API_KEY = "&key=AIzaSyBu2_4IESvaFXrUEpe2HT3slLjmt7wlBhk";

  final String SUGGESTED_BASE_URL = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=";
  final String INTEREST_API_KEY = "+point+of+interest&key=AIzaSyBu2_4IESvaFXrUEpe2HT3slLjmt7wlBhk";

  final String PLACE_PHOTO_BASE_URL = "https://maps.googleapis.com/maps/api/place/photo?";
  final String PLACE_PHOTO_MAXH = "maxheight=";
  final String PLACE_PHOTO_MAXW = "&maxwidth=";
  final String PLACE_PHOTO_REFERENCE = "&photoreference=";
// CmRaAAAAXKVZLayn6A9D7Ec2Mzx5LpPV48KF3OwU6ygc6Wj3Q3jazgpp3ROg5aisSlhYdiNGWimHxQvzMnud2_RSuNFBrqOAovspJbUA-dKTv5H6aUf95ziEpPL4p9zi1nZtP-ssEhDY9HM062ADkhln6B7ynZ18GhT7oc3pHrcxvcs3CcBDEb8YU4bvZA
// &key=AIzaSyBu2_4IESvaFXrUEpe2HT3slLjmt7wlBhk

  final String GEOCODE_BASE_URL = "https://maps.googleapis.com/maps/api/geocode/json?";
  final String GEOCODE_LAT = "latlng=";

  final String LOCALITY_TAG = "CIUDAD";
  final String COUNTRY_TAG = "PAIS";

  // https://maps.googleapis.com/maps/api/geocode/json?
  // latlng=40.714224
  // ,
  // -73.961452
  // &key=YOUR_API_KEY

  Future<List<File>> searchSuggestedPlacesPhotos(List<Stop> stops, String maxW, String maxH) async {
    String url = "";

    List<File> images = new List<File>();

    for(int i = 0; i < stops.length; i++){

      if(stops.elementAt(i).photo != null){
        url = PLACE_PHOTO_BASE_URL
            + PLACE_PHOTO_MAXH
            + maxH
            + PLACE_PHOTO_MAXW
            + maxW
            + PLACE_PHOTO_REFERENCE
            + stops.elementAt(i).photo
            + API_KEY;

        print("look photo " + i.toString());
        print(url);

        try {
          var imageId = await ImageDownloader.downloadImage(url);
          var path = await ImageDownloader.findPath(imageId);
          images.add(File(path));
        } catch (error) {
          print(error);
        }
      }
    }

    return images;
  }
  Future<List<Stop>> searchSuggestedPlaces(String locality) async {
    // https://maps.googleapis.com/maps/api/place/textsearch/json?query=new+york+city+point+of+interest&key=AIzaSyBu2_4IESvaFXrUEpe2HT3slLjmt7wlBhk
    List<String> splitted = locality.split(' ');
    String citySplitted = splitted.elementAt(0);
    for (int i = 1; i < splitted.length; i++){
      citySplitted = citySplitted + "+" + splitted.elementAt(i);
    }

    String url =
        SUGGESTED_BASE_URL +
            citySplitted +
            INTEREST_API_KEY;

    var response = await http.get(url);
    if (response.statusCode == 200){
      print("Response OK!");

      print(response.request.url.toString());
      print(response.body);

      final Map body = convert.json.decode(response.body);

      List<dynamic> results = body['results'];

      if(results.length == 0 || results.isEmpty){
        return null;

      }else{
        List<Stop> suggestedPlaces = new List<Stop>();

        for(int i = 0; i < results.length; i++){
          Stop suggestedStop = new Stop.fromJson(results.elementAt(i));
          suggestedStop.toVisit = false;
          suggestedPlaces.add(suggestedStop);
        }

        suggestedPlaces.sort((a,b) => (b.userRatingsTotal * b.rating).compareTo(a.userRatingsTotal * a.rating));
        return suggestedPlaces;
      }

    }else{
      print("Response KO!");
      return null;
    }

  }
  Future<List<Stop>> searchOneTypePlaces(Position initialPosition, List<FilterType> filters, int index) async {
    String url =
        PLACES_BASE_URL +
        PLACES_PARAMETER_LOCATION +
        initialPosition.latitude.toString() +
        ", " +
        initialPosition.longitude.toString() +
        PLACES_PARAMETER_RADIUS +
        2500.toString() +
        PLACES_PARAMETER_TYPES +
        filters.elementAt(index).value +
        API_KEY;

    var response = await http.get(url);
    if (response.statusCode == 200){
      print("Response OK!");

      print(response.request.url.toString());
      print(response.body);

      final Map body = convert.json.decode(response.body);

      List<dynamic> results = body['results'];

      if(results.length == 0 || results.isEmpty){
        return null;

      }else{
        List<Stop> typeXplaces = new List<Stop>();

        //for(int i = 0; i < results.length; i++){
        for(int i = 0; i < results.length; i++){
          typeXplaces.add(new Stop.fromJson(results.elementAt(i)));
        }
        return typeXplaces;
      }

    }else{
      print("Response KO!");
      return null;
    }

  }
  Future<HashMap<String,String>> geocode(LocationData locationData) async {
    String url =
        GEOCODE_BASE_URL +
            GEOCODE_LAT +
            locationData.latitude.toString() +
            "," +
            locationData.longitude.toString() +
            API_KEY;

    var response = await http.get(url);
    if (response.statusCode == 200) {
      print("Response OK!");

      print(response.request.url.toString());
      print(response.body);

      final Map body = convert.json.decode(response.body);

      List<dynamic> results = body['results'];

      HashMap<String,String> hashMap = new HashMap<String,String>();
      List<dynamic> addressComponents = results[0]['address_components'];
      List<dynamic> types;
      int length = addressComponents.length;
      int count = 0;
      for(int i = 0; i < length && count < 2; i++){
        types = results[0]['address_components'][i]['types'];
        if(types.contains("locality")){
          hashMap.putIfAbsent(LOCALITY_TAG, addressComponents.elementAt(i)['long_name']);
          count++;
        }else{
          if(types.contains("country")){
            hashMap.putIfAbsent(COUNTRY_TAG, addressComponents.elementAt(i)['long_name']);
            count++;
          }
        }
      }

      return hashMap;


    }else{
      print("Response KO!");
      return null;
    }
  }

  PlacesManager();


}