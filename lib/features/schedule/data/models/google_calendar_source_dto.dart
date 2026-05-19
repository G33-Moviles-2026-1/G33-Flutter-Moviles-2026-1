import '../../domain/entities/google_calendar_source.dart';

class GoogleCalendarSourceModel {
  final String id;
  final String summary;
  final bool primary;

  const GoogleCalendarSourceModel({
    required this.id,
    required this.summary,
    required this.primary,
  });

  factory GoogleCalendarSourceModel.fromJson(Map<String, dynamic> json) {
    return GoogleCalendarSourceModel(
      id: json['id']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      primary: json['primary'] as bool? ?? false,
    );
  }

  GoogleCalendarSource toEntity() {
    return GoogleCalendarSource(id: id, summary: summary, primary: primary);
  }
}
