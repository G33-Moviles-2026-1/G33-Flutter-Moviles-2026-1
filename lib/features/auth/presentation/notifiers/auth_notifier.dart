import 'dart:async';

import 'package:andespace/core/di/core_provider.dart';
import 'package:andespace/features/auth/domain/entities/user_status.dart';
import 'package:andespace/features/schedule/presentation/notifiers/schedule_notifier.dart';
import 'package:andespace/features/friendships/presentation/providers/friendships_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:andespace/core/di/auth_providers.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_and_fetch_current_user_usecase.dart';
import '../../domain/usecases/logout_and_clear_session_data_usecase.dart';
import '../../domain/usecases/signup_and_fetch_current_user_usecase.dart';
import '../mappers/auth_error_message_mapper.dart';
import 'auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  late final LoginAndFetchCurrentUserUseCase _loginAndFetchCurrentUserUseCase;
  late final SignUpAndFetchCurrentUserUseCase _signUpAndFetchCurrentUserUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final LogoutAndClearSessionDataUseCase _logoutAndClearSessionDataUseCase;
  StreamSubscription<void>? _connectivitySubscription;

  @override
  AuthState build() {
    _loginAndFetchCurrentUserUseCase = ref.read(
      loginAndFetchCurrentUserUseCaseProvider,
    );
    _signUpAndFetchCurrentUserUseCase = ref.read(
      signUpAndFetchCurrentUserUseCaseProvider,
    );
    _getCurrentUserUseCase = ref.read(getCurrentUserUseCaseProvider);
    _logoutAndClearSessionDataUseCase = ref.read(
      logoutAndClearSessionDataUseCaseProvider,
    );
    _connectivitySubscription = ref
        .read(connectivityRecoveryServiceProvider)
        .onRecovered
        .listen((_) {
          _revalidateRemoteSession();
        });

    ref.onDispose(() {
      _connectivitySubscription?.cancel();
    });

    return const AuthState();
  }

  Future<void> _clearFriendshipsCacheForAuthSwitch() async {
    await ref.read(friendshipsLocalDataSourceProvider).clearLocalData();
    ref.invalidate(friendshipsControllerProvider);
  }

  Future<void> loadCurrentUser() async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final user = await _getCurrentUserUseCase();

      state = AuthState(
        isLoading: false,
        isAuthenticated: user != null,
        user: user,
        isSuccess: false,
      );
    } catch (_) {
      state = const AuthState(isLoading: false, isAuthenticated: false);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final user = await _loginAndFetchCurrentUserUseCase(
        email: email,
        password: password,
      );

      if (user != null) {
        await ref.read(appDatabaseProvider).clearFriendshipsLocalData();
        await _refreshScheduleCacheAfterLogin();
      }

      state = AuthState(
        isLoading: false,
        isAuthenticated: user != null,
        user: user,
        isSuccess: true,
      );
    } catch (error) {
      state = AuthState(
        isLoading: false,
        isAuthenticated: false,
        error: mapAuthErrorMessage(
          error,
          fallbackMessage: 'Could not log in. Please try again.',
        ),
      );
    }
    await _clearFriendshipsCacheForAuthSwitch();
  }

  Future<void> signup({
    required String email,
    required String password,
    required String firstSemester,
    String? username,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      final user = await _signUpAndFetchCurrentUserUseCase(
        email: email,
        password: password,
        firstSemester: firstSemester,
      );

      if (user != null) {
        await ref.read(appDatabaseProvider).clearFriendshipsLocalData();
      }

      if (username != null && username.trim().isNotEmpty) {
        try {
          await ref
              .read(authRepositoryProvider)
              .updateUsername(username.trim());
          final updated = user?.copyWith(username: username.trim());
          state = AuthState(
            isLoading: false,
            isAuthenticated: user != null,
            user: updated ?? user,
            isSuccess: true,
          );
          return;
        } catch (_) {        }
      }

      state = AuthState(
        isLoading: false,
        isAuthenticated: user != null,
        user: user,
        isSuccess: true,
      );
    } catch (error) {
      state = AuthState(
        isLoading: false,
        isAuthenticated: false,
        error: mapAuthErrorMessage(
          error,
          fallbackMessage:
              'The account could not be created. Please try again.',
        ),
      );
    }
    await _clearFriendshipsCacheForAuthSwitch();
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      await _logoutAndClearSessionDataUseCase();

      await ref.read(scheduleControllerProvider.notifier).clearLocalSchedule();
      await ref.read(appDatabaseProvider).clearFriendshipsLocalData();

      state = const AuthState(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        isSuccess: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: mapAuthErrorMessage(
          error,
          fallbackMessage: 'Could not log out. Please try again.',
        ),
      );
    }
    await _clearFriendshipsCacheForAuthSwitch();
  }

  void clearState() {
    state = AuthState(isAuthenticated: state.isAuthenticated, user: state.user);
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).updatePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
      state = state.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> updateStatus(String status) async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).updateStatus(status);
      final newStatus = UserStatus.fromBackendKey(status);
      final updated = state.user?.copyWith(status: newStatus);
      state = state.copyWith(isLoading: false, user: updated);
      try {
        ref.read(friendshipsControllerProvider.notifier).syncMyStatus(newStatus);
      } catch (_) {}
    } catch (error) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> updateUsername(String username) async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).updateUsername(username);
      final updated = state.user?.copyWith(username: username);
      state = state.copyWith(isLoading: false, user: updated);
    } catch (error) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  void applyLocalStatus(UserStatus status) {
    final updated = state.user?.copyWith(status: status);
    state = state.copyWith(user: updated);
  }

  Future<void> _refreshScheduleCacheAfterLogin() async {
    try {
      await ref
          .read(scheduleControllerProvider.notifier)
          .loadWeek(refreshFromRemote: true);
    } catch (_) {
      // A schedule sync failure should not block a valid login.
    }
  }

  Future<void> _revalidateRemoteSession() async {
    if (!state.isAuthenticated || state.user == null) return;

    try {
      final user = await _getCurrentUserUseCase();

      if (user == null) {
        ref.read(scheduleControllerProvider.notifier).resetState();
        await ref.read(appDatabaseProvider).clearFriendshipsLocalData();

        state = const AuthState(
          isLoading: false,
          isAuthenticated: false,
          user: null,
          isSuccess: false,
          error: 'Your session expired. Please log in again.',
        );
        return;
      }

      state = state.copyWith(isAuthenticated: true, user: user, error: null);
    } catch (_) {
      // Keep the local-first session if the validation failed for a temporary reason.
    }
  }
}

final authControllerProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
