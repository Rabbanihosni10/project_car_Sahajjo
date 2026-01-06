import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cars_ahajjo/utils/constrains.dart';
import 'package:cars_ahajjo/services/auth_services.dart';
import 'package:geolocator/geolocator.dart';

class DriverLocationService {
  static String get _baseUrl => '${AppConstants.baseUrl}/location';

  /// Update driver's current location
  static Future<bool> updateDriverLocation({
    required String driverId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http
          .post(
            Uri.parse('$_baseUrl/driver/$driverId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'latitude': latitude,
              'longitude': longitude,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error updating driver location: $e');
      return false;
    }
  }

  /// Get all drivers' locations for an owner
  static Future<List<Map<String, dynamic>>> getOwnerDriversLocations(
    String ownerId,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http
          .get(
            Uri.parse('$_baseUrl/owner/$ownerId/drivers'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final drivers = data['data'] as List?;
        return drivers?.cast<Map<String, dynamic>>() ?? [];
      } else {
        print('Error fetching driver locations: ${response.body}');
        return _getMockDriverLocations(ownerId);
      }
    } catch (e) {
      print('Error: $e - Using mock driver locations');
      return _getMockDriverLocations(ownerId);
    }
  }

  /// Get specific driver's location
  static Future<Map<String, dynamic>?> getDriverLocation(
    String driverId,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      final response = await http
          .get(
            Uri.parse('$_baseUrl/driver/$driverId'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        print('Error fetching driver location: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Start tracking driver location (call periodically)
  static Future<bool> startLocationTracking(String driverId) async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update location
      return await updateDriverLocation(
        driverId: driverId,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('Error starting location tracking: $e');
      return false;
    }
  }

  /// Mock driver locations for demonstration when backend unavailable
  static List<Map<String, dynamic>> _getMockDriverLocations(String ownerId) {
    // Generate some mock drivers with locations
    return [
      {
        'driverId': 'mock_driver_1',
        'driverName': 'Ahmed Khan',
        'phone': '+880 1712-111111',
        'carModel': 'Toyota Corolla',
        'carPlate': 'Dhaka Metro-12-3456',
        'status': 'active',
        'location': {
          'latitude': 23.8103 + (0.01 * 1), // Near Dhaka
          'longitude': 90.4125 + (0.01 * 1),
        },
        'lastUpdated': DateTime.now()
            .subtract(const Duration(minutes: 2))
            .toIso8601String(),
      },
      {
        'driverId': 'mock_driver_2',
        'driverName': 'Rahim Uddin',
        'phone': '+880 1812-222222',
        'carModel': 'Honda Civic',
        'carPlate': 'Dhaka Metro-34-7890',
        'status': 'active',
        'location': {
          'latitude': 23.8103 - (0.015 * 1),
          'longitude': 90.4125 + (0.008 * 1),
        },
        'lastUpdated': DateTime.now()
            .subtract(const Duration(minutes: 5))
            .toIso8601String(),
      },
      {
        'driverId': 'mock_driver_3',
        'driverName': 'Karim Mia',
        'phone': '+880 1912-333333',
        'carModel': 'Toyota Allion',
        'carPlate': 'Dhaka Metro-56-1234',
        'status': 'inactive',
        'location': {
          'latitude': 23.8103 + (0.02 * 1),
          'longitude': 90.4125 - (0.01 * 1),
        },
        'lastUpdated': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
      },
    ];
  }
}
