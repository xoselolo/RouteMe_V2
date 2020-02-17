import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_route_me/model/model_filter_type.dart';
import 'package:flutter_route_me/model/model_stop.dart';
import 'package:flutter_route_me/model/model_suggestion.dart';
import 'package:flutter_route_me/model/request_manager/places_manager.dart';
import 'package:flutter_route_me/model/request_manager/suggestions_manager.dart';
import 'package:flutter_route_me/pages/page_organize.dart';
import 'package:flutter_route_me/widgets/widget_routeme_appbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class FiltersPage extends StatefulWidget {
  FiltersPage({Key key}) : super(key: key);

  @override
  _FiltersPageState createState() => _FiltersPageState();
}


class _FiltersPageState extends State<FiltersPage> {

  TextEditingController textEditingController = new TextEditingController();

  List<FilterType> filters = new List<FilterType>();
  List<Stop> suggestedStops = new List<Stop>();

  CameraPosition _cameraPosition = CameraPosition(target: LatLng(26.8206, 30.8025)); // This will be changed for user actual gps location
  Completer<GoogleMapController> _controller = Completer();
  Position userPosition;
  Position destinyPosition;
  GoogleMapController googleMapcontroller;

  SuggestionsManager suggestionsManager = new SuggestionsManager();
  List<String> suggestionsName = new List<String>();
  List<String> added = [];

  FocusNode focusNode;
  SimpleAutoCompleteTextField autoCompleteTextField;

  PlacesManager placesManager = new PlacesManager();

  Future<void> initPlacesFilters() async {
    filters.add(new FilterType(false, "Library", "library"));
    filters.add(new FilterType(false, "Aquarium", "aquarium"));
    filters.add(new FilterType(false, "Mosque", "mosque"));
    filters.add(new FilterType(false, "Museum", "museum"));
    filters.add(new FilterType(false, "Park", "park"));
    filters.add(new FilterType(false, "Church", "church"));
    filters.add(new FilterType(false, "Stadium", "stadium"));
    filters.add(new FilterType(false, "Synagogue", "synagogue"));
    filters.add(new FilterType(false, "Tourist attraction", "tourist_attraction"));
    filters.add(new FilterType(false, "Hingu temple", "hingu_temple"));
    filters.add(new FilterType(false, "Amusement park", "amusement_park"));
    filters.add(new FilterType(false, "Zoo", "zoo"));

    suggestionsManager = new SuggestionsManager();

    placesManager = new PlacesManager();


    if(suggestedStops == null){
      suggestedStops = new List<Stop>();
    }
    suggestionsName = new List<String>();
  }

  void getUserLocation(){
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) async {
      userPosition = position;
      destinyPosition = position;
      try {
        List<Placemark> p = await geolocator.placemarkFromCoordinates(
            userPosition.latitude,
            userPosition.longitude);

        Placemark place = p[0];

        suggestedStops = new List<Stop>();
        suggestedStops = await placesManager.searchSuggestedPlaces(place.locality);
        //setState(() {});

        setState(() {
          textEditingController.text = "${place.locality}, ${place.country}";

          print("Latitude:");
          print(position.latitude);
          print("Longitude:");
          print(position.longitude);
          print("Adress:");
          print(textEditingController.text);

          _cameraPosition = CameraPosition(target: LatLng(userPosition.latitude, userPosition.longitude));
          googleMapcontroller.animateCamera(
              CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: LatLng(userPosition.latitude, userPosition.longitude),
                      tilt: 0,
                      bearing: 00,
                      zoom: 18.0
                  )
              )
          );
          _controller.complete(googleMapcontroller);
        });

      } catch (e) {
        print(e);
      }

      // Convert Lat/Lon to address

    }).catchError((e){
      print(e);
    });
  }

  // Seria necesario arreglar la función searchLocation, ya que si ponemos
  // Barcelona salta error, pero si ponemos Barcelona, España funciona bien
  Future<void> searchLocation() async {
    print("Search location");

    //List<Placemark> places = await Geolocator().placemarkFromAddress(textEditingController.text);
    List<Placemark> places = await Geolocator().placemarkFromAddress(textEditingController.text);

    Placemark place = places[0];
    Position searchedPosition = place.position;
    destinyPosition = searchedPosition;

    suggestedStops = new List<Stop>();
    suggestedStops = await placesManager.searchSuggestedPlaces(place.locality);
    setState(() {});

    setState(() {
      textEditingController.text = "${place.locality}, ${place.country}";

      _cameraPosition = CameraPosition(target: LatLng(searchedPosition.latitude, searchedPosition.longitude));
      googleMapcontroller.animateCamera(
          CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(searchedPosition.latitude, searchedPosition.longitude),
                  tilt: 0,
                  bearing: 0,
                  zoom: 15.0
              )
          )
      );
      _controller.complete(googleMapcontroller);
    });
  }

  void routeMe(){
    // First of all we look if the location has been set
    if (userPosition == null && destinyPosition == null){
      // show alert dialog with location error
      if (Platform.isAndroid){
        showDialog(
            barrierDismissible: true,
            context: context,
            builder: (BuildContext context){
              return AlertDialog(
                title: new Text("Location error!"),
                content: new Text("You need to search the location you want to visit."),
                actions: <Widget>[
                  new FlatButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: new Text("Agree")
                  )
                ],
              );
            }
        );
      }else{
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => CupertinoActionSheet(
              title: Text("Location error!"),
              message: Text("You need to search the location you want to visit."),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  child: Text("Agree"),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                )
              ],
            )
        );
      }
    }else{
      bool areSelectedFilters = checkIfSelectedFilters();
      if (areSelectedFilters){
        // go to OrganizePage (with loading indicator) with userPosition as Bundle
        print("Go to OtganizePage()");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrganizerPage(
                  initialPosition: userPosition == null ? null : userPosition,
                  destinyPosition: destinyPosition,
                  filters: filters,
                  suggestedStops: suggestedStops,
                )
            )
        );

      }else{
        // show selected filters error
        if (Platform.isAndroid){
          showDialog(
              barrierDismissible: true,
              context: context,
              builder: (BuildContext context){
                return AlertDialog(
                  title: new Text("There are not selected filters or suggested places!"),
                  content: new Text("Please select any place filter or suggested place."),
                  actions: <Widget>[
                    new FlatButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: new Text("Agree")
                    )
                  ],
                );
              }
          );
        }else{
          showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => CupertinoActionSheet(
                title: Text("There are not selected filters!"),
                message: Text("Please select any place filter."),
                actions: <Widget>[
                  CupertinoActionSheetAction(
                    child: Text("Agree"),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  )
                ],
              )
          );
        }
      }
    }
  }

  bool checkIfSelectedFilters(){
    int selectedFilters = 0;
    for (int i = 0; i < filters.length; i++){
      if (filters.elementAt(i).selected){
        selectedFilters++;
      }
    }
    if (suggestedStops.isNotEmpty){
      for (int i = 0; i < suggestedStops.length; i++){
        if(suggestedStops.elementAt(i).toVisit){
          selectedFilters++;
        }
      }
    }
    return selectedFilters != 0;
  }

  void checkSuggestedStop(Stop stop){
    stop.toVisit = !stop.toVisit;
  }

  void checkFilter(FilterType filter){
    filter.selected = !filter.selected;
  }


  // ------------------------- IMPORTANT FUNCTIONS -----------------------
  @override
  void initState() {
    super.initState();

    // Insert all types
    initPlacesFilters();

    // Set the focus
    focusNode = new FocusNode();
  }

  @override
  Widget build(BuildContext context) {

    autoCompleteTextField = new SimpleAutoCompleteTextField(
      key: GlobalKey(),
      decoration: InputDecoration(
        hintStyle: TextStyle(
          fontSize: 17,
          color: Colors.white70,
        ),
        labelStyle: TextStyle(
            fontSize: 17,
            color: Colors.white70
        ),
        focusColor: Colors.lightGreenAccent,
        hintText: 'Enter location',
        suffixIcon: IconButton(
          icon: Icon(
            Icons.clear,
            color: Colors.white,
          ),
          onPressed: (){
            textEditingController.text = "";
            FocusScope.of(context).requestFocus(focusNode);
          },
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(20),
      ),
      controller: textEditingController,
      suggestions: suggestionsName,
      textChanged: (text) async {
        textEditingController.text = text;
        textEditingController.selection = TextSelection.collapsed(offset: text.length);

        suggestionsName = new List<String>();
        List<Suggestion> placesSuggestions = await suggestionsManager.getSuggestion(text);

        if(placesSuggestions != null){
          for(int i = 0; i < placesSuggestions.length; i++){
            suggestionsName.add(placesSuggestions.elementAt(i).name);
          }
          autoCompleteTextField.updateSuggestions(suggestionsName);

        }

      },
      clearOnSubmit: false,
      textSubmitted: (text) {
        searchLocation();
      },
      textInputAction: TextInputAction.search,
      submitOnSuggestionTap: true,
      /*textChanged: (text) async{
                        //FocusScope.of(context).requestFocus(focusNode);
                        if(text.length % 4 == 0){
                            suggestionsName = new List<String>();
                            List<Suggestion> placesSuggestions = await suggestionsManager.getSuggestion(text);
                            if(placesSuggestions != null){
                              for(int i = 0; i < placesSuggestions.length; i++){
                                suggestionsName.add(placesSuggestions.elementAt(i).name);
                              }
                            }
                            if (!this.mounted) return;
                            //textEditingController.text = text;
                        }
                      },
                      textSubmitted: (text){
                        //setState(() {
                          //textEditingController.text = text;
                        //});
                        searchLocation();
                      },*/
    );

    return Padding(
        padding: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                    color: Colors.red[300],
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  child: autoCompleteTextField
              ),
              Visibility(
                replacement: const SizedBox(height: 0, width: 0,),
                visible: suggestedStops == null ? false : suggestedStops.length > 0,
                child: Container(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: <Widget>[
                          Flexible(
                            flex: 4,
                            child: Divider(
                              thickness: .5,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Flexible(
                            flex: 5,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Suggested places",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Flexible(
                            flex: 4,
                            child: Divider(
                              thickness: .5,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Container(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: suggestedStops == null ? 0 : suggestedStops.length,
                          itemBuilder: (BuildContext context, int index){
                            Color backColor;
                            Color detailColor;
                            TextStyle namestyle;
                            if(suggestedStops.elementAt(index).toVisit){
                              backColor = Colors.red[200];
                              detailColor = Colors.white70;
                              namestyle = TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70
                              );
                            }else{
                              backColor = Colors.grey[400];
                              detailColor = Colors.white70;
                              namestyle = TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white70
                              );
                            }
                            return GestureDetector(
                                child: Row(
                                  children: <Widget>[
                                    Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: new BorderRadius.circular(10.0),
                                          side: BorderSide(color: Colors.red[200], width: 1)
                                      ),
                                      color: backColor,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: backColor,
                                          borderRadius: BorderRadius.all(Radius.circular(32)),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 4,
                                              horizontal: 8
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              ClipOval(
                                                child: FadeInImage.assetNetwork(
                                                  image: placesManager.PLACE_PHOTO_BASE_URL
                                                      + placesManager.PLACE_PHOTO_MAXH
                                                      + "2000"
                                                      + placesManager.PLACE_PHOTO_MAXW
                                                      + "2000"
                                                      + placesManager.PLACE_PHOTO_REFERENCE
                                                      + suggestedStops.elementAt(index).photo
                                                      + placesManager.API_KEY
                                                  ,
                                                  placeholder: 'assets/markers/marcador.png',
                                                ),
                                              ),
                                              SizedBox(
                                                width: 6,
                                              ),
                                              Text(
                                                suggestedStops.elementAt(index).name,
                                                style: namestyle,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    )
                                  ],
                                ),
                                onTap: (){
                                  checkSuggestedStop(suggestedStops.elementAt(index));
                                  setState(() {});
                                }
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 3,
                    child: Divider(
                      thickness: .5,
                      color: Colors.red,
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Filter by type",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Divider(
                      thickness: .5,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 3,
              ),
              Container(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  itemBuilder: (BuildContext context, int index){
                    return Row(
                      children: <Widget>[
                        SizedBox(width: 8),
                        FilterChip(
                          label: Text(
                            filters.elementAt(index).name,
                            style: TextStyle(
                                color: filters.elementAt(index).selected ? Colors.white70 : Colors.grey[600],
                                fontWeight: filters.elementAt(index).selected ? FontWeight.bold : FontWeight.normal
                            ),
                          ),
                          avatar: CircleAvatar(
                            backgroundColor: filters.elementAt(index).selected ? Colors.red[100] : Colors.grey,
                            child: Icon(
                              filters.elementAt(index).selected ? Icons.check_circle : Icons.check_circle_outline,
                              color: filters.elementAt(index).selected ? Colors.red[300] : Colors.grey[600],
                            ),
                          ),
                          backgroundColor: filters.elementAt(index).selected ? Colors.red[200] : Colors.grey,
                          onSelected: (bool value){
                            filters.elementAt(index).selected = !filters.elementAt(index).selected;
                            setState(() {});
                          },
                        )
                      ],
                    );
                  },
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                width: 200,
                height: 50,
                child: RaisedButton(
                  color: Colors.white,
                  onPressed: (){
                    routeMe();
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.red[400], width: 2)
                  ),
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        'assets/images/solo_logo_v1.png',
                        width: 23,
                        height: 23,
                        color: Colors.red,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "Route me!",
                        style: GoogleFonts.poppins(
                          fontSize: 23
                        )
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                height: 250,
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller){
                    googleMapcontroller = controller;
                    getUserLocation();
                  },
                  initialCameraPosition: _cameraPosition,
                  myLocationEnabled: true,
                ),
              ),
            ],
          ),
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}