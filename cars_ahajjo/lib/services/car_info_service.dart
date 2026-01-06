import 'package:http/http.dart' as http;
import 'package:cars_ahajjo/services/auth_services.dart';
import 'package:cars_ahajjo/utils/constrains.dart';
import 'dart:convert';

class CarInfoService {
  static String get _baseUrl => '${AppConstants.baseUrl}/rentals';

  /// Get all available cars
  static Future<List<dynamic>> getAllCars() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        print('Error fetching cars: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  /// Search cars by query
  static Future<List<dynamic>> searchCars(String query) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/search?q=$query'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        print('Error searching cars: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  /// Get car details by ID
  static Future<Map<String, dynamic>?> getCarDetails(String carId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$carId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        print('Error fetching car details: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Get cars by category
  static Future<List<dynamic>> getCarsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/?category=$category'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  /// Get cars by location
  static Future<List<dynamic>> getCarsByLocation(String location) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/?location=$location'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  /// Book a car
  static Future<Map<String, dynamic>?> bookCar({
    required String carId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/rentals/$carId/book'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Get maintenance tips for a car
  static Future<Map<String, dynamic>?> getMaintenanceTips(
    String carModel,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/maintenance/$carModel'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
