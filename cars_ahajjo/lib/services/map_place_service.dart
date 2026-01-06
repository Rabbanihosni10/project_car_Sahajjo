import 'dart:convert';
import 'package:cars_ahajjo/services/auth_services.dart';
import 'package:cars_ahajjo/utils/constrains.dart';
import 'package:http/http.dart' as http;

class MapPlaceService {
  static String get _baseUrl => '${AppConstants.baseUrl}/map/places';

  static Future<List<dynamic>> getPlaces() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as List<dynamic>? ?? [];
      }

      return [];
    } catch (e) {
      print('Error fetching places: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> addPlace({
    required String name,
    required double latitude,
    required double longitude,
    String? address,
    String? description,
    String? category,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'latitude': latitude,
          'longitude': longitude,
          if (address != null) 'address': address,
          if (description != null) 'description': description,
          if (category != null) 'category': category,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>?;
      }

      print('Failed to add place: ${response.body}');
      return null;
    } catch (e) {
      print('Error adding place: $e');
      return null;
    }
  }

  static Future<bool> deletePlace(String placeId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$_baseUrl/$placeId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting place: $e');
      return false;
    }
  }
}
