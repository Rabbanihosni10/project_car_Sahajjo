import 'package:http/http.dart' as http;
import 'package:cars_ahajjo/utils/constrains.dart';
import 'package:cars_ahajjo/services/auth_services.dart';
import 'dart:convert';

class MessageService {
  static const String _baseUrl = AppConstraints.baseUrl;
  static final AuthService _authService = AuthService();

  /// Get all conversations
  static Future<List<dynamic>> getConversations() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/messages/conversations'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        print('Error fetching conversations: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  /// Get chat history with specific user
  static Future<List<dynamic>> getChatHistory(String otherUserId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/messages/history/$otherUserId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        print('Error fetching chat history: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  /// Send a message
  static Future<bool> sendMessage(
    String receiverId,
    String message, {
    String messageType = 'text',
    String? fileUrl,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/messages/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'receiverId': receiverId,
          'message': message,
          'messageType': messageType,
          if (fileUrl != null) 'fileUrl': fileUrl,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Error sending message: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  /// Delete a message
  static Future<bool> deleteMessage(String messageId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$_baseUrl/messages/$messageId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error deleting message: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  /// Mark messages as read
  static Future<bool> markAsRead(String otherUserId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$_baseUrl/messages/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'otherUserId': otherUserId}),
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

  /// Get unread count
  static Future<int> getUnreadCount() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return 0;

      final response = await http.get(
        Uri.parse('$_baseUrl/messages/unread/count'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['unreadCount'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error: $e');
      return 0;
    }
  }
}
