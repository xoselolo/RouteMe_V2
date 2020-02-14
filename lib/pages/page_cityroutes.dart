import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_route_me/widgets/widget_routeme_appbar.dart';
import 'package:google_fonts/google_fonts.dart';

class CityRoutesPage extends StatefulWidget {

  @required
  final String cityId;

  const CityRoutesPage({Key key, this.cityId}) : super(key: key);

  @override
  _CityRoutesPageState createState() => _CityRoutesPageState(this.cityId);
}


class _CityRoutesPageState extends State<CityRoutesPage> {

  final String cityId;
  var firestore;

  _CityRoutesPageState(this.cityId);


  @override
  void initState() {
    super.initState();
    firestore = Firestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RouteMeAppBar(
          pageIndex: -1
      ),
      body: FutureBuilder(
        future: getCityRoutes(cityId),
        builder: (_, cityRoutesSnapshot){
          if(cityRoutesSnapshot.connectionState == ConnectionState.waiting){
            return CircularProgressIndicator();
            /*
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/images/cities/default.jpg'),
            );
             */
          }else{

            //print(cityRoutesSnapshot.data.toString());
            return ListView.builder(
                itemCount: cityRoutesSnapshot.data.length,
                itemBuilder: (_, index){
                  int rndm = Random.secure().nextInt(255);
                  int maxLines = 2;
                  return ExpansionTile(
                    title: Text(
                        cityRoutesSnapshot.data[index].data['title'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Chip(
                          label: cityRoutesSnapshot.data[index].data['offer_id'] == "FREE" ?
                          Text(
                            "FREE",
                            style: TextStyle(
                              fontSize: 10
                            ),
                          ) : cityRoutesSnapshot.data[index].data['offer_id'] == "BASE" ?
                          Text(
                            cityRoutesSnapshot.data[index].data['price'].toString() + " €",
                            style: TextStyle(
                                fontSize: 10
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
                                double totalPrice = cityRoutesSnapshot.data[index].data['price'] - (cityRoutesSnapshot.data[index].data['price'] * offerSnapshot.data['discount_percentage'] / 100);
                                return Text(
                                  totalPrice.toString() + " €",
                                  style: TextStyle(
                                      fontSize: 10
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 4),

                      ],
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

}
