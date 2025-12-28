import 'package:http/http.dart' as http;
import 'package:cars_ahajjo/services/auth_services.dart';
import 'dart:convert';

class RatingService {
  static const String _baseUrl = 'http://localhost:5003/api';

  /// Submit a rating
  static Future<bool> submitRating({
    required String ratedUserId,
    required int rating,
    String? review,
    Map<String, dynamic>? categories,
    String? rideId,
    bool isAnonymous = false,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/ratings/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'ratedUserId': ratedUserId,
          'rating': rating,
          if (review != null) 'review': review,
          if (categories != null) 'categories': categories,
          if (rideId != null) 'rideId': rideId,
          'isAnonymous': isAnonymous,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Error submitting rating: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  /// Get ratings for a user
  static Future<Map<String, dynamic>?> getUserRatings(
    String userId, {
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/ratings/user/$userId?limit=$limit&skip=$skip'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error fetching ratings: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Get rating summary
  static Future<Map<String, dynamic>?> getRatingSummary(String userId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/ratings/summary/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Update a rating
  static Future<bool> updateRating({
    required String ratingId,
    int? rating,
    String? review,
    Map<String, dynamic>? categories,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$_baseUrl/ratings/$ratingId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (rating != null) 'rating': rating,
          if (review != null) 'review': review,
          if (categories != null) 'categories': categories,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  /// Delete a rating
  static Future<bool> deleteRating(String ratingId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$_baseUrl/ratings/$ratingId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
