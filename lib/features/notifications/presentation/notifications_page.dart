import 'package:andespace/features/notifications/presentation/notifiers/notifications_notifier.dart';
import 'package:andespace/shared/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>()!;
    final state = ref.watch(notificationsControllerProvider);
    final notifier = ref.read(notificationsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: brand.headerBackground,
        foregroundColor: brand.headerForeground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (state.unread > 0)
            TextButton(
              onPressed: notifier.markAllRead,
              child: Text(
                'Mark all read',
                style: TextStyle(color: brand.headerForeground),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: notifier.refresh,
          ),
        ],
      ),
      body: state.items.isEmpty
          ? Center(
              child: Text(
                'No notifications yet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = state.items[index];
                return ListTile(
                  leading: Icon(
                    n.isRead
                        ? Icons.notifications_none
                        : Icons.notifications_active,
                    color: n.isRead
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                        : theme.colorScheme.secondary,
                  ),
                  title: Text(
                    n.displayMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          n.isRead ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    _formatDate(n.createdAt),
                    style: theme.textTheme.bodySmall,
                  ),
                  onTap: n.isRead ? null : () => notifier.markRead(n.id),
                );
              },
            ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
