import 'package:flutter/material.dart';
import 'package:cars_ahajjo/services/admin_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  Map<String, dynamic>? dashboardStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    try {
      final stats = await AdminService.getDashboardStats();
      setState(() {
        dashboardStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard stats: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[600],
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple[600]!,
                            Colors.deepPurple[400]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome Back, Admin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Last updated: ${DateTime.now().toString().split('.')[0]}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Key Metrics
                    const Text(
                      'Platform Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Users Metrics
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildMetricCard(
                          'Total Users',
                          dashboardStats?['totalUsers']?.toString() ?? '0',
                          Colors.blue[600]!,
                          Icons.people,
                        ),
                        _buildMetricCard(
                          'Drivers',
                          dashboardStats?['driverCount']?.toString() ?? '0',
                          Colors.green[600]!,
                          Icons.directions_car,
                        ),
                        _buildMetricCard(
                          'Car Owners',
                          dashboardStats?['ownerCount']?.toString() ?? '0',
                          Colors.orange[600]!,
                          Icons.directions,
                        ),
                        _buildMetricCard(
                          'Visitors',
                          dashboardStats?['visitorCount']?.toString() ?? '0',
                          Colors.purple[600]!,
                          Icons.person,
                        ),
                        _buildMetricCard(
                          'Garages',
                          dashboardStats?['garageCount']?.toString() ?? '0',
                          Colors.red[600]!,
                          Icons.store,
                        ),
                        _buildMetricCard(
                          'Total Messages',
                          dashboardStats?['recentMessages']?.toString() ?? '0',
                          Colors.teal[600]!,
                          Icons.message,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Financial Metrics
                    const Text(
                      'Financial Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            'Total Revenue',
                            '\$${(dashboardStats?['totalRevenue'] ?? 0).toStringAsFixed(2)}',
                            Colors.green[700]!,
                            Icons.attach_money,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            'Total Transactions',
                            dashboardStats?['totalTransactions']?.toString() ??
                                '0',
                            Colors.indigo[600]!,
                            Icons.payment,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Ratings Metrics
                    const Text(
                      'Quality Metrics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            'Avg Rating',
                            (dashboardStats?['avgRating'] ?? 0).toStringAsFixed(
                              2,
                            ),
                            Colors.amber[600]!,
                            Icons.star,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            'Total Ratings',
                            dashboardStats?['totalRatings']?.toString() ?? '0',
                            Colors.yellow[700]!,
                            Icons.rate_review,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Management Options
                    const Text(
                      'Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildManagementButton(
                      'Manage Users',
                      'View and manage all users',
                      Icons.group_outlined,
                      () => Navigator.of(context).pushNamed('/admin/users'),
                    ),
                    const SizedBox(height: 8),
                    _buildManagementButton(
                      'Transaction History',
                      'Review all transactions',
                      Icons.history,
                      () => Navigator.of(
                        context,
                      ).pushNamed('/admin/transactions'),
                    ),
                    const SizedBox(height: 8),
                    _buildManagementButton(
                      'Moderate Ratings',
                      'Flag or remove inappropriate ratings',
                      Icons.rate_review_outlined,
                      () => Navigator.of(context).pushNamed('/admin/ratings'),
                    ),
                    const SizedBox(height: 8),
                    _buildManagementButton(
                      'Send Announcement',
                      'Broadcast messages to users',
                      Icons.notifications_outlined,
                      () => Navigator.of(
                        context,
                      ).pushNamed('/admin/announcements'),
                    ),
                    const SizedBox(height: 8),
                    _buildManagementButton(
                      'System Logs',
                      'View recent activity and logs',
                      Icons.assessment_outlined,
                      () => Navigator.of(context).pushNamed('/admin/logs'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildManagementButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.deepPurple[600], size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
