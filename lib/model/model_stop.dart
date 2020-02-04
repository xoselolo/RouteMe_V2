import 'package:latlong/latlong.dart';

class Stop{
  final String name;
  final String placeId;
  final double latitude;
  final double longitude;
  final int userRatingsTotal;
  final dynamic rating;
  final String icon;
  final bool openNow;
  final String photo;
  dynamic distanceM;
  bool toVisit;


  Stop(this.name, this.placeId, this.latitude, this.longitude,
      this.userRatingsTotal, this.rating, this.icon, this.openNow, this.toVisit, this.distanceM, this.photo);


  factory Stop.fromJson(Map<String, dynamic> json){
    return new Stop(
        json['name'],
        json['place_id'],
        json['geometry']['location']['lat'],
        json['geometry']['location']['lng'],
        json['user_ratings_total'] == null ? 0 : json['user_ratings_total'],
        json['rating'] == null ? 0 : json['rating'],
        json['icon'] == null ? "no_icon" : json['icon'],
        json['opening_hours'] == null ? true : json['opening_hours']['open_now'] == null ? true : json['opening_hours']['open_now'],
        true,
        -1,
        json['photos'] == null ? null : json['photos'][0]['photo_reference'] == null ? null : json['photos'][0]['photo_reference']
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'placeId': placeId,
        'latitude': latitude,
        'longitude': longitude,
        'userRatingsTotal': userRatingsTotal,
        'rating': rating,
        'icon': icon,
        'openNow': openNow
      };

  @override
  bool operator ==(Object other) {
    Stop otherStop = other as Stop;
    return otherStop.placeId.compareTo(this.placeId) == 0;
  }


}