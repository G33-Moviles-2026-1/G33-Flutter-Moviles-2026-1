import 'dart:math';
import '../../../rooms/domain/entities/time_range.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_purpose.dart';
import '../../domain/repositories/bookings_repository.dart';

class BookingsRepositoryImpl implements BookingsRepository {
  final _rng = Random();
  final List<Booking> _inMemory = [];

  @override
  Future<Booking> createBooking({
    required String roomId,
    required DateTime date,
    required TimeRange timeRange,
    required BookingPurpose purpose,
    required int peopleCount,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final booking = Booking(
      id: 'bk_${_rng.nextInt(999999)}',
      roomId: roomId,
      date: DateTime(date.year, date.month, date.day),
      timeRange: timeRange,
      purpose: purpose,
      peopleCount: peopleCount,
      isPending: true,
    );

    _inMemory.add(booking);
    return booking;
  }
}