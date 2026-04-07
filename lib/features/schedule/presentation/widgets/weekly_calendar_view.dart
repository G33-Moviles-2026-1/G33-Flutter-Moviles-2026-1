import 'package:flutter/material.dart';

import '../../domain/entities/schedule_occurrence.dart';
import '../../domain/entities/weekly_schedule.dart';
import 'day_column.dart';

class WeeklyCalendarView extends StatelessWidget {
  final WeeklySchedule schedule;
  final void Function(ScheduleOccurrence occurrence)? onDeleteOccurrence;
  final DateTime selectedDate;
  final ValueChanged<DateTime>? onDaySelected;

  const WeeklyCalendarView({
    super.key,
    required this.schedule,
    this.onDeleteOccurrence,
    required this.selectedDate,
    this.onDaySelected,
  });

  Map<DateTime, List<ScheduleOccurrence>> _groupByDay(
    List<ScheduleOccurrence> occurrences,
  ) {
    final grouped = <DateTime, List<ScheduleOccurrence>>{};

    for (final occurrence in occurrences) {
      if (occurrence.date.weekday == DateTime.sunday) continue;
      final key = DateTime(
        occurrence.date.year,
        occurrence.date.month,
        occurrence.date.day,
      );
      grouped.putIfAbsent(key, () => []).add(occurrence);
    }

    return grouped;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDay(schedule.occurrences);

    final weekDays = List.generate(
      7,
      (index) => schedule.weekStart.add(Duration(days: index)),
    ).where((day) => day.weekday != DateTime.sunday).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: weekDays.map((day) {
            final key = DateTime(day.year, day.month, day.day);
            final occurrences = grouped[key] ?? [];

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: DayColumn(
                day: day,
                occurrences: occurrences,
                onDeleteOccurrence: onDeleteOccurrence,
                isSelected: _isSameDay(day, selectedDate),
                onTap: () => onDaySelected?.call(day),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}