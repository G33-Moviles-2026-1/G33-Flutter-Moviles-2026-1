import 'dart:async';

import '../../domain/entities/room_search.dart';

class RoomSearchMemorySnapshot {
  const RoomSearchMemorySnapshot({
    required this.baseQuery,
    required this.pages,
  });

  final RoomSearchRequest baseQuery;
  final Map<int, RoomSearchResponse> pages;

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

  void replaceWithFirstPage({
    required RoomSearchRequest baseQuery,
    required RoomSearchResponse firstPage,
  }) {
    _snapshot = RoomSearchMemorySnapshot(
      baseQuery: baseQuery.copyWith(offset: 0),
      pages: {1: firstPage},
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

    final updatedPages = Map<int, RoomSearchResponse>.from(current.pages);
    updatedPages[pageNumber] = response;

    _snapshot = RoomSearchMemorySnapshot(
      baseQuery: current.baseQuery,
      pages: updatedPages,
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