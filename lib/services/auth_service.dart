import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static const _keyUser = 'auth_user';
  static const _keyLastUsername = 'last_username';

  static Future<UserModel> login(String username, String password) async {
    final user = await ApiService.login(username, password);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toMap()));
    await prefs.setString(_keyLastUsername, username);

    return user;
  }

  static Future<String?> getLastUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastUsername);
  }

  static Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_keyUser);
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }
}
