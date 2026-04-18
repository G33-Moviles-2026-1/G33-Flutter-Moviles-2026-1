import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_provider.dart';
import '../../../rooms/domain/entities/room_search.dart';
import '../../../rooms/presentation/providers/rooms_providers.dart';
import '../../data/remote/bookings_api.dart';
import '../../data/repositories/bookings_repository_impl.dart';
import '../../domain/repositories/bookings_repository.dart';
import '../../domain/usecases/create_booking.dart';
import '../../domain/usecases/delete_my_booking.dart';
import '../../domain/usecases/get_my_bookings.dart';
import '../controllers/create_booking_controller.dart';
import '../controllers/create_booking_state.dart';
import '../controllers/my_bookings_controller.dart';
import '../controllers/my_bookings_state.dart';

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

final createBookingControllerProvider = StateNotifierProvider.autoDispose
    .family<CreateBookingController, CreateBookingState, RoomSearchItem>(
  (ref, room) {
    return CreateBookingController(
      room: room,
      createBooking: ref.read(createBookingUseCaseProvider),
      fetchRoomDateAvailability:
          ref.read(fetchRoomDateAvailabilityUseCaseProvider),
      analyticsService: ref.read(analyticsServiceProvider),
      sessionController: ref.read(sessionControllerProvider),
    );
  },
);

final myBookingsControllerProvider =
    StateNotifierProvider.autoDispose<MyBookingsController, MyBookingsState>(
  (ref) {
    return MyBookingsController(
      getMyBookings: ref.read(getMyBookingsUseCaseProvider),
      deleteMyBooking: ref.read(deleteMyBookingUseCaseProvider),
    );
  },
);