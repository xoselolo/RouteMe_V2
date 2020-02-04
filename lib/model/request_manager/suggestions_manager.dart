import 'package:flutter_route_me/model/model_suggestion.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class SuggestionsManager{

  SuggestionsManager();

  final String SUGGESTIONS_BASE_URL = "https://maps.googleapis.com/maps/api/place/autocomplete/json?";
  final String SUGGESTIONS_INPUT = "input=";
  final String API_KEY = "&key=AIzaSyBu2_4IESvaFXrUEpe2HT3slLjmt7wlBhk";

  Future<List<Suggestion>> getSuggestion(String text) async {
    if(text == null || text.isEmpty || text.length == 0){
      return null;
    }else{
      String url = SUGGESTIONS_BASE_URL + SUGGESTIONS_INPUT;

      List<String> separatedWords = text.split(' ');
      url = url + separatedWords.elementAt(0);

      for (int i = 1; i < separatedWords.length; i++){
        url = url + "+" + separatedWords.elementAt(i);
      }

      url = url + API_KEY;

      var response = await http.get(url);
      if (response.statusCode == 200){
        print("Response OK!");

        print(url);
        print(response.body);

        final Map body = convert.json.decode(response.body);

        List<dynamic> results = body['predictions'];

        if(results.length == 0 || results.isEmpty){
          return null;

        }else{

          List<Suggestion> suggestions = new List<Suggestion>();

          for(int i = 0; i < results.length; i++){
            suggestions.add(new Suggestion.fromJson(results.elementAt(i)));
          }

          return suggestions;
        }

      }else{
        print("Response KO!");
        return null;
      }
    }
  }
}