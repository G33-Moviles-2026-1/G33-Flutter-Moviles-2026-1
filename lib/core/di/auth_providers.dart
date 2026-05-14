import 'package:andespace/features/auth/data/local/auth_local_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core_provider.dart';

import '../../features/auth/data/remote/auth_api.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_and_fetch_current_user_usecase.dart';
import '../../features/auth/domain/usecases/logout_and_clear_session_data_usecase.dart';
import '../../features/auth/domain/usecases/signup_and_fetch_current_user_usecase.dart';

import '../../features/bookings/presentation/providers/bookings_providers.dart';
import '../../features/favorites/presentation/providers/favorites_providers.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    api: ref.watch(authApiProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final loginAndFetchCurrentUserUseCaseProvider =
    Provider<LoginAndFetchCurrentUserUseCase>((ref) {
      return LoginAndFetchCurrentUserUseCase(ref.watch(authRepositoryProvider));
    });

final signUpAndFetchCurrentUserUseCaseProvider =
    Provider<SignUpAndFetchCurrentUserUseCase>((ref) {
      return SignUpAndFetchCurrentUserUseCase(
        ref.watch(authRepositoryProvider),
      );
    });

final logoutAndClearSessionDataUseCaseProvider =
    Provider<LogoutAndClearSessionDataUseCase>((ref) {
      return LogoutAndClearSessionDataUseCase(
        authRepository: ref.watch(authRepositoryProvider),
        bookingsRepository: ref.watch(bookingsRepositoryProvider),
        favoritesRepository: ref.watch(favoritesRepositoryProvider),
      );
    });

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl();
});
