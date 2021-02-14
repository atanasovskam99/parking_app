import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Parking {
  
  final int id;
  final String name;
  final String city;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  // final String rating;
  final String mapUrl;
  bool favorite;
  double distanceFromUser;

  Parking({
    @required this.id,
    @required this.name,
    @required this.city,
    @required this.address,
    @required this.latitude,
    @required this.longitude,
    @required this.rating,
    @required this.mapUrl,
    favorite = false,
    distanceFromUser = 1000, // arbitrary large value
  });

  factory Parking.fromJSON(Map<String, dynamic> json) => Parking(
    id: json['id'],
    name: json['name'],
    city: json['city'],
    address: json['address'],
    latitude: json['latitude'],
    longitude: json['longitude'],
    rating: _parseRatingToDouble(json['rating']),
    // rating: json['rating'],
    mapUrl: json['mapUrl'],
  );

  Marker getAsMarker(onTapCallback) {
    final markerIdValue = id;
    final markerId = MarkerId(markerIdValue.toString());

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
          latitude,
          longitude
      ),
      infoWindow: InfoWindow(title: name, snippet: '$rating/5, $address'),
      draggable: false,
      onTap: onTapCallback,

      // to change icon color
      // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan)
    );

    return marker;
  }

  // 'Not known rating' is parsed as a 3.0
  static double _parseRatingToDouble(String rating) {
    if (rating == 'Not known rating')
      return 3.0;
    else
      return double.parse(rating.replaceAll(",", "."));
  }
}


/*
"id": 68,
"name": "Tehnomarket Stadion",
"city": "Skopje",
"address": "Aminta treti",
"latitude": 42.00516940048577,
"longitude": 21.42457596670927,
"rating": "4,3",
"mapUrl": "https://www.google.com/maps/d/embed?mid=1YYjeXoAD36DgDITfcJZzdSQFKlvzFFDN&z=17"
*/
