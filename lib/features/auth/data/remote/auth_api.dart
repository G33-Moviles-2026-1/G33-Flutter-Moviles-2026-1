import 'package:dio/dio.dart';
import '../models/auth_request_dto.dart';

class AuthApi {
  final Dio dio;

  AuthApi(this.dio);

  Future<void> login(LoginRequestDto dto) async {
    await dio.post('/login/', data: dto.toJson());
  }

  Future<void> signup(SignUpRequestDto dto) async {
    await dio.post('/signup/', data: dto.toJson());
  }

  Future<void> logout() async {
    await dio.post('/logout/');
  }

  Future<Map<String, dynamic>> me() async {
    final response = await dio.get('/me/');
    final data = Map<String, dynamic>.from(response.data as Map);

    final activeUser = data['active_user'];
    if (activeUser == null) return data;

    try {
      final profileResponse = await dio.get('/me/profile');
      final profile = Map<String, dynamic>.from(profileResponse.data as Map);

      data['active_user'] = profile['email'] ?? activeUser;
      data['username'] = profile['username'];
      data['status'] = profile['status'];
    } catch (_) {
      // Keep /me/ response if profile fails temporarily.
    }

    return data;
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await dio.put('/me/password/', data: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  Future<void> updateStatus(String status) async {
    await dio.put('/me/status/', data: {'status': status});
  }

  Future<void> updateUsername(String username) async {
    await dio.put('/me/username/', data: {'username': username});
  }
}