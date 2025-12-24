import 'package:flutter/material.dart';

class AdminOwnersManagement extends StatefulWidget {
  const AdminOwnersManagement({super.key});

  @override
  State<AdminOwnersManagement> createState() => _AdminOwnersManagementState();
}

class _AdminOwnersManagementState extends State<AdminOwnersManagement> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'all';

  final List<Map<String, String>> _owners = [
    {
      'id': '1',
      'company': 'Global Taxi Service',
      'contact': 'Muhammad Hasan',
      'email': 'contact@globaltaxi.com',
      'businessType': 'Taxi Service',
      'fleet': '45 cars',
      'status': 'Verified',
      'rating': '4.7',
      'joinDate': '2024-01-20',
    },
    {
      'id': '2',
      'company': 'Elite Ride Sharing',
      'contact': 'Fatima Khan',
      'email': 'info@eliteride.com',
      'businessType': 'Ride Sharing',
      'fleet': '32 cars',
      'status': 'Pending',
      'rating': '4.4',
      'joinDate': '2024-02-15',
    },
    {
      'id': '3',
      'company': 'Premium Car Rentals',
      'contact': 'Tariq Ahmed',
      'email': 'admin@premiumrentals.com',
      'businessType': 'Car Rental',
      'fleet': '78 cars',
      'status': 'Verified',
      'rating': '4.6',
      'joinDate': '2024-01-10',
    },
    {
      'id': '4',
      'company': 'City Tours Transport',
      'contact': 'Zara Hassan',
      'email': 'bookings@citytours.com',
      'businessType': 'Tourist Service',
      'fleet': '15 cars',
      'status': 'Suspended',
      'rating': '2.8',
      'joinDate': '2024-03-05',
    },
  ];

  List<Map<String, String>> get _filteredOwners {
    List<Map<String, String>> filtered = _owners;

    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where(
            (owner) =>
                owner['company']!.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                owner['contact']!.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ),
          )
          .toList();
    }

    if (_selectedFilter != 'all') {
      if (_selectedFilter == 'Verified' ||
          _selectedFilter == 'Pending' ||
          _selectedFilter == 'Suspended') {
        filtered = filtered
            .where(
              (owner) =>
                  owner['status']?.toLowerCase() ==
                  _selectedFilter.toLowerCase(),
            )
            .toList();
      } else {
        filtered = filtered
            .where(
              (owner) =>
                  owner['businessType']?.toLowerCase() ==
                  _selectedFilter.toLowerCase(),
            )
            .toList();
      }
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
                'Car Owner Management',
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
                      'Add Owner',
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
                    hintText: 'Search by company or contact name...',
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
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Owners')),
                    DropdownMenuItem(
                      value: 'Verified',
                      child: Text('Verified'),
                    ),
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(
                      value: 'Taxi Service',
                      child: Text('Taxi Service'),
                    ),
                    DropdownMenuItem(
                      value: 'Ride Sharing',
                      child: Text('Ride Sharing'),
                    ),
                    DropdownMenuItem(
                      value: 'Car Rental',
                      child: Text('Car Rental'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Owners Table
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
                      Expanded(flex: 2, child: _buildHeaderCell('Company')),
                      Expanded(flex: 1, child: _buildHeaderCell('Contact')),
                      Expanded(
                        flex: 1,
                        child: _buildHeaderCell('Business Type'),
                      ),
                      Expanded(flex: 1, child: _buildHeaderCell('Fleet Size')),
                      Expanded(flex: 1, child: _buildHeaderCell('Rating')),
                      Expanded(flex: 1, child: _buildHeaderCell('Status')),
                      Expanded(flex: 1, child: _buildHeaderCell('Actions')),
                    ],
                  ),
                ),
                // Table Rows
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredOwners.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final owner = _filteredOwners[index];
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
                                  owner['company']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  owner['email']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              owner['contact']!,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              owner['businessType']!,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              owner['fleet']!,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  owner['rating']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
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
                                  owner['status']!,
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                owner['status']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _getStatusColor(owner['status']!),
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
                                      Text('View Details'),
                                    ],
                                  ),
                                ),
                                if (owner['status'] == 'Pending')
                                  const PopupMenuItem(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 16,
                                          color: Colors.green,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Verify'),
                                      ],
                                    ),
                                  ),
                                if (owner['status'] != 'Suspended')
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
            'Total: ${_filteredOwners.length} owner${_filteredOwners.length != 1 ? 's' : ''}',
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Verified':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Suspended':
        return Colors.red;
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
