import 'dart:async';

import 'package:andespace/core/di/core_provider.dart';
import 'package:andespace/features/auth/domain/entities/user_status.dart';
import 'package:andespace/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:andespace/features/auth/presentation/notifiers/auth_state.dart';
import 'package:andespace/features/friendships/domain/entities/friendship_request.dart';
import 'package:andespace/features/notifications/data/local/notifications_local_datasource.dart';
import 'package:andespace/features/notifications/data/remote/notifications_api.dart';
import 'package:andespace/features/notifications/domain/entities/app_notification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsState {
  final int total;
  final int unread;
  final List<AppNotification> items;
  final List<FriendshipRequest> pendingRequests;

  const NotificationsState({
    this.total = 0,
    this.unread = 0,
    this.items = const [],
    this.pendingRequests = const [],
  });

  int get badgeCount => unread + pendingRequests.length;

  NotificationsState copyWith({
    int? total,
    int? unread,
    List<AppNotification>? items,
    List<FriendshipRequest>? pendingRequests,
  }) {
    return NotificationsState(
      total: total ?? this.total,
      unread: unread ?? this.unread,
      items: items ?? this.items,
      pendingRequests: pendingRequests ?? this.pendingRequests,
    );
  }
}

class NotificationsNotifier extends Notifier<NotificationsState> {
  Timer? _timer;

  @override
  NotificationsState build() {
    ref.listen<AuthState>(authControllerProvider, (_, next) {
      _onAuthChanged(next);
    });

    ref.onDispose(() => _timer?.cancel());

    final authState = ref.read(authControllerProvider);
    if (_shouldPoll(authState)) {
      Future.microtask(_poll);
      _timer = Timer.periodic(const Duration(seconds: 10), (_) => _poll());
    }

    return const NotificationsState();
  }

  bool _shouldPoll(AuthState auth) => auth.isAuthenticated;

  void _onAuthChanged(AuthState auth) {
    _timer?.cancel();
    if (_shouldPoll(auth)) {
      _poll();
      _timer = Timer.periodic(const Duration(seconds: 10), (_) => _poll());
    } else {
      state = const NotificationsState();
    }
  }

  Future<void> _poll() async {
    final hasInternet = await ref
        .read(connectivityStatusServiceProvider)
        .hasInternetConnection();

    if (!hasInternet) {
      await _loadFromCache();
      return;
    }

    try {
      final notifData = await ref.read(notificationsApiProvider).getNotifications();

      final allNotifications = (notifData['items'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList();

      final pendingRequests = allNotifications
          .where((n) => n.type == 'friend_request_received')
          .map(
            (n) => FriendshipRequest(
              email: n.payload['from_email'] as String? ?? '',
              username: n.payload['from_username'] as String? ?? '',
              status: UserStatus.incognito,
              isIncoming: true,
            ),
          )
          .toList();

      final items = allNotifications
          .where((n) => n.type != 'friend_request_received')
          .toList();

      state = state.copyWith(
        total: notifData['total'] as int? ?? 0,
        unread: notifData['unread'] as int? ?? 0,
        items: items,
        pendingRequests: pendingRequests,
      );

      _saveToCache(items).ignore();
    } catch (_) {
      await _loadFromCache();
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final cached = await ref
          .read(notificationsLocalDataSourceProvider)
          .getSavedNotifications();
      if (cached.isNotEmpty) {
        state = state.copyWith(items: cached);
      }
    } catch (_) {}
  }

  Future<void> _saveToCache(List<AppNotification> items) async {
    try {
      await ref
          .read(notificationsLocalDataSourceProvider)
          .saveNotifications(items);
    } catch (_) {}
  }

  Future<void> markRead(String id) async {
    try {
      await ref.read(notificationsApiProvider).markRead(id);
      state = state.copyWith(
        unread: (state.unread - 1).clamp(0, state.total),
        items: state.items
            .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
            .toList(),
      );
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await ref.read(notificationsApiProvider).markAllRead();
      state = state.copyWith(
        unread: 0,
        items: state.items.map((n) => n.copyWith(isRead: true)).toList(),
      );
    } catch (_) {}
  }

  Future<void> deleteOne(String id) async {
    try {
      await ref.read(notificationsApiProvider).deleteOne(id);
    } catch (_) {}
    final updated = state.items.where((n) => n.id != id).toList();
    final wasUnread = state.items.any((n) => n.id == id && !n.isRead);
    state = state.copyWith(
      items: updated,
      total: (state.total - 1).clamp(0, state.total),
      unread: wasUnread ? (state.unread - 1).clamp(0, state.unread) : state.unread,
    );
    _saveToCache(updated).ignore();
  }

  Future<void> clearAll() async {
    try {
      await ref.read(notificationsApiProvider).markAllRead();
    } catch (_) {}
    try {
      await ref.read(notificationsApiProvider).deleteRead();
    } catch (_) {}
    try {
      await ref
          .read(notificationsLocalDataSourceProvider)
          .saveNotifications([]);
    } catch (_) {}
    state = state.copyWith(unread: 0, total: 0, items: []);
  }

  Future<void> refresh() => _poll();
}

final notificationsApiProvider = Provider<NotificationsApi>((ref) {
  return NotificationsApi(ref.watch(dioProvider));
});

final notificationsLocalDataSourceProvider =
    Provider<NotificationsLocalDataSource>((ref) {
  throw UnimplementedError(
    'notificationsLocalDataSourceProvider must be overridden in main.dart',
  );
});

final notificationsControllerProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);
