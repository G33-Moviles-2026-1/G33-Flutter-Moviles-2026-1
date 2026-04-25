import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignUpAndFetchCurrentUserUseCase {
  final AuthRepository repository;

  SignUpAndFetchCurrentUserUseCase(this.repository);

  Future<AuthUser?> call({
    required String email,
    required String password,
    required String firstSemester,
  }) async {
    await repository.signup(
      email: email,
      password: password,
      firstSemester: firstSemester,
    );

    return repository.getCurrentUser();
  }
}