import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_route_me/widgets/widget_routeme_appbar.dart';
import 'package:google_fonts/google_fonts.dart';

class CityRoutesPage extends StatefulWidget {

  @required
  final String cityId;
  @required
  final String cityName;

  const CityRoutesPage({Key key, this.cityId, this.cityName}) : super(key: key);

  @override
  _CityRoutesPageState createState() => _CityRoutesPageState(this.cityId, this.cityName);
}


class _CityRoutesPageState extends State<CityRoutesPage> {

  final String cityId;
  final String cityName;
  var firestore;

  _CityRoutesPageState(this.cityId, this.cityName);


  @override
  void initState() {
    super.initState();
    firestore = Firestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          cityName,
          style: GoogleFonts.poppins(
              letterSpacing: 2
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: new Icon(Icons.help),
            onPressed: (){
              print("Todo: show help");
            },
          ),
        ],
        backgroundColor: Colors.red[400],
      ),
      body: FutureBuilder(
        future: getCityRoutes(cityId),
        builder: (_, cityRoutesSnapshot){
          if(cityRoutesSnapshot.connectionState == ConnectionState.waiting){
            return CircularProgressIndicator();
          }else{

            return ListView.builder(
                itemCount: cityRoutesSnapshot.data.length,
                itemBuilder: (_, index){
                  bool isFree = cityRoutesSnapshot.data[index].data['offer_id'] == "FREE";
                  bool hasDiscount = cityRoutesSnapshot.data[index].data['offer_id'] != "BASE";
                  double price = cityRoutesSnapshot.data[index].data['offer_id'] == "FREE" ? 0.0 : cityRoutesSnapshot.data[index].data['price'] + .0;
                  double discountedPrice;
                  double discount;

                  return ExpansionTile(
                    title: Text(
                        cityRoutesSnapshot.data[index].data['title'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    subtitle: cityRoutesSnapshot.data[index].data['offer_id'] == "FREE" ?
                      Text(
                        "FREE",
                        style: GoogleFonts.poppins(
                            color: Colors.green,
                            fontSize: 15,
                            fontWeight: FontWeight.bold
                        ),
                      ) :
                      !hasDiscount ?
                      Text(
                        price.toStringAsFixed(2) + "€",
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            //fontWeight: FontWeight.bold
                        ),
                      ) : FutureBuilder(
                        future: calculateRoutePrice(cityRoutesSnapshot.data[index]),
                        builder: (_, offerSnapshot){
                          if(offerSnapshot.connectionState == ConnectionState.waiting || offerSnapshot.hasError){
                            return Text(
                              "...",
                              style: TextStyle(
                                fontSize: 10
                              ),
                            );
                          }else{
                            discount = offerSnapshot.data['discount_percentage'] + .0;
                            discountedPrice = cityRoutesSnapshot.data[index].data['price'] - (cityRoutesSnapshot.data[index].data['price'] * offerSnapshot.data['discount_percentage'] / 100) + .0;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  discountedPrice.toStringAsFixed(2) + "€",
                                  style: GoogleFonts.poppins(
                                      color: Colors.red[700],
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  price.toStringAsFixed(2) + "€",
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey
                                  ),
                                ),
                                SizedBox(width: 4),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red[700],
                                    borderRadius: BorderRadius.circular(4)
                                  ),
                                  child: Text(
                                    "  - " + discount.toStringAsFixed(0) + "% ",
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 15,
                                        //fontWeight: FontWeight.bold
                                    ),
                                  ),
                                )
                              ],
                            );
                          }
                        }
                      ),

                    trailing: FutureBuilder(
                      future: getRouteRatings(cityRoutesSnapshot.data[index].documentID),
                      builder: (_, ratingSnapshot){
                        if(ratingSnapshot.connectionState == ConnectionState.waiting){
                          return Container(
                            height: 10,
                            width: 10,
                          );
                        }else{
                          dynamic rating = 0;
                          dynamic numRatings = ratingSnapshot.data['num_ratings'];

                          if(numRatings == 0){
                            rating = ratingSnapshot.data['base_rating'];
                          }else{
                            for(int i = 0; i < numRatings; i++){
                              rating += ratingSnapshot.data['user_ratings'][i]['rating'];
                            }
                            rating = rating / numRatings;
                          }

                          rating = rating +.0;

                          return Column(
                              children: <Widget>[
                                Text(
                                  rating.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                RatingBar(
                                  onRatingUpdate: (newRating){
                                    print(newRating.toString());
                                  },
                                  initialRating: rating,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  //itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                  itemSize: 14,
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  numRatings.toString(),
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 9
                                  ),
                                )
                              ]
                          );
                        }
                      },
                    ),
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 8,
                          left: 16,
                          right: 16
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                cityRoutesSnapshot.data[index].data['description'],
                                style: GoogleFonts.lato(),
                              ),
                            ),

                            SizedBox(
                              height: 10,
                            ),

                            FutureBuilder(
                              future: getRoutePhotos(cityRoutesSnapshot.data[index].documentID),
                              builder: (_, routePhotosSnapshot){
                                if(routePhotosSnapshot.connectionState == ConnectionState.waiting){
                                  return CircularProgressIndicator();
                                }else{
                                  List items = routePhotosSnapshot.data;
                                  if(items.length == 0){
                                    return SizedBox(height: 10);
                                  }else{
                                    return Container(
                                      height: 100,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        //itemCount: routePhotosSnapshot.data.length,
                                        itemCount: items.length,
                                        itemBuilder: (_, index){
                                          //print(routePhotosSnapshot.data);
                                          //print(urls.elementAt(index));
                                          return Row(
                                            children: <Widget>[
                                              SizedBox(
                                                width: 5,
                                              ),
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.network(
                                                    items.elementAt(index)
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              )
                                            ],
                                          );
                                        },
                                      ),
                                    );
                                  }
                                }
                              },
                            ),

                            SizedBox(
                              height: 10,
                            ),

                            Align(
                              alignment: Alignment.bottomCenter,
                              child: isFree ?
                              RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                ),
                                elevation: 3,
                                color: Colors.white,
                                onPressed: (){
                                  print("Todo: Get or buy the rute");
                                },
                                child: Text("Free")
                              ) :
                              RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                elevation: 3,
                                color: Colors.white,
                                onPressed: (){
                                  print("Todo: Get or buy the rute");
                                },
                                child: Text("Buy")
                              ),
                            ),
                          ],
                        )
                      ),
                    ],
                  );
                }
            );
          }
        },
      ),
    );
  }

  Future getCityRoutes(String cityId) async {
    QuerySnapshot snapshot = await firestore.collection('companies_routes')
        .where("cityId", isEqualTo: cityId).getDocuments();
    return snapshot.documents;
  }

  Future calculateRoutePrice(routeInfo) async {
    DocumentSnapshot snapshot = await firestore.collection('offers').document(routeInfo.data['offer_id']).get();
    return snapshot;
  }

  Future getRoutePhotos(String routeId) async {
    //HashMap<String, dynamic> map = new HashMap<String, dynamic>();

    //List keys = new List();
    List values = new List();
    List<String> urls = new List<String>();

    FirebaseStorage.instance.ref().child("routes/" + routeId).listAll().then((result) {
      LinkedHashMap itemsMap = result['items'];

      itemsMap.forEach((key, value) async {
        //keys.add(key);
        values.add(value);

        final ref = FirebaseStorage.instance.ref().child(value['path']);
        String url = await ref.getDownloadURL();
        urls.add(url);
        //print(value);
      });

    });

    //map.putIfAbsent("keys", () => keys);
    //map.putIfAbsent("values", () => values);

    return urls;
  }

  Future getFileUrl(data) async {
    String url = await data.listAll();
    return url;
  }

  Future getRouteRatings(String routeId) async {
    DocumentSnapshot snapshot = await firestore.collection('routes_ratings').document(routeId).get();
    return snapshot;
  }

}
