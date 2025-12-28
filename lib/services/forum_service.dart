import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cars_ahajjo/utils/constrains.dart';
import '../models/forum_post.dart';

class ForumService {
  static String get baseUrl => '${AppConstants.baseUrl}/forum';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Create post
  static Future<ForumPost?> createPost({
    required String title,
    required String content,
    required String category,
    List<String>? tags,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('No token found');
        return null;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'content': content,
          'category': category,
          'tags': tags ?? [],
        }),
      );

      print('Forum POST response status: ${response.statusCode}');
      print('Forum POST response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ForumPost.fromJson(data['data']);
      } else if (response.statusCode == 401) {
        print('Unauthorized: Token may be invalid');
        return null;
      } else if (response.statusCode == 500) {
        print('Server error: ${response.body}');
        return null;
      }
      return null;
    } catch (e) {
      print('Error creating post: $e');
      return null;
    }
  }

  // Get posts
  static Future<List<ForumPost>> getPosts({
    String? category,
    String? search,
    String sortBy = 'newest',
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/posts');
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;
      queryParams['sortBy'] = sortBy;

      uri = uri.replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((post) => ForumPost.fromJson(post))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }

  // Get post details with comments
  static Future<Map<String, dynamic>?> getPostDetails(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/$postId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'post': ForumPost.fromJson(data['data']['post']),
          'comments': (data['data']['comments'] as List)
              .map((c) => ForumComment.fromJson(c))
              .toList(),
          'commentCount': data['data']['commentCount'] ?? 0,
        };
      }
      return null;
    } catch (e) {
      print('Error fetching post details: $e');
      return null;
    }
  }

  // Add comment
  static Future<bool> addComment(String postId, String content) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/comments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'content': content}),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error adding comment: $e');
      return false;
    }
  }

  // Like post
  static Future<bool> likePost(String postId) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error liking post: $e');
      return false;
    }
  }

  // Like comment
  static Future<bool> likeComment(String commentId) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/comments/$commentId/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error liking comment: $e');
      return false;
    }
  }

  // Update post
  static Future<bool> updatePost({
    required String postId,
    String? title,
    String? content,
    String? category,
    List<String>? tags,
  }) async {
    try {
      final token = await _getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/posts/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (title != null) 'title': title,
          if (content != null) 'content': content,
          if (category != null) 'category': category,
          if (tags != null) 'tags': tags,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating post: $e');
      return false;
    }
  }

  // Delete post
  static Future<bool> deletePost(String postId) async {
    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/posts/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }
}
