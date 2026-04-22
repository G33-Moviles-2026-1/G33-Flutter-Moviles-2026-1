import '../../../../core/connectivity/pending_action.dart';
import '../remote/bookings_api.dart';

class CreateBookingAction extends PendingAction {
  final BookingsApi _api;
  final Map<String, dynamic> payload;

  CreateBookingAction(this._api, this.payload);

  @override
  String get successMessage => 'Your booking was successfully created.';

  @override
  String get failureMessage => 'We could not create your booking.';

  @override
  Future<void> execute() => _api.createBooking(payload);
}
