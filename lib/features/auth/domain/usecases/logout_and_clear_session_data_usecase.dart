import '../../../bookings/data/local/bookings_local_datasource.dart';
import '../../../favorites/data/local/favorites_local_datasource.dart';
import '../repositories/auth_repository.dart';

class LogoutAndClearSessionDataUseCase {
  final AuthRepository authRepository;
  final BookingsLocalDataSource bookingsLocalDataSource;
  final FavoritesLocalDataSource favoritesLocalDataSource;

  LogoutAndClearSessionDataUseCase({
    required this.authRepository,
    required this.bookingsLocalDataSource,
    required this.favoritesLocalDataSource,
  });

  Future<void> call() async {
    await authRepository.logout();
    await bookingsLocalDataSource.clear();
    await favoritesLocalDataSource.clear();
  }
}
