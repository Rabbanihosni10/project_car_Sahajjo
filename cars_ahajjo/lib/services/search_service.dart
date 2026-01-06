import 'package:http/http.dart' as http;
import 'package:cars_ahajjo/services/auth_services.dart';
import 'package:cars_ahajjo/utils/constrains.dart';
import 'dart:convert';

class SearchService {
  static String get _baseUrl => AppConstants.baseUrl;

  /// Search drivers by name, email, or phone
  static Future<List<dynamic>> searchDrivers(
    String query, {
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/search/drivers?query=$query&limit=$limit&skip=$skip',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        print('Error searching drivers: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  /// Filter drivers by experience, vehicle type, or rating
  static Future<List<dynamic>> filterDrivers({
    String? yearsOfExperience,
    String? vehicleType,
    double? minRating,
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      String url = '$_baseUrl/search/drivers/filter?limit=$limit&skip=$skip';
      if (yearsOfExperience != null) {
        url += '&yearsOfExperience=$yearsOfExperience';
      }
      if (vehicleType != null) {
        url += '&vehicleType=$vehicleType';
      }
      if (minRating != null) {
        url += '&minRating=$minRating';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  /// Search car owners
  static Future<List<dynamic>> searchOwners(
    String query, {
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/search/owners?query=$query&limit=$limit&skip=$skip',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  /// Search garages
  static Future<List<dynamic>> searchGarages(
    String query, {
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/search/garages?query=$query&limit=$limit&skip=$skip',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  /// Filter garages by services
  static Future<List<dynamic>> filterGarages({
    List<String>? services,
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      String url = '$_baseUrl/search/garages/filter?limit=$limit&skip=$skip';
      if (services != null && services.isNotEmpty) {
        url += '&services=${services.join(',')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}
