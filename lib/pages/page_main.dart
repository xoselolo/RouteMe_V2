import 'package:flutter/material.dart';
import 'package:flutter_route_me/widgets/widget_routeme_appbar.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}


class _MainPageState extends State<MainPage> {

  int _currentIndex;


  @override
  void initState() {
    _currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: RouteMeAppBar(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_a_photo),
            title: Text('Discover'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.map),
              title: Text('Route')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Profile')
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.amber[700],
        onTap: _onBottomItemTap,
      ),
      body: Container(),
    );
  }


  void _onBottomItemTap(int value) {
    // TODO
    setState(() {
      _currentIndex = value;
    });
  }
}
