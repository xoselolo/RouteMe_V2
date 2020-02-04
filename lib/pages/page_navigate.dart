import 'package:flutter/material.dart';
import 'package:flutter_route_me/model/model_stop.dart';
import 'package:flutter_route_me/widgets/widget_routeme_appbar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class NavigationPage extends StatefulWidget {
  NavigationPage({Key key, this.initialLatitude, this.initialLongitude,
    this.polylinePoints, this.polylineString,
    this.pinLocationIcon, this.stops, this.position}) : super(key: key);

  // ----------------------------- DATA ELEMENTS --------------------------
  double initialLatitude;
  double initialLongitude;

  List<Stop> stops;

  List<LatLng> polylinePoints = new List<LatLng>();
  String polylineString;

  BitmapDescriptor pinLocationIcon;

  CameraPosition position;

  @override
  _NavigationPageState createState() => _NavigationPageState(this.initialLatitude,
      this.initialLongitude, this.polylinePoints,
      this.polylineString, this.pinLocationIcon, this.stops, this.position);
}


class _NavigationPageState extends State<NavigationPage> {

  // Constructor
  _NavigationPageState(this.initialLatitude, this.initialLongitude,
      this.polylinePoints, this.polylineString,
      this.pinLocationIcon, this.stops, this._position);

  // ------------------------ DATA ELEMENTS from prev ----------------------
  double initialLatitude;
  double initialLongitude;

  List<Stop> stops;

  List<LatLng> polylinePoints = new List<LatLng>();
  String polylineString;

  BitmapDescriptor pinLocationIcon;

  // ------------------------ new DATA ELEMENTS ----------------------
  double distanceRemaining, durationRemaining;
  bool arrived;
  int nextStop;

  // Displayable information
  Stop infoStop;
  String description = "";
  Scaffold infoScaffold;
  Scaffold noInfoScaffold;
  bool hasToDisplayInfo = false;
  bool finished = false;

  // ------------------------- IMPORTANT FUNCTIONS -----------------------
  @override
  void initState() {
    super.initState();

    /*
    _position = new CameraPosition(
        target: LatLng(41.4163469, 2.1768663),
        tilt: 0,
        bearing: 00,
        zoom: 18.0
    );

     */

    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) async {
          _position = new CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              tilt: 0,
              bearing: 00,
              zoom: 18.0
          );
    });

     

    hasToDisplayInfo = false;

    arrived = false;
    nextStop = 0;

    infoStop = stops.elementAt(nextStop);

    /*infoScaffold = new Scaffold(
        appBar: RouteMeAppBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButton: RaisedButton(
          color: Colors.amber[400],
          onPressed: (){
            print("Next stop!");
            nextStop++;
            infoStop = stops.elementAt(nextStop);
          },
          shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(18.0),
            //side: BorderSide(color: Colors.amber, width: 4)
          ),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                child: Icon(
                  Icons.play_arrow,
                  size: 23,
                ),
                backgroundColor: Colors.amber[400],
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                "Next Stop!",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold
                ),
              )
            ],
          ),
        ),
        body: Container(
          color: Colors.red[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.amber[200],
                  border: Border.all(
                    color: Colors.amber[500],
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                      infoStop.name
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(description),
              )
            ],
          ),
        )
    );
    noInfoScaffold = new Scaffold(
      appBar: RouteMeAppBar(),
      body: Container(),
    );*/
  }

  /*Future<void> onRouteProgress(bool arrived) async {
    double distanceRemaining = await mapboxNavigation.distanceRemaining;
    if(arrived || distanceRemaining < 250){

      print("Arriving!");

      hasToDisplayInfo = true;
      await mapboxNavigation.finishNavigation(); // (provisional)
      setState(() {});

      if(nextStop == stops.length - 1){
        print("Finished");
        finished = true;
      }
    }else{
      print("Not arriving");
    }
  }*/

  MapboxMap mapboxMap;

  MapboxMapController mapController;
  CameraPosition _position;
  bool _isMoving = false;
  bool _compassEnabled = true;
  CameraTargetBounds _cameraTargetBounds = CameraTargetBounds.unbounded;
  MinMaxZoomPreference _minMaxZoomPreference = MinMaxZoomPreference.unbounded;
  String _styleString = MapboxStyles.LIGHT;
  bool _rotateGesturesEnabled = true;
  bool _scrollGesturesEnabled = true;
  bool _tiltGesturesEnabled = true;
  bool _zoomGesturesEnabled = true;
  bool _myLocationEnabled = true;
  bool _telemetryEnabled = true;
  MyLocationTrackingMode _myLocationTrackingMode = MyLocationTrackingMode.Tracking;

  void _onMapChanged() {
    setState(() {
      _extractMapInfo();
    });
  }

  void _extractMapInfo() {
    _position = mapController.cameraPosition;
    _isMoving = mapController.isCameraMoving;
  }

  @override
  void dispose() {
    mapController.removeListener(_onMapChanged);
    super.dispose();
  }

  Widget _myLocationTrackingModeCycler() {
    final MyLocationTrackingMode nextType =
    MyLocationTrackingMode.values[(_myLocationTrackingMode.index + 1) % MyLocationTrackingMode.values.length];
    return FlatButton(
      child: Text('change to $nextType'),
      onPressed: () {
        setState(() {
          _myLocationTrackingMode = nextType;
        });
      },
    );
  }

  Widget _compassToggler() {
    return FlatButton(
      child: Text('${_compassEnabled ? 'disable' : 'enable'} compasss'),
      onPressed: () {
        setState(() {
          _compassEnabled = !_compassEnabled;
        });
      },
    );
  }

  Widget _zoomBoundsToggler() {
    return FlatButton(
      child: Text(_minMaxZoomPreference.minZoom == null
          ? 'bound zoom'
          : 'release zoom'),
      onPressed: () {
        setState(() {
          _minMaxZoomPreference = _minMaxZoomPreference.minZoom == null
              ? const MinMaxZoomPreference(12.0, 16.0)
              : MinMaxZoomPreference.unbounded;
        });
      },
    );
  }

  Widget _setStyleToSatellite() {
    return FlatButton(
      child: Text('change map style to Satellite'),
      onPressed: () {
        setState(() {
          _styleString = MapboxStyles.SATELLITE;
        });
      },
    );
  }

  Widget _rotateToggler() {
    return FlatButton(
      child: Text('${_rotateGesturesEnabled ? 'disable' : 'enable'} rotate'),
      onPressed: () {
        setState(() {
          _rotateGesturesEnabled = !_rotateGesturesEnabled;
        });
      },
    );
  }

  Widget _scrollToggler() {
    return FlatButton(
      child: Text('${_scrollGesturesEnabled ? 'disable' : 'enable'} scroll'),
      onPressed: () {
        setState(() {
          _scrollGesturesEnabled = !_scrollGesturesEnabled;
        });
      },
    );
  }

  Widget _tiltToggler() {
    return FlatButton(
      child: Text('${_tiltGesturesEnabled ? 'disable' : 'enable'} tilt'),
      onPressed: () {
        setState(() {
          _tiltGesturesEnabled = !_tiltGesturesEnabled;
        });
      },
    );
  }

  Widget _zoomToggler() {
    return FlatButton(
      child: Text('${_zoomGesturesEnabled ? 'disable' : 'enable'} zoom'),
      onPressed: () {
        setState(() {
          _zoomGesturesEnabled = !_zoomGesturesEnabled;
        });
      },
    );
  }

  Widget _myLocationToggler() {
    return FlatButton(
      child: Text('${_myLocationEnabled ? 'disable' : 'enable'} my location'),
      onPressed: () {
        setState(() {
          _myLocationEnabled = !_myLocationEnabled;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    mapboxMap = MapboxMap(
        onMapCreated: onMapCreated,
        initialCameraPosition: _position,
        trackCameraPosition: true,
        compassEnabled: false,
        cameraTargetBounds: _cameraTargetBounds,
        minMaxZoomPreference: _minMaxZoomPreference,
        styleString: _styleString,
        rotateGesturesEnabled: true, // true
        scrollGesturesEnabled: true, // true
        tiltGesturesEnabled: true, // true
        zoomGesturesEnabled: true, // true
        myLocationEnabled: true, // true
        myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
        onMapClick: (point, latLng) {
          print(point.toString());
        },
        /*onCameraTrackingDismissed: () {
          this.setState(() {
            _myLocationTrackingMode = MyLocationTrackingMode.None;
          });
        }*/
    );

    return Scaffold(
      appBar: RouteMeAppBar(),
      bottomNavigationBar: BottomAppBar(
        color: Colors.red[200],
        shape: CircularNotchedRectangle(),
        child: ListTile(
          title: Text(stops.elementAt(nextStop).name),
        ),
      ),
      body: mapboxMap,
    );
  }

  void onMapCreated(MapboxMapController controller) {
    mapController = controller;
    mapController.addListener(_onMapChanged);
    _extractMapInfo();
  }

}
