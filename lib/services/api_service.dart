import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/sms_model.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = 'https://edubest.edubestcloud.com/api';

  static Future<UserModel> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      final token = data['token']?.toString();
      final userJson = data['user'] as Map<String, dynamic>?;

      if (token == null || userJson == null) {
        throw ApiException('Response invalid');
      }
      return UserModel.fromJson(userJson, token);
    } else {
      final msg = data['message']?.toString() ?? 'Login failed';
      throw ApiException(msg);
    }
  }


  static Future<List<SmsModel>> getLatestSms(String token, {int limit = 5}) async {
    final url = Uri.parse('$baseUrl/sms/latest?limit=$limit');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List rawList = decoded is List ? decoded : (decoded['data'] ?? []);

      return rawList
          .map((e) => SmsModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw ApiException('Session expired or invalid');
    } else {
      throw ApiException('SMS load failed (code ${response.statusCode})');
    }
  }
}