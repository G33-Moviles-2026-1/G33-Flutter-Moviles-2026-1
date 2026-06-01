import 'package:andespace/features/friendships/domain/entities/free_slot_selection.dart';
import 'package:andespace/features/schedule/domain/entities/friends_free_slot.dart';

enum FriendsFreeSlotsStatus { loading, success, error }

class FriendsFreeSlotsState {
  const FriendsFreeSlotsState({
    required this.referenceDate,
    this.status = FriendsFreeSlotsStatus.loading,
    this.freeSlots,
    this.selectedSlots = const {},
    this.errorMessage,
    this.findRoomsErrorMessage,
    this.isFindingRooms = false,
    this.isOffline = false,
    this.lastUpdated,
  });

  final DateTime referenceDate;
  final FriendsFreeSlotsStatus status;
  final FriendsFreeSlots? freeSlots;
  final Map<String, FreeSlotSelection> selectedSlots;
  final String? errorMessage;
  final String? findRoomsErrorMessage;
  final bool isFindingRooms;
  final bool isOffline;
  final DateTime? lastUpdated;

  bool get isLoading => status == FriendsFreeSlotsStatus.loading;
  bool get hasError => status == FriendsFreeSlotsStatus.error;
  bool get hasSelectedSlots => selectedSlots.isNotEmpty;
  Set<String> get selectedSlotKeys => selectedSlots.keys.toSet();

  List<FreeSlotSelection> get selectedSlotList => selectedSlots.values.toList();

  String get weekRangeLabel {
    final start = referenceDate.subtract(
      Duration(days: referenceDate.weekday - 1),
    );
    final end = start.add(const Duration(days: 5));

    return '${start.day}/${start.month} - ${end.day}/${end.month}';
  }

  FriendsFreeSlotsState copyWith({
    DateTime? referenceDate,
    FriendsFreeSlotsStatus? status,
    FriendsFreeSlots? freeSlots,
    bool clearFreeSlots = false,
    Map<String, FreeSlotSelection>? selectedSlots,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? findRoomsErrorMessage,
    bool clearFindRoomsErrorMessage = false,
    bool? isFindingRooms,
    bool? isOffline,
    DateTime? lastUpdated,
    bool clearLastUpdated = false,
  }) {
    return FriendsFreeSlotsState(
      referenceDate: referenceDate ?? this.referenceDate,
      status: status ?? this.status,
      freeSlots: clearFreeSlots ? null : (freeSlots ?? this.freeSlots),
      selectedSlots: selectedSlots ?? this.selectedSlots,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      findRoomsErrorMessage: clearFindRoomsErrorMessage
          ? null
          : (findRoomsErrorMessage ?? this.findRoomsErrorMessage),
      isFindingRooms: isFindingRooms ?? this.isFindingRooms,
      isOffline: isOffline ?? this.isOffline,
      lastUpdated: clearLastUpdated ? null : (lastUpdated ?? this.lastUpdated),
    );
  }
}
