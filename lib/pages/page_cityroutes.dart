import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
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

            print(cityRoutesSnapshot.data.toString());
            return ListView.builder(
                itemCount: cityRoutesSnapshot.data.length,
                itemBuilder: (_, index){
                  int rndm = Random.secure().nextInt(255);
                  return ExpansionTile(
                    title: Text(
                        cityRoutesSnapshot.data[index].data['title'],
                      style: GoogleFonts.poppins(),
                    ),

                  );
                }
            );
            /*
            Container(
              height: 150,
              color: Color.fromARGB(rndm, rndm, rndm, rndm),
            );

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(cityImageSnapshot.data),
            );
             */
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

}
