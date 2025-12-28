import 'package:http/http.dart' as http;
import 'package:cars_ahajjo/services/auth_services.dart';
import 'package:cars_ahajjo/services/socket_service.dart';
import 'dart:convert';

class LocationService {
  static const String _baseUrl = 'http://localhost:5003/api';
  static final SocketService _socketService = SocketService();

  /// Update driver's current location (via REST API & WebSocket)
  static Future<bool> updateLocation(double latitude, double longitude) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      // REST API call
      final response = await http.post(
        Uri.parse('$_baseUrl/location/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
      );

      if (response.statusCode == 200) {
        // Also emit via Socket.io for real-time updates
        final userId = await AuthService.getUserId();
        if (userId != null) {
          _socketService.sendDriverLocation(userId, latitude, longitude);
        }
        return true;
      } else {
        print('Error updating location: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  /// Get driver's last known location
  static Future<Map<String, dynamic>?> getDriverLocation(
    String driverId,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/location/$driverId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        print('Error fetching location: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Get nearby garages
  static Future<List<dynamic>> getNearbyGarages(
    double latitude,
    double longitude, {
    double maxDistance = 5000, // 5km in meters
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/garages/nearby?latitude=$latitude&longitude=$longitude&maxDistance=$maxDistance',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

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

  /// Get all garages
  static Future<List<dynamic>> getAllGarages() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/garages/all'),
        headers: {'Authorization': 'Bearer $token'},
      );

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

  /// Initialize Socket.io for real-time location updates
  static void initializeSocket() {
    _socketService.initialize();
    _socketService.connect();
  }

  /// Listen for real-time driver location updates
  static void onDriverLocationChanged(Function(Map<String, dynamic>) callback) {
    _socketService.on('driver_location_changed', callback);
  }

  /// Listen for driver going offline
  static void onDriverOffline(Function(Map<String, dynamic>) callback) {
    _socketService.on('driver_offline', callback);
  }

  /// Get active drivers in real-time
  static void getActiveDriversRealtime(Function(Map<String, dynamic>) callback) {
    _socketService.requestActiveDrivers();
    _socketService.on('active_drivers', callback);
  }

  /// Update driver status (online, offline, busy)
  static void setDriverStatus(String driverId, String status) {
    _socketService.updateDriverStatus(driverId, status);
  }

  /// Disconnect socket when done
  static void disconnectSocket() {
    _socketService.disconnect();
  }

