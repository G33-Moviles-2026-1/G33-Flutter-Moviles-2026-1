import '../../../../core/connectivity/pending_action.dart';
import '../remote/bookings_api.dart';

class DeleteBookingAction extends PendingAction {
  final BookingsApi _api;
  final String bookingId;

  DeleteBookingAction(this._api, this.bookingId);

  @override
  String get successMessage => 'Your booking was successfully deleted.';

  @override
  String get failureMessage => 'We could not delete your booking.';

  @override
  Future<void> execute() => _api.deleteMyBooking(bookingId: bookingId);
}
