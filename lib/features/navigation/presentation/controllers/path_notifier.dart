import 'package:andespace/core/cache/lru_cache.dart';
import 'package:andespace/core/di/core_provider.dart';
import 'package:andespace/core/error/dio_error_mapper.dart';
import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/path_local_data_source.dart';
import '../../domain/entities/navigation.dart';
import '../../domain/usecases/get_navigation_path.dart';
import '../../domain/usecases/get_nearest_node.dart';
import '../providers/navigation_providers.dart';
import 'path_state.dart';

final _validChars = RegExp(r'^[a-zA-Z0-9 \-\.,]+$');

class _HistoryEntry {
  final String originText;
  final String destText;
  final NavigationPath path;

  const _HistoryEntry({
    required this.originText,
    required this.destText,
    required this.path,
  });

  String get key => '$originText|$destText';
}

class PathNotifier
    extends AutoDisposeFamilyNotifier<PathState, RoomSearchItem?> {
  late final GetNearestNode _getNearestNode;
  late final GetNavigationPath _getNavigationPath;
  late final SessionNotifier _sessionNotifier;
  late final PathLocalDataSource _localDs;
  RoomSearchItem? _arg;
  final _lru = LruCache<String, NavigationPath>(10);
  final _history = <_HistoryEntry>[];
  int _historyIndex = -1;

  @override
  PathState build(RoomSearchItem? arg) {
    _arg = arg;
    _getNearestNode = ref.read(getNearestNodeUseCaseProvider);
    _getNavigationPath = ref.read(getNavigationPathUseCaseProvider);
    _sessionNotifier = ref.read(sessionControllerProvider.notifier);
    _localDs = ref.read(pathLocalDataSourceProvider);

    final destText = arg != null ? arg.roomId : '';
    Future.microtask(_loadFromCache);
    return const PathState.initial().copyWith(destText: destText);
  }

  Future<void> _loadFromCache() async {
    try {
      final entries = await _localDs.loadAll();
      if (entries.isEmpty) return;

      for (final e in entries) {
        _lru.put(e.key, e.path);
        _history.add(_HistoryEntry(
          originText: e.originText,
          destText: e.destText,
          path: e.path,
        ));
      }
      _historyIndex = _history.length - 1;

      if (_arg == null) {
        final latest = _history.last;
        state = state.copyWith(
          status: PathStatus.success,
          originText: latest.originText,
          destText: latest.destText,
          path: latest.path,
          cacheIndex: _historyIndex,
          cacheSize: _history.length,
        );
      }
    } catch (_) {}
  }

  Future<void> _persistLru() async {
    try {
      await _localDs.persist(_lru.entries.toList());
    } catch (_) {}
  }

  String? _validate(String text, String fieldName) {
    if (text.trim().isEmpty) return '$fieldName cannot be empty.';
    if (text.length > 50) return '$fieldName must be 50 characters or fewer.';
    if (!_validChars.hasMatch(text)) {
      return '$fieldName contains invalid characters. Only letters, numbers, spaces, hyphens, dots and commas are allowed.';
    }
    return null;
  }

  void updateOriginText(String text) {
    state = state.copyWith(
      originText: text,
      clearPath: true,
      clearOriginValidationError: true,
    );
  }

  void updateDestText(String text) {
    state = state.copyWith(
      destText: text,
      clearPath: true,
      clearDestValidationError: true,
    );
  }

  Future<void> locateOrigin() async {
    state = state.copyWith(
      status: PathStatus.locatingOrigin,
      clearPath: true,
    );

    try {
      await _sessionNotifier.refreshLocation();
      final location = _sessionNotifier.currentLocation;

      if (location == null) {
        state = state.copyWith(status: PathStatus.initial);
        throw Exception('Could not get your location. Please enable GPS and try again.');
      }

      final node = await _getNearestNode(
        lat: location.latitude,
        lon: location.longitude,
      );

      state = state.copyWith(
        status: PathStatus.initial,
        originText: node.buildingHint,
        clearOriginValidationError: true,
      );
    } catch (e) {
      state = state.copyWith(status: PathStatus.initial);
      rethrow;
    }
  }

  Future<void> submit() async {
    final originError = _validate(state.originText, 'Origin');
    final destError = _validate(state.destText, 'Destination');

    if (originError != null || destError != null) {
      state = state.copyWith(
        originValidationError: originError,
        destValidationError: destError,
      );
      return;
    }

    final originText = state.originText.trim();
    final destText = state.destText.trim();
    final key = '$originText|$destText';

    final cached = _lru.get(key);
    if (cached != null) {
      _addToHistory(_HistoryEntry(originText: originText, destText: destText, path: cached));
      state = state.copyWith(
        status: PathStatus.success,
        path: cached,
        cacheIndex: _historyIndex,
        cacheSize: _history.length,
      );
      _persistLru();
      return;
    }

    state = state.copyWith(status: PathStatus.loadingPath, clearPath: true);

    try {
      final path = await _getNavigationPath(fromRoom: originText, toRoom: destText);

      _lru.put(key, path);
      _addToHistory(_HistoryEntry(originText: originText, destText: destText, path: path));

      state = state.copyWith(
        status: PathStatus.success,
        path: path,
        cacheIndex: _historyIndex,
        cacheSize: _history.length,
      );
      _persistLru();
    } catch (e) {
      state = state.copyWith(status: PathStatus.initial);
      rethrow;
    }
  }

  void goToPrevious() {
    if (!state.canGoPrev) return;
    _historyIndex--;
    _restoreFromHistory();
  }

  void goToNext() {
    if (!state.canGoNext) return;
    _historyIndex++;
    _restoreFromHistory();
  }

  void _restoreFromHistory() {
    final entry = _history[_historyIndex];
    _lru.get(entry.key);
    state = state.copyWith(
      status: PathStatus.success,
      originText: entry.originText,
      destText: entry.destText,
      path: entry.path,
      cacheIndex: _historyIndex,
      cacheSize: _history.length,
      clearOriginValidationError: true,
      clearDestValidationError: true,
    );
    _persistLru();
  }

  void _addToHistory(_HistoryEntry entry) {
    final existingIdx = _history.indexWhere((e) => e.key == entry.key);

    if (existingIdx >= 0) {
      _history[existingIdx] = entry;
      _historyIndex = existingIdx;
      return;
    }

    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    _history.add(entry);
    if (_history.length > 10) _history.removeAt(0);
    _historyIndex = _history.length - 1;
  }

  String mapError(Object error) => DioErrorMapper.map(
        error,
        onBadResponse: (statusCode, detail) {
          if (statusCode == 404) {
            return 'Room not found or no route exists between the selected rooms.';
          }
          if (detail != null) return detail;
          return 'Something went wrong. Please try again.';
        },
      );
}

final pathControllerProvider = NotifierProvider.autoDispose
    .family<PathNotifier, PathState, RoomSearchItem?>(PathNotifier.new);
