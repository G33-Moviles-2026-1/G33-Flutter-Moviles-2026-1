import '../entities/room_search.dart';
import '../entities/room_search_result.dart';
import '../entities/room_search_source.dart';
import '../repositories/rooms_repository.dart';
import 'search_rooms_exceptions.dart';

class SearchRoomsValidationException implements Exception {
  const SearchRoomsValidationException(this.message);

  final String message;

  @override
  String toString() => message;
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

  Future<RoomSearchResult> call(SearchRoomsInput input) async {
    _validate(input);
    final request = _buildRequest(input);
    return _execute(request, allowHomepageFallback: true);
  }

  Future<RoomSearchResult> callWithRequest(RoomSearchRequest request) {
    return _execute(request, allowHomepageFallback: false);
  }

  Future<RoomSearchResult> _execute(
    RoomSearchRequest request, {
    required bool allowHomepageFallback,
  }) async {
    try {
      final response = await _repository.searchRooms(request);

      if (request.offset == 0) {
        _repository.cacheFirstSearchPage(
          baseQuery: request.copyWith(offset: 0),
          firstPage: response,
        );
        unawaited(_repository.prefetchFirstPages(request.copyWith(offset: 0)));
      }

      return RoomSearchResult(
        response: response,
        source: RoomSearchSource.network,
      );
    } on SearchRoomsConnectivityException {
      final pageNumber = _pageNumberFromRequest(request);

      if (pageNumber <= 3) {
        final cached = _repository.getCachedSearchPage(pageNumber);
        if (cached != null) {
          return RoomSearchResult(
            response: cached,
            source: RoomSearchSource.cache,
            message: allowHomepageFallback
                ? 'No internet connection. Showing the cached results from your last search.'
                : 'No internet connection. Showing cached results for page $pageNumber.',
          );
        }
      }

      if (!allowHomepageFallback && pageNumber > 3) {
        throw const SearchRoomsOfflinePaginationException(
          'More results require an internet connection. Please check your connection and try again.',
        );
      }

      rethrow;
    }
  }

  void _validate(SearchRoomsInput input) {
    _validateDate(input.date);

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

  void _validateDate(String rawDate) {
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) {
      throw const SearchRoomsValidationException(
        'Please select a valid date.',
      );
    }

    if (parsed.weekday == DateTime.sunday) {
      throw const SearchRoomsValidationException(
        'Campus is closed on Sundays.',
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

  int _pageNumberFromRequest(RoomSearchRequest request) {
    return (request.offset ~/ request.limit) + 1;
  }
}

void unawaited(Future<void> future) {}