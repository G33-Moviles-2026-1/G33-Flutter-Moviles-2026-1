class ScheduleOccurrence {
  final String classId;
  final String? title;
  final String? locationText;
  final String? roomId;
  final DateTime date;
  final String weekday;
  final String startTime;
  final String endTime;

  const ScheduleOccurrence({
    required this.classId,
    this.title,
    this.locationText,
    this.roomId,
    required this.date,
    required this.weekday,
    required this.startTime,
    required this.endTime,
  });
}