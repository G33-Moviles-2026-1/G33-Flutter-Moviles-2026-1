import '../entities/my_booking.dart';
import '../repositories/bookings_repository.dart';

class GetCachedBookings {
  const GetCachedBookings(this._repository);

  final BookingsRepository _repository;

  Future<List<MyBooking>> call() => _repository.getCachedBookings();
}
