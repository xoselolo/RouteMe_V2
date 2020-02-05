import 'dart:async';
import 'package:flutter_route_me/model/model_route.dart' as Routes;
import 'package:flutter_route_me/model/request_manager/routes_manager.dart';
import 'package:flutter_route_me/pages/page_navigate.dart';
import 'package:latlong/latlong.dart' as LL;
import 'package:progress_dialog/progress_dialog.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_route_me/model/model_filter_type.dart';
import 'package:flutter_route_me/model/model_stop.dart';
import 'package:flutter_route_me/model/request_manager/places_manager.dart';
import 'package:flutter_route_me/widgets/widget_routme_appbar_with_save.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:mapbox_gl/mapbox_gl.dart' as MAP;

class OrganizerPage extends StatefulWidget {
  OrganizerPage({Key key, this.initialPosition, this.destinyPosition, this.filters, this.suggestedStops}) : super(key: key);

  final Position initialPosition;
  final Position destinyPosition;
  List<FilterType> filters = new List<FilterType>();
  List<Stop> suggestedStops = new List<Stop>();

  @override
  _OrganizerPageState createState() => _OrganizerPageState(initialPosition, destinyPosition, filters, suggestedStops);
}




class _OrganizerPageState extends State<OrganizerPage> {

  ProgressDialog progressDialog;

  double initialLatitude;
  double initialLongitude;

  // Previous selected filters
  Position initialPosition;
  Position destinyPosition;
  List<FilterType> filters;
  List<Stop> suggestedStops;
  PlacesManager placesManager;

  // Route that we create
  Routes.Route route;
  RouteManager routeManager = new RouteManager();
  List<Stop> stops = new List<Stop>();
  GoogleMapController googleMapcontroller;

  Set<Polyline> polylines = new Set<Polyline>();
  List<LatLng> polylinePoints = new List<LatLng>();
  String polylineString;

  BitmapDescriptor pinLocationIcon;
  Set<Marker> mapMarkers = new Set<Marker>();

  // Constructor
  _OrganizerPageState(this.initialPosition, this.destinyPosition, this.filters, this.suggestedStops);


  @override
  void initState() {
    polylines = new Set<Polyline>();
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(
            devicePixelRatio: 2.5,
            size: Size(2.0, 2.0)
        ),
        'assets/markers/marcador.png')
        .then((onValue) {
            pinLocationIcon = onValue;
        }
    );

    createRoute();
  }

  // Functions
  Future<void> createRoute() async {

    if (placesManager == null){
      placesManager = new PlacesManager();
    }

    stops = new List<Stop>();
    for(int j = 0; j < suggestedStops.length; j++){
      if(suggestedStops.elementAt(j).toVisit){
        print("Sugested to visit: " + suggestedStops.elementAt(j).name);
        stops.add(suggestedStops.elementAt(j));
      }
    }

    for (int i = 0; i < filters.length; i++){
      //progressDialog.update(progress: ((i + 1)/ filters.length) * 100);
      if (filters.elementAt(i).selected){
        print("Filter selected");
        List<Stop> placesOfAType = await placesManager.searchOneTypePlaces(destinyPosition, filters, i);
        // Append the list of places
        int inserted = 0;
        if(placesOfAType != null){
          for (int j = 0; j < placesOfAType.length; j++){
            if(!stops.contains(placesOfAType.elementAt(j))){
              if (inserted < 3){
                Stop stop = placesOfAType.elementAt(j);
                stops.add(stop);
                inserted++;
              }
            }
          }
        }
      }
    }
    // Tenemos todas las Stops creadas


    // Ordenamos las stops por proximidad
    if(stops.length > 1){
      stops.sort((a,b) => (b.userRatingsTotal * b.rating).compareTo(a.userRatingsTotal * a.rating));
    }

    // Miramos si existe punto inicial (localización) y si está a menos de X km de la primera stop
    if(initialPosition == null){
      initialLatitude = stops.elementAt(0).latitude;
      initialLongitude = stops.elementAt(0).longitude;
    }else{
      // Calculamos la distancia
      Stop stop = stops.elementAt(0);
      double distance = new LL.Distance().distance(
          new LL.LatLng(stop.latitude, stop.longitude),
          new LL.LatLng(initialPosition.latitude, initialPosition.longitude)
      ); // en metros

      // Diremos que si la distancia a la que se encuentra el usuario
      // respecto la primera parada de la ruta es mayor a 20 km
      // entonces empezaremos la ruta en la primera parada
      if(distance > 20000){
        initialLatitude = stops.elementAt(0).latitude;
        initialLongitude = stops.elementAt(0).longitude;
      }else{
        // sino, se encuentra sufucuentemente cerca, con lo que empezara desde su ubicacion
        initialLatitude = initialPosition.latitude;
        initialLongitude = initialPosition.longitude;
      }
    }

    // Ahora montamos la ruta
    mountRoute();
  }

  Future<void> mountRoute() async {
    routeManager = new RouteManager();

    route = await routeManager.makeAndGetRoutePolyline(initialLatitude, initialLongitude, stops);
    polylineString = route.routes[0]['overview_polyline']['points'];

    // json['routes'][0] == null ? null : json['routes'][0]['overview_polyline']['points'];
    //polylineString = await routeManager.makeAndGetRoutePolyline(initialLatitude, initialLongitude, stops);

    List<Stop> orderedStops = new List<Stop>();
    for(int i = 0; i < route.order.length; i++){
      orderedStops.add(stops.elementAt(route.order.elementAt(i)));
    }
    orderedStops.add(stops.elementAt(stops.length - 1));

    //stops.clear();
    stops = orderedStops;

    List<PointLatLng> points = NetworkUtil().decodeEncodedPolyline(polylineString);
    polylinePoints = new List<LatLng>();
    points.forEach((PointLatLng point){
      polylinePoints.add(new LatLng(point.latitude, point.longitude));
    });

    Polyline polyline = new Polyline(
        polylineId: new PolylineId(polylineString),
        color: Colors.amber,
        points: polylinePoints,
        width: 5
    );

    mapMarkers = new Set<Marker>();
    stops.forEach((Stop stop){
      mapMarkers.add(
          new Marker(
              markerId: new MarkerId(stop.name),
              position: new LatLng(stop.latitude, stop.longitude),
              infoWindow: InfoWindow(
                  title: stop.name
              ),
              icon: pinLocationIcon
          )
      );
    });

    googleMapcontroller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(initialLatitude, initialLongitude),
        zoom: 13,
        tilt: 0,
        bearing: 0
      )
    ));

    setState(() {
      polylines = new Set<Polyline>();
      polylines.add(polyline);
    });
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.amber,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: (){
            print("Add new stop");
            // todo
          },

        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.red[400],
          shape: CircularNotchedRectangle(),
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  width: 140,
                  height: 50,
                  child: Center(
                    child: RaisedButton(
                      color: Colors.amber[400],
                      onPressed: (){
                        print("Navigate!");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NavigationPage(
                              initialLatitude: initialLatitude,
                              initialLongitude: initialLongitude,
                              polylineString: polylineString,
                              stops: stops,
                              position:  new MAP.CameraPosition(
                                  target: MAP.LatLng(stops.elementAt(0).latitude, stops.elementAt(0).longitude),
                                  tilt: 0,
                                  bearing: 00,
                                  zoom: 18.0
                              ),
                            )
                          )
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18.0),
                        //side: BorderSide(color: Colors.amber, width: 4)
                      ),
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                            'assets/images/solo_logo_v1.png',
                            width: 23,
                            height: 23,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            "Start!",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 23
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        resizeToAvoidBottomPadding: false,
      appBar: RouteMeAppBarWithSave(),
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 4,
            child: GoogleMap(
              mapToolbarEnabled: true,
              markers: mapMarkers,
              polylines: polylines,
              onMapCreated: (GoogleMapController controller) async {
                googleMapcontroller = controller;
              },
              initialCameraPosition: CameraPosition(
                  target: LatLng(destinyPosition.latitude, destinyPosition.longitude),
                  tilt: 0,
                  bearing: 0,
                  zoom: 18.0
              ),
              myLocationEnabled: true,
            ),
          ),
          Flexible(
            flex: 6,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: stops.length,
              itemBuilder: (BuildContext context, int index){
                return Container(
                  child: ListTile(
                    leading: SizedBox(
                      width: 60,
                      height: 60,
                      child: ClipOval(
                        child: FadeInImage.assetNetwork(
                          image: placesManager.PLACE_PHOTO_BASE_URL
                              + placesManager.PLACE_PHOTO_MAXH
                              + "2000"
                              + placesManager.PLACE_PHOTO_MAXW
                              + "2000"
                              + placesManager.PLACE_PHOTO_REFERENCE
                              + stops.elementAt(index).photo
                              + placesManager.API_KEY
                          ,
                          placeholder: 'assets/markers/marcador.png',
                        ),
                      ),
                    ),
                    title: Text(
                      stops.elementAt(index).name,
                      style: TextStyle(
                          color: Colors.black
                      ),
                    ),
                    subtitle: Row(
                      children: <Widget>[
                        Icon(
                          Icons.star,
                          size: 22,
                          color: Colors.grey,
                        ),
                        Text(
                            stops.elementAt(index).rating.toString()
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        Container(
                          width: 50,
                          padding: const EdgeInsets.symmetric(
                            vertical: 1.5,
                            //horizontal: 4.5
                          ),
                          //color: stop.openNow ? Colors.green : Colors.white30,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(const Radius.circular(32.0)),
                              color: stops.elementAt(index).openNow ? Colors.green[200] : Colors.red[100]
                          ),
                          child: Center(
                            child: Text(
                              stops.elementAt(index).openNow ? "OPEN" : "CLOSED",
                              style: TextStyle(
                                  fontSize: 9.5
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.cancel,
                      ),
                      onPressed: (){
                        print("Remove element");
                        stops.removeAt(index);
                        mapMarkers.remove(mapMarkers.elementAt(index));
                        mountRoute();
                      },
                    ),
                    onLongPress: (){
                      print("Move");
                    },
                    dense: false,
                  ),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                            color: Colors.red[300],
                          )
                      )
                  ),
                );
              },
            ),
          )
        ],
      )
    );
  }

}
