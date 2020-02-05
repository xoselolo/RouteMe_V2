import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_route_me/model/model_stop.dart';
import 'package:flutter_route_me/model/request_manager/navigation_manager.dart';
import 'package:flutter_route_me/model/request_manager/places_manager.dart';
import 'package:flutter_route_me/widgets/widget_routeme_appbar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as GoogleMapsFlutter;
import 'package:mapbox_gl/mapbox_gl.dart';

class NavigationPage extends StatefulWidget {
  NavigationPage({Key key, this.stops, this.mapMarkers}) : super(key: key);

  // ----------------------------- DATA ELEMENTS --------------------------
  List<Stop> stops;
  Set<GoogleMapsFlutter.Marker> mapMarkers;

  @override
  _NavigationPageState createState() => _NavigationPageState(this.stops, this.mapMarkers);
}


class _NavigationPageState extends State<NavigationPage> {

  // Constructor
  _NavigationPageState(this.stops, this.mapMarkers);

  // ------------------------ DATA ELEMENTS from prev ----------------------
  double initialLatitude;
  double initialLongitude;
  List<Stop> stops;

  // ------------------------ new DATA ELEMENTS ----------------------
  Position initialPosition;
  Position actualPosition;
  StepManeuver step;

  double distanceRemaining, durationRemaining;
  bool arrived;
  int nextStop;
  Stop infoStop;
  bool hasToDisplayInfo = false;
  bool finished = false;

  PlacesManager placesManager;

  // ---------------------------- INDICATIONS ------------------------------
  String indication;
  String metres;
  Icon iconIndicator;

  // -------------------------- MAP ELEMENTS  ------------------------
  List<GoogleMapsFlutter.LatLng> polylinePoints = new List<GoogleMapsFlutter.LatLng>();
  String polylineString;
  GoogleMapsFlutter.BitmapDescriptor pinLocationIcon;
  Set<GoogleMapsFlutter.Marker> mapMarkers = new Set<GoogleMapsFlutter.Marker>();
  Set<GoogleMapsFlutter.Polyline> polylines = new Set<GoogleMapsFlutter.Polyline>();

  GoogleMapsFlutter.GoogleMapController googleMapcontroller;

  StreamSubscription<Position> positionStream;

  // ------------------------- IMPORTANT FUNCTIONS -----------------------
  @override
  void initState() {
    super.initState();

    placesManager = new PlacesManager();

    hasToDisplayInfo = false;
    arrived = false;
    nextStop = 0;
    infoStop = stops.elementAt(nextStop);
    distanceRemaining = 0;
    durationRemaining = 0;

    indication = "";
    metres = "";
    iconIndicator = new Icon(
      Icons.arrow_upward,
      color: Colors.red[400],
    );

    polylines = new Set<GoogleMapsFlutter.Polyline>();
    GoogleMapsFlutter.BitmapDescriptor.fromAssetImage(
        ImageConfiguration(
            devicePixelRatio: 2.5,
            size: Size(2.0, 2.0)
        ),
        'assets/markers/marcador.png')
        .then((onValue) {
          pinLocationIcon = onValue;
        }
    );

    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) async {
          initialPosition = position;
          actualPosition = position;

          googleMapcontroller.animateCamera(GoogleMapsFlutter.CameraUpdate.newCameraPosition(
              GoogleMapsFlutter.CameraPosition(
                  target: GoogleMapsFlutter.LatLng(initialPosition.latitude, initialPosition.longitude),
                  zoom: 18,
                  tilt: 0,
                  bearing: 0
              )
          ));

          step = await NavigationManager.request(stops, initialPosition, nextStop, actualPosition, distanceRemaining);

          indication = step.instruction;
          metres = "For " + step.stepDistance.toString() + " metres";
          if(step.type.compareTo("turn") == 0){
            if(step.modifier.compareTo("left") == 0){
              iconIndicator = new Icon(
                Icons.arrow_back,
                color: Colors.red[400],
              );
            }else{
              iconIndicator = new Icon(
                Icons.arrow_forward,
                color: Colors.red[400],
              );
            }
          }else{
            iconIndicator = new Icon(
              Icons.arrow_upward,
              color: Colors.red[400],
            );
          }

          List<PointLatLng> points = NetworkUtil().decodeEncodedPolyline(step.polyline);
          polylinePoints = new List<GoogleMapsFlutter.LatLng>();
          points.forEach((PointLatLng point){
            polylinePoints.add(new GoogleMapsFlutter.LatLng(point.latitude, point.longitude));
          });

          GoogleMapsFlutter.Polyline polyline = new GoogleMapsFlutter.Polyline(
              polylineId: new GoogleMapsFlutter.PolylineId(step.polyline),
              color: Colors.amber[700],
              points: polylinePoints,
              width: 5
          );

          polylines.add(polyline);

          print("Number of stops" + stops.length.toString());

          var geolocator = Geolocator();
          var locationOptions = LocationOptions(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 40);

          setState(() {

          });

          positionStream = geolocator.getPositionStream(locationOptions).listen(
              (Position position) async {

                actualPosition = position;
                googleMapcontroller.animateCamera(GoogleMapsFlutter.CameraUpdate.newCameraPosition(
                    GoogleMapsFlutter.CameraPosition(
                        target: GoogleMapsFlutter.LatLng(actualPosition.latitude, actualPosition.longitude),
                        zoom: 18,
                        tilt: 0,
                        bearing: 0
                    )
                ));

                step = await NavigationManager.request(stops, initialPosition, nextStop, actualPosition, distanceRemaining);

                if(step.finish){

                  showBottomSheet(context: context, builder: (context) => Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(const Radius.circular(16.0)),
                    ),
                    color: Colors.red[100],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          child: SizedBox(
                            width: 200,
                            height: 200,
                            child: ClipOval(
                              child: FadeInImage.assetNetwork(
                                image: placesManager.PLACE_PHOTO_BASE_URL
                                    + placesManager.PLACE_PHOTO_MAXH
                                    + "2000"
                                    + placesManager.PLACE_PHOTO_MAXW
                                    + "2000"
                                    + placesManager.PLACE_PHOTO_REFERENCE
                                    + stops.elementAt(nextStop).photo
                                    + placesManager.API_KEY
                                ,
                                placeholder: 'assets/markers/marcador.png',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Center(
                          child: Text(stops.elementAt(nextStop).name),
                        )
                      ],
                    ),
                  ));

                  nextStop++;
                  if(nextStop == stops.length){
                    // hem acabat la ruta
                    Navigator.pop(context);
                  }
                }

                indication = step.instruction;
                if(step.type.compareTo("turn") == 0){
                  metres = "";
                  if(step.modifier.compareTo("left") == 0){
                    iconIndicator = new Icon(
                      Icons.arrow_back,
                      color: Colors.red[400],
                    );
                  }else{
                    iconIndicator = new Icon(
                      Icons.arrow_forward,
                      color: Colors.red[400],
                    );
                  }
                }else{
                  metres = "For " + step.stepDistance.toString() + " metres";
                  iconIndicator = new Icon(
                    Icons.arrow_upward,
                    color: Colors.red[400],
                  );
                }

                if(step.routeIsLarger){
                  List<PointLatLng> points = NetworkUtil().decodeEncodedPolyline(step.polyline);
                  polylinePoints = new List<GoogleMapsFlutter.LatLng>();
                  points.forEach((PointLatLng point){
                    polylinePoints.add(new GoogleMapsFlutter.LatLng(point.latitude, point.longitude));
                  });

                  GoogleMapsFlutter.Polyline polyline = new GoogleMapsFlutter.Polyline(
                      polylineId: new GoogleMapsFlutter.PolylineId(step.polyline),
                      color: Colors.amber[700],
                      points: polylinePoints,
                      width: 5
                  );

                  polylines = new Set<GoogleMapsFlutter.Polyline>();
                  polylines.add(polyline);
                }

                setState(() {});
              }
          );

    });
  }

  /*
  _position = new CameraPosition(
    target: LatLng(position.latitude, position.longitude),
    tilt: 0,
    bearing: 00,
    zoom: 20.0
  );


  List<PointLatLng> points = NetworkUtil().decodeEncodedPolyline(polylineString);
    polylinePoints = new List<LatLng>();
    points.forEach((PointLatLng point){
      polylinePoints.add(new LatLng(point.latitude, point.longitude));
    });

    Polyline polyline = new Polyline(
        polylineId: new PolylineId(polylineString),
        color: Colors.amber[700],
        points: polylinePoints,
        width: 5
    );


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
   */

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: RouteMeAppBar(),
      bottomNavigationBar: BottomAppBar(
        color: Colors.red[100],
        shape: CircularNotchedRectangle(),
        child: ListTile(
          leading: CircleAvatar(
            child: Icon(
              Icons.play_circle_filled,
            ),
          ),
          title: Text(
              stops.elementAt(nextStop).name,
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
          ),
          subtitle: Text("Next stop"),
        ),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMapsFlutter.GoogleMap(
            mapToolbarEnabled: true,
            markers: mapMarkers,
            polylines: polylines,
            onMapCreated: (GoogleMapsFlutter.GoogleMapController controller) async {
              googleMapcontroller = controller;
            },
            initialCameraPosition: GoogleMapsFlutter.CameraPosition(
                target: GoogleMapsFlutter.LatLng(stops.elementAt(0).latitude, stops.elementAt(0).longitude),
                tilt: 0,
                bearing: 0,
                zoom: 18.0
            ),
            myLocationEnabled: true,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 8,
                ),
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[300],
                            width: 1.5
                          ),
                          left: BorderSide(
                              color: Colors.grey[300],
                              width: 1.5
                          ),
                      )
                  ),
                  child: ListTile(
                    dense: false,
                    leading: CircleAvatar(
                      child: iconIndicator,
                      backgroundColor: Colors.transparent,
                    ),
                    title: Text(indication),
                    subtitle: Text(metres),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

}
