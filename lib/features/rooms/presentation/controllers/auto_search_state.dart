import '../../domain/entities/room_search.dart';

enum AutoSearchStatus { initial, loading, success, empty, failure }

class AutoSearchState {
  const AutoSearchState({
    required this.status,
    this.rooms = const [],
    this.currentIndex = 0,
    this.targetDate,
    this.targetTime,
    this.errorMessage,
    this.isSubmittingInteraction = false,
  });

  const AutoSearchState.initial() : this(status: AutoSearchStatus.initial);

  final AutoSearchStatus status;
  final List<RoomSearchItem> rooms;
  final int currentIndex;
  final String? targetDate;
  final String? targetTime;
  final String? errorMessage;
  final bool isSubmittingInteraction;

  bool get isLoading => status == AutoSearchStatus.loading;
  bool get hasRoom => currentRoom != null;

  RoomSearchItem? get currentRoom {
    if (currentIndex < 0 || currentIndex >= rooms.length) return null;
    return rooms[currentIndex];
  }

  AutoSearchState copyWith({
    AutoSearchStatus? status,
    List<RoomSearchItem>? rooms,
    int? currentIndex,
    String? targetDate,
    String? targetTime,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isSubmittingInteraction,
  }) {
    return AutoSearchState(
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      currentIndex: currentIndex ?? this.currentIndex,
      targetDate: targetDate ?? this.targetDate,
      targetTime: targetTime ?? this.targetTime,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      isSubmittingInteraction:
          isSubmittingInteraction ?? this.isSubmittingInteraction,
    );
  }
}
