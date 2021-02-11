import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/all.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:parking_app/application/parking_notifier.dart';

import 'package:parking_app/models/parking.dart';
import 'package:parking_app/application/providers.dart';
import 'package:parking_app/screens/parking_screen.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class SearchResults extends StatefulWidget {
  static const routeName = '/search-results';

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  static const double DEFAULT_MAP_ZOOM = 15.5;
  static const double MAP_HEIGHT_PERCENTAGE = 0.4;
  static const String LOTTIE_ANIMATION = 'assets/lottie/location-pin-drop.json';

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kCameraSkopjePosition = CameraPosition(
      target: LatLng(41.99646, 21.43141), zoom: DEFAULT_MAP_ZOOM);
  CameraPosition _kCameraUserPosition = _kCameraSkopjePosition;

  int _currentlySelectedParkingId = -1;
  ItemScrollController _scrollController = ItemScrollController();

  bool _sortByRating = true;

  Widget buildLoadSuccess(BuildContext ctx, List<Parking> parkings) {
    Map<MarkerId, Marker> markers = _generateMarkersForParkings(parkings);

    return Column(
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * MAP_HEIGHT_PERCENTAGE,
          // TODO maybe remove visibility and setState inside onMapCreated
          // TODO(2) because the effect isn't really there
          child: Visibility(
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            visible: _controller.isCompleted,
            replacement: lottie.Lottie.asset(LOTTIE_ANIMATION),
            child: GoogleMap(
              // for map drag to work inside the column
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer())
              ].toSet(),

              onMapCreated: (GoogleMapController controller) {
                setState(() {
                  _controller.complete(controller);
                });
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
        LiteRollingSwitch(
          value: _sortByRating,
          textOn: 'Rating',
          textOff: 'Name',
          colorOn: Colors.teal,
          colorOff: Colors.teal,
          iconOn: Icons.stars,
          iconOff: Icons.sort_by_alpha,
          textSize: 16.0,
          onChanged: (bool state) {
            _sortByRating = state;
            // setState(() {
            //   if (_sortByRating) {
            //     parkings.sort((a, b) => b.rating.compareTo(a.rating));
            //   } else {
            //     parkings.sort((a, b) => a.name.compareTo(b.name));
            //   }
            // });
          },
        ),
        Expanded(
          child: ScrollablePositionedList.builder(
            itemScrollController: _scrollController,
            itemCount: parkings.length,
            itemBuilder: (ctx, index) {
              Parking p = parkings[index];
              return ListTile(
                selected: p.id == _currentlySelectedParkingId,
                title: Text(p.name),
                subtitle: Text(p.address),
                onTap: () {
                  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
                    return ParkingScreen(parking: p);
                  }));
                },
              );
            },
          ),
        ),
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
    imageCache.clear();
    return Scaffold(
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
                child:
                    lottie.Lottie.asset('assets/lottie/location-pin-drop.json'),
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
        ));
  }
}
