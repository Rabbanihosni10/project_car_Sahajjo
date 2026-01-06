import 'package:http/http.dart' as http;
import 'package:cars_ahajjo/services/auth_services.dart';
import 'package:cars_ahajjo/utils/constrains.dart';
import 'dart:convert';

class AdminService {
  static String get _baseUrl => AppConstants.baseUrl;

  /// Get dashboard statistics
  static Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/dashboard/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        print('Error fetching dashboard stats: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Get all users with filters
  static Future<Map<String, dynamic>?> getAllUsers({
    String? role,
    String? status,
    String? search,
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      String query = '?limit=$limit&skip=$skip';
      if (role != null) query += '&role=$role';
      if (status != null) query += '&status=$status';
      if (search != null) query += '&search=$search';

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/users$query'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error fetching users: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Get user details
  static Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/users/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        print('Error fetching user details: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Ban/Unban a user
  static Future<bool> toggleUserBan(String userId, bool isBanned) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$_baseUrl/admin/users/$userId/ban'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'isBanned': isBanned}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error banning user: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  /// Deactivate a user
  static Future<bool> deactivateUser(String userId, String reason) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$_baseUrl/admin/users/$userId/deactivate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'reason': reason}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error deactivating user: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  /// Get all transactions with filters
  static Future<Map<String, dynamic>?> getTransactions({
    String? status,
    String? startDate,
    String? endDate,
    int limit = 15,
    int skip = 0,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      String query = '?limit=$limit&skip=$skip';
      if (status != null) query += '&status=$status';
      if (startDate != null) query += '&startDate=$startDate';
      if (endDate != null) query += '&endDate=$endDate';

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/transactions$query'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error fetching transactions: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Get revenue statistics
  static Future<List<dynamic>?> getRevenueStats({
    String period = 'monthly',
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/revenue/stats?period=$period'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        print('Error fetching revenue stats: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Get all ratings with filters
  static Future<Map<String, dynamic>?> getRatings({
    int? minRating,
    String? userId,
    int limit = 15,
    int skip = 0,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      String query = '?limit=$limit&skip=$skip';
      if (minRating != null) query += '&minRating=$minRating';
      if (userId != null) query += '&userId=$userId';

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/ratings$query'),
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

  /// Flag/Unflag a rating
  static Future<bool> toggleRatingFlag(String ratingId, bool isFlagged) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$_baseUrl/admin/ratings/$ratingId/flag'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'isFlagged': isFlagged}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error flagging rating: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  /// Get system logs
  static Future<Map<String, dynamic>?> getSystemLogs({
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/logs?limit=$limit&skip=$skip'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        print('Error fetching logs: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Send announcement
  static Future<bool> sendAnnouncement({
    required String title,
    required String message,
    String? targetRole,
    List<String>? recipientIds,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/admin/announcements'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'message': message,
          if (targetRole != null) 'targetRole': targetRole,
          if (recipientIds != null) 'recipientIds': recipientIds,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error sending announcement: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  /// Get health check status
  static Future<Map<String, dynamic>?> getHealthCheck() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/admin/health'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        print('Error fetching health check: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Get all user requests (profile updates and deletions)
  static Future<Map<String, dynamic>?> getUserRequests({
    String? type, // 'update', 'delete', or null for all
    String? status, // 'pending', 'approved', 'rejected'
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      String query = '?limit=$limit&skip=$skip';
      if (type != null) query += '&type=$type';
      if (status != null) query += '&status=$status';

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/user-requests$query'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error fetching user requests: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Approve/Reject profile update request
  static Future<bool> handleProfileUpdateRequest({
    required String requestId,
    required bool approve,
    String? adminNotes,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$_baseUrl/admin/user-requests/$requestId/profile-update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'approve': approve,
          if (adminNotes != null) 'adminNotes': adminNotes,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error handling profile update request: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  /// Approve/Reject account deletion request
  static Future<bool> handleAccountDeletionRequest({
    required String requestId,
    required bool approve,
    String? adminNotes,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$_baseUrl/admin/user-requests/$requestId/account-deletion'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'approve': approve,
          if (adminNotes != null) 'adminNotes': adminNotes,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error handling account deletion request: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
