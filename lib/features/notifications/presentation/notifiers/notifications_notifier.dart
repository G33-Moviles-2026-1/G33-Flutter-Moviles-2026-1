import 'dart:async';

import 'package:andespace/core/di/core_provider.dart';
import 'package:andespace/features/auth/domain/entities/user_status.dart';
import 'package:andespace/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:andespace/features/auth/presentation/notifiers/auth_state.dart';
import 'package:andespace/features/notifications/data/remote/notifications_api.dart';
import 'package:andespace/features/notifications/domain/entities/app_notification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsState {
  final int total;
  final int unread;
  final List<AppNotification> items;

  const NotificationsState({
    this.total = 0,
    this.unread = 0,
    this.items = const [],
  });

  NotificationsState copyWith({
    int? total,
    int? unread,
    List<AppNotification>? items,
  }) {
    return NotificationsState(
      total: total ?? this.total,
      unread: unread ?? this.unread,
      items: items ?? this.items,
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

  bool _shouldPoll(AuthState auth) =>
      auth.isAuthenticated && auth.user?.status != UserStatus.incognito;

  void _onAuthChanged(AuthState auth) {
    _timer?.cancel();
    if (_shouldPoll(auth)) {
      _poll();
      _timer = Timer.periodic(const Duration(seconds: 10), (_) => _poll());
    } else if (!auth.isAuthenticated) {
      state = const NotificationsState();
    }
  }

  Future<void> _poll() async {
    final hasInternet = await ref
        .read(connectivityStatusServiceProvider)
        .hasInternetConnection();
    if (!hasInternet) return;

    try {
      final data = await ref.read(notificationsApiProvider).getNotifications();
      final items = (data['items'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList();

      state = state.copyWith(
        total: data['total'] as int? ?? 0,
        unread: data['unread'] as int? ?? 0,
        items: items,
      );
    } catch (_) {
    }
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

  Future<void> refresh() => _poll();
}

final notificationsApiProvider = Provider<NotificationsApi>((ref) {
  return NotificationsApi(ref.watch(dioProvider));
});

final notificationsControllerProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);
