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
    required int peopleCount,
    required int roomCapacity,
  }) async {
    if (peopleCount < 1) {
      throw ArgumentError('peopleCount must be >= 1');
    }
    if (peopleCount > roomCapacity) {
      throw ArgumentError('peopleCount cannot exceed room capacity');
    }

    return _repo.createBooking(
      roomId: roomId,
      date: date,
      timeRange: timeRange,
      purpose: purpose,
      peopleCount: peopleCount,
    );
  }
}