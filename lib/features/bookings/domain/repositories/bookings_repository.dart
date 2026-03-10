import '../../../rooms/domain/entities/time_range.dart';
import '../entities/booking.dart';
import '../entities/booking_purpose.dart';

abstract class BookingsRepository {
  Future<Booking> createBooking({
    required String roomId,
    required DateTime date,
    required TimeRange timeRange,
    required BookingPurpose purpose,
    required int peopleCount,
  });
}