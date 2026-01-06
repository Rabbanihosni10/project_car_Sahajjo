import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cars_ahajjo/utils/constrains.dart';
import 'package:cars_ahajjo/services/auth_services.dart';

class GarageService {
  static String get _baseUrl => '${AppConstants.baseUrl}/garages';

  // Mock garage data for when backend is unavailable
  static List<Map<String, dynamic>> _getMockGarages(
    double userLat,
    double userLng,
  ) {
    return [
      {
        'id': 'mock_1',
        'name': 'City Auto Care',
        'address': '123 Main Street, Dhaka',
        'phone': '+880 1712-345678',
        'services': ['Oil Change', 'Tire Rotation', 'Brake Service'],
        'rating': 4.5,
        'location': {
          'type': 'Point',
          'coordinates': [userLng + 0.01, userLat + 0.01], // ~1km away
        },
      },
      {
        'id': 'mock_2',
        'name': 'Quick Fix Garage',
        'address': '456 Park Road, Dhaka',
        'phone': '+880 1812-345678',
        'services': ['Engine Repair', 'AC Service', 'Alignment'],
        'rating': 4.2,
        'location': {
          'type': 'Point',
          'coordinates': [userLng - 0.015, userLat + 0.008], // ~1.5km away
        },
      },
      {
        'id': 'mock_3',
        'name': 'Premium Motors',
        'address': '789 Lake View, Dhaka',
        'phone': '+880 1912-345678',
        'services': ['Full Service', 'Diagnostics', 'Body Work'],
        'rating': 4.8,
        'location': {
          'type': 'Point',
          'coordinates': [userLng + 0.02, userLat - 0.01], // ~2km away
        },
      },
      {
        'id': 'mock_4',
        'name': 'Express Auto Service',
        'address': '321 River Side, Dhaka',
        'phone': '+880 1712-987654',
        'services': ['Quick Oil Change', 'Tire Service', 'Battery'],
        'rating': 4.0,
        'location': {
          'type': 'Point',
          'coordinates': [userLng - 0.008, userLat - 0.012], // ~1.5km away
        },
      },
      {
        'id': 'mock_5',
        'name': 'Elite Car Workshop',
        'address': '555 Green Avenue, Dhaka',
        'phone': '+880 1812-456789',
        'services': ['Engine Diagnostics', 'Transmission', 'Suspension'],
        'rating': 4.6,
        'location': {
          'type': 'Point',
          'coordinates': [userLng + 0.005, userLat + 0.015], // ~1.8km away
        },
      },
    ];
  }

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
      final response = await http
          .get(
            Uri.parse('$_baseUrl/nearby').replace(
              queryParameters: {
                'latitude': latitude.toString(),
                'longitude': longitude.toString(),
                'radius': radiusInKm.toString(),
              },
            ),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final garages = data['data'] ?? [];

        // If backend returns empty, use mock data
        if (garages.isEmpty) {
          print('Backend returned empty garages, using mock data');
          return _getMockGarages(latitude, longitude);
        }

        return garages;
      } else {
        print('Error fetching nearby garages: ${response.body}');
        print('Using mock garage data instead');
        return _getMockGarages(latitude, longitude);
      }
    } catch (e) {
      print('Error connecting to garage service: $e');
      print('Using mock garage data for demonstration');
      return _getMockGarages(latitude, longitude);
    }
  }

  /// Create a new garage
  static Future<bool> createGarage(dynamic garage) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        print('No authentication token found');
        return false;
      }

      final garageData = garage is Map<String, dynamic>
          ? garage
          : (garage.toJson != null ? garage.toJson() : {});

      print('Creating garage: ${garageData['name']}');
      print('Location: ${garageData['latitude']}, ${garageData['longitude']}');

      final response = await http.post(
        Uri.parse('$_baseUrl/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(garageData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Garage created successfully');
        return true;
      } else {
        print('Failed to create garage: ${response.body}');
        throw Exception('Failed to create garage: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating garage: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception(
          'Cannot connect to server. Please ensure backend is running at ${_baseUrl}',
        );
      }
      rethrow;
    }
  }

  /// Get garage by ID
  static Future<Map<String, dynamic>?> getGarageById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$id'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else {
        print('Error fetching garage: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Update a garage
  static Future<bool> updateGarage(String id, dynamic garage) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final garageData = garage is Map<String, dynamic>
          ? garage
          : (garage.toJson != null ? garage.toJson() : {});

      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(garageData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating garage: $e');
      return false;
    }
  }

  /// Delete a garage
  static Future<bool> deleteGarage(String id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting garage: $e');
      return false;
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
