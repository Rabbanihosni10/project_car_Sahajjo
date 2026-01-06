import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cars_ahajjo/utils/constrains.dart';

class MarketplaceService {
  static const String _productsEndpoint = '/marketplace/products';
  static const String _cartEndpoint = '/marketplace/cart';
  static const String _ordersEndpoint = '/marketplace/orders';

  static String get _baseUrl => '${AppConstants.baseUrl}$_productsEndpoint';
  static String get _cartUrl => '${AppConstants.baseUrl}$_cartEndpoint';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ===== PRODUCTS =====
  /// Get all marketplace products with optional filters
  static Future<List<Map<String, dynamic>>> getProducts({
    String? category,
    String? search,
    String? sortBy,
  }) async {
    try {
      String url = _baseUrl;
      final params = <String, String>{};
      if (category != null) params['category'] = category;
      if (search != null) params['search'] = search;
      if (sortBy != null) params['sortBy'] = sortBy;

      if (params.isNotEmpty) {
        url += '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = List<Map<String, dynamic>>.from(data['data'] ?? []);
        return products;
      }
      print('Error fetching products: ${response.body}');
      return [];
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  /// Get single product details
  static Future<Map<String, dynamic>?> getProductDetails(
    String productId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$productId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // ===== CART MANAGEMENT =====
  /// Get user's cart
  static Future<Map<String, dynamic>?> getCart() async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(_cartUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Add product to cart
  static Future<bool> addToCart(String productId, int quantity) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$_cartUrl/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'productId': productId, 'quantity': quantity}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  /// Remove product from cart
  static Future<bool> removeFromCart(String productId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$_cartUrl/remove/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  /// Update cart item quantity
  static Future<bool> updateCartQuantity(String productId, int quantity) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await http.patch(
        Uri.parse('$_cartUrl/$productId/quantity'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'quantity': quantity}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  // ===== CHECKOUT & ORDERS =====
  /// Create order from cart
  static Future<Map<String, dynamic>?> checkout({
    required String shippingAddress,
    String paymentMethod = 'cash_on_delivery',
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}$_ordersEndpoint/checkout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'shippingAddress': shippingAddress,
          'paymentMethod': paymentMethod,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>?;
      }
      print('Checkout error: ${response.body}');
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  /// Get user's orders
  static Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}$_ordersEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  /// Get order details
  static Future<Map<String, dynamic>?> getOrderDetails(String orderId) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}$_ordersEndpoint/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
