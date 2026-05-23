import 'dart:async';

import 'package:andespace/core/di/core_provider.dart';
import 'package:andespace/core/error/dio_error_mapper.dart';
import 'package:andespace/features/auth/domain/entities/user_status.dart';
import 'package:andespace/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/friend.dart';
import '../../domain/entities/friendship_request.dart';
import '../../domain/repositories/friendships_repository.dart';
import '../providers/friendships_providers.dart';
import 'friendships_state.dart';

class FriendshipsNotifier extends Notifier<FriendshipsState> {
  FriendshipsRepository get _repository =>
      ref.read(friendshipsRepositoryProvider);

  StreamSubscription<void>? _connectivitySubscription;
  bool _connectivityListenerStarted = false;

  static const String _exceptionPrefix = 'Exception: ';

  @override
  FriendshipsState build() {
    if (!_connectivityListenerStarted) {
      _connectivityListenerStarted = true;

      _connectivitySubscription = ref
          .read(connectivityRecoveryServiceProvider)
          .onRecovered
          .listen((_) {
        refreshAll();
      });

      ref.onDispose(() {
        _connectivitySubscription?.cancel();
      });
    }

    Future.microtask(refreshAll);

    final authStatus =
        ref.read(authControllerProvider).user?.status ?? UserStatus.incognito;

    return FriendshipsState(myStatus: authStatus);
  }

  Future<void> refreshAll() async {
    final currentUser = ref.read(authControllerProvider).user;

    if (currentUser == null) {
      await clearLocalData();
      return;
    }

    await loadFriends();
    await loadOnlineSections();
  }

  Future<void> loadFriends() async {
    final currentUser = ref.read(authControllerProvider).user;

    if (currentUser == null) {
      await clearLocalData();
      return;
    }

    await _repository.ensureLocalCacheForUser(currentUser.email);

    final authStatus = currentUser.status;

    final cachedStatus = await _repository.getCachedMyStatus(
      fallback: authStatus,
    );
    final cachedFriends = await _repository.getCachedFriends();

    state = state.copyWith(
      friends: cachedFriends,
      myStatus: cachedStatus,
      isFriendsLoading: true,
      clearErrorMessage: true,
    );

    try {
      final fresh = await _repository.loadFriends();

      state = state.copyWith(
        isFriendsLoading: false,
        friends: fresh,
      );
    } catch (error) {
      final cachedAfterFailure = await _repository.getCachedFriends();

      state = state.copyWith(
        isFriendsLoading: false,
        friends: cachedAfterFailure,
        errorMessage: cachedAfterFailure.isEmpty ? _mapError(error) : null,
        clearErrorMessage: cachedAfterFailure.isNotEmpty,
      );
    }
  }

Future<void> loadOnlineSections() async {
  final hasInternet = await ref
      .read(connectivityStatusServiceProvider)
      .hasInternetConnection();

  if (!hasInternet) {
    state = state.copyWith(
      onlineSectionsOffline: true,
      isOnlineSectionsLoading: false,
      hasLoadedOnlineSections: true,
      clearRequestsErrorMessage: true,
      clearSuggestionsErrorMessage: true,
    );
    return;
  }

  state = state.copyWith(
    isOnlineSectionsLoading: true,
    onlineSectionsOffline: false,
    clearErrorMessage: true,
    clearRequestsErrorMessage: true,
    clearSuggestionsErrorMessage: true,
  );

  var incoming = state.incomingRequests;
  var outgoing = state.outgoingRequests;
  var suggestions = state.suggestions;

  String? requestsError;
  String? suggestionsError;

  try {
    incoming = await _repository.loadIncomingRequests();
    outgoing = await _repository.loadOutgoingRequests();
  } catch (error) {
    requestsError = _mapError(
      error,
      fallback: 'Could not load pending requests. Pull to retry.',
    );
  }

  try {
    suggestions = await _repository.loadSuggestions();
  } catch (error) {
    suggestionsError = _mapError(
      error,
      fallback: 'Could not load friend suggestions. Pull to retry.',
    );
  }

  state = state.copyWith(
    isOnlineSectionsLoading: false,
    incomingRequests: incoming,
    outgoingRequests: outgoing,
    suggestions: suggestions,
    requestsErrorMessage: requestsError,
    suggestionsErrorMessage: suggestionsError,
    hasLoadedOnlineSections: true,
  );
}

  void setAddFriendInput(String value) {
    state = state.copyWith(addFriendInput: value);
  }

Future<bool> sendFriendRequest([String? rawUsername]) async {
  final username = (rawUsername ?? state.addFriendInput).trim().toLowerCase();

  if (username.length > 25) {
    state = state.copyWith(
      errorMessage: 'Username cannot be longer than 25 characters.',
    );
    return false;
  }

  final validUsernamePattern = RegExp(r'^[a-z0-9._-]+$');
  if (!validUsernamePattern.hasMatch(username)) {
    state = state.copyWith(
      errorMessage:
          'Username can only contain letters, numbers, dots, underscores, or hyphens.',
    );
    return false;
  }

  if (username.isEmpty) {
    state = state.copyWith(errorMessage: 'Type a username first.');
    return false;
  }

  final hasInternet = await ref
      .read(connectivityStatusServiceProvider)
      .hasInternetConnection();

  if (!hasInternet) {
    state = state.copyWith(
      errorMessage:
          'No internet connection. Friend requests cannot be sent offline.',
    );
    return false;
  }

  state = state.copyWith(
    pendingFriendUsernames: {...state.pendingFriendUsernames, username},
    clearErrorMessage: true,
  );

  try {
    await _repository.sendFriendRequest(username);

    state = state.copyWith(
      addFriendInput: '',
      suggestions: state.suggestions
          .where((suggestion) => suggestion.toLowerCase() != username)
          .toList(),
    );

    await loadOnlineSections();
    return true;
  } catch (error) {
    final message = _mapError(error);
    final lowerMessage = message.toLowerCase();

    final alreadyExistsOrPending =
        lowerMessage.contains('already exists') ||
        lowerMessage.contains('pending');

    await loadOnlineSections();

    final alreadyVisible = state.pendingRequests.any(
      (request) => request.username.toLowerCase() == username,
    );

    if (alreadyExistsOrPending && alreadyVisible) {
      state = state.copyWith(
        addFriendInput: '',
        clearErrorMessage: true,
      );
      return true;
    }

    if (alreadyExistsOrPending && !alreadyVisible) {
      state = state.copyWith(
        errorMessage:
            'This friendship already exists or is pending, but it was not returned by the pending requests endpoint yet.',
      );
      return false;
    }

    state = state.copyWith(errorMessage: message);
    return false;
  } finally {
    state = state.copyWith(
      pendingFriendUsernames: {...state.pendingFriendUsernames}
        ..remove(username),
    );
  }
}

  Future<void> acceptRequest(String username) async {
    final hasInternet = await ref
        .read(connectivityStatusServiceProvider)
        .hasInternetConnection();

    if (!hasInternet) {
      state = state.copyWith(
        errorMessage:
            'No internet connection. Requests cannot be accepted offline.',
      );
      return;
    }

    try {
      await _repository.acceptFriendRequest(username);
      await refreshAll();
    } catch (error) {
      state = state.copyWith(errorMessage: _mapError(error));
    }
  }

  Future<void> declineOrCancelRequest(String username) async {
    final hasInternet = await ref
        .read(connectivityStatusServiceProvider)
        .hasInternetConnection();

    if (!hasInternet) {
      state = state.copyWith(
        errorMessage:
            'No internet connection. Requests cannot be changed offline.',
      );
      return;
    }

    try {
      await _repository.declineOrCancelRequest(username);
      await loadOnlineSections();
    } catch (error) {
      state = state.copyWith(errorMessage: _mapError(error));
    }
  }

  Future<void> removeFriend(Friend friend) async {
    state = state.copyWith(
      friends: state.friends.where((f) => f.email != friend.email).toList(),
      pendingFriendUsernames: {
        ...state.pendingFriendUsernames,
        friend.username,
      },
      clearErrorMessage: true,
    );

    try {
      await _repository.removeFriend(friend);

      final cached = await _repository.getCachedFriends();
      state = state.copyWith(friends: cached);
    } catch (error) {
      final cached = await _repository.getCachedFriends();

      state = state.copyWith(
        friends: cached,
        errorMessage: _mapError(error),
      );
    } finally {
      state = state.copyWith(
        pendingFriendUsernames: {...state.pendingFriendUsernames}
          ..remove(friend.username),
      );
    }
  }

  Future<void> updateMyStatus(UserStatus status) async {
    final previous = state.myStatus;

    state = state.copyWith(
      myStatus: status,
      clearErrorMessage: true,
    );

    ref.read(authControllerProvider.notifier).applyLocalStatus(status);

    try {
      await _repository.updateMyStatus(status);
    } catch (error) {
      state = state.copyWith(
        myStatus: previous,
        errorMessage: _mapError(error),
      );
      ref.read(authControllerProvider.notifier).applyLocalStatus(previous);
    }
  }

  Future<void> clearLocalData() async {
    await _repository.clearLocalData();

    state = state.copyWith(
      friends: const [],
      incomingRequests: const [],
      outgoingRequests: const [],
      suggestions: const [],
      myStatus: UserStatus.incognito,
      pendingFriendUsernames: const {},
      addFriendInput: '',
      onlineSectionsOffline: false,
      clearErrorMessage: true,
    );
  }

  String _mapError(
    Object error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    final mapped = DioErrorMapper.map(
      error,
      fallback: fallback,
      onBadResponse: (statusCode, detail) {
        if (detail != null && detail.trim().isNotEmpty) {
          return detail.trim();
        }

        if (statusCode == 404) return 'User was not found.';
        if (statusCode == 409) {
          return 'This friendship already exists or is pending.';
        }
        if (statusCode == 401) return 'Please log in again.';

        return fallback;
      },
    );

    return mapped.replaceFirst(_exceptionPrefix, '');
  }
}