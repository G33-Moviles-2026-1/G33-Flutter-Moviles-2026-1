import 'package:andespace/core/di/core_provider.dart';
import 'package:andespace/core/error/dio_error_mapper.dart';
import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/get_navigation_path.dart';
import '../../domain/usecases/get_nearest_node.dart';
import '../providers/navigation_providers.dart';
import 'path_state.dart';

final _validChars = RegExp(r'^[a-zA-Z0-9 \-\.,]+$');

class PathNotifier
    extends AutoDisposeFamilyNotifier<PathState, RoomSearchItem?> {
  late final GetNearestNode _getNearestNode;
  late final GetNavigationPath _getNavigationPath;
  late final SessionNotifier _sessionNotifier;

  @override
  PathState build(RoomSearchItem? arg) {
    _getNearestNode = ref.read(getNearestNodeUseCaseProvider);
    _getNavigationPath = ref.read(getNavigationPathUseCaseProvider);
    _sessionNotifier = ref.read(sessionControllerProvider.notifier);

    final destText = arg != null ? arg.roomId : '';
    return PathState.initial().copyWith(destText: destText);
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

    state = state.copyWith(
      status: PathStatus.loadingPath,
      clearPath: true,
    );

    try {
      final path = await _getNavigationPath(
        fromRoom: state.originText.trim(),
        toRoom: state.destText.trim(),
      );

      state = state.copyWith(
        status: PathStatus.success,
        path: path,
      );
    } catch (e) {
      state = state.copyWith(status: PathStatus.initial);
      rethrow;
    }
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