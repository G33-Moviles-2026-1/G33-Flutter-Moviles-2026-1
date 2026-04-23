import 'dart:async';

import '../../domain/entities/room_search.dart';

class RoomSearchPageSparseArray {
  const RoomSearchPageSparseArray._(this._values);

  factory RoomSearchPageSparseArray.empty() {
    return const RoomSearchPageSparseArray._({});
  }

  final Map<int, RoomSearchResponse> _values;

  RoomSearchResponse? operator [](int pageNumber) => _values[pageNumber];

  bool containsPage(int pageNumber) => _values.containsKey(pageNumber);

  Map<int, RoomSearchResponse> toMap() => Map<int, RoomSearchResponse>.from(_values);

  RoomSearchPageSparseArray put(int pageNumber, RoomSearchResponse response) {
    final next = Map<int, RoomSearchResponse>.from(_values);
    next[pageNumber] = response;
    return RoomSearchPageSparseArray._(next);
  }

  RoomSearchPageSparseArray keepOnlyFirstThreePages() {
    final next = <int, RoomSearchResponse>{};

    for (final entry in _values.entries) {
      if (entry.key >= 1 && entry.key <= 3) {
        next[entry.key] = entry.value;
      }
    }

    return RoomSearchPageSparseArray._(next);
  }
}

class RoomSearchMemorySnapshot {
  const RoomSearchMemorySnapshot({
    required this.baseQuery,
    required this.pages,
  });

  final RoomSearchRequest baseQuery;
  final RoomSearchPageSparseArray pages;

  RoomSearchResponse? page(int pageNumber) => pages[pageNumber];
}

class RoomSearchMemoryCache {
  RoomSearchMemoryCache();

  final StreamController<RoomSearchMemorySnapshot?> _controller =
      StreamController<RoomSearchMemorySnapshot?>.broadcast();

  RoomSearchMemorySnapshot? _snapshot;

  Stream<RoomSearchMemorySnapshot?> get stream => _controller.stream;

  RoomSearchMemorySnapshot? get snapshot => _snapshot;

  bool get hasSnapshot => _snapshot != null;

  RoomSearchResponse? getCachedPage(int pageNumber) {
    return _snapshot?.page(pageNumber);
  }

  RoomSearchItem? findCachedRoomById(String roomId) {
    final snapshot = _snapshot;
    if (snapshot == null) return null;

    for (final response in snapshot.pages.toMap().values) {
      for (final item in response.items) {
        if (item.roomId == roomId) {
          return item;
        }
      }
    }

    return null;
  }

  void replaceWithFirstPage({
    required RoomSearchRequest baseQuery,
    required RoomSearchResponse firstPage,
  }) {
    _snapshot = RoomSearchMemorySnapshot(
      baseQuery: baseQuery.copyWith(offset: 0),
      pages: RoomSearchPageSparseArray.empty().put(1, firstPage),
    );
    _emit();
  }

  void storePage({
    required int pageNumber,
    required RoomSearchResponse response,
  }) {
    final current = _snapshot;
    if (current == null) return;
    if (pageNumber < 1 || pageNumber > 3) return;

    _snapshot = RoomSearchMemorySnapshot(
      baseQuery: current.baseQuery,
      pages: current.pages.put(pageNumber, response).keepOnlyFirstThreePages(),
    );
    _emit();
  }

  void clear() {
    _snapshot = null;
    _emit();
  }

  void dispose() {
    _controller.close();
  }

  void _emit() {
    _controller.add(_snapshot);
  }
}