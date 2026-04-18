import '../entities/booking_date_bounds.dart';

class GetBookingDateBounds {
  const GetBookingDateBounds();

  BookingDateBounds call() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return BookingDateBounds(
      firstBookableDate: today,
      lastBookableDate: today.add(const Duration(days: 7)),
    );
  }
}