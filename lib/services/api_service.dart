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

    final url = Uri.parse('$baseUrl/crm-login');

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
      final userJson = (data['user'] as Map<String, dynamic>?) ?? data;

      if (token == null) {
        throw ApiException('Token not found');
      }
      return UserModel.fromJson(userJson, token);
    } else {
      final msg = data['message']?.toString() ?? 'Login failed';
      throw ApiException(msg);
    }
  }


  static Future<List<SmsModel>> getLatestSms(String token, {int limit = 5}) async {
    // 🚧 TODO: Replace with real API call once endpoint is ready
    // final url = Uri.parse('$baseUrl/sms/latest');
    // final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      SmsModel(
        id: 1,
        number: '03001234567',
        message: 'Your OTP is 4521. Do not share with anyone.',
        status: 'delivered',
        dateTime: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      SmsModel(
        id: 2,
        number: '03007654321',
        message: 'Fee reminder: Your dues are payable by 15th Aug.',
        status: 'delivered',
        dateTime: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      SmsModel(
        id: 3,
        number: '03211112222',
        message: 'Result announced. Check portal for details.',
        status: 'pending',
        dateTime: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      SmsModel(
        id: 4,
        number: '03339998888',
        message: 'Class rescheduled to 3 PM tomorrow.',
        status: 'failed',
        dateTime: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      SmsModel(
        id: 5,
        number: '03451234567',
        message: 'Welcome to EduBest CRM portal.',
        status: 'delivered',
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
