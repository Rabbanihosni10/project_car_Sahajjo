import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cars_ahajjo/utils/constrains.dart';
import 'package:cars_ahajjo/services/auth_services.dart';

class UserService {
  static String get _baseUrl => '${AppConstants.baseUrl}/users';

  /// Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? avatar,
    String? licenseNumber,
    String? vehicleType,
    String? companyName,
    String? businessType,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (avatar != null) body['avatar'] = avatar;
      if (licenseNumber != null) body['licenseNumber'] = licenseNumber;
      if (vehicleType != null) body['vehicleType'] = vehicleType;
      if (companyName != null) body['companyName'] = companyName;
      if (businessType != null) body['businessType'] = businessType;

      final response = await http.put(
        Uri.parse('$_baseUrl/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      print('Error updating profile: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Request profile update (requires admin approval)
  static Future<Map<String, dynamic>> requestProfileUpdate({
    required String userId,
    required Map<String, dynamic> changes,
    String? reason,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/$userId/update-request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'changes': changes,
          'reason': reason ?? 'User requested profile update',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Profile update request submitted successfully',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to submit request',
        };
      }
    } catch (e) {
      print('Error requesting profile update: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Request account deletion
  static Future<Map<String, dynamic>> requestAccountDeletion({
    required String userId,
    String? reason,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/$userId/delete-request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'reason': reason ?? 'User requested account deletion',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message':
              'Account deletion request submitted. Admin will review your request.',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to submit request',
        };
      }
    } catch (e) {
      print('Error requesting account deletion: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Get user profile
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        print('Error fetching user profile: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
