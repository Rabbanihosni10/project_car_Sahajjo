import 'package:flutter/material.dart';
import 'package:cars_ahajjo/services/job_service.dart';
import 'package:intl/intl.dart';

class CreateJobScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const CreateJobScreen({super.key, required this.userData});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _carModelController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _experienceController = TextEditingController();

  String _salaryType = 'monthly';
  String _jobType = 'full-time';
  String _licenseType = 'B';
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));

  final List<String> _workingHours = [];
  final List<String> _requirements = [];
  final List<String> _perks = [];

  final _workingHourController = TextEditingController();
  final _requirementController = TextEditingController();
  final _perkController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _carModelController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _experienceController.dispose();
    _workingHourController.dispose();
    _requirementController.dispose();
    _perkController.dispose();
    super.dispose();
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_workingHours.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one working hour')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      print('Creating job post...');
      print('Title: ${_titleController.text}');
      print('Description: ${_descriptionController.text}');
      print('Car Model: ${_carModelController.text}');
      print('Location: ${_locationController.text}');
      print('Salary: ${_salaryController.text}');

      final result = await JobService.createJobPost(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? 'Driver needed for ${_carModelController.text.trim()}'
            : _descriptionController.text.trim(),
        carModel: _carModelController.text.trim(),
        location: _locationController.text.trim(),
        salary: double.parse(_salaryController.text.trim()),
        salaryType: _salaryType,
        jobType: _jobType,
        experience: int.parse(_experienceController.text.trim()),
        licenseType: _licenseType,
        workingHours: _workingHours,
        requirements: _requirements,
        perks: _perks,
        expiryDate: _expiryDate,
      );

      print('Result: $result');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job posted successfully! Awaiting admin approval.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error creating job: $e');
      if (mounted) {
        String errorMsg = 'Failed to create job post';
        if (e.toString().contains('SocketException') ||
            e.toString().contains('Connection refused') ||
            e.toString().contains('Failed host lookup')) {
          errorMsg =
              'Cannot connect to server. Please ensure the backend is running at http://localhost:5003';
        } else if (e.toString().contains('Failed to create job')) {
          errorMsg = e.toString().replaceAll('Exception: ', '');
        } else {
          errorMsg = 'Error: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _addWorkingHour() {
    if (_workingHourController.text.trim().isNotEmpty) {
      setState(() {
        _workingHours.add(_workingHourController.text.trim());
        _workingHourController.clear();
      });
    }
  }

  void _addRequirement() {
    if (_requirementController.text.trim().isNotEmpty) {
      setState(() {
        _requirements.add(_requirementController.text.trim());
        _requirementController.clear();
      });
    }
  }

  void _addPerk() {
    if (_perkController.text.trim().isNotEmpty) {
      setState(() {
        _perks.add(_perkController.text.trim());
        _perkController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Job'),
        backgroundColor: Colors.blue[600],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Job Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Job Title *',
                hintText: 'e.g., Personal Driver for Honda Civic',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter job title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Job Description',
                hintText: 'Describe the job responsibilities (optional)...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),

            // Car Model
            TextFormField(
              controller: _carModelController,
              decoration: const InputDecoration(
                labelText: 'Car Model *',
                hintText: 'e.g., Honda Civic 2020',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter car model';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location *',
                hintText: 'e.g., Dhaka, Bangladesh',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Salary and Type
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _salaryController,
                    decoration: const InputDecoration(
                      labelText: 'Salary *',
                      hintText: '30000',
                      border: OutlineInputBorder(),
                      prefixText: '৳ ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _salaryType,
                    decoration: const InputDecoration(
                      labelText: 'Period',
                      border: OutlineInputBorder(),
                    ),
                    items: ['monthly', 'daily', 'weekly']
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              type[0].toUpperCase() + type.substring(1),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _salaryType = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Job Type
            DropdownButtonFormField<String>(
              value: _jobType,
              decoration: const InputDecoration(
                labelText: 'Job Type',
                border: OutlineInputBorder(),
              ),
              items: ['full-time', 'part-time', 'contract']
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(
                        type
                            .split('-')
                            .map((s) => s[0].toUpperCase() + s.substring(1))
                            .join('-'),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _jobType = value!),
            ),
            const SizedBox(height: 16),

            // Experience and License
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _experienceController,
                    decoration: const InputDecoration(
                      labelText: 'Experience (years) *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _licenseType,
                    decoration: const InputDecoration(
                      labelText: 'License Type',
                      border: OutlineInputBorder(),
                    ),
                    items: ['A', 'B', 'C', 'D', 'E']
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text('Type $type'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _licenseType = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Expiry Date
            ListTile(
              title: const Text('Job Expiry Date'),
              subtitle: Text(DateFormat('MMM dd, yyyy').format(_expiryDate)),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _expiryDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _expiryDate = date);
                }
              },
            ),
            const SizedBox(height: 24),

            // Working Hours
            _buildListSection(
              title: 'Working Hours *',
              items: _workingHours,
              controller: _workingHourController,
              hint: 'e.g., Monday-Friday 9AM-5PM',
              onAdd: _addWorkingHour,
            ),
            const SizedBox(height: 16),

            // Requirements
            _buildListSection(
              title: 'Requirements',
              items: _requirements,
              controller: _requirementController,
              hint: 'e.g., Clean driving record',
              onAdd: _addRequirement,
            ),
            const SizedBox(height: 16),

            // Perks
            _buildListSection(
              title: 'Perks & Benefits',
              items: _perks,
              controller: _perkController,
              hint: 'e.g., Health insurance, Paid vacation',
              onAdd: _addPerk,
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitJob,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Submit Job for Approval',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 16),

            Text(
              'Note: Your job posting will be reviewed by admin before being published.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection({
    required String title,
    required List<String> items,
    required TextEditingController controller,
    required String hint,
    required VoidCallback onAdd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle),
              color: Colors.blue[600],
              iconSize: 32,
            ),
          ],
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (item) => Chip(
                    label: Text(item),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => setState(() => items.remove(item)),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
