import '../../domain/entities/time_range.dart';

class TimeRangeDto {
  final String start;
  final String end;

  const TimeRangeDto({
    required this.start,
    required this.end,
  });

  factory TimeRangeDto.fromJson(Map<String, dynamic> json) {
    return TimeRangeDto(
      start: json['start'],
      end: json['end'],
    );
  }

  TimeRange toDomain() {
    return TimeRange(
      start: start,
      end: end,
    );
  }
}