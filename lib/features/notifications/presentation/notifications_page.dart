import 'package:andespace/core/di/core_provider.dart';
import 'package:andespace/features/notifications/data/remote/notifications_api.dart';
import 'package:andespace/features/notifications/domain/entities/app_notification.dart';
import 'package:andespace/shared/theme/app_theme_extension.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _notificationsApiProvider = Provider<NotificationsApi>((ref) {
  return NotificationsApi(ref.watch(dioProvider));
});

final _notificationsProvider =
    FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  final api = ref.watch(_notificationsApiProvider);
  final raw = await api.getNotifications();
  return raw.map((json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      message: json['message'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }).toList();
});

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final _readIds = <String>{};

  Future<void> _markRead(String id) async {
    try {
      await ref.read(_notificationsApiProvider).markRead(id);
      setState(() => _readIds.add(id));
    } on DioException {
      // silent — notification stays unread locally
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>()!;
    final async = ref.watch(_notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: brand.headerBackground,
        foregroundColor: brand.headerForeground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(_notificationsProvider),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load notifications.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final n = notifications[index];
              final isRead = n.isRead || _readIds.contains(n.id);

              return ListTile(
                leading: Icon(
                  isRead
                      ? Icons.notifications_none
                      : Icons.notifications_active,
                  color: isRead
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                      : theme.colorScheme.secondary,
                ),
                title: Text(
                  n.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        isRead ? FontWeight.normal : FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _formatDate(n.createdAt),
                  style: theme.textTheme.bodySmall,
                ),
                onTap: isRead ? null : () => _markRead(n.id),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
