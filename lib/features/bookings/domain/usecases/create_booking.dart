import '../../../rooms/domain/entities/time_range.dart';
import '../entities/booking.dart';
import '../entities/booking_purpose.dart';
import '../repositories/bookings_repository.dart';

class CreateBooking {
  final BookingsRepository _repo;

  const CreateBooking(this._repo);

  Future<Booking> call({
    required String roomId,
    required DateTime date,
    required TimeRange timeRange,
    required BookingPurpose purpose,
  }) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    return _repo.createBooking(
      roomId: roomId,
      date: normalizedDate,
      timeRange: timeRange,
      purpose: purpose,
    );
  }
}