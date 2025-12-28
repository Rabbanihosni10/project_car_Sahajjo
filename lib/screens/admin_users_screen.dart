import 'package:flutter/material.dart';
import 'package:cars_ahajjo/services/admin_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<dynamic> users = [];
  bool _isLoading = true;
  String _selectedRole = '';
  String _selectedStatus = '';
  int _currentPage = 0;
  int _totalPages = 1;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final result = await AdminService.getAllUsers(
        role: _selectedRole.isEmpty ? null : _selectedRole,
        status: _selectedStatus.isEmpty ? null : _selectedStatus,
        search: _searchController.text.isEmpty ? null : _searchController.text,
        limit: 20,
        skip: _currentPage * 20,
      );

      setState(() {
        users = result?['data'] ?? [];
        _totalPages = result?['pages'] ?? 1;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[600],
        title: const Text('Manage Users'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and Filters
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          _currentPage = 0;
                          _loadUsers();
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by name, email, or phone...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedRole.isEmpty
                                  ? null
                                  : _selectedRole,
                              decoration: InputDecoration(
                                labelText: 'Role',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'driver',
                                  child: Text('Driver'),
                                ),
                                DropdownMenuItem(
                                  value: 'owner',
                                  child: Text('Car Owner'),
                                ),
                                DropdownMenuItem(
                                  value: 'visitor',
                                  child: Text('Visitor'),
                                ),
                                DropdownMenuItem(
                                  value: 'garage',
                                  child: Text('Garage'),
                                ),
                              ],
                              onChanged: (value) {
                                _currentPage = 0;
                                setState(() => _selectedRole = value ?? '');
                                _loadUsers();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedStatus.isEmpty
                                  ? null
                                  : _selectedStatus,
                              decoration: InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'active',
                                  child: Text('Active'),
                                ),
                                DropdownMenuItem(
                                  value: 'inactive',
                                  child: Text('Inactive'),
                                ),
                              ],
                              onChanged: (value) {
                                _currentPage = 0;
                                setState(() => _selectedStatus = value ?? '');
                                _loadUsers();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Users List
                Expanded(
                  child: users.isEmpty
                      ? Center(
                          child: Text(
                            'No users found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return _buildUserCard(user);
                          },
                        ),
                ),
                // Pagination
                if (_totalPages > 1)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _currentPage > 0
                              ? () {
                                  _currentPage--;
                                  _loadUsers();
                                }
                              : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                        ),
                        Text(
                          'Page ${_currentPage + 1}/$_totalPages',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: _currentPage < _totalPages - 1
                              ? () {
                                  _currentPage++;
                                  _loadUsers();
                                }
                              : null,
                          label: const Text('Next'),
                          icon: const Icon(Icons.arrow_forward),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isBanned = user['isBanned'] ?? false;
    final isActive = user['isActive'] ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.deepPurple[600],
              child: Text(
                user['name']?[0]?.toUpperCase() ?? 'U',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user['email'] ?? 'No email',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (isBanned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'BANNED',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            if (!isActive && !isBanned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'INACTIVE',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Role', user['role']?.toUpperCase() ?? 'N/A'),
                _buildDetailRow('Phone', user['phone'] ?? 'N/A'),
                _buildDetailRow(
                  'Joined',
                  user['createdAt'] != null
                      ? DateTime.parse(
                          user['createdAt'],
                        ).toString().split('.')[0]
                      : 'N/A',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showUserDetails(user),
                        icon: const Icon(Icons.visibility),
                        label: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _toggleBan(user),
                        icon: Icon(isBanned ? Icons.lock_open : Icons.lock),
                        label: Text(isBanned ? 'Unban' : 'Ban'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isBanned
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _deactivateUser(user),
                        icon: const Icon(Icons.close),
                        label: const Text('Deactivate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                        ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  void _toggleBan(Map<String, dynamic> user) async {
    final isBanned = user['isBanned'] ?? false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isBanned ? 'Unban User?' : 'Ban User?'),
        content: Text(
          isBanned
              ? 'This user will be able to access the platform again.'
              : 'This user will be blocked from accessing the platform.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(isBanned ? 'Unban' : 'Ban'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await AdminService.toggleUserBan(user['_id'], !isBanned);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User ${isBanned ? 'unbanned' : 'banned'} successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers();
      }
    }
  }

  void _deactivateUser(Map<String, dynamic> user) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to deactivate this user?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Reason (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await AdminService.deactivateUser(
        user['_id'],
        reasonController.text,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deactivated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers();
      }
    }
  }

  void _showUserDetails(Map<String, dynamic> user) async {
    final details = await AdminService.getUserDetails(user['_id']);
    if (details != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('User Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Name', details['user']?['name'] ?? 'N/A'),
                _buildDetailRow('Email', details['user']?['email'] ?? 'N/A'),
                _buildDetailRow('Phone', details['user']?['phone'] ?? 'N/A'),
                _buildDetailRow(
                  'Role',
                  details['user']?['role']?.toUpperCase() ?? 'N/A',
                ),
                _buildDetailRow(
                  'Avg Rating',
                  details['avgRating']?.toStringAsFixed(2) ?? 'N/A',
                ),
                _buildDetailRow(
                  'Rating Count',
                  details['ratingCount']?.toString() ?? '0',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
