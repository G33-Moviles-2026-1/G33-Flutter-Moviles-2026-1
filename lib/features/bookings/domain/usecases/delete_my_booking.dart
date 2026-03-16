import '../repositories/bookings_repository.dart';

class DeleteMyBooking {
  final BookingsRepository _repository;

  const DeleteMyBooking(this._repository);

  Future<void> call({
    required String bookingId,
  }) {
    return _repository.deleteMyBooking(bookingId: bookingId);
  }
}