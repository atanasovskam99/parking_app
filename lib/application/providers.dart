
import 'package:flutter_riverpod/all.dart';

import 'package:parking_app/application/http_client.dart';
import 'package:parking_app/application/parking_notifier.dart';
import 'package:parking_app/models/parking.dart';

final httpClientProvider = Provider<HttpClient>((ref) => HttpClient());

final parkingNotifierProvider = StateNotifierProvider((ref) => ParkingNotifier(ref.watch(httpClientProvider)));
