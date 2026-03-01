import 'time_range_dto.dart';
import '../../domain/entities/time_range.dart';
import '../../domain/entities/room_detail.dart';


class RoomDetailDto {
  final String id;
  final String buildingName;
  final int capacity;
  final double reliability;
  final bool isCurrentlyAvailable;
  final List<String> utilities;
  final Map<String, List<TimeRangeDto>> weeklyAvailability;

  const RoomDetailDto({
    required this.id,
    required this.buildingName,
    required this.capacity,
    required this.reliability,
    required this.isCurrentlyAvailable,
    required this.utilities,
    required this.weeklyAvailability,
  });

  factory RoomDetailDto.fromJson(Map<String, dynamic> json) {
    final weekly = <String, List<TimeRangeDto>>{};

    final rawWeekly = json['weeklyAvailability'] as Map<String, dynamic>;

    rawWeekly.forEach((key, value) {
      weekly[key] = (value as List)
          .map((e) => TimeRangeDto.fromJson(e))
          .toList();
    });

    return RoomDetailDto(
      id: json['id'],
      buildingName: json['buildingName'],
      capacity: json['capacity'],
      reliability: (json['reliability'] as num).toDouble(),
      isCurrentlyAvailable: json['isCurrentlyAvailable'],
      utilities: List<String>.from(json['utilities']),
      weeklyAvailability: weekly,
    );
  }

  RoomDetail toDomain() {
    final domainWeekly = <Weekday, List<TimeRange>>{};

    weeklyAvailability.forEach((key, value) {
      final weekday = Weekday.values.firstWhere(
        (e) => e.name == key,
      );

      domainWeekly[weekday] =
          value.map((dto) => dto.toDomain()).toList();
    });

    return RoomDetail(
      id: id,
      buildingName: buildingName,
      capacity: capacity,
      reliability: reliability,
      isCurrentlyAvailable: isCurrentlyAvailable,
      utilities: utilities,
      weeklyAvailability: domainWeekly,
    );
  }
}