import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../models/product_model.dart';

/// Thin HTTP wrapper. Throws [ApiException] on any failure.
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Product>> fetchProducts() async {
    final uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.productsEndpoint}');
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw ApiException(
        'Failed to load products (HTTP ${response.statusCode})',
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
