import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';

import 'screens/home_screen.dart';
import 'screens/search_results_screen.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF22857B, color),
        backgroundColor: Colors.blueGrey[900],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: 'Your Parking Compass'),
      routes: {
        SearchResults.routeName: (ctx) => SearchResults(),
      },
    );
  }



  Map<int, Color> color =
  {
    50:Color.fromRGBO(34,133,123, .1),
    100:Color.fromRGBO(34,133,123, .2),
    200:Color.fromRGBO(34,133,123, .3),
    300:Color.fromRGBO(34,133,123, .4),
    400:Color.fromRGBO(34,133,123, .5),
    500:Color.fromRGBO(34,133,123, .6),
    600:Color.fromRGBO(34,133,123, .7),
    700:Color.fromRGBO(34,133,123, .8),
    800:Color.fromRGBO(34,133,123, .9),
    900:Color.fromRGBO(34,133,123, 1),
  };


}