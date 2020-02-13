import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_route_me/pages/page_filters.dart';
import 'package:flutter_route_me/pages/page_cities.dart';
import 'package:flutter_route_me/widgets/widget_routeme_appbar.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}


class _MainPageState extends State<MainPage> {

  int currentIndex;
  PageController _pageController;

  RouteMeAppBar appbar;


  @override
  void initState() {

    currentIndex = 0;

    _pageController = new PageController(
      initialPage: currentIndex,
      keepPage: true
    );

    appbar = new RouteMeAppBar(
      pageIndex: currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: appbar,
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
        currentIndex: currentIndex,
        selectedItemColor: Colors.red[700],
        onTap: _onBottomItemTap,
      ),
      body: PageView(
        scrollDirection: Axis.horizontal,
        reverse: false,
        controller: _pageController,
        physics: BouncingScrollPhysics(),
        pageSnapping: true,
        onPageChanged: _onPageChanged,
        children: <Widget>[
          //RoutesPage(),
          CitiesPage(),
          FiltersPage(),
          Container(color: Colors.pink,)
        ],
      ),
    );
  }


  void _onBottomItemTap(int value) {
    // TODO
    currentIndex = value;
    _pageController.jumpToPage(currentIndex);

    setState(() {
      appbar = RouteMeAppBar(
        pageIndex: currentIndex,
      );
    });
  }

  void _onPageChanged(int value) {
    // TODO
    currentIndex = value;

    setState(() {
      appbar = RouteMeAppBar(
        pageIndex: currentIndex,
      );
    });
  }
}
