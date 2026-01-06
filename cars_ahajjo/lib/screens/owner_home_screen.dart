import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import '../services/driver_service.dart';
import '../services/message_service.dart';
import './conversations_screen.dart';
import './chat_screen.dart';
import './my_job_posts_screen.dart';
import './add_garage_screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const OwnerHomeScreen({super.key, required this.userData});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  int _selectedIndex = 0;
  late Future<List<dynamic>> _driversFuture;

  @override
  void initState() {
    super.initState();
    _driversFuture = DriverService.getOwnerDrivers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        title: const Text(
          'Car Sahajjo - Owner',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmation(),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Drivers'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildDriversTab();
      case 2:
        return _buildChatTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${widget.userData['name'] ?? 'Owner'}! 👋',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Manage your fleet efficiently'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Business Stats
          const Text(
            'Business Analytics 📊',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Profit/Loss',
                  'TK +45,800',
                  Colors.green,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Net Income',
                  'TK 125,300',
                  Colors.blue,
                  Icons.wallet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Active Cars',
                  '12',
                  Colors.orange,
                  Icons.directions_car,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Active Drivers',
                  '8',
                  Colors.purple,
                  Icons.people,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Stats Overview
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This Month Summary',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Total Rides', '342'),
                  _buildDetailRow('Total Revenue', 'TK 85,400'),
                  _buildDetailRow('Expenses', 'TK 39,600'),
                  _buildDetailRow('Net Profit', 'TK 45,800'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Features Grid
          const Text(
            'Management Tools',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildFeatureCard(
                'Post Job',
                Icons.work,
                Colors.teal[400]!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MyJobPostsScreen(userData: widget.userData),
                  ),
                ),
              ),
              _buildFeatureCard(
                'AI Chat',
                Icons.smart_toy,
                Colors.blue[400]!,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/ai-chat',
                  arguments: widget.userData,
                ),
              ),
              _buildFeatureCard(
                'People',
                Icons.people,
                Colors.purple[400]!,
                onTap: () => Navigator.pushNamed(context, '/people'),
              ),
              _buildFeatureCard(
                'My Garages',
                Icons.location_on,
                Colors.red[400]!,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/owner/garages',
                  arguments: widget.userData,
                ),
              ),
              _buildFeatureCard(
                'Add Garage',
                Icons.add_location,
                Colors.indigo[400]!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddGarageScreen(),
                  ),
                ),
              ),
              _buildFeatureCard(
                'Car Info',
                Icons.info,
                Colors.green[400]!,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/car-info',
                  arguments: widget.userData,
                ),
              ),
              _buildFeatureCard(
                'My Connections',
                Icons.chat_bubble,
                Colors.pink[400]!,
                onTap: () => Navigator.pushNamed(context, '/my-connections'),
              ),
              _buildFeatureCard(
                'Community Forum',
                Icons.forum,
                Colors.orange[400]!,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/forum',
                  arguments: widget.userData,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Garage Information
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text(
                        'Nearby Garage Locations',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildGarageItem(
                    'Ali\'s Service Center',
                    '3.2 km away',
                    '⭐ 4.7',
                  ),
                  _buildGarageItem('Premium Auto Care', '5.1 km away', '⭐ 4.5'),
                  _buildGarageItem('QuickFix Garage', '6.8 km away', '⭐ 4.3'),
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening Maps...')),
                          ),
                      child: const Text('View in Map'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    String label,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGarageItem(String name, String distance, String rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.location_on, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  distance,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            rating,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDriversTab() {
    return FutureBuilder<List<dynamic>>(
      future: _driversFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red[400], size: 64),
                const SizedBox(height: 16),
                const Text('Error loading drivers'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _driversFuture = DriverService.getOwnerDrivers();
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final drivers = snapshot.data ?? [];

        if (drivers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, color: Colors.grey[400], size: 64),
                const SizedBox(height: 16),
                Text(
                  'No drivers assigned yet',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Drivers 👥',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: drivers.length,
                itemBuilder: (context, index) {
                  final driver = drivers[index];
                  final name =
                      driver['name'] ?? driver['firstName'] ?? 'Unknown Driver';
                  final driverId = driver['_id'] ?? driver['id'] ?? '';
                  final licenseNumber = driver['licenseNumber'] ?? 'N/A';
                  final status = driver['status'] ?? 'offline';
                  final rating = driver['rating'] ?? 4.5;
                  final totalRides = driver['totalRides'] ?? 0;
                  final earnings = driver['totalEarnings'] ?? 0;
                  final phone = driver['phone'] ?? 'N/A';

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        Colors.blue[300 +
                                            ((index * 100) % 400).toInt()],
                                    child: Text(
                                      name[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        'License: $licenseNumber',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        'Phone: $phone',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: status == 'online'
                                      ? Colors.green[100]
                                      : Colors.orange[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  status == 'online' ? 'Online' : 'Offline',
                                  style: TextStyle(
                                    color: status == 'online'
                                        ? Colors.green
                                        : Colors.orange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '⭐ $rating',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Rating',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '$totalRides',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Rides',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'TK $earnings',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Earnings',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.location_on, size: 16),
                                  label: const Text('Track'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[600],
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Tracking $name... (GPS integration coming)',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.info, size: 16),
                                  label: const Text('Details'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange[600],
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    _showDriverDetails(context, driver);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.chat, size: 16),
                                  label: const Text('Chat'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[600],
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    _startChat(context, driverId, name);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDriverDetails(BuildContext context, Map<String, dynamic> driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(driver['name'] ?? 'Driver Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailTile('License', driver['licenseNumber'] ?? 'N/A'),
              _buildDetailTile('Phone', driver['phone'] ?? 'N/A'),
              _buildDetailTile('Email', driver['email'] ?? 'N/A'),
              _buildDetailTile('Vehicle', driver['vehicleNumber'] ?? 'N/A'),
              _buildDetailTile('Status', driver['status'] ?? 'N/A'),
              _buildDetailTile('Rating', '⭐ ${driver['rating'] ?? 'N/A'}'),
              _buildDetailTile('Total Rides', '${driver['totalRides'] ?? 0}'),
              _buildDetailTile(
                'Total Earnings',
                'TK ${driver['totalEarnings'] ?? 0}',
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

  Widget _buildDetailTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _startChat(
    BuildContext context,
    String driverId,
    String driverName,
  ) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Get or create conversation
      final conversation = await MessageService.getOrCreateConversation(
        driverId,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (conversation != null) {
        // Navigate directly to ChatScreen with otherUser data
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                otherUser: {
                  '_id': driverId,
                  'name': driverName,
                  'role': 'driver',
                },
                currentUser: widget.userData,
              ),
            ),
          );
        }
      } else {
        // If backend fails, still allow chat (will work with socket.io if available)
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                otherUser: {
                  '_id': driverId,
                  'name': driverName,
                  'role': 'driver',
                },
                currentUser: widget.userData,
              ),
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

      // Still navigate to chat screen (offline mode)
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              otherUser: {
                '_id': driverId,
                'name': driverName,
                'role': 'driver',
              },
              currentUser: widget.userData,
            ),
          ),
        );
      }
    }
  }

  Widget _buildChatTab() {
    return ConversationsScreen(currentUser: widget.userData);
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue[400],
                    child: Text(
                      widget.userData['name']?[0].toUpperCase() ?? 'O',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.userData['name'] ?? 'Owner',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(widget.userData['email'] ?? ''),
                  const SizedBox(height: 4),
                  Text(widget.userData['phone'] ?? ''),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Business Information',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Company Name',
                    widget.userData['companyName'] ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Business Registration',
                    widget.userData['businessRegistration'] ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Number of Cars',
                    widget.userData['numberOfCars'] ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Business Type',
                    widget.userData['businessType'] ?? 'N/A',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/edit-profile',
                  arguments: widget.userData,
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[400],
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showLogoutConfirmation(),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
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
            onPressed: () async {
              final navigator = Navigator.of(context);
              navigator.pop();
              await AuthService.logout();
              navigator.pushReplacementNamed('/signin');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
