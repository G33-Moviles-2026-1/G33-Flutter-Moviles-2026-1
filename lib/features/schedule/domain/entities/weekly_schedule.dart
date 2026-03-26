import 'schedule_occurrence.dart';

class WeeklySchedule {
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<ScheduleOccurrence> occurrences;

  const WeeklySchedule({
    required this.weekStart,
    required this.weekEnd,
    required this.occurrences,
  });
}