import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'page_cityroutes.dart';

class CitiesPage extends StatefulWidget {
  CitiesPage({Key key}) : super(key: key);

  @override
  _CitiesPageState createState() => _CitiesPageState();
}


class _CitiesPageState extends State<CitiesPage> {

  var firestore;
  int random;

  // ------------------------- IMPORTANT FUNCTIONS -----------------------
  @override
  void initState() {
    super.initState();

    firestore = Firestore.instance;
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: getCities(),
      builder: (_, citiesSnapshot){
        if(citiesSnapshot.connectionState == ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator(),
          );
        }else{
          return ListView.builder(
            itemCount: citiesSnapshot.data.length,
            itemBuilder: (_, index){
              return GestureDetector(
                onTap: (){
                  gotoCityRoutes(citiesSnapshot.data[index].documentID, citiesSnapshot.data[index].data['name']);
                },
                child: Container(
                  //height: 150,
                  child: Center(
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            FutureBuilder(
                              future: getCityImage(citiesSnapshot.data[index].documentID),
                              builder: (_, cityImageSnapshot){
                                if(cityImageSnapshot.connectionState == ConnectionState.waiting || cityImageSnapshot.hasError || cityImageSnapshot.data == null){
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset('assets/images/cities/default.jpg'),
                                  );
                                }else{
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(cityImageSnapshot.data),
                                  );
                                }
                              },
                            ),
                            Opacity(
                              opacity: 0.60,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[500],
                                  borderRadius: BorderRadius.circular(30)
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 20
                                  ),
                                  child:  Text(
                                    citiesSnapshot.data[index].data['name'],
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 30,
                                      letterSpacing: 4,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                )
                            ),
                            )
                          ],
                        ),
                      )
                    ),
                  )
                )
              );
            }
          );
        }
      },
    );
  }


  /*

  Future getRoutes() async {
    QuerySnapshot snapshot = await firestore.collection('companies_routes').getDocuments();
    return snapshot.documents;
  }
  Future getCompanyName(String companyId) async {
    DocumentSnapshot snapshot = await firestore.collection('trip_companies').document(companyId).get();
    return snapshot;
  }

   */




  Future getCities() async {
    QuerySnapshot snapshot = await firestore.collection('cities').getDocuments();
    return snapshot.documents;
  }

  Future getCityImage(String cityId) async {
    random = Random.secure().nextInt(1000) % 3 + 1;
    final ref = FirebaseStorage.instance.ref().child('cities/' + cityId + "/picture_" + random.toString() + ".jpg");
    String url = await ref.getDownloadURL();
    print(url);
    return url;
  }

  void gotoCityRoutes(String documentID, String cityName) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => CityRoutesPage(
          cityId: documentID,
          cityName: cityName,
        )
    ));
  }

}