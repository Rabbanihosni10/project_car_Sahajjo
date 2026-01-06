import 'package:flutter/material.dart';
import 'package:cars_ahajjo/services/message_service.dart';
import 'package:cars_ahajjo/screens/chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  List<dynamic> _allUsers = [];
  List<dynamic> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _fetchAllUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userId');
    });
  }

  Future<void> _fetchAllUsers() async {
    try {
      setState(() => _isLoading = true);

      // Try to fetch users from backend
      final users = await _getUsersFromBackend();

      // Filter out current user
      final filteredList = users.where((user) {
        return user['_id'] != _currentUserId;
      }).toList();

      setState(() {
        _allUsers = filteredList;
        _filteredUsers = filteredList;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      // Use mock users if backend is not available
      _useMockUsers();
    }
  }

  Future<List<dynamic>> _getUsersFromBackend() async {
    // This will call your backend API to get all users
    // You need to implement this endpoint in your backend
    // For now, we'll use a timeout to fall back to mock data

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('Not authenticated');
      }

      // TODO: Implement actual backend call
      // final response = await http.get(
      //   Uri.parse('http://YOUR_BACKEND_URL/api/users/all'),
      //   headers: {'Authorization': 'Bearer $token'},
      // ).timeout(const Duration(seconds: 5));

      // For now, throw to use mock data
      throw Exception('Backend endpoint not implemented yet');
    } catch (e) {
      rethrow;
    }
  }

  void _useMockUsers() {
    // Mock users for testing when backend is not available
    final mockUsers = [
      {
        '_id': 'user1',
        'name': 'John Driver',
        'email': 'john@example.com',
        'role': 'driver',
        'phone': '+8801712345678',
      },
      {
        '_id': 'user2',
        'name': 'Sarah Owner',
        'email': 'sarah@example.com',
        'role': 'owner',
        'phone': '+8801798765432',
      },
      {
        '_id': 'user3',
        'name': 'Mike Mechanic',
        'email': 'mike@example.com',
        'role': 'driver',
        'phone': '+8801756789012',
      },
      {
        '_id': 'user4',
        'name': 'Lisa Admin',
        'email': 'lisa@example.com',
        'role': 'admin',
        'phone': '+8801734567890',
      },
      {
        '_id': 'user5',
        'name': 'Tom Car Owner',
        'email': 'tom@example.com',
        'role': 'owner',
        'phone': '+8801723456789',
      },
    ];

    // Filter out current user from mock data
    final filteredMocks = mockUsers.where((user) {
      return user['_id'] != _currentUserId;
    }).toList();

    setState(() {
      _allUsers = filteredMocks;
      _filteredUsers = filteredMocks;
      _isLoading = false;
    });
  }

  void _filterUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredUsers = _allUsers;
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final name = (user['name'] ?? '').toString().toLowerCase();
        final email = (user['email'] ?? '').toString().toLowerCase();
        final role = (user['role'] ?? '').toString().toLowerCase();
        return name.contains(lowerQuery) ||
            email.contains(lowerQuery) ||
            role.contains(lowerQuery);
      }).toList();
    });
  }

  Future<void> _startChat(Map<String, dynamic> user) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Get or create conversation with this user
      final conversation = await MessageService.getOrCreateConversation(
        user['_id'],
      );

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (conversation != null) {
        // Navigate to chat screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(otherUser: user),
            ),
          );
        }
      } else {
        // Show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not start conversation. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error starting chat: $e');
      // Close loading dialog if still open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // For demo purposes, navigate anyway if backend is not available
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen(otherUser: user)),
        );
      }
    }
  }

  Color _getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'owner':
      case 'carowner':
      case 'car owner':
        return Colors.blue;
      case 'driver':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'owner':
      case 'carowner':
      case 'car owner':
        return Icons.directions_car;
      case 'driver':
        return Icons.drive_eta;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Users'),
        elevation: 0,
        backgroundColor: Colors.blue[600],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterUsers,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by name, email, or role...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          _filterUsers('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Users list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No users found'
                              : 'No matching users',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              _filterUsers('');
                            },
                            child: const Text('Clear search'),
                          ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchAllUsers,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return _buildUserCard(user);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final role = user['role']?.toString() ?? 'user';
    final roleColor = _getRoleColor(role);
    final roleIcon = _getRoleIcon(role);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: roleColor.withOpacity(0.2),
          child: Icon(roleIcon, color: roleColor, size: 28),
        ),
        title: Text(
          user['name'] ?? 'Unknown User',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user['email'] ?? 'No email',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: roleColor,
                    ),
                  ),
                ),
                if (user['phone'] != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    user['phone'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: ElevatedButton.icon(
          onPressed: () => _startChat(user),
          icon: const Icon(Icons.chat, size: 18),
          label: const Text('Chat'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
