import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/schedule_occurrence.dart';
import '../notifiers/schedule_notifier.dart';
import 'class_tile.dart';

class DayColumn extends StatelessWidget {
  final DateTime day;
  final List<ScheduleOccurrence> occurrences;
  final void Function(ScheduleOccurrence occurrence)? onDeleteOccurrence;
  final VoidCallback? onTap;

  const DayColumn({
    super.key,
    required this.day,
    required this.occurrences,
    this.onDeleteOccurrence,
    this.onTap,
  });

  static String _weekdayLabel(DateTime date) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    if (date.weekday >= 1 && date.weekday <= 6) {
      return labels[date.weekday - 1];
    }
    return '';
  }

  static String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  static Key _tileKey(ScheduleOccurrence occurrence) {
    final classId = occurrence.classId.trim();

    if (classId.isNotEmpty) {
      return ValueKey<String>(
        'schedule-class-$classId-${_dateKey(occurrence.date)}',
      );
    }

    final fallback = [
      occurrence.title?.trim() ?? '',
      occurrence.weekday.trim(),
      _dateKey(occurrence.date),
      occurrence.startTime.trim(),
      occurrence.endTime.trim(),
    ].join('|');

    return ValueKey<String>('schedule-class-$fallback');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DayHeader(
            day: day,
            label: '${_weekdayLabel(day)} ${day.day}',
            onTap: onTap,
          ),
          const SizedBox(height: 10),
          _OccurrencesList(
            occurrences: occurrences,
            onDeleteOccurrence: onDeleteOccurrence,
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends ConsumerWidget {
  final DateTime day;
  final String label;
  final VoidCallback? onTap;

  const _DayHeader({required this.day, required this.label, this.onTap});

  static bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(
      scheduleControllerProvider.select((state) => state.selectedDate),
    );
    final isSelected = _isSameDay(day, selectedDate);
    final theme = Theme.of(context);
    final selectedBackground = theme.colorScheme.secondary.withValues(
      alpha: 0.22,
    );
    final selectedBorder = theme.colorScheme.secondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBackground : theme.cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.all(
            color: isSelected
                ? selectedBorder
                : theme.dividerColor.withValues(alpha: .18),
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _OccurrencesList extends StatelessWidget {
  final List<ScheduleOccurrence> occurrences;
  final void Function(ScheduleOccurrence occurrence)? onDeleteOccurrence;

  const _OccurrencesList({required this.occurrences, this.onDeleteOccurrence});

  @override
  Widget build(BuildContext context) {
    if (occurrences.isEmpty) {
      final theme = Theme.of(context);

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          color: theme.cardColor,
          border: Border.all(color: theme.dividerColor.withValues(alpha: .12)),
        ),
        child: Text('No classes', style: theme.textTheme.bodyMedium),
      );
    }

    return ListView.builder(
      itemCount: occurrences.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final occurrence = occurrences[index];

        return ClassTile(
          key: DayColumn._tileKey(occurrence),
          occurrence: occurrence,
          onDelete: onDeleteOccurrence == null
              ? null
              : () => onDeleteOccurrence!(occurrence),
        );
      },
    );
  }
}
