class ScheduleClassModel {
  final String classId;
  final String? title;
  final String? locationText;
  final String? roomId;
  final DateTime startDate;
  final DateTime endDate;
  final String startTime;
  final String endTime;
  final List<String> weekdays;

  const ScheduleClassModel({
    required this.classId,
    this.title,
    this.locationText,
    this.roomId,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.weekdays,
  });

  factory ScheduleClassModel.fromJson(Map<String, dynamic> json) {
    return ScheduleClassModel(
      classId: json['class_id']?.toString() ?? '',
      title: json['title'] as String?,
      locationText: json['location_text'] as String?,
      roomId: json['room_id'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      weekdays: (json['weekdays'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
