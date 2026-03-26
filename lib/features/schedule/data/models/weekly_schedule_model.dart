class ScheduleOccurrenceModel {
  final String classId;
  final String? title;
  final String? locationText;
  final String? roomId;
  final DateTime date;
  final String weekday;
  final String startTime;
  final String endTime;

  const ScheduleOccurrenceModel({
    required this.classId,
    this.title,
    this.locationText,
    this.roomId,
    required this.date,
    required this.weekday,
    required this.startTime,
    required this.endTime,
  });

  factory ScheduleOccurrenceModel.fromJson(Map<String, dynamic> json) {
    return ScheduleOccurrenceModel(
      classId: json['class_id']?.toString() ?? '',
      title: json['title'] as String?,
      locationText: json['location_text'] as String?,
      roomId: json['room_id'] as String?,
      date: DateTime.parse(json['date'] as String),
      weekday: json['weekday'] as String? ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
    );
  }
}

class WeeklyScheduleModel {
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<ScheduleOccurrenceModel> occurrences;

  const WeeklyScheduleModel({
    required this.weekStart,
    required this.weekEnd,
    required this.occurrences,
  });

  factory WeeklyScheduleModel.fromJson(Map<String, dynamic> json) {
    return WeeklyScheduleModel(
      weekStart: DateTime.parse(json['week_start'] as String),
      weekEnd: DateTime.parse(json['week_end'] as String),
      occurrences: (json['occurrences'] as List<dynamic>? ?? [])
          .map((e) => ScheduleOccurrenceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}