import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cars_ahajjo/models/ride.dart';
import 'package:cars_ahajjo/services/auth_services.dart';

class RideService {
  static const String _apiBase = 'http://localhost:5003/api';

  // Request a ride
  static Future<Ride> requestRide({
    required Map<String, dynamic> pickupLocation,
    required Map<String, dynamic> dropLocation,
    required double distance,
    required int duration,
    String? notes,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$_apiBase/rides'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'pickupLocation': pickupLocation,
          'dropLocation': dropLocation,
          'distance': distance,
          'duration': duration,
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Ride.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to request ride: ${response.body}');
    } catch (e) {
      throw Exception('Error requesting ride: $e');
    }
  }

  // Accept a ride (driver)
  static Future<Ride> acceptRide(String rideId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('$_apiBase/rides/$rideId/accept'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Ride.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to accept ride');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Reject a ride
  static Future<void> rejectRide(String rideId, {String? reason}) async {
    try {
      final token = await AuthService.getToken();
      await http.post(
        Uri.parse('$_apiBase/rides/$rideId/reject'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'reason': reason}),
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Start ride
  static Future<Ride> startRide(String rideId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('$_apiBase/rides/$rideId/start'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Ride.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to start ride');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Complete ride
  static Future<Ride> completeRide(String rideId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('$_apiBase/rides/$rideId/complete'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Ride.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to complete ride');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Cancel ride
  static Future<void> cancelRide(String rideId, {String? reason}) async {
    try {
      final token = await AuthService.getToken();
      await http.post(
        Uri.parse('$_apiBase/rides/$rideId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'reason': reason}),
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get ride details
  static Future<Ride> getRide(String rideId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$_apiBase/rides/$rideId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Ride.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Ride not found');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get user's rides
  static Future<List<Ride>> getUserRides({
    String role = 'rider',
    String? status,
  }) async {
    try {
      final token = await AuthService.getToken();
      final query = '?role=$role${status != null ? '&status=$status' : ''}';
      final response = await http.get(
        Uri.parse('$_apiBase/rides$query'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rides = (data['data'] as List)
            .map((r) => Ride.fromJson(r as Map<String, dynamic>))
            .toList();
        return rides;
      }
      return [];
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Rate a ride
  static Future<void> rateRide(
    String rideId, {
    required int rating,
    String? feedback,
  }) async {
    try {
      final token = await AuthService.getToken();
      await http.post(
        Uri.parse('$_apiBase/rides/$rideId/rate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'rating': rating,
          if (feedback != null) 'feedback': feedback,
        }),
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
