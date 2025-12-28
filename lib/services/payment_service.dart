import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cars_ahajjo/models/payment_session.dart';
import 'package:cars_ahajjo/services/auth_services.dart';

class PaymentService {
  static const String _apiBase = 'http://localhost:5003/api';

  // Stripe: Create intent
  static Future<Map<String, dynamic>?> createPaymentIntent({
    required double amount,
    String currency = 'USD',
    String description = 'Ride payment',
    String paymentMethod = 'stripe',
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;
      final response = await http.post(
        Uri.parse('$_apiBase/payments/create-intent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'description': description,
          'paymentMethod': paymentMethod,
        }),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Stripe: Confirm
  static Future<bool> confirmPayment({
    required String transactionId,
    required String paymentIntentId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;
      final response = await http.post(
        Uri.parse('$_apiBase/payments/confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'transactionId': transactionId,
          'paymentIntentId': paymentIntentId,
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // History
  static Future<List<dynamic>> getTransactionHistory({
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];
      final response = await http.get(
        Uri.parse('$_apiBase/payments/history?limit=$limit&skip=$skip'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // Transaction by ID
  static Future<Map<String, dynamic>?> getTransactionById(
    String transactionId,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;
      final response = await http.get(
        Uri.parse('$_apiBase/payments/$transactionId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Compatibility wrapper used by PaymentWebViewScreen
  static Future<Map<String, dynamic>> getTransaction({
    required String transactionId,
    String? baseUrl,
  }) async {
    final token = await AuthService.getToken();
    final api = baseUrl != null ? '${baseUrl}/api' : _apiBase;
    final response = await http.get(
      Uri.parse('$api/payments/$transactionId'),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body['data'] as Map<String, dynamic>;
    }
    throw Exception(
      'Failed to fetch transaction: ${response.statusCode} ${response.body}',
    );
  }

  // Wallet balance
  static Future<double> getWalletBalance() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return 0;
      final response = await http.get(
        Uri.parse('$_apiBase/payments/wallet/balance'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data']['walletBalance'] ?? 0).toDouble();
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  // Refund
  static Future<bool> processRefund({
    required String transactionId,
    String? reason,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;
      final response = await http.post(
        Uri.parse('$_apiBase/payments/refund'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'transactionId': transactionId,
          if (reason != null) 'reason': reason,
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // SSLCommerz session
  static Future<PaymentSession> createSslCommerzSession({
    required double amount,
    String description = 'Ride payment',
  }) async {
    final token = await AuthService.getToken();
    final resp = await http.post(
      Uri.parse('$_apiBase/payments/ssl/session'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'amount': amount,
        'currency': 'BDT',
        'description': description,
      }),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      return PaymentSession.fromJson(data);
    }
    throw Exception(
      'Failed to create SSLCommerz session: ${resp.statusCode} ${resp.body}',
    );
  }
}
