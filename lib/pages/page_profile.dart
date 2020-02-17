import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {

  var firestore;
  FirebaseUser user;

  // ------------------------- IMPORTANT FUNCTIONS -----------------------
  @override
  Future<void> initState() {
    super.initState();

    firestore = Firestore.instance;
    getUserAndHisInfo();
  }

  @override
  Widget build(BuildContext context) {
    return user == null ?
    CircularProgressIndicator() :
    Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 15,
        ),
        GestureDetector(
          onTap: (){
            // todo: take foto or select in the gallery
            // todo: upload to the storage and update the photo url of the user
            print("Todo: change profile photo");
          },
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(
                        user.photoUrl
                    )
                )
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),

      ],
    );
  }

  void getUserAndHisInfo() async {
    user = await FirebaseAuth.instance.currentUser();
    String photoUrl = user.photoUrl;
    if(photoUrl == null){
      print("User doesn't have a profile photo");
    }else{
      print("User has a profile photo");
    }
    setState(() {});
  }

}