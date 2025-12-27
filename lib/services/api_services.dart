import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constrains.dart';

class ApiService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("${AppConstants.baseUrl}/auth/login"),
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data as Map<String, dynamic>;
    }

    final message = data["message"] ?? "Login failed";
    throw Exception(message);
  }
}
