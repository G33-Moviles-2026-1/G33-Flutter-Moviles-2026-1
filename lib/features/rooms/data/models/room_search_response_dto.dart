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
    required this.distanceSeconds,
    required this.matchingWindows,
  });

  final String roomId;
  final String buildingCode;
  final String? buildingName;
  final String roomNumber;
  final int capacity;
  final double reliability;
  final List<String> utilities;
  final double? distanceSeconds;
  final List<MatchingWindowDto> matchingWindows;

  factory RoomSearchItemDto.fromJson(Map<String, dynamic> json) {
    return RoomSearchItemDto(
      roomId: json['room_id'] as String,
      buildingCode: json['building_code'] as String,
      buildingName: json['building_name'] as String?,
      roomNumber: json['room_number'] as String,
      capacity: (json['capacity'] as num).toInt(),
      reliability: (json['reliability'] as num).toDouble(),
      utilities: List<String>.from(json['utilities'] ?? const <String>[]),
      distanceSeconds: json['distance_seconds'] == null
          ? null
          : (json['distance_seconds'] as num).toDouble(),
      matchingWindows: (json['matching_windows'] as List<dynamic>? ?? const [])
          .map(
            (e) => MatchingWindowDto.fromJson(
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
      distanceSeconds: distanceSeconds,
      matchingWindows: matchingWindows.map((e) => e.toDomain()).toList(),
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

