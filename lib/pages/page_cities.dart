import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
    random = Random.secure().nextInt(1000) % 3 + 1;
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
                  print("ToDo: Show CityRoutesPage");
                },
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: <Widget>[
                      FutureBuilder(
                        future: getCityImage(citiesSnapshot.data[index].documentID),
                        builder: (_, cityImageSnapshot){
                          if(cityImageSnapshot.connectionState == ConnectionState.waiting || cityImageSnapshot.data == null){
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(30),
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(citiesSnapshot.data[index].data['name']),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
          );
        }
      },
    );

    /*
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('companies_routes').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError)
            return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return new Text('Loading...');
            default:
              return new ListView(
                children: snapshot.data.documents.map((DocumentSnapshot document) {
                  String companyName = "Company name";
                  Firestore.instance
                      .collection('trip_companies')
                      .document(document['company'])
                      .get()
                      .then((DocumentSnapshot ds) {
                        print(ds.data['name']);
                    companyName = ds['name'];
                    // use ds as a snapshot
                  });
                  return new ListTile(
                    title: new Text(companyName),
                    subtitle: new Text(document['distance'].toString()),
                  );
                }).toList(),
              );
          }
        }
    );
     */
  }


  Future getRoutes() async {
    QuerySnapshot snapshot = await firestore.collection('companies_routes').getDocuments();
    return snapshot.documents;
  }

  Future getCompanyName(String companyId) async {
    DocumentSnapshot snapshot = await firestore.collection('trip_companies').document(companyId).get();
    return snapshot;
  }

  Future getCities() async {
    QuerySnapshot snapshot = await firestore.collection('cities').getDocuments();
    return snapshot.documents;
  }

  Future getCityImage(String cityId) async {
    final ref = FirebaseStorage.instance.ref().child('cities/' + cityId + "/picture_" + random.toString() + ".jpg");
    String url = await ref.getDownloadURL();
    return url;
  }

}