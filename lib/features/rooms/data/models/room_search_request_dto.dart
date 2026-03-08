import '../../domain/entities/room_search.dart';

class RoomSearchRequestDto {
  const RoomSearchRequestDto(this.request);

  final RoomSearchRequest request;

  Map<String, dynamic> toJson() {
    return {
      'room_prefixes': request.roomPrefixes,
      'date': request.date,
      if (request.since != null) 'since': request.since,
      if (request.until != null) 'until': request.until,
      'building_codes': request.buildingCodes,
      'utilities': request.utilities,
      'near_me': request.nearMe,
      if (request.userLocation != null)
        'user_location': {
          'latitude': request.userLocation!.latitude,
          'longitude': request.userLocation!.longitude,
        },
      'limit': request.limit,
      'offset': request.offset,
    };
  }
}