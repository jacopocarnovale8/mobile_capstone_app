import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  static const _usersKey = 'users';
  static const _currentUserKey = 'current_user';

  static Future<Map<String, dynamic>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    final e = email.trim().toLowerCase();

    if (username.trim().isEmpty) {
      throw AuthException('Username is required');
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e)) {
      throw AuthException('Please enter a valid email');
    }
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }

    final users = await _getUsers();
    if (users.containsKey(e)) {
      throw AuthException('An account with this email already exists');
    }

    users[e] = {'username': username.trim(), 'password': password};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final e = email.trim().toLowerCase();
    final users = await _getUsers();
    final user = users[e];

    if (user == null || user['password'] != password) {
      throw AuthException('Invalid email or password');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, e);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey) != null;
  }

  static Future<String?> currentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_currentUserKey);
    if (email == null) return null;
    final users = await _getUsers();
    return users[email]?['username'] as String?;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }
}