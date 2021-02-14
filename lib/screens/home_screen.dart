import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:lottie/lottie.dart';

import 'package:parking_app/application/providers.dart';
import 'package:parking_app/screens/favorites_screen.dart';
import 'package:parking_app/screens/search_results_screen.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.defCounter}) : super(key: key);

  final String title;
  final int defCounter;

  @override
  _HomePageState createState() => _HomePageState();
}

class WavyHeaderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      child: Lottie.asset('assets/lottie/car.json',),
      clipper: BottomWaveClipper(),
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 130);

    var firstControlPoint = Offset(size.width / 4.5, size.height - 40.0);
    var firstEndPoint = Offset(size.width / 2.5, size.height - 70.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
    Offset(size.width - (size.width / 3.75), size.height - 150);
    var secondEndPoint = Offset(size.width, size.height - 100);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _HomePageState extends State<HomePage> {
  bool _shouldLocateUser = true;
  bool _isSearchingCity = true;
  Position _position;
  String _searchQuery = "";

  void _initiateSearch(BuildContext ctx) async {
    if (_shouldLocateUser) {
      try {
        _position = await _determinePosition();
      } catch (error) {
        Scaffold.of(ctx).showSnackBar(
            SnackBar(content: Text("Can't retrieve your location!")));
      }
    }
    // ctx.read(parkingNotifierProvider).retrieveParkings(
    //     _shouldLocateUser, _isSearchingCity, _searchQuery, _position);
    // Navigator.of(ctx).pushNamed(SearchResults.routeName);
    ctx.read(parkingNotifierProvider).favoriteParkings();
    Navigator.of(ctx).pushNamed(Favorites.routeName);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw ('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      throw ('Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw ('Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            WavyHeaderImage(),
            // LiteRollingSwitch(
            //   value: _isSearchingCity,
            //   //initial value
            //   textOn: 'City',
            //   textOff: 'Address',
            //   // colorOn: Colors.tealAccent[700],
            //   // colorOff: Colors.tealAccent[200],
            //   colorOn: Color(0xFF22857B),
            //   colorOff: Color(0xff00A3A3),
            //   iconOn: Icons.location_city,
            //   iconOff: Icons.location_on,
            //   textSize: 16.0,
            //   onChanged: (bool state) {
            //     _isSearchingCity = state;
            //   },
            // ),
            // SizedBox(
            //   height: 30,
            // ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 0, left: 24.0, right: 24.0, top: 16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _shouldLocateUser = value == "";
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  fillColor: Colors.white70,
                  filled: true,
                  hintText: 'Or enter city/address',
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: SizedBox(
          height: 150,
          width: 150,
          child: FloatingActionButton(
            backgroundColor: Colors.teal,
            onPressed: () => _initiateSearch(context),
            tooltip: 'Search',
            child: _shouldLocateUser
              ? Image.asset('images/button.gif')
              : Icon(
              Icons.search,
              size: 100,
            ),
            // IconButton(
            //   icon: Image.asset('images/button.gif'),
            //   iconSize: 200,
            //   highlightColor: Colors.transparent,
            //   splashColor: Colors.transparent,
            //   onPressed: () {
            //     Navigator.of(context).pushNamed(SearchResults.routeName);
            //   },
            // ),
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
