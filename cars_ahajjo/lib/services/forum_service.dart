import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cars_ahajjo/utils/constrains.dart';
import '../models/forum_post.dart';
import 'local_forum_database.dart';
import 'dart:math';
import 'auth_services.dart';
import 'dart:io';

class ForumService {
  static String get baseUrl => '${AppConstants.baseUrl}/forum';
  static final _localDb = LocalForumDatabase();

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> _getCurrentUserId() async {
    // Try to read from AuthService userData
    final userData = await AuthService.getUserData();
    return userData?['_id'] as String?;
  }

  static Future<String?> _getCurrentUserName() async {
    final userData = await AuthService.getUserData();
    return (userData?['name'] as String?) ??
        (userData?['fullName'] as String?) ??
        (userData?['username'] as String?);
  }

  // Create post - only allowed for driver and owner roles
  static Future<ForumPost?> createPost({
    required String title,
    required String content,
    required String category,
    List<String>? tags,
    List<File>? images,
  }) async {
    try {
      // Require authentication
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        print('Posting denied: not authenticated');
        return null;
      }

      // Validate role (only driver/owner allowed)
      final role = await AuthService.getUserRole();
      final allowedRoles = {'driver', 'owner', 'carOwner'};
      if (role == null || !allowedRoles.contains(role)) {
        print('Posting denied: role $role not permitted');
        return null;
      }

      // Get user info
      final authorId =
          await _getCurrentUserId() ?? 'unknown_${Random().nextInt(100000)}';
      final authorName = await _getCurrentUserName() ?? 'Unknown';

      // Create unique ID
      final postId =
          'post_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
      final now = DateTime.now();

      // Upload images if provided
      List<String> uploadedImageUrls = [];
      if (images != null && images.isNotEmpty) {
        print('Uploading ${images.length} images...');
        uploadedImageUrls = await _uploadImages(images);
        print('Images uploaded: $uploadedImageUrls');
      }

      // Create ForumPost object with uploaded image URLs
      final newPost = ForumPost(
        id: postId,
        authorId: authorId,
        authorName: authorName,
        authorAvatar: null,
        title: title,
        content: content,
        category: category,
        tags: tags ?? [],
        images: uploadedImageUrls,
        likeCount: 0,
        views: 0,
        isPinned: false,
        isSolved: false,
        isLikedByMe: false,
        status: 'published',
        createdAt: now,
        updatedAt: now,
      );

      // Save to local database immediately
      await _localDb.insertPost(newPost);
      print('Post saved locally with ID: ${newPost.id}');

      // Try to sync with server in background
      _syncPostWithServer(newPost, token);

      return newPost;
    } catch (e) {
      print('Error creating post: $e');
      return null;
    }
  }

  // Upload images and return their URLs
  static Future<List<String>> _uploadImages(List<File> images) async {
    final token = await _getToken();
    if (token == null) return [];

    List<String> uploadedUrls = [];

    for (final imageFile in images) {
      try {
        // Create multipart request
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/upload-image'),
        );

        request.headers['Authorization'] = 'Bearer $token';
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);
          final imageUrl = data['data']?['url'] ?? data['url'];
          if (imageUrl != null) {
            uploadedUrls.add(imageUrl);
            print('Image uploaded: $imageUrl');
          }
        } else {
          print('Error uploading image: ${response.body}');
          // Fallback: use base64 encoding for local storage
          final base64Image = base64Encode(imageFile.readAsBytesSync());
          uploadedUrls.add('data:image/jpeg;base64,$base64Image');
        }
      } catch (e) {
        print('Error uploading image: $e');
        // Fallback to base64
        try {
          final base64Image = base64Encode(imageFile.readAsBytesSync());
          uploadedUrls.add('data:image/jpeg;base64,$base64Image');
        } catch (_) {
          // Skip this image if all fails
        }
      }
    }

    return uploadedUrls;
  }

  // Sync post with server in background
  static Future<void> _syncPostWithServer(ForumPost post, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': post.title,
          'content': post.content,
          'category': post.category,
          'tags': post.tags,
        }),
      );

      if (response.statusCode == 201) {
        await _localDb.markPostAsSynced(post.id);
        print('Post synced with server');
      }
    } catch (e) {
      print('Error syncing post with server: $e');
    }
  }

  // Get posts from both local database and API
  static Future<List<ForumPost>> getPosts({
    String? category,
    String? search,
    String sortBy = 'newest',
    bool includeLocal = true,
  }) async {
    try {
      List<ForumPost> allPosts = [];

      // Get posts from local database
      if (includeLocal) {
        final localPosts = await _localDb.getAllPosts(category: category);
        allPosts.addAll(localPosts);
      }

      // Try to get from API
      try {
        var uri = Uri.parse('$baseUrl/posts');
        final queryParams = <String, String>{};
        if (category != null && category.isNotEmpty) {
          queryParams['category'] = category;
        }
        if (search != null) queryParams['search'] = search;
        queryParams['sortBy'] = sortBy;

        uri = uri.replace(queryParameters: queryParams);

        final response = await http
            .get(uri, headers: {'Content-Type': 'application/json'})
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final apiPosts = (data['data'] as List)
              .map((post) => ForumPost.fromJson(post))
              .toList();

          // Add API posts and update local database
          for (var post in apiPosts) {
            // Check if post already exists in local database
            final existingPost = await _localDb.getPost(post.id);
            if (existingPost == null) {
              await _localDb.insertPost(post);
            } else {
              // Update existing post with server data
              await _localDb.updatePost(post);
            }
          }

          // Return combined list, removing duplicates and sorting by date
          allPosts.addAll(apiPosts);
        }
      } catch (e) {
        print('Error fetching from API: $e');
        // Fallback to local database
      }

      // Remove duplicates and sort
      final seen = <String>{};
      final uniquePosts = <ForumPost>[];
      for (var post in allPosts) {
        if (!seen.contains(post.id)) {
          seen.add(post.id);
          uniquePosts.add(post);
        }
      }

      // Sort by date (newest first)
      uniquePosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return uniquePosts;
    } catch (e) {
      print('Error fetching posts: $e');
      // Return local posts as fallback
      return await _localDb.getAllPosts(category: category);
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
