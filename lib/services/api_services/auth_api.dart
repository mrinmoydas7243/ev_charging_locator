import 'dart:convert';
import 'package:http/http.dart' as http;
import '/config.dart';

class AuthApi {
  Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    try {
      final url = Uri.parse(
        "${AppConfig.baseUrl}/auth/send-otp?mobileNumber=$mobileNumber",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'otp': data['otp']};
      } else {
        throw Exception("Failed to send OTP");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> validateOtp(String mobileNumber, String otp) async {
    try {
      final url = Uri.parse(
        "${AppConfig.baseUrl}/auth/validate-otp?mobileNumber=$mobileNumber&otp=$otp",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("OTP validation failed");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> completeProfile(Map<String, dynamic> userData) async {
    try {
      final url = Uri.parse("${AppConfig.baseUrl}/auth/complete-profile");
      
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to complete profile");
      }
    } catch (e) {
      rethrow;
    }
  }
}