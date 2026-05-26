import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:andespace/features/notifications/domain/entities/app_notification.dart';
import 'package:andespace/features/notifications/presentation/notifiers/notifications_notifier.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';
import 'package:andespace/shared/widgets/auth_required_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (!authState.hasActiveSession) {
      return AuthRequiredScaffold(
        currentTab: AppTab.rooms,
        onTabSelected: (tab) => AppRoutes.handleTabSelection(context, tab),
        title: 'Log in to view notifications',
        message: 'Sign in to see your activity and friend requests.',
      );
    }

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
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                if (state.items.isNotEmpty)
                  IconButton(
                    tooltip: 'Clear all',
                    icon: const Icon(Icons.delete_sweep_outlined),
                    onPressed: () => _confirmClear(context, notifier),
                  ),
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
                              backgroundColor: theme.colorScheme.secondary,
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
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              req.email,
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: FilledButton(
                              onPressed: () =>
                                  Navigator.pushNamed(
                                context,
                                AppRoutes.addFriends,
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    theme.colorScheme.secondary,
                                foregroundColor:
                                    theme.colorScheme.onSecondary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
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
                              Dismissible(
                                key: ValueKey(n.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  color: Theme.of(context).colorScheme.error,
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (_) => notifier.deleteOne(n.id),
                                child: _NotificationTile(
                                  notification: n,
                                  onTap: () {
                                    if (!n.isRead) notifier.markRead(n.id);
                                    _showDetail(context, n);
                                  },
                                ),
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

  void _confirmClear(
      BuildContext context, NotificationsNotifier notifier) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear notifications'),
        content: const Text(
          'This will mark all as read and remove them from your list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              notifier.clearAll();
            },
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, AppNotification n) {
    if (n.type != 'friend_booking' && !n.isFriendRequestUpdate) return;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => n.isFriendRequestUpdate
          ? _FriendRequestUpdateSheet(notification: n)
          : _BookingDetailSheet(notification: n),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final n = notification;
    final isRead = n.isRead;

    return ListTile(
      onTap: onTap,
      leading: Icon(
        isRead ? Icons.notifications_none : Icons.notifications_active,
        color: isRead
            ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
            : theme.colorScheme.secondary,
      ),
      title: Text(
        n.displayMessage,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
        ),
      ),
      subtitle: Text(
        n.displaySubtitle.isNotEmpty
            ? n.displaySubtitle
            : _formatDate(n.createdAt),
        style: theme.textTheme.bodySmall,
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
        size: 18,
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

class _BookingDetailSheet extends StatelessWidget {
  const _BookingDetailSheet({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final n = notification;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    theme.colorScheme.secondary.withValues(alpha: 0.15),
                child: Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Friend Booking',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DetailRow(
            icon: Icons.person_outline,
            label: 'Friend',
            value: n.friendUsername,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.room_outlined,
            label: 'Room',
            value: n.roomId,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.calendar_month_outlined,
            label: 'Date',
            value: n.bookingDate,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.access_time_outlined,
            label: 'Time',
            value: '${n.startTime} – ${n.endTime}',
          ),
          const SizedBox(height: 24),
          Text(
            _formatCreatedAt(n.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCreatedAt(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Received just now';
    if (diff.inHours < 1) return 'Received ${diff.inMinutes}m ago';
    if (diff.inDays < 1) return 'Received ${diff.inHours}h ago';
    return 'Received ${diff.inDays}d ago';
  }
}

class _FriendRequestUpdateSheet extends StatelessWidget {
  const _FriendRequestUpdateSheet({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final n = notification;
    final accepted = n.type == 'friend_request_accepted';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: (accepted
                        ? Colors.green
                        : theme.colorScheme.error)
                    .withValues(alpha: 0.15),
                child: Icon(
                  accepted ? Icons.check_circle_outline : Icons.cancel_outlined,
                  color: accepted ? Colors.green : theme.colorScheme.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                accepted ? 'Request Accepted' : 'Request Declined',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (n.fromUsername.isNotEmpty)
            _DetailRow(
              icon: Icons.person_outline,
              label: 'From',
              value: n.fromUsername,
            ),
          const SizedBox(height: 12),
          Text(
            _formatCreatedAt(n.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCreatedAt(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Received just now';
    if (diff.inHours < 1) return 'Received ${diff.inMinutes}m ago';
    if (diff.inDays < 1) return 'Received ${diff.inHours}h ago';
    return 'Received ${diff.inDays}d ago';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon,
            size: 18,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : '—',
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
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
