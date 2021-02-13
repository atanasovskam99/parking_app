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
        primarySwatch: Colors.teal,
        backgroundColor: Colors.blueGrey[900],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: 'Flutter Demo Home Page'),
      routes: {
        SearchResults.routeName: (ctx) => SearchResults(),
      },
    );
  }
}
