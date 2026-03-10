import '../../domain/entities/room_search.dart';

class RoomSearchResponseDto {
  const RoomSearchResponseDto({
    required this.query,
    required this.total,
    required this.items,
  });

  final RoomSearchRequest query;
  final int total;
  final List<RoomSearchItemDto> items;

  factory RoomSearchResponseDto.fromJson(Map<String, dynamic> json) {
    final queryJson = Map<String, dynamic>.from(json['query'] as Map);

    return RoomSearchResponseDto(
      query: RoomSearchRequest(
        roomPrefixes:
            List<String>.from(queryJson['room_prefixes'] ?? const <String>[]),
        date: queryJson['date'] as String,
        since: queryJson['since'] as String?,
        until: queryJson['until'] as String?,
        buildingCodes:
            List<String>.from(queryJson['building_codes'] ?? const <String>[]),
        utilities:
            List<String>.from(queryJson['utilities'] ?? const <String>[]),
        nearMe: queryJson['near_me'] as bool? ?? false,
        userLocation: queryJson['user_location'] == null
            ? null
            : SearchLocation(
                latitude:
                    (queryJson['user_location']['latitude'] as num).toDouble(),
                longitude:
                    (queryJson['user_location']['longitude'] as num).toDouble(),
              ),
        limit: queryJson['limit'] as int? ?? 20,
        offset: queryJson['offset'] as int? ?? 0,
      ),
      total: (json['total'] as num?)?.toInt() ?? 0,
      items: (json['items'] as List<dynamic>? ?? const [])
          .map(
            (e) => RoomSearchItemDto.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }

  RoomSearchResponse toDomain() {
    return RoomSearchResponse(
      query: query,
      total: total,
      items: items.map((e) => e.toDomain()).toList(),
    );
  }
}

class RoomSearchItemDto {
  const RoomSearchItemDto({
    required this.roomId,
    required this.buildingCode,
    required this.buildingName,
    required this.roomNumber,
    required this.capacity,
    required this.reliability,
    required this.utilities,
    required this.distanceMeters,
    required this.matchingWindows,
    required this.weeklyAvailability,
  });

  final String roomId;
  final String buildingCode;
  final String? buildingName;
  final String roomNumber;
  final int capacity;
  final double reliability;
  final List<String> utilities;
  final double? distanceMeters;
  final List<MatchingWindowDto> matchingWindows;
  final List<WeeklyAvailabilityWindowDto> weeklyAvailability;

  factory RoomSearchItemDto.fromJson(Map<String, dynamic> json) {
    return RoomSearchItemDto(
      roomId: json['room_id'] as String,
      buildingCode: json['building_code'] as String,
      buildingName: json['building_name'] as String?,
      roomNumber: json['room_number'] as String,
      capacity: (json['capacity'] as num).toInt(),
      reliability: (json['reliability'] as num).toDouble(),
      utilities: List<String>.from(json['utilities'] ?? const <String>[]),
      distanceMeters: json['distance_meters'] == null
          ? null
          : (json['distance_meters'] as num).toDouble(),
      matchingWindows: (json['matching_windows'] as List<dynamic>? ?? const [])
          .map(
            (e) => MatchingWindowDto.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      weeklyAvailability:
          (json['weekly_availability'] as List<dynamic>? ?? const [])
              .map(
                (e) => WeeklyAvailabilityWindowDto.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList(),
    );
  }

  RoomSearchItem toDomain() {
    return RoomSearchItem(
      roomId: roomId,
      buildingCode: buildingCode,
      buildingName: buildingName,
      roomNumber: roomNumber,
      capacity: capacity,
      reliability: reliability,
      utilities: utilities,
      distanceMeters: distanceMeters,
      matchingWindows: matchingWindows.map((e) => e.toDomain()).toList(),
      weeklyAvailability: weeklyAvailability.map((e) => e.toDomain()).toList(),
    );
  }
}

class MatchingWindowDto {
  const MatchingWindowDto({
    required this.start,
    required this.end,
  });

  final String start;
  final String end;

  factory MatchingWindowDto.fromJson(Map<String, dynamic> json) {
    return MatchingWindowDto(
      start: json['start'] as String,
      end: json['end'] as String,
    );
  }

  MatchingWindow toDomain() => MatchingWindow(
        start: start,
        end: end,
      );
}

class WeeklyAvailabilityWindowDto {
  const WeeklyAvailabilityWindowDto({
    required this.day,
    required this.start,
    required this.end,
    required this.validFrom,
    required this.validTo,
  });

  final String day;
  final String start;
  final String end;
  final String validFrom;
  final String validTo;

  factory WeeklyAvailabilityWindowDto.fromJson(Map<String, dynamic> json) {
    return WeeklyAvailabilityWindowDto(
      day: json['day'] as String,
      start: json['start'] as String,
      end: json['end'] as String,
      validFrom: json['valid_from'] as String,
      validTo: json['valid_to'] as String,
    );
  }

  WeeklyAvailabilityWindow toDomain() => WeeklyAvailabilityWindow(
        day: day,
        start: start,
        end: end,
        validFrom: validFrom,
        validTo: validTo,
      );
}