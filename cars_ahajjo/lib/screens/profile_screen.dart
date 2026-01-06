import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfileScreen({super.key, required this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ImageProvider? _getProfileImage() {
    final avatar =
        widget.userData['avatar'] ?? widget.userData['profilePicture'];
    if (avatar == null) return null;

    if (avatar.startsWith('data:image')) {
      // Base64 image
      try {
        return MemoryImage(base64Decode(avatar.split(',')[1]));
      } catch (e) {
        return null;
      }
    } else if (avatar.startsWith('http')) {
      // Network image
      return NetworkImage(avatar);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.userData['role'] as String? ?? 'visitor';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmation(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue[400],
                      backgroundImage: _getProfileImage(),
                      child: _getProfileImage() == null
                          ? Text(
                              widget.userData['name']?[0].toUpperCase() ?? 'U',
                              style: const TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.userData['name'] ?? 'User',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.userData['email'] ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.userData['phone'] ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(role).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getRoleColor(role)),
                      ),
                      child: Text(
                        _getRoleLabel(role),
                        style: TextStyle(
                          color: _getRoleColor(role),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Information Section
            const Text(
              'Account Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoCard('Email', widget.userData['email'] ?? 'N/A'),
            _buildInfoCard('Phone', widget.userData['phone'] ?? 'N/A'),
            const SizedBox(height: 16),

            // Role-Specific Information
            if (role == 'driver') ...[
              const Text(
                'Driver Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                'License Number',
                widget.userData['licenseNumber'] ?? 'N/A',
              ),
              _buildInfoCard(
                'License Expiry',
                widget.userData['licenseExpiry'] ?? 'N/A',
              ),
              _buildInfoCard(
                'Vehicle Type',
                widget.userData['vehicleType'] ?? 'N/A',
              ),
              _buildInfoCard(
                'Years of Experience',
                widget.userData['yearsOfExperience'] ?? 'N/A',
              ),
            ] else if (role == 'owner' || role == 'carOwner') ...[
              const Text(
                'Owner Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                'Company Name',
                widget.userData['companyName'] ?? 'N/A',
              ),
              _buildInfoCard(
                'Business Registration',
                widget.userData['businessRegistration'] ?? 'N/A',
              ),
              _buildInfoCard(
                'Number of Cars',
                widget.userData['numberOfCars'] ?? 'N/A',
              ),
              _buildInfoCard(
                'Business Type',
                widget.userData['businessType'] ?? 'N/A',
              ),
            ],

            const SizedBox(height: 32),

            // Edit and Logout Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
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
                  backgroundColor: const Color(0xFF2196F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutConfirmation(),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'driver':
        return Colors.green;
      case 'owner':
      case 'carOwner':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'driver':
        return 'Driver';
      case 'owner':
      case 'carOwner':
        return 'Car Owner';
      default:
        return 'Visitor';
    }
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
              Navigator.pop(context);
              await AuthService.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/signin');
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
