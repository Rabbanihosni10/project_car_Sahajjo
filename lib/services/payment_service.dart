import 'package:http/http.dart' as http;
import 'package:cars_ahajjo/utils/constrains.dart';
import 'package:cars_ahajjo/services/auth_services.dart';
import 'dart:convert';

class PaymentService {
  static const String _baseUrl = AppConstraints.baseUrl;
  static final AuthService _authService = AuthService();

  /// Create payment intent
  static Future<Map<String, dynamic>?> createPaymentIntent({
    required double amount,
    required String currency,
    required String description,
    required String paymentMethod,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('$_baseUrl/payments/create-intent'),
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
      } else {
        print('Error creating payment intent: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Confirm payment
  static Future<bool> confirmPayment({
    required String transactionId,
    required String paymentIntentId,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/payments/confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'transactionId': transactionId,
          'paymentIntentId': paymentIntentId,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error confirming payment: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  /// Get transaction history
  static Future<List<dynamic>> getTransactionHistory({
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/payments/history?limit=$limit&skip=$skip'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        print('Error fetching transactions: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  /// Get specific transaction
  static Future<Map<String, dynamic>?> getTransaction(
    String transactionId,
  ) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/payments/$transactionId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        print('Error fetching transaction: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Get wallet balance
  static Future<double> getWalletBalance() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return 0;

      final response = await http.get(
        Uri.parse('$_baseUrl/payments/wallet/balance'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data']['walletBalance'] ?? 0).toDouble();
      } else {
        return 0;
      }
    } catch (e) {
      print('Error: $e');
      return 0;
    }
  }

  /// Process refund
  static Future<bool> processRefund({
    required String transactionId,
    String? reason,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/payments/refund'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'transactionId': transactionId,
          if (reason != null) 'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error processing refund: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
