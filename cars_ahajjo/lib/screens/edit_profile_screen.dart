import 'package:flutter/material.dart';
import 'package:cars_ahajjo/services/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _licenseNumberController;
  late TextEditingController _vehicleTypeController;
  late TextEditingController _companyNameController;
  late TextEditingController _businessTypeController;

  bool _isLoading = false;
  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.userData['name'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.userData['email'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.userData['phone'] ?? '',
    );
    _licenseNumberController = TextEditingController(
      text: widget.userData['licenseNumber'] ?? '',
    );
    _vehicleTypeController = TextEditingController(
      text: widget.userData['vehicleType'] ?? '',
    );
    _companyNameController = TextEditingController(
      text: widget.userData['companyName'] ?? '',
    );
    _businessTypeController = TextEditingController(
      text: widget.userData['businessType'] ?? '',
    );
    _profileImageUrl =
        widget.userData['avatar'] ?? widget.userData['profilePicture'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseNumberController.dispose();
    _vehicleTypeController.dispose();
    _companyNameController.dispose();
    _businessTypeController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePicture() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<String?> _uploadProfilePicture() async {
    if (_profileImage == null) return _profileImageUrl;

    try {
      // Convert to base64 for storage
      final bytes = await _profileImage!.readAsBytes();
      final base64Image = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64Image';
    } catch (e) {
      print('Error encoding image: $e');
      return _profileImageUrl;
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      final userId = widget.userData['id'] ?? widget.userData['_id'];
      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Upload profile picture if selected
      final profilePictureUrl = await _uploadProfilePicture();

      // Try direct update first
      final result = await UserService.updateProfile(
        userId: userId,
        name: _nameController.text,
        phone: _phoneController.text,
        avatar: profilePictureUrl,
        licenseNumber: _isDriver() ? _licenseNumberController.text : null,
        vehicleType: _isDriver() ? _vehicleTypeController.text : null,
        companyName: _isOwner() ? _companyNameController.text : null,
        businessType: _isOwner() ? _businessTypeController.text : null,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, result['data']); // Return updated data
      } else {
        // If direct update fails, try submitting a request for admin approval
        _showProfileUpdateRequestDialog();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showProfileUpdateRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Profile Update'),
        content: const Text(
          'Your changes require admin approval. Would you like to submit a request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _submitProfileUpdateRequest();
            },
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitProfileUpdateRequest() async {
    setState(() => _isLoading = true);

    try {
      final userId = widget.userData['id'] ?? widget.userData['_id'];
      final changes = <String, dynamic>{};

      if (_nameController.text != widget.userData['name']) {
        changes['name'] = _nameController.text;
      }
      if (_phoneController.text != widget.userData['phone']) {
        changes['phone'] = _phoneController.text;
      }
      if (_isDriver()) {
        if (_licenseNumberController.text != widget.userData['licenseNumber']) {
          changes['licenseNumber'] = _licenseNumberController.text;
        }
        if (_vehicleTypeController.text != widget.userData['vehicleType']) {
          changes['vehicleType'] = _vehicleTypeController.text;
        }
      }
      if (_isOwner()) {
        if (_companyNameController.text != widget.userData['companyName']) {
          changes['companyName'] = _companyNameController.text;
        }
        if (_businessTypeController.text != widget.userData['businessType']) {
          changes['businessType'] = _businessTypeController.text;
        }
      }

      final result = await UserService.requestProfileUpdate(
        userId: userId,
        changes: changes,
        reason: 'User requested profile changes',
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Request submitted'),
          backgroundColor: result['success'] == true
              ? Colors.green
              : Colors.orange,
        ),
      );

      if (result['success'] == true) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  bool _isDriver() {
    return widget.userData['role'] == 'driver' ||
        widget.userData['licenseNumber'] != null;
  }

  bool _isOwner() {
    return widget.userData['role'] == 'owner' ||
        widget.userData['companyName'] != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        title: const Text('Edit Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (_profileImageUrl != null &&
                              _profileImageUrl!.startsWith('data:image'))
                        ? MemoryImage(
                                base64Decode(_profileImageUrl!.split(',')[1]),
                              )
                              as ImageProvider
                        : (_profileImageUrl != null &&
                              _profileImageUrl!.startsWith('http'))
                        ? NetworkImage(_profileImageUrl!)
                        : null,
                    child: (_profileImage == null && _profileImageUrl == null)
                        ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue[600],
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                        onPressed: _pickProfilePicture,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Basic Information Section
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              enabled: false, // Email typically not editable
              hintText: 'Email cannot be changed',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              enabled: !_isLoading,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            // Driver Specific Section
            if (_isDriver()) ...[
              const Text(
                'Driver Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _licenseNumberController,
                label: 'License Number',
                icon: Icons.badge,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _vehicleTypeController,
                label: 'Vehicle Type',
                icon: Icons.directions_car,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                'License Expiry',
                widget.userData['licenseExpiry'] ?? 'N/A',
                Icons.calendar_today,
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                'Years of Experience',
                '${widget.userData['yearsOfExperience'] ?? 'N/A'} years',
                Icons.trending_up,
              ),
              const SizedBox(height: 24),
            ],

            // Owner Specific Section
            if (_isOwner()) ...[
              const Text(
                'Business Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _companyNameController,
                label: 'Company Name',
                icon: Icons.business,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _businessTypeController,
                label: 'Business Type',
                icon: Icons.category,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                'Business Registration',
                widget.userData['businessRegistration'] ?? 'N/A',
                Icons.assignment,
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                'Number of Cars',
                widget.userData['numberOfCars'] ?? 'N/A',
                Icons.directions_car,
              ),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(height: 24),

            // Danger Zone
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Danger Zone',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _showDeleteAccountConfirmation(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Delete Account'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: !enabled,
        fillColor: !enabled ? Colors.grey[200] : Colors.white,
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation() {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
                hintText: 'Why are you leaving?',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              reasonController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _submitDeleteAccountRequest(reasonController.text);
              reasonController.dispose();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitDeleteAccountRequest(String reason) async {
    setState(() => _isLoading = true);

    try {
      final userId = widget.userData['id'] ?? widget.userData['_id'];
      if (userId == null) {
        throw Exception('User ID not found');
      }

      final result = await UserService.requestAccountDeletion(
        userId: userId,
        reason: reason.isEmpty ? 'User requested account deletion' : reason,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Request submitted'),
          backgroundColor: result['success'] == true
              ? Colors.orange
              : Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );

      if (result['success'] == true) {
        // Wait a moment before going back
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
