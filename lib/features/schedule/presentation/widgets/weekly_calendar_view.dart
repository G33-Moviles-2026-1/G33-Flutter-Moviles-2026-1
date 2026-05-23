import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/schedule_occurrence.dart';
import '../notifiers/schedule_notifier.dart';
import '../notifiers/schedule_state.dart';
import 'day_column.dart';

class WeeklyCalendarView extends StatelessWidget {
  final void Function(ScheduleOccurrence occurrence)? onDeleteOccurrence;
  final ValueChanged<DateTime>? onDaySelected;

  const WeeklyCalendarView({
    super.key,
    this.onDeleteOccurrence,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(6, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _DayColumnSlot(
                index: index,
                onDeleteOccurrence: onDeleteOccurrence,
                onDaySelected: onDaySelected,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _DayColumnSlot extends ConsumerWidget {
  final int index;
  final void Function(ScheduleOccurrence occurrence)? onDeleteOccurrence;
  final ValueChanged<DateTime>? onDaySelected;

  const _DayColumnSlot({
    required this.index,
    this.onDeleteOccurrence,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayData = ref.watch(
      scheduleControllerProvider.select<ScheduleDayOccurrences?>((state) {
        if (state.weekDays.length <= index) return null;
        return state.weekDays[index];
      }),
    );

    if (dayData == null) {
      return const SizedBox(width: 280);
    }

    return DayColumn(
      key: ValueKey<DateTime>(dayData.day),
      day: dayData.day,
      occurrences: dayData.occurrences,
      onDeleteOccurrence: onDeleteOccurrence,
      onTap: () => onDaySelected?.call(dayData.day),
    );
  }
}
