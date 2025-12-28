import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cars_ahajjo/utils/constrains.dart';
import 'package:cars_ahajjo/services/auth_services.dart';

class GarageService {
  static String get _baseUrl => '${AppConstants.baseUrl}/garages';

  /// Get all garages
  static Future<List<dynamic>> getAllGarages() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        print('Error fetching garages: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  /// Get nearby garages
  static Future<List<dynamic>> getNearbyGarages({
    required double latitude,
    required double longitude,
    double radiusInKm = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/nearby').replace(
          queryParameters: {
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
            'radius': radiusInKm.toString(),
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        print('Error fetching nearby garages: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  /// Seed test garages
  static Future<bool> seedGarages() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/seed'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
