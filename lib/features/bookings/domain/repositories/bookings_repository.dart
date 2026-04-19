import '../../../rooms/domain/entities/time_range.dart';
import '../entities/booking.dart';
import '../entities/booking_purpose.dart';
import '../entities/my_booking.dart';

abstract class BookingsRepository {
  Future<Booking> createBooking({
    required String roomId,
    required DateTime date,
    required TimeRange timeRange,
    required BookingPurpose purpose,
  });

  Future<List<MyBooking>> getCachedBookings();

  Future<List<MyBooking>> getMyBookings();

  Future<void> deleteMyBooking({
    required String bookingId,
  });
}