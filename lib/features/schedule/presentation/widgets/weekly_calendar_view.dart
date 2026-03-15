import 'package:flutter/material.dart';

import '../../domain/entities/schedule_occurrence.dart';
import '../../domain/entities/weekly_schedule.dart';
import 'day_column.dart';

class WeeklyCalendarView extends StatelessWidget {
  final WeeklySchedule schedule;
  final void Function(ScheduleOccurrence occurrence)? onDeleteOccurrence;

  const WeeklyCalendarView({
    super.key,
    required this.schedule,
    this.onDeleteOccurrence,
  });

  Map<DateTime, List<ScheduleOccurrence>> _groupByDay(
    List<ScheduleOccurrence> occurrences,
  ) {
    final grouped = <DateTime, List<ScheduleOccurrence>>{};

    for (final occurrence in occurrences) {
      final key = DateTime(
        occurrence.date.year,
        occurrence.date.month,
        occurrence.date.day,
      );
      grouped.putIfAbsent(key, () => []).add(occurrence);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDay(schedule.occurrences);

    final weekDays = List.generate(
      7,
      (index) => schedule.weekStart.add(Duration(days: index)),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: weekDays.map((day) {
          final key = DateTime(day.year, day.month, day.day);
          final occurrences = grouped[key] ?? [];

          return DayColumn(
            day: day,
            occurrences: occurrences,
            onDeleteOccurrence: onDeleteOccurrence,
          );
        }).toList(),
      ),
    );
  }
}