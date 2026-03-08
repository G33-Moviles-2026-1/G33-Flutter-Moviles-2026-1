import '../../../rooms/domain/entities/time_range.dart';
import 'booking_purpose.dart';

class Booking {
  final String id;
  final String roomId;

  /// Date only (no time). We’ll store midnight UTC-ish? For now: local date.
  final DateTime date;

  final TimeRange timeRange;
  final BookingPurpose purpose;
  final int peopleCount;

  /// Pending / Verified / Cancelled etc later. For now keep minimal.
  final bool isPending;

  const Booking({
    required this.id,
    required this.roomId,
    required this.date,
    required this.timeRange,
    required this.purpose,
    required this.peopleCount,
    required this.isPending,
  });
}