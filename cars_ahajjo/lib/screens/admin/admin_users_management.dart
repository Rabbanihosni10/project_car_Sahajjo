import 'package:flutter/material.dart';

class AdminUsersManagement extends StatefulWidget {
  const AdminUsersManagement({super.key});

  @override
  State<AdminUsersManagement> createState() => _AdminUsersManagementState();
}

class _AdminUsersManagementState extends State<AdminUsersManagement> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'all';

  final List<Map<String, String>> _users = [
    {
      'id': '1',
      'name': 'Ahmed Hassan',
      'email': 'ahmed@example.com',
      'phone': '+880 1234567890',
      'role': 'Driver',
      'status': 'Active',
      'joinDate': '2024-01-15',
    },
    {
      'id': '2',
      'name': 'Sarah Khan',
      'email': 'sarah@example.com',
      'phone': '+880 9876543210',
      'role': 'Visitor',
      'status': 'Active',
      'joinDate': '2024-02-20',
    },
    {
      'id': '3',
      'name': 'Fatima Ali',
      'email': 'fatima@example.com',
      'phone': '+880 5555555555',
      'role': 'Car Owner',
      'status': 'Suspended',
      'joinDate': '2024-03-10',
    },
    {
      'id': '4',
      'name': 'Hassan Ibrahim',
      'email': 'hassan@example.com',
      'phone': '+880 4444444444',
      'role': 'Driver',
      'status': 'Active',
      'joinDate': '2024-01-25',
    },
    {
      'id': '5',
      'name': 'Zara Khan',
      'email': 'zara@example.com',
      'phone': '+880 3333333333',
      'role': 'Visitor',
      'status': 'Inactive',
      'joinDate': '2024-04-05',
    },
  ];

  List<Map<String, String>> get _filteredUsers {
    List<Map<String, String>> filtered = _users;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where(
            (user) =>
                user['name']!.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                user['email']!.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ),
          )
          .toList();
    }

    // Apply role/status filter
    if (_selectedFilter != 'all') {
      filtered = filtered
          .where(
            (user) =>
                user['role']?.toLowerCase() == _selectedFilter.toLowerCase() ||
                user['status']?.toLowerCase() == _selectedFilter.toLowerCase(),
          )
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'User Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Add User',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search and Filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search users by name or email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  underline: const SizedBox(),
                  onChanged: (value) {
                    setState(() => _selectedFilter = value ?? 'all');
                  },
                  items: [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('All Users'),
                    ),
                    const DropdownMenuItem(
                      value: 'Driver',
                      child: Text('Drivers'),
                    ),
                    const DropdownMenuItem(
                      value: 'Visitor',
                      child: Text('Visitors'),
                    ),
                    const DropdownMenuItem(
                      value: 'Car Owner',
                      child: Text('Car Owners'),
                    ),
                    const DropdownMenuItem(
                      value: 'Active',
                      child: Text('Active'),
                    ),
                    const DropdownMenuItem(
                      value: 'Suspended',
                      child: Text('Suspended'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Users Table
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFEEEEEE)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: _buildHeaderCell('Name')),
                      Expanded(flex: 2, child: _buildHeaderCell('Email')),
                      Expanded(flex: 1, child: _buildHeaderCell('Role')),
                      Expanded(flex: 1, child: _buildHeaderCell('Status')),
                      Expanded(flex: 1, child: _buildHeaderCell('Actions')),
                    ],
                  ),
                ),
                // Table Rows
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredUsers.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  user['phone']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              user['email']!,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getRoleColor(
                                  user['role']!,
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                user['role']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _getRoleColor(user['role']!),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  user['status']!,
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                user['status']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _getStatusColor(user['status']!),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.visibility,
                                        size: 16,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(width: 8),
                                      Text('View'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.block,
                                        size: 16,
                                        color: Color(0xFFD32F2F),
                                      ),
                                      SizedBox(width: 8),
                                      Text('Suspend'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Total: ${_filteredUsers.length} user${_filteredUsers.length != 1 ? 's' : ''}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: Colors.black87,
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Driver':
        return Colors.green;
      case 'Car Owner':
        return Colors.orange;
      case 'Visitor':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Suspended':
        return Colors.red;
      case 'Inactive':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
