import 'dart:convert';
import 'package:http/http.dart' as http;
import '/config.dart';

class BookingApi {
  Future<List<dynamic>> getAllBookings() async {
    try {
      final url = Uri.parse("${AppConfig.baseUrl}/bookings");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load bookings");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getBookingsByUser(String userId) async {
    try {
      final url = Uri.parse("${AppConfig.baseUrl}/bookings/user/$userId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load user bookings");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final url = Uri.parse("${AppConfig.baseUrl}/bookings");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bookingData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to create booking");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      final url = Uri.parse("${AppConfig.baseUrl}/bookings/$bookingId/cancel");
      final response = await http.put(url);

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }
}