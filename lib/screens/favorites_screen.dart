import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parking_app/application/constants.dart';
import 'package:parking_app/application/parking_notifier.dart';
import 'package:parking_app/application/providers.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:parking_app/models/parking.dart';
import 'package:parking_app/widgets/my_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Favorites extends StatefulWidget {
  static const routeName = '/favorites';

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  static const String LOTTIE_ANIMATION = 'assets/lottie/location-pin-drop.json';
  static const double DEFAULT_MAP_ZOOM = 13.5;
  static const double CARD_WIDTH = 0.75;

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kCameraSkopjePosition = CameraPosition(
      target: LatLng(41.99646, 21.43141), zoom: DEFAULT_MAP_ZOOM);

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _isCurrentlyFavoriting = false;
  List<Parking> favoriteParkingsAtLoad;

  void _saveFavoritesListToPrefs() {
    List<String> toSave = favoriteParkingsAtLoad
        // filter those who are still favorited
        .where((parking) => parking.favorite)
        .map((parking) => parking.id.toString())
        .toList(growable: false);
    _prefs.then((SharedPreferences prefs) =>
        prefs.setStringList(PREFS_FAV_PARKINGS_LIST, toSave));
  }

  Future<void> addParkingToFavorites(Parking p) async {
    try {
      setState(() {
        _isCurrentlyFavoriting = true;
      });
      favoriteParkingsAtLoad
          .firstWhere((parking) => parking.id == p.id)
          .favorite = true;
      _saveFavoritesListToPrefs();
    } finally {
      setState(() {
        _isCurrentlyFavoriting = false;
      });
    }
  }

  Future<void> removeParkingFromFavorites(Parking p) async {
    try {
      setState(() {
        _isCurrentlyFavoriting = true;
      });
      favoriteParkingsAtLoad
          .firstWhere((parking) => parking.id == p.id)
          .favorite = false;
      _saveFavoritesListToPrefs();
    } finally {
      setState(() {
        _isCurrentlyFavoriting = false;
      });
    }
  }

  bool isFavorite(Parking p) => p.favorite ?? false;

  Widget buildLoadSuccess(BuildContext ctx, List<Parking> parkings) {
    final Map<MarkerId, Marker> markers = _generateMarkersForParkings(parkings);

    parkings.forEach((parking) => parking.favorite = true);
    favoriteParkingsAtLoad = parkings;

    Widget _makeCardSubtitle(IconData icon, String text) {
      return RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            WidgetSpan(
              child: Icon(icon, size: 16),
            ),
            TextSpan(
              text: ' ' + text,
              style:
                  TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.6)),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      drawer: MyDrawer(),
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text("Favorites"),
      ),
      body: ListView.builder(
        itemCount: favoriteParkingsAtLoad.length,
        itemBuilder: (ctx, index) {
          Parking p = favoriteParkingsAtLoad[index];
          return Container(
            width: MediaQuery.of(context).size.width * CARD_WIDTH,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Card(
              elevation: 5,
              color: Color(0xFFE8E8E8),
              child: ListTile(
                // selected: p.id == _currentlySelectedParkingId,
                title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.bold)),
                      Divider(color: Colors.black.withOpacity(0.6)),
                      _makeCardSubtitle(Icons.location_on, p.address),
                      SizedBox(
                        height: 8,
                      ),
                      _makeCardSubtitle(Icons.location_city, p.city),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Chip(
                            padding: EdgeInsets.all(0),
                            backgroundColor: Colors.teal,
                            label: RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Icon(Icons.star, size: 14),
                                  ),
                                  TextSpan(
                                    text: p.rating.toString(),
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isFavorite(p)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite(p) ? Colors.red[900] : null,
                            ),
                            tooltip: "Add to favorites",
                            onPressed: _isCurrentlyFavoriting
                                ? null
                                : () {
                                    if (isFavorite(p))
                                      removeParkingFromFavorites(p);
                                    else
                                      addParkingToFavorites(p);
                                  },
                          ),
                        ],
                      ),
                    ]),
                onTap: () {
                  _controller.future.then((GoogleMapController controller) {
                    Marker m = p.getAsMarker(null);
                    controller
                        .animateCamera(CameraUpdate.newLatLng(m.position))
                        .then(
                            (_) => controller.showMarkerInfoWindow(m.markerId));
                  });
                },
              ),
            ),
          );
          // ListTile(
          //   title: Text(p.name),
          //   subtitle: Text("${p.address}, ${p.city}"),
          //   // onTap: () {
          //   //   _controller.future
          //   //       .then((GoogleMapController controller) {
          //   //     Marker m = p.getAsMarker(null);
          //   //     controller
          //   //         .animateCamera(CameraUpdate.newLatLng(m.position))
          //   //         .then((_) =>
          //   //         controller.showMarkerInfoWindow(m.markerId));
          //   //     // _openMapInBottomSheet(context, markers);
          //   //   });
          // );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0))),
              context: context,
              builder: (BuildContext context) {
                return Container(
                  // decoration: BoxDecoration(
                  //   borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0))
                  // ),
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 16.0),
                        child: Container(
                          height: 4.0,
                          width: 64.0,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        flex: 9,
                        child: GoogleMap(
                          // for map drag to work inside the sheet/column
                          gestureRecognizers:
                              <Factory<OneSequenceGestureRecognizer>>[
                            Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer())
                          ].toSet(),

                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                          mapType: MapType.normal,
                          initialCameraPosition: _kCameraSkopjePosition,
                          // myLocationEnabled: true,
                          markers: Set<Marker>.of(markers.values),

                          // map on-screen controls settings
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                        ),
                      ),
                    ],
                  ),
                );
              });
        },
        child: Icon(Icons.map),
      ),
    );
  }

  Map<MarkerId, Marker> _generateMarkersForParkings(List<Parking> parkings) {
    Map<MarkerId, Marker> markers = {};
    parkings.forEach((parking) {
      Marker marker = parking.getAsMarker(null);
      markers[marker.markerId] = marker;
    });

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey[900],
      child: Consumer(
        builder: (context, watch, child) {
          final state = watch(parkingNotifierProvider.state);
          if (state is ParkingInitial) {
            return Center(child: Text("Shouldn't be on initial state here"));
          } else if (state is ParkingLoading) {
            return Center(
              child: lottie.Lottie.asset(LOTTIE_ANIMATION),
            );
          } else if (state is ParkingLoaded) {
            return buildLoadSuccess(context, state.parkings);
          } else {
            // (state is ParkingError)
            return Center(
                child: Text("Error loading parkings. Please try again!"));
          }
        },
      ),
    );
  }
}
