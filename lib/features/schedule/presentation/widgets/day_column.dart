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
    final sortedOccurrences = [...occurrences]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_weekdayLabel(day)} ${day.day}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (sortedOccurrences.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
              ),
              child: const Text('No classes'),
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