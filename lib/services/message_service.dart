import 'package:http/http.dart' as http;
import 'package:cars_ahajjo/services/auth_services.dart';
import 'package:cars_ahajjo/services/socket_service.dart';
import 'package:cars_ahajjo/utils/constrains.dart';
import 'dart:convert';

class MessageService {
  static final SocketService _socketService = SocketService();

  static String get _baseUrl => '${AppConstants.baseUrl}/messages';

  /// Get or create a conversation with a user
  static Future<Map<String, dynamic>?> getOrCreateConversation(
    String otherUserId,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('$_baseUrl/conversations/get-or-create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'otherUserId': otherUserId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else {
        print('Error getting/creating conversation: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Get all conversations
  static Future<List<dynamic>> getConversations() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/conversations'),
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
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/history/$otherUserId'),
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
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/send'),
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
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$_baseUrl/$messageId'),
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
      final token = await AuthService.getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$_baseUrl/read'),
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
      final token = await AuthService.getToken();
      if (token == null) return 0;

      final response = await http.get(
        Uri.parse('$_baseUrl/unread/count'),
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

  /// Initialize Socket.io for real-time messaging
  static void initializeSocket() {
    _socketService.initialize();
    _socketService.connect();
  }

  /// Send a message in real-time via Socket.io
  static void sendChatMessageRealtime(
    String senderId,
    String receiverId,
    String message,
    String conversationId,
  ) {
    _socketService.sendChatMessage(
      senderId,
      receiverId,
      message,
      conversationId,
    );
  }

  /// Listen for incoming messages in real-time
  static void onMessageReceived(Function(Map<String, dynamic>) callback) {
    _socketService.on('message_received', callback);
  }

  /// Join a conversation for real-time updates
  static void joinConversation(String conversationId) {
    _socketService.joinConversation(conversationId);
  }

  /// Leave a conversation
  static void leaveConversation(String conversationId) {
    _socketService.leaveConversation(conversationId);
  }

  /// Notify others that you're typing
  static void notifyTyping(String conversationId, String userId) {
    _socketService.notifyTyping(conversationId, userId);
  }

  /// Notify others that you stopped typing
  static void notifyStopTyping(String conversationId, String userId) {
    _socketService.notifyStopTyping(conversationId, userId);
  }

  /// Listen for typing indicators
  static void onUserTyping(Function(Map<String, dynamic>) callback) {
    _socketService.on('user_typing', callback);
  }

  /// Disconnect socket when done
  static void disconnectSocket() {
    _socketService.disconnect();
  }
}
