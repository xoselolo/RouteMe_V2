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
                  gotoCityRoutes(citiesSnapshot.data[index].documentID);
                },
                child: Container(
                  child: Center(
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Stack(
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
                            Positioned.fill(
                              child: Text(
                                citiesSnapshot.data[index].data['name'],
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 30,
                                  letterSpacing: 4,
                                ),
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

  void gotoCityRoutes(String documentID) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => CityRoutesPage(
          cityId: documentID,
        )
    ));
  }

}