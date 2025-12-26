import 'dart:convert';
import 'package:http/http.dart' as http;
import '/config.dart';

class StationApi {
  Future<List<dynamic>> getAllStations() async {
    try {
      final url = Uri.parse("${AppConfig.baseUrl}/stations");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load stations");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStationById(String id) async {
    try {
      final url = Uri.parse("${AppConfig.baseUrl}/stations/$id");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load station details");
      }
    } catch (e) {
      rethrow;
    }
  }
}