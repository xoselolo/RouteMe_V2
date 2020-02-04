import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RouteMeAppBarWithSave extends StatefulWidget implements PreferredSizeWidget {
  RouteMeAppBarWithSave({Key key}) : preferredSize = Size.fromHeight(kToolbarHeight), super(key: key);

  @override
  final Size preferredSize; // default is 56.0

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<RouteMeAppBarWithSave>{

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("Route Me"),
      leading: Padding(
        padding: EdgeInsets.only(left: 16, top: 8, right: 8, bottom: 8),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          iconSize: 20,
          onPressed: (){
            Navigator.pop(context);
          },
        )
      ),
      actions: <Widget>[
        IconButton(
          icon: new Icon(Icons.help),
          onPressed: (){
            showHelp();
          },
        ),
        IconButton(
          icon: new Icon(Icons.save),
          onPressed: (){
            saveRoute();
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

  void saveRoute() {
    print("Save route");
  }
}