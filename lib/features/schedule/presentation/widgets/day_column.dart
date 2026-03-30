import 'package:flutter/material.dart';
import '../../domain/entities/schedule_occurrence.dart';
import 'class_tile.dart';

class DayColumn extends StatelessWidget {
  final DateTime day;
  final List<ScheduleOccurrence> occurrences;
  final void Function(ScheduleOccurrence occurrence)? onDeleteOccurrence;
  final bool isSelected;
  final VoidCallback? onTap;

  const DayColumn({
    super.key,
    required this.day,
    required this.occurrences,
    this.onDeleteOccurrence,
    this.isSelected = false,
    this.onTap,
  });

  String _weekdayLabel(DateTime date) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    if (date.weekday >= 1 && date.weekday <= 6) {
      return labels[date.weekday - 1];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final sortedOccurrences = [...occurrences]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final selectedBackground = theme.colorScheme.secondary.withValues(alpha: 0.22);
    final selectedBorder = theme.colorScheme.secondary;

    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? selectedBackground : theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? selectedBorder
                      : theme.dividerColor.withValues(alpha: .18),
                  width: isSelected ? 1.4 : 1,
                ),
              ),
              child: Text(
                '${_weekdayLabel(day)} ${day.day}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (sortedOccurrences.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: theme.cardColor,
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: .12),
                ),
              ),
              child: Text(
                'No classes',
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            ...sortedOccurrences.map(
              (occurrence) => ClassTile(
                occurrence: occurrence,
                onDelete: onDeleteOccurrence == null
                    ? null
                    : () => onDeleteOccurrence!(occurrence),
              ),
            ),
        ],
      ),
    );
  }
}