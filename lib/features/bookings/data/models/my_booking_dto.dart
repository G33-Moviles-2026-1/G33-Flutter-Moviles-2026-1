import '../../../rooms/domain/entities/time_range.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_purpose.dart';
import '../../domain/entities/my_booking.dart';

class MyBookingDto {
  final String id;
  final String roomId;
  final DateTime date;
  final DateTime createdAt;
  final String startTime;
  final String endTime;
  final String purpose;
  final String status;

  const MyBookingDto({
    required this.id,
    required this.roomId,
    required this.date,
    required this.createdAt,
    required this.startTime,
    required this.endTime,
    required this.purpose,
    required this.status,
  });

  factory MyBookingDto.fromJson(Map<String, dynamic> json) {
    return MyBookingDto(
      id: json['id'].toString(),
      roomId: json['room_id'] as String,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      purpose: json['purpose'] as String,
      status: json['status'] as String,
    );
  }

  MyBooking toDomain() {
    return MyBooking(
      id: id,
      roomId: roomId,
      date: DateTime(date.year, date.month, date.day),
      createdAt: createdAt,
      timeRange: TimeRange(
        start: _hhmm(startTime),
        end: _hhmm(endTime),
      ),
      purpose: BookingPurposeX.fromBackendKey(purpose),
      status: BookingStatusX.fromBackendKey(status),
    );
  }

  String _hhmm(String value) {
    return value.length >= 5 ? value.substring(0, 5) : value;
  }
}