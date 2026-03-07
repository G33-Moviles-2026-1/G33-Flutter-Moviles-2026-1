import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<void> call({
    required String email,
    required String password,
    required String firstSemester,
  }) {
    return repository.signup(email: email, password: password, firstSemester: firstSemester);
  }
}