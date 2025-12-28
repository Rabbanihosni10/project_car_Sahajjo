import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cars_ahajjo/utils/constrains.dart';

class DriverService {
  static String get _baseUrl => '${AppConstants.baseUrl}/drivers';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Get all drivers for owner
  static Future<List<dynamic>> getOwnerDrivers() async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/owner'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('GET owner drivers: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final drivers = data['data'] is List
            ? data['data']
            : data['drivers'] ?? [];
        return drivers;
      }
      return [];
    } catch (e) {
      print('Error fetching owner drivers: $e');
      return [];
    }
  }

  /// Get driver details
  static Future<Map<String, dynamic>?> getDriverDetails(String driverId) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/$driverId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      }
      return null;
    } catch (e) {
      print('Error fetching driver details: $e');
      return null;
    }
  }

  /// Get driver location
  static Future<Map<String, dynamic>?> getDriverLocation(
    String driverId,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/location/driver/$driverId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      }
      return null;
    } catch (e) {
      print('Error fetching driver location: $e');
      return null;
    }
  }

  /// Get driver statistics
  static Future<Map<String, dynamic>?> getDriverStats(String driverId) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/$driverId/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      }
      return null;
    } catch (e) {
      print('Error fetching driver stats: $e');
      return null;
    }
  }
}
