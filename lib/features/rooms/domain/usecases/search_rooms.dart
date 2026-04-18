import '../entities/room_search.dart';
import '../repositories/rooms_repository.dart';

class SearchRoomsValidationException implements Exception {
  const SearchRoomsValidationException(this.message);
  final String message;
}

class SearchRoomsInput {
  const SearchRoomsInput({
    required this.rawRoomInput,
    required this.date,
    this.since,
    this.until,
    required this.utilities,
    required this.nearMe,
    this.userLocation,
    this.offset = 0,
  });

  final String rawRoomInput;
  final String date;
  final String? since;
  final String? until;
  final Set<String> utilities;
  final bool nearMe;
  final SearchLocation? userLocation;
  final int offset;
}

class SearchRooms {
  const SearchRooms(this._repository);

  final RoomRepository _repository;

  Future<RoomSearchResponse> call(SearchRoomsInput input) {
    _validate(input);
    return _repository.searchRooms(_buildRequest(input));
  }

  Future<RoomSearchResponse> callWithRequest(RoomSearchRequest request) {
    return _repository.searchRooms(request);
  }

  void _validate(SearchRoomsInput input) {
    if (input.since == null && input.until == null) {
      throw const SearchRoomsValidationException(
        'Please provide at least one of Since or Until.',
      );
    }

    final since = input.since;
    final until = input.until;
    if (since != null && until != null && !_isStrictlyEarlier(since, until)) {
      throw const SearchRoomsValidationException(
        'Since must be earlier than Until.',
      );
    }
  }

  RoomSearchRequest _buildRequest(SearchRoomsInput input) {
    return RoomSearchRequest(
      roomPrefixes: _normalizePrefixes(input.rawRoomInput),
      date: input.date,
      since: input.since,
      until: input.until,
      buildingCodes: const [],
      utilities: input.utilities.toList()..sort(),
      nearMe: input.nearMe,
      userLocation: input.userLocation,
      limit: 20,
      offset: input.offset,
    );
  }

  List<String> _normalizePrefixes(String raw) {
    return raw
        .split(',')
        .map(_normalizeToken)
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  String _normalizeToken(String value) {
    return value
        .replaceAll('-', ' ')
        .trim()
        .toUpperCase()
        .split(RegExp(r'\s+'))
        .join(' ');
  }

  bool _isStrictlyEarlier(String a, String b) {
    final aMinutes = _toMinutes(a);
    final bMinutes = _toMinutes(b);
    return aMinutes < bMinutes;
  }

  int _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
