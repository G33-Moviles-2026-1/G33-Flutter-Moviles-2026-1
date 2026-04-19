import '../../../rooms/domain/entities/time_range.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_purpose.dart';
import '../../domain/entities/my_booking.dart';
import '../../domain/repositories/bookings_repository.dart';
import '../local/bookings_local_datasource.dart';
import '../models/booking_response_dto.dart';
import '../models/create_booking_request_dto.dart';
import '../models/my_bookings_response_dto.dart';
import '../remote/bookings_api.dart';

class BookingsRepositoryImpl implements BookingsRepository {
  BookingsRepositoryImpl({
    required this.bookingsApi,
    required this.localDataSource,
  });

  final BookingsApi bookingsApi;
  final BookingsLocalDataSource localDataSource;

  @override
  Future<Booking> createBooking({
    required String roomId,
    required DateTime date,
    required TimeRange timeRange,
    required BookingPurpose purpose,
  }) async {
    final requestDto = CreateBookingRequestDto(
      roomId: roomId,
      date: date,
      timeRange: timeRange,
      purpose: purpose,
    );

    final raw = await bookingsApi.createBooking(requestDto.toJson());
    final dto = BookingResponseDto.fromJson(raw);
    return dto.toDomain();
  }

  @override
  Future<List<MyBooking>> getCachedBookings() async {
    final dtos = await localDataSource.getBookings();
    return dtos.map((d) => d.toDomain()).toList();
  }

  @override
  Future<List<MyBooking>> getMyBookings() async {
    final raw = await bookingsApi.fetchMyBookings();
    final responseDto = MyBookingsResponseDto.fromJson(raw);
    try {
      await localDataSource.saveBookings(responseDto.items);
    } catch (_) {}
    return responseDto.toDomain();
  }

  @override
  Future<void> deleteMyBooking({required String bookingId}) async {
    await bookingsApi.deleteMyBooking(bookingId: bookingId);
    await localDataSource.removeBooking(bookingId);
  }
}