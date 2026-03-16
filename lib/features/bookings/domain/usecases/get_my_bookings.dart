import '../entities/my_booking.dart';
import '../repositories/bookings_repository.dart';

class GetMyBookings {
  final BookingsRepository _repository;

  const GetMyBookings(this._repository);

  Future<List<MyBooking>> call() {
    return _repository.getMyBookings();
  }
}