import 'package:andespace/core/utils/date_time_utils.dart';

class ManualClassModel {
  final String title;
  final String? locationText;
  final String? roomId;
  final DateTime startDate;
  final DateTime endDate;
  final String startTime; // HH:mm:ss
  final String endTime;   // HH:mm:ss
  final List<String> weekdays;

  const ManualClassModel({
    required this.title,
    this.locationText,
    this.roomId,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.weekdays,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'location_text': locationText,
      'room_id': roomId,
      'start_date': _formatDateOnly(startDate),
      'end_date': _formatDateOnly(endDate),
      'start_time': startTime,
      'end_time': endTime,
      'weekdays': weekdays,
    };
  }

  static String _formatDateOnly(DateTime date) => DateTimeUtils.toApiDate(date);
}
