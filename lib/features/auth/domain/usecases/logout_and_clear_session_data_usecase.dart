import '../../../bookings/data/local/bookings_local_datasource.dart';
import '../../../favorites/data/local/favorites_local_datasource.dart';
import '../../../schedule/data/local/schedule_local_data_source.dart';
import '../repositories/auth_repository.dart';

class LogoutAndClearSessionDataUseCase {
  final AuthRepository authRepository;
  final BookingsLocalDataSource bookingsLocalDataSource;
  final FavoritesLocalDataSource favoritesLocalDataSource;
  final ScheduleLocalDataSource scheduleLocalDataSource;

  LogoutAndClearSessionDataUseCase({
    required this.authRepository,
    required this.bookingsLocalDataSource,
    required this.favoritesLocalDataSource,
    required this.scheduleLocalDataSource,
  });

  Future<void> call() async {
    await authRepository.logout();

    await Future.wait([
      bookingsLocalDataSource.clear(),
      favoritesLocalDataSource.clear(),
      scheduleLocalDataSource.clearSchedule(),
    ]);
  }
}