import 'package:flutter/material.dart';
import 'package:parking_app/application/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parking_app/screens/favorites_screen.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
                'Your Parking compass',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.bold)),
            decoration: BoxDecoration(
              color: Color(0xFF263238),
            ),
          ),
          ListTile(
            tileColor: ModalRoute.of(context).settings.name == '/' ? Color(0xFF22857B) : Color(0xFF235A61),
            title: Text(
                'Home',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16, )),
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
          ListTile(
            tileColor: ModalRoute.of(context).settings.name == '/favorites' ? Color(0xFF22857B) : Color(0xFF235A61),
            title: Text(
                'Favorites',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16)),
            onTap: () {
              context.read(parkingNotifierProvider).favoriteParkings();
              Navigator.of(context).pushNamed(Favorites.routeName);

            },
          ),
        ],
      ),
    );
  }
}