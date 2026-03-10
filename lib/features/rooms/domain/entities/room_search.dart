class SearchLocation {
  const SearchLocation({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

class RoomSearchRequest {
  const RoomSearchRequest({
    required this.roomPrefixes,
    required this.date,
    required this.since,
    required this.until,
    required this.buildingCodes,
    required this.utilities,
    required this.nearMe,
    required this.userLocation,
    this.limit = 20,
    this.offset = 0,
  });

  final List<String> roomPrefixes;
  final String date;
  final String? since;
  final String? until;
  final List<String> buildingCodes;
  final List<String> utilities;
  final bool nearMe;
  final SearchLocation? userLocation;
  final int limit;
  final int offset;

  Map<String, dynamic> toMap() => {
        'room_prefixes': roomPrefixes,
        'date': date,
        if (since != null) 'since': since,
        if (until != null) 'until': until,
        'building_codes': buildingCodes,
        'utilities': utilities,
        'near_me': nearMe,
        if (userLocation != null) 'user_location': userLocation!.toMap(),
        'limit': limit,
        'offset': offset,
      };
}

class MatchingWindow {
  const MatchingWindow({
    required this.start,
    required this.end,
  });

  final String start;
  final String end;

  Map<String, dynamic> toMap() => {
        'start': start,
        'end': end,
      };
}

class WeeklyAvailabilityWindow {
  const WeeklyAvailabilityWindow({
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

  Map<String, dynamic> toMap() => {
        'day': day,
        'start': start,
        'end': end,
        'valid_from': validFrom,
        'valid_to': validTo,
      };
}

class RoomSearchItem {
  const RoomSearchItem({
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
  final List<MatchingWindow> matchingWindows;
  final List<WeeklyAvailabilityWindow> weeklyAvailability;

  Map<String, dynamic> toMap() => {
        'room_id': roomId,
        'building_code': buildingCode,
        'building_name': buildingName,
        'room_number': roomNumber,
        'capacity': capacity,
        'reliability': reliability,
        'utilities': utilities,
        'distance_meters': distanceMeters,
        'matching_windows': matchingWindows.map((e) => e.toMap()).toList(),
        'weekly_availability':
            weeklyAvailability.map((e) => e.toMap()).toList(),
      };
}

class RoomSearchResponse {
  const RoomSearchResponse({
    required this.query,
    required this.total,
    required this.items,
  });

  final RoomSearchRequest query;
  final int total;
  final List<RoomSearchItem> items;

  Map<String, dynamic> toMap() => {
        'query': query.toMap(),
        'total': total,
        'items': items.map((e) => e.toMap()).toList(),
      };
}