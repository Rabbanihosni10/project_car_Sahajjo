import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cars_ahajjo/services/auth_services.dart';
import 'package:cars_ahajjo/utils/constrains.dart';
import 'package:cars_ahajjo/services/message_service.dart';

// Models
class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isVerified;
  final UserProfile? profile;
  final String connectionStatus;
  final bool isFollowing;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isVerified,
    this.profile,
    required this.connectionStatus,
    required this.isFollowing,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'visitor',
      isVerified: json['isVerified'] ?? false,
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'])
          : null,
      connectionStatus: json['connectionStatus'] ?? 'not_connected',
      isFollowing: json['isFollowing'] ?? false,
    );
  }
}

class UserProfile {
  final String bio;
  final String? avatar;
  final String? coverImage;
  final String? location;
  final String? profession;
  final String? website;
  final List<String> interests;
  final int followerCount;
  final int followingCount;
  final int friendCount;
  final double averageRating;
  final bool isProfilePublic;
  final bool allowDirectMessages;
  final bool isVerifiedDriver;
  final bool isVerifiedOwner;

  UserProfile({
    required this.bio,
    this.avatar,
    this.coverImage,
    this.location,
    this.profession,
    this.website,
    required this.interests,
    required this.followerCount,
    required this.followingCount,
    required this.friendCount,
    required this.averageRating,
    required this.isProfilePublic,
    required this.allowDirectMessages,
    required this.isVerifiedDriver,
    required this.isVerifiedOwner,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      bio: json['bio'] ?? '',
      avatar: json['avatar'],
      coverImage: json['coverImage'],
      location: json['location'],
      profession: json['profession'],
      website: json['website'],
      interests: List<String>.from(json['interests'] ?? []),
      followerCount: json['followerCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      friendCount: json['friendCount'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      isProfilePublic: json['isProfilePublic'] ?? true,
      allowDirectMessages: json['allowDirectMessages'] ?? true,
      isVerifiedDriver: json['isVerifiedDriver'] ?? false,
      isVerifiedOwner: json['isVerifiedOwner'] ?? false,
    );
  }
}

class Connection {
  final String id;
  final String status;
  final String connectionType;
  final bool isFollowing;
  final DateTime requestedAt;
  final DateTime? acceptedAt;

  Connection({
    required this.id,
    required this.status,
    required this.connectionType,
    required this.isFollowing,
    required this.requestedAt,
    this.acceptedAt,
  });

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['_id'] ?? '',
      status: json['status'] ?? 'pending',
      connectionType: json['connectionType'] ?? 'friend',
      isFollowing: json['isFollowing'] ?? false,
      requestedAt: DateTime.parse(
        json['requestedAt'] ?? DateTime.now().toIso8601String(),
      ),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'])
          : null,
    );
  }
}

// API Service
class PeopleService {
  static String get _baseUrl => '${AppConstants.baseUrl}/people';

  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  // Discover people
  static Future<List<User>> discoverPeople({
    int page = 1,
    int limit = 10,
    String? searchQuery,
  }) async {
    try {
      String url = '$_baseUrl/discover?page=$page&limit=$limit';
      if (searchQuery != null && searchQuery.isNotEmpty) {
        url += '&searchQuery=$searchQuery';
      }

      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((user) => User.fromJson(user)).toList();
      } else {
        throw Exception('Failed to discover people');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile
  static Future<User> getUserProfile(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/profile/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return User.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to get user profile');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Send connection request
  static Future<Connection> sendConnectionRequest(
    String recipientId, {
    String connectionType = 'friend',
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/connect'),
        headers: headers,
        body: json.encode({
          'recipientId': recipientId,
          'connectionType': connectionType,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Connection.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to send connection request');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Accept connection request
  static Future<Connection> acceptConnectionRequest(String connectionId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/accept-connection'),
        headers: headers,
        body: json.encode({'connectionId': connectionId}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Connection.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to accept connection request');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Toggle follow
  static Future<bool> toggleFollow(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/follow'),
        headers: headers,
        body: json.encode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['data']['isFollowing'] ?? false;
      } else {
        throw Exception('Failed to toggle follow');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get friends
  static Future<List<User>> getFriends(
    String userId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/friends/$userId?page=$page&limit=$limit'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((user) => User.fromJson(user)).toList();
      } else {
        throw Exception('Failed to get friends');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get followers
  static Future<List<User>> getFollowers(
    String userId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/followers/$userId?page=$page&limit=$limit'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((user) => User.fromJson(user)).toList();
      } else {
        throw Exception('Failed to get followers');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Block user
  static Future<void> blockUser(String userId, {String reason = ''}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/block'),
        headers: headers,
        body: json.encode({'userId': userId, 'reason': reason}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to block user');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update profile
  static Future<void> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/profile'),
        headers: headers,
        body: json.encode(profileData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      rethrow;
    }
  }
}

// UI Widgets

// 1. User Card Widget
class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onConnect;
  final VoidCallback onMessage;

  const UserCard({
    super.key,
    required this.user,
    required this.onConnect,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Avatar
          Container(
            height: 150,
            width: double.infinity,
            color: Colors.grey[300],
            child: user.profile?.avatar != null
                ? Image.network(
                    user.profile!.avatar!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, size: 80),
                  )
                : const Icon(Icons.person, size: 80),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name with verification badges
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (user.profile?.profession != null)
                            Text(
                              user.profile!.profession!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (user.profile?.isVerifiedDriver ?? false)
                      const Tooltip(
                        message: 'Verified Driver',
                        child: Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                    if (user.profile?.isVerifiedOwner ?? false)
                      const Tooltip(
                        message: 'Verified Owner',
                        child: Icon(
                          Icons.verified_user,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Bio
                if (user.profile?.bio != null)
                  Text(
                    user.profile!.bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                const SizedBox(height: 8),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${user.profile?.followerCount ?? 0}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text('Followers', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${user.profile?.friendCount ?? 0}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text('Friends', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${user.profile?.averageRating ?? 0}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text('Rating', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onConnect,
                        child: const Text('Connect'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onMessage,
                        child: const Text('Message'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 2. User Profile Screen
class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<User> _userFuture;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _userFuture = PeopleService.getUserProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Cover image
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: user.profile?.coverImage != null
                      ? Image.network(
                          user.profile!.coverImage!,
                          fit: BoxFit.cover,
                        )
                      : Container(),
                ),
                // Profile header
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: user.profile?.avatar != null
                                ? NetworkImage(user.profile!.avatar!)
                                : null,
                            child: user.profile?.avatar == null
                                ? Icon(Icons.person, size: 50)
                                : null,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        user.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  user.profile?.profession ?? 'No profession',
                                ),
                                if (user.profile?.location != null)
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, size: 14),
                                      SizedBox(width: 4),
                                      Text(user.profile!.location!),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn(
                            'Followers',
                            user.profile?.followerCount ?? 0,
                          ),
                          _buildStatColumn(
                            'Following',
                            user.profile?.followingCount ?? 0,
                          ),
                          _buildStatColumn(
                            'Friends',
                            user.profile?.friendCount ?? 0,
                          ),
                          _buildStatColumn(
                            'Rating',
                            user.profile?.averageRating ?? 0,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle connect
                              },
                              child: Text('Connect'),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                // Handle message
                              },
                              child: Text('Message'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Bio
                      if (user.profile?.bio != null &&
                          user.profile!.bio.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(user.profile!.bio),
                            SizedBox(height: 16),
                          ],
                        ),
                      // Interests
                      if (user.profile?.interests != null &&
                          user.profile!.interests.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Interests',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: user.profile!.interests
                                  .map(
                                    (interest) => Chip(label: Text(interest)),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String label, dynamic value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// 3. People Discovery Screen
class PeopleDiscoveryScreen extends StatefulWidget {
  const PeopleDiscoveryScreen({super.key});

  @override
  State<PeopleDiscoveryScreen> createState() => _PeopleDiscoveryScreenState();
}

class _PeopleDiscoveryScreenState extends State<PeopleDiscoveryScreen> {
  List<User> _users = [];
  int _currentPage = 1;
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPeople();
  }

  Future<void> _loadPeople() async {
    setState(() => _isLoading = true);
    try {
      final users = await PeopleService.discoverPeople(
        page: _currentPage,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _handleConnect(User user) async {
    try {
      await PeopleService.sendConnectionRequest(user.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection request sent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to connect: $e')));
      }
    }
  }

  Future<void> _handleMessage(User user) async {
    try {
      final conversation = await MessageService.getOrCreateConversation(
        user.id,
      );
      if (conversation != null && mounted) {
        Navigator.pushNamed(context, '/messages');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to start chat: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover People')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: (value) {
                _searchQuery = value;
                _currentPage = 1;
                _loadPeople();
              },
              decoration: InputDecoration(
                hintText: 'Search people...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          // People list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                ? const Center(child: Text('No people found'))
                : ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return UserCard(
                        user: user,
                        onConnect: () => _handleConnect(user),
                        onMessage: () => _handleMessage(user),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
