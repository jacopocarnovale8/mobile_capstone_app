import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class LocalStorage {
  static const _favoritesKey = 'favorites';

  static Future<List<Product>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_favoritesKey) ?? [];
    return raw
        .map((s) => Product.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  static Future<bool> isFavorite(int id) async {
    final favs = await getFavorites();
    return favs.any((p) => p.id == id);
  }

  static Future<void> addFavorite(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = await getFavorites();
    if (favs.any((p) => p.id == product.id)) return;
    favs.add(product);
    await prefs.setStringList(
      _favoritesKey,
      favs.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  static Future<void> removeFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = await getFavorites();
    favs.removeWhere((p) => p.id == id);
    await prefs.setStringList(
      _favoritesKey,
      favs.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  /// Returns true if the product is now a favorite.
  static Future<bool> toggleFavorite(Product product) async {
    if (await isFavorite(product.id)) {
      await removeFavorite(product.id);
      return false;
    }
    await addFavorite(product);
    return true;
  }
}