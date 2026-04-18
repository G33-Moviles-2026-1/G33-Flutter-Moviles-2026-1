import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_provider.dart';
import '../../../rooms/presentation/providers/rooms_providers.dart';
import '../../data/remote/bookings_api.dart';
import '../../data/repositories/bookings_repository_impl.dart';
import '../../domain/repositories/bookings_repository.dart';
import '../../domain/usecases/create_booking.dart';
import '../../domain/usecases/delete_my_booking.dart';
import '../../domain/usecases/get_booking_availability.dart';
import '../../domain/usecases/get_create_booking_initial_data.dart';
import '../../domain/usecases/get_my_bookings.dart';
import '../../domain/usecases/load_my_bookings.dart';
import '../../domain/usecases/remove_booking_from_list.dart';
import '../../domain/usecases/submit_booking.dart';
import '../../domain/usecases/validate_booking_date.dart';
import '../../domain/usecases/get_booking_date_bounds.dart';

final bookingsApiProvider = Provider<BookingsApi>((ref) {
  return BookingsApi(ref.watch(dioProvider));
});

final bookingsRepositoryProvider = Provider<BookingsRepository>((ref) {
  return BookingsRepositoryImpl(bookingsApi: ref.watch(bookingsApiProvider));
});

final createBookingUseCaseProvider = Provider<CreateBooking>((ref) {
  return CreateBooking(ref.watch(bookingsRepositoryProvider));
});

final getMyBookingsUseCaseProvider = Provider<GetMyBookings>((ref) {
  return GetMyBookings(ref.watch(bookingsRepositoryProvider));
});

final deleteMyBookingUseCaseProvider = Provider<DeleteMyBooking>((ref) {
  return DeleteMyBooking(ref.watch(bookingsRepositoryProvider));
});

final getCreateBookingInitialDataUseCaseProvider =
    Provider<GetCreateBookingInitialData>((ref) {
  return const GetCreateBookingInitialData();
});

final validateBookingDateUseCaseProvider = Provider<ValidateBookingDate>((ref) {
  return const ValidateBookingDate();
});

final getBookingAvailabilityUseCaseProvider = Provider<GetBookingAvailability>((ref) {
  return GetBookingAvailability(ref.watch(fetchRoomDateAvailabilityUseCaseProvider));
});

final submitBookingUseCaseProvider = Provider<SubmitBooking>((ref) {
  return SubmitBooking(
    ref.watch(createBookingUseCaseProvider),
    ref.watch(analyticsServiceProvider),
  );
});

final loadMyBookingsUseCaseProvider = Provider<LoadMyBookings>((ref) {
  return LoadMyBookings(ref.watch(getMyBookingsUseCaseProvider));
});

final removeBookingFromListUseCaseProvider = Provider<RemoveBookingFromList>((ref) {
  return RemoveBookingFromList(ref.watch(deleteMyBookingUseCaseProvider));
});

final getBookingDateBoundsUseCaseProvider =
    Provider<GetBookingDateBounds>((ref) {
  return const GetBookingDateBounds();
});