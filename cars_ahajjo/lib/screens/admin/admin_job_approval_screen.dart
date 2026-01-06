import 'package:flutter/material.dart';
import 'package:cars_ahajjo/services/job_service.dart';
import 'package:cars_ahajjo/models/job_post.dart';
import 'package:intl/intl.dart';

class AdminJobApprovalScreen extends StatefulWidget {
  const AdminJobApprovalScreen({super.key});

  @override
  State<AdminJobApprovalScreen> createState() => _AdminJobApprovalScreenState();
}

class _AdminJobApprovalScreenState extends State<AdminJobApprovalScreen> {
  bool _isLoading = true;
  List<JobPost> _pendingJobs = [];

  @override
  void initState() {
    super.initState();
    _fetchPendingJobs();
  }

  Future<void> _fetchPendingJobs() async {
    setState(() => _isLoading = true);

    final jobs = await JobService.getPendingJobs();

    if (mounted) {
      setState(() {
        _pendingJobs = jobs;
        _isLoading = false;
      });
    }
  }

  Future<void> _approveJob(JobPost job) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Job'),
        content: Text('Approve job post "${job.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await JobService.approveJob(job.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Job approved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _fetchPendingJobs();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to approve job'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _rejectJob(JobPost job) async {
    final reasonController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Job'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reject job post "${job.title}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await JobService.rejectJob(
        job.id,
        reason: reasonController.text.trim(),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Job rejected'),
              backgroundColor: Colors.orange,
            ),
          );
          _fetchPendingJobs();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to reject job'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Approvals (${_pendingJobs.length})'),
        backgroundColor: Colors.blue[600],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPendingJobs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingJobs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pending job approvals',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchPendingJobs,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _pendingJobs.length,
                itemBuilder: (context, index) {
                  final job = _pendingJobs[index];
                  return _buildJobCard(job);
                },
              ),
            ),
    );
  }

  Widget _buildJobCard(JobPost job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Posted Date
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PENDING',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Owner Info
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(job.ownerName, style: TextStyle(color: Colors.grey[700])),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(job.postedAt),
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            const Divider(height: 24),

            // Job Details Grid
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.attach_money,
                    label: 'Salary',
                    value:
                        '\u09f3${NumberFormat('#,##0').format(job.salary)}/${job.salaryType}',
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.work,
                    label: 'Type',
                    value: job.jobType,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.directions_car,
                    label: 'Car',
                    value: job.carModel,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: job.location,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.badge,
                    label: 'Experience',
                    value: '${job.experience} years',
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.card_membership,
                    label: 'License',
                    value: 'Type ${job.licenseType}',
                  ),
                ),
              ],
            ),

            // Description Preview
            if (job.description.isNotEmpty) ...[
              const Divider(height: 24),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                job.description.length > 150
                    ? '${job.description.substring(0, 150)}...'
                    : job.description,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],

            // Working Hours
            if (job.workingHours.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Working Hours:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: job.workingHours
                    .map(
                      (hour) => Chip(
                        label: Text(hour, style: const TextStyle(fontSize: 11)),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],

            // Requirements
            if (job.requirements.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Requirements:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              ...job.requirements
                  .take(3)
                  .map(
                    (req) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.check, size: 14, color: Colors.green[600]),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              req,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (job.requirements.length > 3)
                Text(
                  '  +${job.requirements.length - 3} more',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
            ],

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectJob(job),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveJob(job),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
