import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:parking_app/application/providers.dart';
import 'package:parking_app/screens/search_results_screen.dart';
import 'package:parking_app/widgets/my_drawer.dart';
import 'package:parking_app/widgets/wavy_header_image.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.defCounter}) : super(key: key);

  final String title;
  final int defCounter;

  @override
  _HomePageState createState() => _HomePageState();
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
    ctx.read(parkingNotifierProvider).retrieveParkings(
        _shouldLocateUser, _isSearchingCity, _searchQuery, _position);
    Navigator.of(ctx).pushNamed(SearchResults.routeName);
    // ctx.read(parkingNotifierProvider).favoriteParkings();
    // Navigator.of(ctx).pushNamed(Favorites.routeName);
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
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            WavyHeaderImage(),
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
