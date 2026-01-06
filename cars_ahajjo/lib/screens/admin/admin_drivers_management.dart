import 'package:flutter/material.dart';

class AdminDriversManagement extends StatefulWidget {
  const AdminDriversManagement({super.key});

  @override
  State<AdminDriversManagement> createState() => _AdminDriversManagementState();
}

class _AdminDriversManagementState extends State<AdminDriversManagement> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'all';

  final List<Map<String, String>> _drivers = [
    {
      'id': '1',
      'name': 'Ahmed Hassan',
      'email': 'ahmed@example.com',
      'license': 'DL-2021-0001',
      'vehicle': 'Sedan',
      'experience': '5 years',
      'status': 'Verified',
      'rating': '4.8',
      'joinDate': '2024-01-15',
    },
    {
      'id': '2',
      'name': 'Hassan Ibrahim',
      'email': 'hassan@example.com',
      'license': 'DL-2022-0045',
      'vehicle': 'SUV',
      'experience': '3 years',
      'status': 'Pending',
      'rating': '4.5',
      'joinDate': '2024-01-25',
    },
    {
      'id': '3',
      'name': 'Karim Ahmed',
      'email': 'karim@example.com',
      'license': 'DL-2020-0089',
      'vehicle': 'Pickup Truck',
      'experience': '8 years',
      'status': 'Verified',
      'rating': '4.9',
      'joinDate': '2024-02-10',
    },
    {
      'id': '4',
      'name': 'Omar Khan',
      'email': 'omar@example.com',
      'license': 'DL-2023-0012',
      'vehicle': 'Hatchback',
      'experience': '1 year',
      'status': 'Suspended',
      'rating': '2.1',
      'joinDate': '2024-03-20',
    },
  ];

  List<Map<String, String>> get _filteredDrivers {
    List<Map<String, String>> filtered = _drivers;

    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where(
            (driver) =>
                driver['name']!.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                driver['license']!.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ),
          )
          .toList();
    }

    if (_selectedFilter != 'all') {
      filtered = filtered
          .where(
            (driver) =>
                driver['status']?.toLowerCase() ==
                _selectedFilter.toLowerCase(),
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
                'Driver Management',
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
                      'Verify Driver',
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
                    hintText: 'Search by name or license number...',
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
                    DropdownMenuItem(value: 'all', child: Text('All Drivers')),
                    DropdownMenuItem(
                      value: 'Verified',
                      child: Text('Verified'),
                    ),
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(
                      value: 'Suspended',
                      child: Text('Suspended'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Drivers Table
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
                      Expanded(flex: 2, child: _buildHeaderCell('Driver Name')),
                      Expanded(flex: 1, child: _buildHeaderCell('License')),
                      Expanded(flex: 1, child: _buildHeaderCell('Vehicle')),
                      Expanded(flex: 1, child: _buildHeaderCell('Experience')),
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
                  itemCount: _filteredDrivers.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final driver = _filteredDrivers[index];
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
                                  driver['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  driver['email']!,
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
                              driver['license']!,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              driver['vehicle']!,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              driver['experience']!,
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
                                  driver['rating']!,
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
                                  driver['status']!,
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                driver['status']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _getStatusColor(driver['status']!),
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
                                if (driver['status'] == 'Pending')
                                  const PopupMenuItem(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 16,
                                          color: Colors.green,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Approve'),
                                      ],
                                    ),
                                  ),
                                if (driver['status'] != 'Suspended')
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
            'Total: ${_filteredDrivers.length} driver${_filteredDrivers.length != 1 ? 's' : ''}',
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
