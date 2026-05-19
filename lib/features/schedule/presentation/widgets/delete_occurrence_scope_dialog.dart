import 'package:andespace/features/schedule/domain/usecases/delete_schedule_occurrence_for_current_user_usecase.dart';
import 'package:flutter/material.dart';

Future<ScheduleOccurrenceDeletionScope?> showDeleteOccurrenceScopeDialog({
  required BuildContext context,
}) {
  return showDialog<ScheduleOccurrenceDeletionScope>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete event'),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DeleteScopeTile(
            icon: Icons.event_busy_outlined,
            title: 'This event',
            onTap: () => Navigator.pop(
              context,
              ScheduleOccurrenceDeletionScope.thisEvent,
            ),
          ),
          const SizedBox(height: 8),
          _DeleteScopeTile(
            icon: Icons.event_repeat_outlined,
            title: 'This and following events',
            onTap: () => Navigator.pop(
              context,
              ScheduleOccurrenceDeletionScope.thisAndFollowing,
            ),
          ),
          const SizedBox(height: 8),
          _DeleteScopeTile(
            icon: Icons.delete_outline,
            title: 'All events',
            isDestructive: true,
            onTap: () => Navigator.pop(
              context,
              ScheduleOccurrenceDeletionScope.allEvents,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}

class _DeleteScopeTile extends StatelessWidget {
  const _DeleteScopeTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = isDestructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;
    final background = isDestructive
        ? theme.colorScheme.error.withValues(alpha: 0.08)
        : theme.colorScheme.secondary.withValues(alpha: 0.1);
    final iconColor = isDestructive
        ? theme.colorScheme.error
        : theme.colorScheme.secondary;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.iconTheme.color?.withValues(alpha: 0.62),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
