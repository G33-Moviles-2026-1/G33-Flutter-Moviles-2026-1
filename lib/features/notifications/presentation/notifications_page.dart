import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/features/notifications/presentation/notifiers/notifications_notifier.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(notificationsControllerProvider);
    final notifier = ref.read(notificationsControllerProvider.notifier);

    final hasContent =
        state.pendingRequests.isNotEmpty || state.items.isNotEmpty;

    return AppScaffold(
      currentTab: AppTab.rooms,
      onTabSelected: (tab) => AppRoutes.handleTabSelection(context, tab),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
            child: Row(
              children: [
                Text(
                  'Notifications',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (state.unread > 0)
                  TextButton(
                    onPressed: notifier.markAllRead,
                    child: const Text('Mark all read'),
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: notifier.refresh,
                ),
              ],
            ),
          ),
          Expanded(
            child: !hasContent
                ? Center(
                    child: Text(
                      'No notifications yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      if (state.pendingRequests.isNotEmpty) ...[
                        _SectionLabel(
                          label: 'Friend Requests',
                          count: state.pendingRequests.length,
                        ),
                        ...state.pendingRequests.map(
                          (req) => ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.secondary,
                              child: Icon(
                                Icons.person_add,
                                color: theme.colorScheme.onSecondary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              req.username.isNotEmpty
                                  ? req.username
                                  : req.email,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              req.email,
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: FilledButton(
                              onPressed: () => Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.friends,
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    theme.colorScheme.secondary,
                                foregroundColor:
                                    theme.colorScheme.onSecondary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('View'),
                            ),
                          ),
                        ),
                        if (state.items.isNotEmpty)
                          const Divider(height: 24),
                      ],
                      if (state.items.isNotEmpty) ...[
                        if (state.pendingRequests.isNotEmpty)
                          _SectionLabel(label: 'Activity'),
                        ...state.items.asMap().entries.map((entry) {
                          final i = entry.key;
                          final n = entry.value;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (i > 0) const Divider(height: 1),
                              ListTile(
                                leading: Icon(
                                  n.isRead
                                      ? Icons.notifications_none
                                      : Icons.notifications_active,
                                  color: n.isRead
                                      ? theme.colorScheme.onSurface
                                          .withValues(alpha: 0.4)
                                      : theme.colorScheme.secondary,
                                ),
                                title: Text(
                                  n.displayMessage,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: n.isRead
                                        ? FontWeight.normal
                                        : FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  _formatDate(n.createdAt),
                                  style: theme.textTheme.bodySmall,
                                ),
                                onTap: n.isRead
                                    ? null
                                    : () => notifier.markRead(n.id),
                              ),
                            ],
                          );
                        }),
                      ],
                    ],
                  ),
          ),
        ],
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.count});
  final String label;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
