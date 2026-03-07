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

  Future<String?> me() async {
    final response = await dio.get('/me/');
    return response.data['active_user'] as String?;
  }
}