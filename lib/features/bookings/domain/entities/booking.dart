import '../../../rooms/domain/entities/time_range.dart';
import 'booking_purpose.dart';

enum BookingStatus {
  active,
  cancelled,
  completed,
}

extension BookingStatusX on BookingStatus {
  static BookingStatus fromBackendKey(String value) {
    switch (value) {
      case 'active':
        return BookingStatus.active;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      default:
        throw ArgumentError('Unknown booking status: $value');
    }
  }
}

class Booking {
  final String id;
  final String userEmail;
  final String termId;
  final String roomId;
  final DateTime date;
  final TimeRange timeRange;
  final BookingPurpose purpose;
  final BookingStatus status;

  const Booking({
    required this.id,
    required this.userEmail,
    required this.termId,
    required this.roomId,
    required this.date,
    required this.timeRange,
    required this.purpose,
    required this.status,
  });

  bool get blocksAvailability => status == BookingStatus.active;
}