import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fare.dart';
import '../utils/constrains.dart';

class FareService {
  static String get baseUrl => '${AppConstants.baseUrl}/fares';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String> _getBaseUrl() async {
    return baseUrl;
  }

  // Estimate fare
  static Future<FareEstimate?> estimateFare({
    required double distance,
    required int durationMinutes,
    String demandLevel = 'normal',
  }) async {
    try {
      final url = await _getBaseUrl();

      final response = await http.post(
        Uri.parse('$url/estimate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'distance': distance,
          'durationMinutes': durationMinutes,
          'demandLevel': demandLevel,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FareEstimate.fromJson(data['data'] ?? {});
      }
      return null;
    } catch (e) {
      print('Error estimating fare: $e');
      return null;
    }
  }

  // Record fare after ride completion
  static Future<bool> recordFare({
    required String rideId,
    required double distance,
    required int durationMinutes,
    required double surgeFactor,
    required String paymentMethod,
  }) async {
    try {
      final token = await _getToken();
      final url = await _getBaseUrl();

      final response = await http.post(
        Uri.parse('$url/record'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'rideId': rideId,
          'distance': distance,
          'durationMinutes': durationMinutes,
          'surgeFactor': surgeFactor,
          'paymentMethod': paymentMethod,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error recording fare: $e');
      return false;
    }
  }

  // Get fare history
  static Future<List<Fare>> getFareHistory({
    required String role, // 'rider' or 'driver'
  }) async {
    try {
      final token = await _getToken();
      final url = await _getBaseUrl();

      final response = await http.get(
        Uri.parse('$url/history?role=$role'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fares =
            (data['data'] as List?)
                ?.map((fare) => Fare.fromJson(fare as Map<String, dynamic>))
                .toList() ??
            [];
        return fares;
      }
      return [];
    } catch (e) {
      print('Error fetching fare history: $e');
      return [];
    }
  }

  // Get fare statistics
  static Future<FareStatistics?> getFareStatistics({
    required String role,
    int days = 30,
  }) async {
    try {
      final token = await _getToken();
      final url = await _getBaseUrl();

      final response = await http.get(
        Uri.parse('$url/statistics?role=$role&days=$days'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FareStatistics.fromJson(data['data'] ?? {});
      }
      return null;
    } catch (e) {
      print('Error fetching fare statistics: $e');
      return null;
    }
  }

  // Generate receipt
  static Future<Map<String, dynamic>?> generateReceipt(String fareId) async {
    try {
      final token = await _getToken();
      final url = await _getBaseUrl();

      final response = await http.get(
        Uri.parse('$url/receipt/$fareId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error generating receipt: $e');
      return null;
    }
  }
}
