import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_route_me/pages/page_filters.dart';
import 'package:flutter_route_me/widgets/widget_routeme_appbar.dart';

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
      appBar: RouteMeAppBar(),
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
        // TODO: Display for the user that we sent an email
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FiltersPage()));
      }catch(e){
        print("Firebase auth error!");
        print(e.message);
      }
    }

  }
}
