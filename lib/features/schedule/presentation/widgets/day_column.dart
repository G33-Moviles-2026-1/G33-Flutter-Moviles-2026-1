import 'package:flutter/material.dart';
import '../../domain/entities/schedule_occurrence.dart';
import 'class_tile.dart';

class DayColumn extends StatelessWidget {
  final DateTime day;
  final List<ScheduleOccurrence> occurrences;
  final void Function(ScheduleOccurrence occurrence)? onDeleteOccurrence;

  const DayColumn({
    super.key,
    required this.day,
    required this.occurrences,
    this.onDeleteOccurrence,
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

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.18),
              ),
            ),
            child: Text(
              '${_weekdayLabel(day)} ${day.day}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
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
                  color: theme.dividerColor.withOpacity(0.12),
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