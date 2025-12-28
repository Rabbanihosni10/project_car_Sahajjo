import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job_post.dart';

class JobService {
  static const String baseUrl = 'http://localhost:5003/api/jobs';
  static const String apiBaseUrl =
      'http://10.0.2.2:5003/api/jobs'; // Android emulator

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
      final url = await _getBaseUrl();

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
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
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return JobPost.fromJson(data['data'] ?? {});
      }
      return null;
    } catch (e) {
      print('Error creating job post: $e');
      return null;
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
}
