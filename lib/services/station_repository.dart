
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/ev_station.dart';

class StationRepository {
  Future<List<EVStation>> loadMockStations() async {
    final raw = await rootBundle.loadString('assets/data/mock_stations.json');
    final items = (json.decode(raw) as List).cast<Map<String, dynamic>>();
    return items.map(EVStation.fromJson).toList();
  }
}
