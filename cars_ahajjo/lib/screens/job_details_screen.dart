import 'package:flutter/material.dart';
import 'package:cars_ahajjo/models/job_post.dart';
import 'package:cars_ahajjo/services/job_service.dart';
import 'package:intl/intl.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobId;
  final Map<String, dynamic> userData;

  const JobDetailsScreen({
    super.key,
    required this.jobId,
    required this.userData,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  JobPost? _job;
  bool _isLoading = true;
  bool _isApplying = false;
  bool _hasApplied = false;

  @override
  void initState() {
    super.initState();
    _loadJobDetails();
  }

  Future<void> _loadJobDetails() async {
    setState(() => _isLoading = true);

    final job = await JobService.getJobPost(widget.jobId);

    if (mounted) {
      setState(() {
        _job = job;
        _isLoading = false;

        // Check if current user has already applied
        final userId = widget.userData['_id'] ?? widget.userData['id'];
        _hasApplied = job?.applicants.any((a) => a.driverId == userId) ?? false;
      });
    }
  }

  Future<void> _applyForJob() async {
    if (_job == null) return;

    setState(() => _isApplying = true);

    final success = await JobService.applyForJob(_job!.id);

    if (mounted) {
      setState(() => _isApplying = false);

      if (success) {
        setState(() => _hasApplied = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadJobDetails(); // Reload to show updated applicants
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit application. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: Colors.blue[600],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _job == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Job not found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadJobDetails,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Job Title and Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _job!.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildStatusBadge(_job!.status),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Posted by
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.blue[100],
                          child: Icon(
                            Icons.person,
                            size: 18,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _job!.ownerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _job!.ownerEmail,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Key Info Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.attach_money,
                            label: 'Salary',
                            value:
                                '\u09f3${NumberFormat('#,##0').format(_job!.salary)}',
                            subtitle: _job!.salaryType,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.work_outline,
                            label: 'Job Type',
                            value: _job!.jobType
                                .split('-')
                                .map((s) => s[0].toUpperCase() + s.substring(1))
                                .join('-'),
                            subtitle: '${_job!.experience} yrs exp',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.directions_car,
                            label: 'Car Model',
                            value: _job!.carModel,
                            subtitle: 'License: ${_job!.licenseType}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.location_on,
                            label: 'Location',
                            value: _job!.location,
                            subtitle:
                                _job!.applicants.length.toString() +
                                ' applicants',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    _buildSection(
                      title: 'Job Description',
                      icon: Icons.description,
                      child: Text(
                        _job!.description,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Working Hours
                    if (_job!.workingHours.isNotEmpty)
                      _buildSection(
                        title: 'Working Hours',
                        icon: Icons.access_time,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _job!.workingHours
                              .map(
                                (hour) => Chip(
                                  label: Text(hour),
                                  backgroundColor: Colors.blue[50],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Requirements
                    if (_job!.requirements.isNotEmpty)
                      _buildSection(
                        title: 'Requirements',
                        icon: Icons.checklist,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _job!.requirements
                              .map(
                                (req) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 20,
                                        color: Colors.green[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(req)),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Perks
                    if (_job!.perks.isNotEmpty)
                      _buildSection(
                        title: 'Perks & Benefits',
                        icon: Icons.star,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _job!.perks
                              .map(
                                (perk) => Chip(
                                  label: Text(perk),
                                  backgroundColor: Colors.amber[50],
                                  avatar: Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber[700],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Posted and Expiry Dates
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Posted On',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(_job!.postedAt),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Expires On',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(_job!.expiryDate),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _job!.hasExpired
                                      ? Colors.red
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100), // Space for floating button
                  ],
                ),
              ),
            ),
      floatingActionButton:
          _job != null &&
              widget.userData['role'] == 'driver' &&
              _job!.isOpen &&
              !_job!.hasExpired
          ? FloatingActionButton.extended(
              onPressed: _hasApplied || _isApplying ? null : _applyForJob,
              backgroundColor: _hasApplied ? Colors.grey : Colors.blue[600],
              icon: _isApplying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(_hasApplied ? Icons.check : Icons.send),
              label: Text(
                _hasApplied ? 'Already Applied' : 'Apply Now',
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'open':
        color = Colors.green;
        text = 'Open';
        break;
      case 'closed':
        color = Colors.red;
        text = 'Closed';
        break;
      case 'filled':
        color = Colors.blue;
        text = 'Filled';
        break;
      case 'pending':
        color = Colors.orange;
        text = 'Pending Approval';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
