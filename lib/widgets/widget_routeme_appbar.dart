import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RouteMeAppBar extends StatefulWidget implements PreferredSizeWidget {
  RouteMeAppBar({Key key}) : preferredSize = Size.fromHeight(kToolbarHeight), super(key: key);

  @override
  final Size preferredSize; // default is 56.0

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<RouteMeAppBar>{

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("Route Me"),
      leading: Padding(
        padding: EdgeInsets.only(left: 16, top: 8, right: 8, bottom: 8),
        child: Image.asset(
          'assets/images/solo_logo_v1.png',
          width: 20,
          height: 20,
          color: Colors.white,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: new Icon(Icons.help),
          onPressed: (){
            showHelp();
          },
        )
      ],
      centerTitle: true,
      backgroundColor: Colors.red[400],
    );
  }

  void showHelp(){
    print("Help");
  }
}