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

  static Future<Map<String, dynamic>> registerVisitor({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    return _registerUser(
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: 'visitor',
    );
  }

  static Future<Map<String, dynamic>> registerDriver({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String licenseNumber,
    required String licenseExpiry,
    required String vehicleType,
    required String yearsOfExperience,
  }) async {
    return _registerUser(
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: 'driver',
      licenseNumber: licenseNumber,
      licenseExpiry: licenseExpiry,
      vehicleType: vehicleType,
      yearsOfExperience: yearsOfExperience,
    );
  }

  static Future<Map<String, dynamic>> registerOwner({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String companyName,
    required String businessRegistration,
    required String numberOfCars,
    required String businessType,
  }) async {
    return _registerUser(
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: 'owner',
      companyName: companyName,
      businessRegistration: businessRegistration,
      numberOfCars: numberOfCars,
      businessType: businessType,
    );
  }

  static Future<Map<String, dynamic>> _registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    String? licenseNumber,
    String? licenseExpiry,
    String? vehicleType,
    String? yearsOfExperience,
    String? companyName,
    String? businessRegistration,
    String? numberOfCars,
    String? businessType,
  }) async {
    final body = {
      "name": name,
      "email": email,
      "phone": phone,
      "password": password,
      "role": role,
    };

    // Add optional fields if provided
    if (licenseNumber != null) body["licenseNumber"] = licenseNumber;
    if (licenseExpiry != null) body["licenseExpiry"] = licenseExpiry;
    if (vehicleType != null) body["vehicleType"] = vehicleType;
    if (yearsOfExperience != null)
      body["yearsOfExperience"] = yearsOfExperience;
    if (companyName != null) body["companyName"] = companyName;
    if (businessRegistration != null)
      body["businessRegistration"] = businessRegistration;
    if (numberOfCars != null) body["numberOfCars"] = numberOfCars;
    if (businessType != null) body["businessType"] = businessType;

    final response = await http.post(
      Uri.parse("${AppConstants.baseUrl}/auth/register"),
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data as Map<String, dynamic>;
    }

    final message = data["message"] ?? "Registration failed";
    throw Exception(message);
  }
}
