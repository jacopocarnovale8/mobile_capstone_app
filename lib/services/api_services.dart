import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const _baseUrl = 'https://dummyjson.com';

  static Future<List<Product>> fetchProducts() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/products?limit=30'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Failed to load products (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['products'] as List<dynamic>;
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Product> fetchProduct(int id) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/products/$id'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Failed to load product (${response.statusCode})');
    }
    return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}