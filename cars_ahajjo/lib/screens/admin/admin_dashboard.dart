import 'package:flutter/material.dart';
import 'admin_users_management.dart';
import 'admin_drivers_management.dart';
import 'admin_owners_management.dart';
import 'admin_reports.dart';
import 'admin_job_approval_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<String> _navigationLabels = [
    'Dashboard',
    'Users',
    'Drivers',
    'Owners',
    'Job Approvals',
    'Reports',
  ];

  final List<IconData> _navigationIcons = [
    Icons.dashboard,
    Icons.people,
    Icons.directions_car,
    Icons.business,
    Icons.work_outline,
    Icons.assessment,
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return const AdminMainDashboard();
      case 1:
        return const AdminUsersManagement();
      case 2:
        return const AdminDriversManagement();
      case 3:
        return const AdminOwnersManagement();
      case 4:
        return const AdminJobApprovalScreen();
      case 5:
        return const AdminReports();
      default:
        return const AdminMainDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 2,
        centerTitle: true,
        title: const Text(
          'Admin Panel - Car Sahajjo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushReplacementNamed('/admin/login');
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Color(0xFFD32F2F)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: isLargeScreen
          ? Row(
              children: [
                // Sidebar
                Container(
                  width: 250,
                  color: Colors.white,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _navigationLabels.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _onNavItemTapped(index),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedIndex == index
                                          ? const Color(
                                              0xFFD32F2F,
                                            ).withOpacity(0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: _selectedIndex == index
                                          ? Border(
                                              left: BorderSide(
                                                color: const Color(0xFFD32F2F),
                                                width: 4,
                                              ),
                                            )
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _navigationIcons[index],
                                          color: _selectedIndex == index
                                              ? const Color(0xFFD32F2F)
                                              : Colors.grey,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          _navigationLabels[index],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: _selectedIndex == index
                                                ? const Color(0xFFD32F2F)
                                                : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(15),
                        child: Text(
                          'Admin v1.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                // Main Content
                Expanded(child: _buildMainContent()),
              ],
            )
          : Column(
              children: [
                Expanded(child: _buildMainContent()),
                // Bottom Navigation for Mobile
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        _navigationLabels.length,
                        (index) => Container(
                          width: 70,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _onNavItemTapped(index),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _navigationIcons[index],
                                    color: _selectedIndex == index
                                        ? const Color(0xFFD32F2F)
                                        : Colors.grey,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _navigationLabels[index],
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _selectedIndex == index
                                          ? const Color(0xFFD32F2F)
                                          : Colors.grey,
                                      fontWeight: _selectedIndex == index
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class AdminMainDashboard extends StatelessWidget {
  const AdminMainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome, Admin!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Here is your dashboard overview',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Last updated: ${DateTime.now().toString().split('.')[0]}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Statistics Grid
          const Text(
            'Key Metrics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildStatCard('Total Users', '1,245', Icons.people, Colors.blue),
              _buildStatCard(
                'Active Drivers',
                '342',
                Icons.directions_car,
                Colors.green,
              ),
              _buildStatCard(
                'Car Owners',
                '156',
                Icons.business,
                Colors.orange,
              ),
              _buildStatCard(
                'Visitors',
                '747',
                Icons.person_outline,
                Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Activity
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
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
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final activities = [
                  'New driver registration: Ahmed Hassan',
                  'Car owner verified: Global Taxi Service',
                  'User account suspended: john.doe@email.com',
                  'New visitor signup: Sarah Khan',
                  'Admin action: System maintenance completed',
                ];
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activities[index],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${index + 1} hour${index > 0 ? 's' : ''} ago',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
