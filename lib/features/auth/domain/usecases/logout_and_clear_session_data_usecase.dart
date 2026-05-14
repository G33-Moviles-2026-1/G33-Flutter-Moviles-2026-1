import '../../../bookings/domain/repositories/bookings_repository.dart';
import '../../../favorites/domain/repositories/favorites_repository.dart';
import '../repositories/auth_repository.dart';

class LogoutAndClearSessionDataUseCase {
  final AuthRepository authRepository;
  final BookingsRepository bookingsRepository;
  final FavoritesRepository favoritesRepository;

  LogoutAndClearSessionDataUseCase({
    required this.authRepository,
    required this.bookingsRepository,
    required this.favoritesRepository,
  });

  Future<void> call() async {
    await authRepository.logout();
    await bookingsRepository.clearLocalData();
    await favoritesRepository.clearLocalData();
  }
}
