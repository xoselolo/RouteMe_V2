import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class RouteMeAppBar extends StatefulWidget implements PreferredSizeWidget {
  RouteMeAppBar({Key key, this.pageIndex}) : preferredSize = Size.fromHeight(kToolbarHeight), super(key: key);

  @override
  final Size preferredSize; // default is 56.0
  final int pageIndex;

  @override
  _CustomAppBarState createState() => _CustomAppBarState(this.pageIndex);
}

class _CustomAppBarState extends State<RouteMeAppBar>{

  int pageIndex;

  _CustomAppBarState(this.pageIndex);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        "RouteMe",
        style: GoogleFonts.poppins(
          letterSpacing: 2
        ),
      ),
      leading: Padding(
        padding: EdgeInsets.only(left: 16, top: 8, right: 8, bottom: 8),
        child: Image.asset(
          'assets/images/solo_logo_v1.png',
          width: 20,
          height: 20,
          color: Colors.white,
        )
      ),
      actions: <Widget>[
        IconButton(
          icon: new Icon(Icons.help),
          onPressed: (){
            showHelp();
          },
        ),
        Visibility(
          visible: pageIndex == 2,
          //visible: true,
          child: IconButton(
            icon: new Icon(Icons.edit),
            onPressed: (){
              showEdit();
            },
          ),
        )
      ],
      centerTitle: true,
      backgroundColor: Colors.red[400],
    );
  }

  void showHelp(){
    print("Help");
  }

  void showEdit() {
    print("Edit");
  }

  Future getUserName() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return user.displayName;
  }
}