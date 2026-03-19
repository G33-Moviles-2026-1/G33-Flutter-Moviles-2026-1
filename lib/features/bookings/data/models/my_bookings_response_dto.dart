import '../../domain/entities/my_booking.dart';
import 'my_booking_dto.dart';

class MyBookingsResponseDto {
  final int total;
  final List<MyBookingDto> items;

  const MyBookingsResponseDto({
    required this.total,
    required this.items,
  });

  factory MyBookingsResponseDto.fromJson(Map<String, dynamic> json) {
    return MyBookingsResponseDto(
      total: json['total'] as int? ?? 0,
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((item) => MyBookingDto.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  List<MyBooking> toDomain() {
    return items.map((item) => item.toDomain()).toList();
  }
}