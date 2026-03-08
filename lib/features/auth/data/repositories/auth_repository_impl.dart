import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api.dart';
import '../models/auth_request_dto.dart';
import '../models/auth_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi api;

  AuthRepositoryImpl(this.api);

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await api.login(LoginRequestDto(email: email, password: password));
  }

  @override
  Future<void> signup({
    required String email,
    required String password,
    required String firstSemester,
  }) async {
    await api.signup(
      SignUpRequestDto(
        email: email,
        password: password,
        firstSemester: firstSemester,
      ),
    );
  }

  @override
  Future<void> logout() async {
    await api.logout();
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    final data = await api.me();

    final activeUser = data['active_user'];
    if (activeUser == null) return null;

    final model = AuthUserModel.fromMeResponse(data);
    return model.toEntity();
  }
}