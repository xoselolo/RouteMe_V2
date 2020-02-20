import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_route_me/pages/page_filters.dart';
import 'package:flutter_route_me/pages/page_cities.dart';
import 'package:flutter_route_me/pages/page_profile.dart';
import 'package:flutter_route_me/widgets/widget_routeme_appbar.dart';

class MainPage extends StatefulWidget {
  MainPage(FirebaseUser this.user);

  final FirebaseUser user;

  @override
  _MainPageState createState() => _MainPageState(this.user);
}


class _MainPageState extends State<MainPage> {

  int currentIndex;
  PageController _pageController;

  RouteMeAppBar appbar;

  final FirebaseUser user;

  _MainPageState(FirebaseUser this.user);


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
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: ListView(
                children: <Widget>[
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: user == null || user.photoUrl == null ?
                            AssetImage(
                                'assets/images/user_default_image.png'
                            ) :
                            NetworkImage(
                                user.photoUrl
                            )
                        )
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Center(
                    child: Text(
                      user.displayName
                    ),
                  )
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.red[200],
                borderRadius: BorderRadius.circular(10)
              ),
            )
          ],
        ),
      ),
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
          ProfilePage()
        ],
      ),
    );
  }


  void _onBottomItemTap(int value) {
    currentIndex = value;
    _pageController.jumpToPage(currentIndex);

    setState(() {
      appbar = RouteMeAppBar(
        pageIndex: currentIndex,
      );
    });
  }

  void _onPageChanged(int value) {
    currentIndex = value;

    setState(() {
      appbar = RouteMeAppBar(
        pageIndex: currentIndex,
      );
    });
  }
}
