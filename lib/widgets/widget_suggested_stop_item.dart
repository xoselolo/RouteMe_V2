import 'package:flutter/material.dart';
import 'package:flutter_route_me/model/model_stop.dart';

class SuggestedStopItem extends StatelessWidget{
  final Stop stop;

  SuggestedStopItem(this.stop);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: stop.toVisit ? Colors.red[200] : Colors.grey,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Image.network(
              stop.icon,
              scale: 1,
              color: Colors.black,
            ),
            Text(
              stop.name,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );

  }
}