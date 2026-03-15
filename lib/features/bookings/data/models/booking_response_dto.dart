import '../../../rooms/domain/entities/time_range.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_purpose.dart';

class BookingResponseDto {
  final String id;
  final String userEmail;
  final String termId;
  final String roomId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String purpose;
  final String status;

  const BookingResponseDto({
    required this.id,
    required this.userEmail,
    required this.termId,
    required this.roomId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.purpose,
    required this.status,
  });

  factory BookingResponseDto.fromJson(Map<String, dynamic> json) {
    return BookingResponseDto(
      id: json['id'].toString(),
      userEmail: json['user_email'] as String,
      termId: json['term_id'] as String,
      roomId: json['room_id'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      purpose: json['purpose'] as String,
      status: json['status'] as String,
    );
  }

  Booking toDomain() {
    return Booking(
      id: id,
      userEmail: userEmail,
      termId: termId,
      roomId: roomId,
      date: DateTime(date.year, date.month, date.day),
      timeRange: TimeRange(start: _hhmm(startTime), end: _hhmm(endTime)),
      purpose: BookingPurposeX.fromBackendKey(purpose),
      status: BookingStatusX.fromBackendKey(status),
    );
  }

  String _hhmm(String value) {
    return value.length >= 5 ? value.substring(0, 5) : value;
  }
}