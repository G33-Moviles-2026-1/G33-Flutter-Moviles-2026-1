import '../../../rooms/domain/entities/time_range.dart';
import '../../domain/entities/booking_purpose.dart';

class CreateBookingRequestDto {
  final String roomId;
  final DateTime date;
  final TimeRange timeRange;
  final BookingPurpose purpose;

  const CreateBookingRequestDto({
    required this.roomId,
    required this.date,
    required this.timeRange,
    required this.purpose,
  });

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'date': _formatDate(date),
      'start_time': timeRange.start,
      'end_time': timeRange.end,
      'purpose': purpose.backendKey,
    };
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}