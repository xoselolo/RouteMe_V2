import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_route_me/pages/page_welcome.dart';

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
          height: 20,
        ),
        GestureDetector(
          onTap: (){
            // todo: take foto or select in the gallery
            // todo: upload to the storage and update the photo url of the user
            print("Todo: change profile photo");
          },
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: user.photoUrl == null ?
                    AssetImage(
                        'assets/images/user_default_image.png'
                    ) :
                    NetworkImage(
                        user.photoUrl
                    )
                )
            ),
          ),
        ),

        SizedBox(
          height: 8,
        ),

        Text(
          user.displayName
        ),

        SizedBox(
          height: 4,
        ),

        Text(
            user.email
        ),

        SizedBox(
          height: 20,
        ),

        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 50,
              vertical: 2
          ),
          child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              elevation: 3,
              color: Colors.white,
              onPressed: (){
                FirebaseAuth.instance.signOut().then((value){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomePage()));
                }).catchError((e){
                  print(e);
                });
              },
              child: Text("Sign out")
          ),
        )

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