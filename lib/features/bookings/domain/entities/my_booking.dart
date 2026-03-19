import '../../../rooms/domain/entities/time_range.dart';
import 'booking.dart';
import 'booking_purpose.dart';

class MyBooking {
  final String id;
  final String roomId;
  final DateTime date;
  final DateTime createdAt;
  final TimeRange timeRange;
  final BookingPurpose purpose;
  final BookingStatus status;

  const MyBooking({
    required this.id,
    required this.roomId,
    required this.date,
    required this.createdAt,
    required this.timeRange,
    required this.purpose,
    required this.status,
  });
}