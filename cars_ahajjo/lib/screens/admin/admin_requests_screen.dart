import 'package:flutter/material.dart';
import 'package:cars_ahajjo/services/admin_service.dart';
import 'package:intl/intl.dart';

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _profileUpdateRequests = [];
  List<dynamic> _deletionRequests = [];
  String _selectedStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);

    try {
      // Fetch profile update requests
      final updateResult = await AdminService.getUserRequests(
        type: 'update',
        status: _selectedStatus,
      );

      // Fetch deletion requests
      final deleteResult = await AdminService.getUserRequests(
        type: 'delete',
        status: _selectedStatus,
      );

      setState(() {
        _profileUpdateRequests = updateResult?['data'] ?? [];
        _deletionRequests = deleteResult?['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching requests: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Requests'),
        backgroundColor: Colors.blue[600],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Profile Updates (${_profileUpdateRequests.length})'),
            Tab(text: 'Account Deletions (${_deletionRequests.length})'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _selectedStatus = value);
              _fetchRequests();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'approved', child: Text('Approved')),
              const PopupMenuItem(value: 'rejected', child: Text('Rejected')),
              const PopupMenuItem(value: '', child: Text('All')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRequests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProfileUpdatesList(),
                _buildDeletionRequestsList(),
              ],
            ),
    );
  }

  Widget _buildProfileUpdatesList() {
    if (_profileUpdateRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No profile update requests',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _profileUpdateRequests.length,
        itemBuilder: (context, index) {
          final request = _profileUpdateRequests[index];
          return _buildProfileUpdateCard(request);
        },
      ),
    );
  }

  Widget _buildProfileUpdateCard(Map<String, dynamic> request) {
    final user = request['user'] ?? {};
    final changes = request['changes'] ?? {};
    final status = request['status'] ?? 'pending';
    final createdAt = request['createdAt'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    (user['name'] ?? 'U')[0].toUpperCase(),
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'] ?? 'Unknown User',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        user['email'] ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(status),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'Requested Changes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...changes.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_formatFieldName(entry.key)}: ',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (createdAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Requested: ${_formatDate(createdAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            if (status == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleProfileUpdate(request, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleProfileUpdate(request, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeletionRequestsList() {
    if (_deletionRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No deletion requests',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _deletionRequests.length,
        itemBuilder: (context, index) {
          final request = _deletionRequests[index];
          return _buildDeletionRequestCard(request);
        },
      ),
    );
  }

  Widget _buildDeletionRequestCard(Map<String, dynamic> request) {
    final user = request['user'] ?? {};
    final reason = request['reason'] ?? 'No reason provided';
    final status = request['status'] ?? 'pending';
    final createdAt = request['createdAt'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red[100],
                  child: Text(
                    (user['name'] ?? 'U')[0].toUpperCase(),
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'] ?? 'Unknown User',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        user['email'] ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        'Role: ${user['role'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(status),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'Reason:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(reason, style: TextStyle(color: Colors.grey[700])),
            if (createdAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Requested: ${_formatDate(createdAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            if (status == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleAccountDeletion(request, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.delete_forever, size: 18),
                      label: const Text('Approve Deletion'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleAccountDeletion(request, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.orange;
        icon = Icons.pending;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
      backgroundColor: color,
      avatar: Icon(icon, color: Colors.white, size: 16),
      padding: EdgeInsets.zero,
    );
  }

  Future<void> _handleProfileUpdate(
    Map<String, dynamic> request,
    bool approve,
  ) async {
    final requestId = request['_id'] ?? request['id'];
    if (requestId == null) return;

    final confirmed = await _showConfirmationDialog(
      approve ? 'Approve Request' : 'Reject Request',
      approve
          ? 'Are you sure you want to approve this profile update?'
          : 'Are you sure you want to reject this profile update?',
    );

    if (!confirmed) return;

    final success = await AdminService.handleProfileUpdateRequest(
      requestId: requestId,
      approve: approve,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '${approve ? 'Approved' : 'Rejected'} successfully'
              : 'Failed to process request',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      _fetchRequests();
    }
  }

  Future<void> _handleAccountDeletion(
    Map<String, dynamic> request,
    bool approve,
  ) async {
    final requestId = request['_id'] ?? request['id'];
    if (requestId == null) return;

    final confirmed = await _showConfirmationDialog(
      approve ? 'Approve Account Deletion' : 'Reject Deletion Request',
      approve
          ? 'WARNING: This will permanently delete the user account. This action cannot be undone!'
          : 'Are you sure you want to reject this deletion request?',
      approve ? Colors.red : null,
    );

    if (!confirmed) return;

    final success = await AdminService.handleAccountDeletionRequest(
      requestId: requestId,
      approve: approve,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '${approve ? 'Account deleted' : 'Deletion rejected'} successfully'
              : 'Failed to process request',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      _fetchRequests();
    }
  }

  Future<bool> _showConfirmationDialog(
    String title,
    String message, [
    Color? color,
  ]) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: color ?? Theme.of(context).primaryColor,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String _formatFieldName(String fieldName) {
    return fieldName
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
