import 'dart:async';
import 'dart:math';

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/all.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:parking_app/application/constants.dart';
import 'package:parking_app/application/parking_notifier.dart';

import 'package:parking_app/models/parking.dart';
import 'package:parking_app/application/providers.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchResults extends StatefulWidget {
  static const routeName = '/search-results';

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  static const double DEFAULT_MAP_ZOOM = 15.5;
  static const double MAP_HEIGHT_PERCENTAGE = 0.5;
  static const double CARD_WIDTH = 0.75;
  static const String LOTTIE_ANIMATION = 'assets/lottie/location-pin-drop.json';

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kCameraSkopjePosition = CameraPosition(
      target: LatLng(41.99646, 21.43141), zoom: DEFAULT_MAP_ZOOM);
  CameraPosition _kCameraUserPosition = _kCameraSkopjePosition;

  int _currentlySelectedParkingId = -1;
  ItemScrollController _scrollController = ItemScrollController();

  bool _sortByRating = true;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<String> _favoritesList;
  bool _isCurrentlyFavoriting = false;

  // singleton like behavior
  Future<List<String>> _loadFavoritesListFromPrefs() async {
    SharedPreferences prefs = await _prefs;
    _favoritesList = prefs.getStringList(PREFS_FAV_PARKINGS_LIST);

    if (_favoritesList == null) {
      prefs.setStringList(PREFS_FAV_PARKINGS_LIST, []);
    }

    return _favoritesList;
  }

  void _saveFavoritesListToPrefs() {
    _prefs.then((SharedPreferences prefs) =>
        prefs.setStringList(PREFS_FAV_PARKINGS_LIST, _favoritesList));
  }

  bool isFavorite(Parking p) => p.favorite ?? false;

  Future<void> addParkingToFavorites(Parking p) async {
    try {
      setState(() {
        _isCurrentlyFavoriting = true;
      });
      List<String> favoritesList = await _loadFavoritesListFromPrefs();
      favoritesList.add(p.id.toString());
      p.favorite = true;
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
      List<String> favoritesList = await _loadFavoritesListFromPrefs();
      favoritesList.remove(p.id.toString());
      p.favorite = false;
      _saveFavoritesListToPrefs();
    } finally {
      setState(() {
        _isCurrentlyFavoriting = false;
      });
    }
  }

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

  Widget buildLoadSuccess(BuildContext ctx, List<Parking> parkings) {
    Map<MarkerId, Marker> markers = _generateMarkersForParkings(parkings);

    return Column(
      children: <Widget>[
        SizedBox(
          height: 8,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                origin: Offset(-255, -80),
                angle: pi / 5,
                child: Transform.scale(
                    scale: 1.5, child: Image.asset('images/handle.png')),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF235A61),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.width * 0.9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width * 0.9 * 0.5),
                  child: GoogleMap(
                    // for map drag to work inside the column
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                      Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer())
                    ].toSet(),

                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    mapType: MapType.normal,
                    initialCameraPosition: _kCameraUserPosition,
                    trafficEnabled: true,
                    myLocationEnabled: true,
                    markers: Set<Marker>.of(markers.values),

                    // map on-screen controls settings
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    // to push the toolbar towards the inside
                    padding: EdgeInsets.all(50.0),
                  ),
                ),
              ),
            ],
          ),
        ),
        Spacer(
          flex: 3,
        ),
        Expanded(
          flex: 7,
          child: Padding(
            padding: EdgeInsets.only(
                left:
                    MediaQuery.of(context).size.width * (1 - CARD_WIDTH - 0.1)),
            child: ScrollablePositionedList.builder(
              scrollDirection: Axis.horizontal,
              itemScrollController: _scrollController,
              itemCount: parkings.length,
              itemBuilder: (ctx, index) {
                Parking p = parkings[index];
                return Container(
                  width: MediaQuery.of(context).size.width * CARD_WIDTH,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Card(
                    elevation: 5,
                    color: Color(0xFFE8E8E8),
                    child: ListTile(
                      selected: p.id == _currentlySelectedParkingId,
                      title: Flexible(
                        child: Column(
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
                                            style:
                                                TextStyle(color: Colors.black),
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
                                      color: isFavorite(p)
                                          ? Colors.red[900]
                                          : null,
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
                      ),
                      onTap: () {
                        _controller.future
                            .then((GoogleMapController controller) {
                          Marker m = p.getAsMarker(null);
                          controller
                              .animateCamera(CameraUpdate.newLatLng(m.position))
                              .then((_) =>
                                  controller.showMarkerInfoWindow(m.markerId));
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Spacer(
          flex: 1,
        )
      ],
    );
  }

  void _setCameraToUserPositionIfPossible(Map<String, dynamic> searchParams) {
    if (searchParams.containsKey('latitude') &&
        searchParams.containsKey('longitude')) {
      _kCameraUserPosition = CameraPosition(
          target: LatLng(searchParams['latitude'], searchParams['longitude']),
          zoom: DEFAULT_MAP_ZOOM);
    }
  }

  Map<MarkerId, Marker> _generateMarkersForParkings(List<Parking> parkings) {
    Map<MarkerId, Marker> markers = {};
    parkings.forEach((parking) {
      Marker marker = parking.getAsMarker(() {
        setState(() {
          _currentlySelectedParkingId = parking.id;
        });
        _scrollController.scrollTo(
            index: parkings.indexOf(parking),
            duration: Duration(milliseconds: 500));
      });
      markers[marker.markerId] = marker;
    });

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    imageCache.clear(); // for the asset problem - possible fix
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text("Search Results"),
      ),
      body: Consumer(
        builder: (context, watch, child) {
          final state = watch(parkingNotifierProvider.state);
          if (state is ParkingInitial) {
            return Center(child: Text("Shouldn't be on initial state here"));
          } else if (state is ParkingLoading) {
            return Center(
              child: lottie.Lottie.asset(LOTTIE_ANIMATION),
            );
          } else if (state is ParkingLoaded) {
            _setCameraToUserPositionIfPossible(state.searchParams);
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
