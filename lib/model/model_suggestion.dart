class Suggestion{
  final String placeId;
  final String name;

  Suggestion(this.placeId, this.name);
  
  factory Suggestion.fromJson(Map<String, dynamic> json){
    return new Suggestion(json['place_id'], json['description']);
  }


}