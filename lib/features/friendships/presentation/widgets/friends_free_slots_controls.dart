import 'package:andespace/features/friendships/domain/entities/friend.dart';
import 'package:andespace/features/friendships/presentation/widgets/friends_free_slots_theme.dart';
import 'package:flutter/material.dart';

class FriendsFreeSlotsWeekSelector extends StatelessWidget {
  const FriendsFreeSlotsWeekSelector({
    super.key,
    required this.label,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  final String label;
  final VoidCallback? onPreviousWeek;
  final VoidCallback? onNextWeek;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: friendsFreeSlotsPanelBackground(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: friendsFreeSlotsGridBorderColor(context)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous week',
            onPressed: onPreviousWeek,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Next week',
            onPressed: onNextWeek,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class SelectedFriendsStrip extends StatelessWidget {
  const SelectedFriendsStrip({super.key, required this.friends});

  final List<Friend> friends;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final friend in friends)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.secondary.withValues(alpha: 0.55),
              ),
            ),
            child: Text(
              friend.username,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}
