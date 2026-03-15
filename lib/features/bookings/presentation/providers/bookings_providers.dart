import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_provider.dart';
import '../../../rooms/domain/entities/room_search.dart';
import '../../../rooms/presentation/providers/rooms_providers.dart';
import '../../data/remote/bookings_api.dart';
import '../../data/repositories/bookings_repository_impl.dart';
import '../../domain/repositories/bookings_repository.dart';
import '../../domain/usecases/create_booking.dart';
import '../controllers/create_booking_controller.dart';
import '../controllers/create_booking_state.dart';

final bookingsApiProvider = Provider<BookingsApi>((ref) {
  return BookingsApi(ref.read(dioProvider));
});

final bookingsRepositoryProvider = Provider<BookingsRepository>((ref) {
  return BookingsRepositoryImpl(
    dio: ref.read(dioProvider),
    bookingsApi: ref.read(bookingsApiProvider),
  );
});

final createBookingUseCaseProvider = Provider<CreateBooking>((ref) {
  return CreateBooking(ref.read(bookingsRepositoryProvider));
});

final createBookingControllerProvider = StateNotifierProvider.autoDispose
    .family<CreateBookingController, CreateBookingState, RoomSearchItem>(
  (ref, room) {
    return CreateBookingController(
      room: room,
      createBooking: ref.read(createBookingUseCaseProvider),
      fetchRoomDateAvailability:
          ref.read(fetchRoomDateAvailabilityUseCaseProvider),
    );
  },
);