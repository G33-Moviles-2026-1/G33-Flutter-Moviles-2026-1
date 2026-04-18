import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_provider.dart';
import '../../data/remote/bookings_api.dart';
import '../../data/repositories/bookings_repository_impl.dart';
import '../../domain/repositories/bookings_repository.dart';
import '../../domain/usecases/create_booking.dart';
import '../../domain/usecases/delete_my_booking.dart';
import '../../domain/usecases/get_my_bookings.dart';

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