import 'dart:convert';
import 'package:http/http.dart' as http;
import '/config.dart';

class SlotApi {
  Future<List<dynamic>> getSlotsByStation(String stationId) async {
    try {
      final url = Uri.parse("${AppConfig.baseUrl}/slots/station/$stationId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load slots");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getAvailableSlots(String stationId) async {
    try {
      final url = Uri.parse("${AppConfig.baseUrl}/slots/station/$stationId/available");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load available slots");
      }
    } catch (e) {
      rethrow;
    }
  }
}