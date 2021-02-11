import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parking_app/application/http_client.dart';
import 'package:parking_app/models/parking.dart';

abstract class ParkingLoadState {
  const ParkingLoadState();
}

class ParkingInitial extends ParkingLoadState {
  const ParkingInitial();
}

class ParkingLoading extends ParkingLoadState {
  const ParkingLoading();
}

class ParkingLoaded extends ParkingLoadState {
  final List<Parking> parkings;
  final Map<String, dynamic> searchParams;

  const ParkingLoaded(this.parkings, this.searchParams);

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;

    return other is ParkingLoaded && mapEquals(searchParams, other.searchParams);
  }
}

class ParkingError extends ParkingLoadState {
  final String message;

  const ParkingError(this.message);

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;

    return other is ParkingError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class ParkingNotifier extends StateNotifier<ParkingLoadState> {
  final HttpClient _httpClient;

  ParkingNotifier(this._httpClient): super(ParkingInitial());

  Future<void> retrieveParkings(bool shouldLocateUser, bool isSearchingCity, String searchQuery, Position position) async {
    try {
      state = ParkingLoading();
      
      var parkings;

      Map<String, dynamic> searchParams = {};
      if (shouldLocateUser) {
        // searchParams['latitude'] = 41.980375;
        // searchParams['longitude'] = 21.471765;
        searchParams['latitude'] = position.latitude;
        searchParams['longitude'] = position.longitude;

        parkings = await _httpClient.getResultsForCurrentLocation(searchParams);
      } else {
        searchParams[isSearchingCity ? 'city' : 'address'] = searchQuery;
        searchParams[!isSearchingCity ? 'city' : 'address'] = ""; // TODO until the backend is fixed (null ptr)
        
        parkings = await _httpClient.getResultsForCityAndAddress(searchParams);
      }
      state = ParkingLoaded(parkings, searchParams);
    } catch (error) {
      print("error loading parkings");
      print(error);
      state = ParkingError(error.toString());
    }
  }
}