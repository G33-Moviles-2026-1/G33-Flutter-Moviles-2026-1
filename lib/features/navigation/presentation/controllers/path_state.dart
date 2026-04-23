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
    this.cacheIndex = 0,
    this.cacheSize = 0,
  });

  const PathState.initial()
      : status = PathStatus.initial,
        originText = '',
        destText = '',
        path = null,
        originValidationError = null,
        destValidationError = null,
        cacheIndex = 0,
        cacheSize = 0;

  final PathStatus status;
  final String originText;
  final String destText;
  final NavigationPath? path;
  final String? originValidationError;
  final String? destValidationError;
  final int cacheIndex;
  final int cacheSize;

  bool get isLocatingOrigin => status == PathStatus.locatingOrigin;
  bool get isLoadingPath => status == PathStatus.loadingPath;
  bool get hasPath => status == PathStatus.success && path != null;
  bool get canGoPrev => cacheIndex > 0;
  bool get canGoNext => cacheIndex < cacheSize - 1;

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
    int? cacheIndex,
    int? cacheSize,
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
      cacheIndex: cacheIndex ?? this.cacheIndex,
      cacheSize: cacheSize ?? this.cacheSize,
    );
  }
}