import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:parking_app/models/parking.dart';

// Endpoints are

// /api/parking
//             /result (String city, String address)
//             /currentLocation (Double longitude, Double latitude)
//             /allParkings

class HttpClient {

  static const MAIN_URL = "http://10.0.2.2:9090/api/parking/";

  /// FOR PHONE
  /// RUN jar on pc
  /// THEN use the url below
  //  static const MAIN_URL = "http://192.168.0.110:9090/api/parking/";
  /// sudo ufw enable
  /// sudo ufw allow 9090 (or selected port)
  /// check with - sudo uwf status numbered
  /// when done exectute following
  /// sudo ufw delete 1
  /// UNTIL ufw status numbered shows nothing
  /// THEN sudo ufw disable

  String _buildUrl (String endpoint, Map<String, Object> params) {
    String paramsString = "?";
    params.forEach((key, value) => paramsString += "&${key}=${value}");

    return MAIN_URL + endpoint + paramsString;
  }

  Future<List<Parking>> makeRequest(String endpoint, Map<String, dynamic> params) async {
    try {

      final response = await http.get(_buildUrl(endpoint, params));
      final responseBody = jsonDecode(response.body);
      if (response.statusCode != 200) throw HttpException(responseBody);

      print(responseBody);

      final parkingList = responseBody as List;
      return parkingList.map((e) => Parking.fromJSON(e)).toList();
    } catch (error) {
      print("Error while processing request");
      print(error);
      throw(error);
    }
  }

  Future<List<Parking>> getAllParkings() async {
    return await makeRequest('allParkings', {});
  }

  Future<List<Parking>> getResultsForCityAndAddress(Map<String, dynamic> searchParams) async {
    return await makeRequest('result', searchParams);
  }

  Future<List<Parking>> getResultsForCurrentLocation(Map<String, dynamic> searchParams) async {
    return await makeRequest('currentLocation', searchParams);
  }
}

