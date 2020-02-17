import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_route_me/pages/page_filters.dart';
import 'package:flutter_route_me/pages/page_main.dart';
import 'package:flutter_route_me/pages/page_signup.dart';
import 'package:flutter_route_me/widgets/widget_routeme_appbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}


class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  String _email;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Forgot Password",
            style: GoogleFonts.poppins(
              letterSpacing: 2
            ),
          ),
          backgroundColor: Colors.red[400],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const FractionalOffset(0.5, 0.0),
              end: const FractionalOffset(0.0, 0.5), //
              stops: [0.5, 1.0], // 10% of the width, so there are ten blinds.
              colors: [Colors.red[300], Colors.redAccent[200]],
              //colors: [Colors.red[300], Colors.orange[200]],
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20
                  ),
                  child: Text(
                    "If you have forgot your password, please write your email below and we will send you a password reset link",
                    style: GoogleFonts.poppins(
                        color: Colors.white
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: TextFormField(
                    validator: (input) {
                      if(input.isEmpty){
                        return 'Please type an email';
                      }
                    },
                    onChanged: (input){
                      _email = input;
                    },
                    onSaved: (input) {
                      _email = input;
                    },
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                            color: Colors.white
                        ),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white
                            )
                        ),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white
                            )
                        ),
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white
                            )
                        )
                    ),
                    cursorColor: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 8,
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
                      onPressed: () {
                        sendPasswordEmail();
                      },
                      child: Text("Send password")
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }

  Future<void> sendPasswordEmail() async {
    FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
    Navigator.pop(context);
    Fluttertoast.showToast(
      msg: "Password reset email has been sent!",
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.black38,
      textColor: Colors.white
    );
  }
}