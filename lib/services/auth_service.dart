import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  // Secure storage for persisting the auth token safely.
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'auth_token';

  String? _token;

  String? get token => _token;

  bool get isAuthenticated => _token != null;

  AuthService() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    _token = await _storage.read(key: _tokenKey);
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    const baseUrl = 'https://hardlopen.metvirgil.nl';
    final url = Uri.parse('$baseUrl/api/login');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _token = data['token'] as String?;
        if (_token != null) {
          await _storage.write(key: _tokenKey, value: _token);
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
    }
    return false;
  }

  Future<void> logout() async {
    _token = null;
    await _storage.delete(key: _tokenKey);
    notifyListeners();
  }
} 