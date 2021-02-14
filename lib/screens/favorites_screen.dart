import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parking_app/application/parking_notifier.dart';
import 'package:parking_app/application/providers.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:parking_app/models/parking.dart';

class Favorites extends StatefulWidget {
  static const routeName = '/favorites';

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  static const String LOTTIE_ANIMATION = 'assets/lottie/location-pin-drop.json';
  static const double DEFAULT_MAP_ZOOM = 13.5;

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kCameraSkopjePosition = CameraPosition(
      target: LatLng(41.99646, 21.43141), zoom: DEFAULT_MAP_ZOOM);

  Widget buildLoadSuccess(BuildContext ctx, List<Parking> parkings) {
    final Map<MarkerId, Marker> markers = _generateMarkersForParkings(parkings);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text("Favorites"),
      ),
      body: ListView.builder(
        itemCount: parkings.length,
        itemBuilder: (ctx, index) {
          Parking p = parkings[index];
          return ListTile(
            title: Text(p.name),
            subtitle: Text("${p.address}, ${p.city}"),
            // onTap: () {
            //   _controller.future
            //       .then((GoogleMapController controller) {
            //     Marker m = p.getAsMarker(null);
            //     controller
            //         .animateCamera(CameraUpdate.newLatLng(m.position))
            //         .then((_) =>
            //         controller.showMarkerInfoWindow(m.markerId));
            //     // _openMapInBottomSheet(context, markers);
            //   });
          );
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
    return Consumer(
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
    );
  }
}
