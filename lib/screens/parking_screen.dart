import 'package:flutter/material.dart';

import 'package:parking_app/models/parking.dart';

class ParkingScreen extends StatelessWidget {
  final Parking parking;

  ParkingScreen({this.parking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(parking.name),
      ),
      body: Center(
        child: Text("${parking.name} in ${parking.address}, ${parking.city}"),
      ),
    );
  }
}
