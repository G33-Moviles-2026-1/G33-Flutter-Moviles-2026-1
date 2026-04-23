import 'package:andespace/features/auth/domain/usecases/get_current_user_usecase.dart';

class GetAuthenticatedUserEmailUseCase {
  final GetCurrentUserUseCase getCurrentUserUseCase;

  GetAuthenticatedUserEmailUseCase(this.getCurrentUserUseCase);

  Future<String> call() async {
    final currentUser = await getCurrentUserUseCase();
    final email = currentUser?.email ?? '';

    if (email.trim().isEmpty) {
      throw Exception('No authenticated user email found.');
    }

    return email;
  }
}