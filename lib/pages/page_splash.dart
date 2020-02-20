import 'dart:ui';

import 'package:animator/animator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_route_me/pages/page_filters.dart';
import 'package:flutter_route_me/pages/page_main.dart';
import 'package:flutter_route_me/pages/page_signup.dart';
import 'package:flutter_route_me/widgets/widget_routeme_appbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}


class _SplashPageState extends State<SplashPage> {
  bool haveToken;
  bool lookToken;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    haveToken = false;
    lookToken = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Animator<double>(
          curve: Curves.easeOutCirc,
          tween: Tween<double>(begin: 100, end: 300),
          duration: Duration(seconds: 1),
          cycles: 0,
          builder: (anim) => Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              height: anim.value,
              width: anim.value,
              child: Image.asset(
                'assets/images/solo_logo_v1.png',
                width: 20,
                height: 20,
                color: Colors.red,
              ),
            ),
          ),
          endAnimationListener: (param){
          },
        ),
      ),
    );
  }

}