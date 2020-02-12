import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RoutesPage extends StatefulWidget {
  RoutesPage({Key key}) : super(key: key);

  @override
  _RoutesPageState createState() => _RoutesPageState();
}


class _RoutesPageState extends State<RoutesPage> {

  // ------------------------- IMPORTANT FUNCTIONS -----------------------
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: getRoutes(),
      builder: (_, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(
            child: Text("Loading ..."),
          );
        }else{
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (_, index){
              return ListTile(
                title: FutureBuilder(
                  future: getCompanyName(snapshot.data[index].data['company']),
                  builder: (_, companyNameSnapshot){
                    if(companyNameSnapshot.connectionState == ConnectionState.waiting){
                      return Text("Loading ...");
                    }else{
                      //print(companyNameSnapshot.data['name']);
                      //return Text(snapshot.data['name']);
                      return Text(companyNameSnapshot.data["name"]);
                    }
                  },
                ),
                subtitle: Text(snapshot.data[index].data['distance'].toString()),
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

  @override
  void dispose() {
    super.dispose();
  }


  Future getRoutes() async {
    var firestore = Firestore.instance;
    
    QuerySnapshot snapshot = await firestore.collection('companies_routes').getDocuments();

    return snapshot.documents;
  }

  Future getCompanyName(String companyId) async {
    var firestore = Firestore.instance;

    print("Hola");
    
    DocumentSnapshot snapshot = await firestore.collection('trip_companies').document(companyId).get();

    return snapshot;
  }

}