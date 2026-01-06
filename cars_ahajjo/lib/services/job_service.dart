import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job_post.dart';
import '../utils/constrains.dart';

class JobService {
  static String get baseUrl => '${AppConstants.baseUrl}/jobs';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String> _getBaseUrl() async {
    // Use local host for physical device, emulator uses 10.0.2.2
    return baseUrl;
  }

  // Owner: Create job post
  static Future<JobPost?> createJobPost({
    required String title,
    required String description,
    required String carModel,
    required String location,
    required double salary,
    required String salaryType,
    required String jobType,
    required int experience,
    required String licenseType,
    required List<String> workingHours,
    required List<String> requirements,
    required List<String> perks,
    DateTime? expiryDate,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('No auth token found');
        return null;
      }

      final url = await _getBaseUrl();
      print('Posting job to: $url');

      final body = {
        'title': title,
        'description': description,
        'carModel': carModel,
        'location': location,
        'salary': salary,
        'salaryType': salaryType,
        'jobType': jobType,
        'experience': experience,
        'licenseType': licenseType,
        'workingHours': workingHours,
        'requirements': requirements,
        'perks': perks,
        'expiryDate': expiryDate?.toIso8601String(),
      };

      print('Request body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return JobPost.fromJson(data['data'] ?? data);
      } else {
        final errorMsg =
            'Failed to create job: ${response.statusCode} - ${response.body}';
        print(errorMsg);
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      print('Error creating job post: $e');
      print('Stack trace: $stackTrace');
      rethrow; // Re-throw to let the caller handle it
    }
  }

  // Get all job posts
  static Future<List<JobPost>> getJobPosts({String status = 'open'}) async {
    try {
      final url = await _getBaseUrl();

      final response = await http.get(
        Uri.parse('$url?status=$status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jobs =
            (data['data'] as List?)
                ?.map((job) => JobPost.fromJson(job as Map<String, dynamic>))
                .toList() ??
            [];
        return jobs;
      }
      return [];
    } catch (e) {
      print('Error fetching jobs: $e');
      return [];
    }
  }

  // Get job post details
  static Future<JobPost?> getJobPost(String jobId) async {
    try {
      final url = await _getBaseUrl();

      final response = await http.get(
        Uri.parse('$url/$jobId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return JobPost.fromJson(data['data'] ?? {});
      }
      return null;
    } catch (e) {
      print('Error fetching job: $e');
      return null;
    }
  }

  // Driver: Apply for job
  static Future<bool> applyForJob(String jobId) async {
    try {
      final token = await _getToken();
      final url = await _getBaseUrl();

      final response = await http.post(
        Uri.parse('$url/$jobId/apply'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error applying for job: $e');
      return false;
    }
  }

  // Driver: Get my applications
  static Future<List<JobPost>> getMyApplications() async {
    try {
      final token = await _getToken();
      final url = await _getBaseUrl();

      final response = await http.get(
        Uri.parse('$url/driver/my-applications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jobs =
            (data['data'] as List?)
                ?.map((job) => JobPost.fromJson(job as Map<String, dynamic>))
                .toList() ??
            [];
        return jobs;
      }
      return [];
    } catch (e) {
      print('Error fetching applications: $e');
      return [];
    }
  }

  // Owner: Update application status
  static Future<bool> updateApplicationStatus(
    String jobId,
    String driverId,
    String status, {
    String? notes,
  }) async {
    try {
      final token = await _getToken();
      final url = await _getBaseUrl();

      final response = await http.patch(
        Uri.parse('$url/$jobId/applicants/$driverId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status, if (notes != null) 'notes': notes}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating application status: $e');
      return false;
    }
  }

  // Owner: Close job post
  static Future<bool> closeJobPost(String jobId) async {
    try {
      final token = await _getToken();
      final url = await _getBaseUrl();

      final response = await http.patch(
        Uri.parse('$url/$jobId/close'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error closing job: $e');
      return false;
    }
  }

  // Admin: Get pending jobs for approval
  static Future<List<JobPost>> getPendingJobs() async {
    try {
      final token = await _getToken();
      final url = await _getBaseUrl();

      final response = await http.get(
        Uri.parse('$url?status=pending'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jobs =
            (data['data'] as List?)
                ?.map((job) => JobPost.fromJson(job as Map<String, dynamic>))
                .toList() ??
            [];
        return jobs;
      }
      return [];
    } catch (e) {
      print('Error fetching pending jobs: $e');
      return [];
    }
  }

  // Admin: Approve job post
  static Future<bool> approveJob(String jobId, {String? notes}) async {
    try {
      final token = await _getToken();
      final url = await _getBaseUrl();

      final response = await http.patch(
        Uri.parse('$url/$jobId/approve'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'notes': notes}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error approving job: $e');
      return false;
    }
  }

  // Admin: Reject job post
  static Future<bool> rejectJob(String jobId, {String? reason}) async {
    try {
      final token = await _getToken();
      final url = await _getBaseUrl();

      final response = await http.patch(
        Uri.parse('$url/$jobId/reject'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'reason': reason}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error rejecting job: $e');
      return false;
    }
  }

  // Owner: Get my job posts
  static Future<List<JobPost>> getMyJobPosts() async {
    try {
      final token = await _getToken();
      final url = await _getBaseUrl();

      final response = await http.get(
        Uri.parse('$url/owner/my-jobs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jobs =
            (data['data'] as List?)
                ?.map((job) => JobPost.fromJson(job as Map<String, dynamic>))
                .toList() ??
            [];
        return jobs;
      }
      return [];
    } catch (e) {
      print('Error fetching my jobs: $e');
      return [];
    }
  }

  // Owner: Get applicants for a job
  static Future<List<dynamic>> getJobApplicants(String jobId) async {
    try {
      final token = await _getToken();
      final url = await _getBaseUrl();

      final response = await http.get(
        Uri.parse('$url/$jobId/applicants'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching applicants: $e');
      return [];
    }
  }
}
