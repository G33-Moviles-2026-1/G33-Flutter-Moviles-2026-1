import '../../domain/entities/navigation.dart';

enum PathStatus { initial, locatingOrigin, loadingPath, success }

class PathState {
  const PathState({
    required this.status,
    required this.originText,
    required this.destText,
    this.path,
    this.originValidationError,
    this.destValidationError,
  });

  const PathState.initial()
      : status = PathStatus.initial,
        originText = '',
        destText = '',
        path = null,
        originValidationError = null,
        destValidationError = null;

  final PathStatus status;
  final String originText;
  final String destText;
  final NavigationPath? path;
  final String? originValidationError;
  final String? destValidationError;

  bool get isLocatingOrigin => status == PathStatus.locatingOrigin;
  bool get isLoadingPath => status == PathStatus.loadingPath;
  bool get hasPath => status == PathStatus.success && path != null;

  PathState copyWith({
    PathStatus? status,
    String? originText,
    String? destText,
    NavigationPath? path,
    bool clearPath = false,
    String? originValidationError,
    bool clearOriginValidationError = false,
    String? destValidationError,
    bool clearDestValidationError = false,
  }) {
    return PathState(
      status: status ?? this.status,
      originText: originText ?? this.originText,
      destText: destText ?? this.destText,
      path: clearPath ? null : (path ?? this.path),
      originValidationError: clearOriginValidationError
          ? null
          : (originValidationError ?? this.originValidationError),
      destValidationError: clearDestValidationError
          ? null
          : (destValidationError ?? this.destValidationError),
    );
  }
}