import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_route_me/pages/page_filters.dart';
import 'package:flutter_route_me/pages/page_main.dart';
import 'package:flutter_route_me/widgets/widget_routeme_appbar.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}


class _SignUpPageState extends State<SignUpPage> {
  String _email, _password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RouteMeAppBar(
        pageIndex: -1
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              validator: (input){
                if(input.isEmpty){
                  return 'Please type an email';
                }
              },
              onSaved: (input){
                _email = input;
              },
              decoration: InputDecoration(
                  labelText: 'Email'
              ),
            ),
            TextFormField(
              validator: (input){
                if(input.length < 6){
                  return 'Your password needs to be at least 6 characters';
                }
              },
              onSaved: (input){
                _password = input;
              },
              decoration: InputDecoration(
                  labelText: 'Password'
              ),
              obscureText: true,
            ),
            RaisedButton(
              onPressed: signUp,
              child: Text('Sign up'),
            )
          ],
        ),
      ),
    );
  }


  Future<void> signUp() async{
    final formState = _formKey.currentState;
    if(formState.validate()){
      formState.save();
      try{
        AuthResult authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password);
        authResult.user.sendEmailVerification();

        final ref = FirebaseStorage.instance.ref().child('users/default.png');
        String url = await ref.getDownloadURL();
        UserUpdateInfo newInfoUpdate = UserUpdateInfo();
        newInfoUpdate.photoUrl = url;
        authResult.user.updateProfile(newInfoUpdate);

        Fluttertoast.showToast(msg: "Please verify your email");

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage()));
      }catch(e){
        print("Firebase auth error!");
        print(e.message);
      }
    }

  }
}
