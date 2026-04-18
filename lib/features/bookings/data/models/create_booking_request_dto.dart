import 'package:andespace/core/utils/date_time_utils.dart';
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
      'date': DateTimeUtils.toApiDate(date),
      'start_time': timeRange.start,
      'end_time': timeRange.end,
      'purpose': purpose.backendKey,
    };
  }
}