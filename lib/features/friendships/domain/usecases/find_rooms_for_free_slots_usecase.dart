import 'package:andespace/core/utils/date_time_utils.dart';
import 'package:andespace/features/friendships/domain/entities/free_slot_selection.dart';
import 'package:andespace/features/friendships/domain/entities/friends_free_slots_room_recommendations.dart';
import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:andespace/features/rooms/domain/repositories/rooms_repository.dart';

class FindRoomsForFreeSlotsUseCase {
  const FindRoomsForFreeSlotsUseCase({required this.roomRepository});

  final RoomRepository roomRepository;

  Future<FriendsFreeSlotsRoomRecommendations> call({
    required Iterable<FreeSlotSelection> selections,
  }) async {
    final sortedSelections = selections.toList()..sort(_compareSelections);

    final responses = await Future.wait(
      sortedSelections.map((slot) {
        return roomRepository.searchRooms(
          RoomSearchRequest(
            roomPrefixes: const [],
            date: DateTimeUtils.toApiDate(slot.date),
            since: slot.startTime,
            until: slot.endTime,
            buildingCodes: const [],
            utilities: const [],
            nearMe: false,
            userLocation: null,
            limit: 20,
            offset: 0,
          ),
        );
      }),
    );

    return FriendsFreeSlotsRoomRecommendations(
      rooms: _mergeRoomResults(responses.expand((r) => r.items)),
      timeFilterOptions: _mergeTimeFilterOptions(sortedSelections),
      description:
          'Selected slots: ${sortedSelections.map((slot) => slot.label).join(', ')}',
    );
  }

  int _compareSelections(FreeSlotSelection a, FreeSlotSelection b) {
    final dayComparison = a.date.compareTo(b.date);
    if (dayComparison != 0) return dayComparison;

    return minutesFromSelectionTime(
      a.startTime,
    ).compareTo(minutesFromSelectionTime(b.startTime));
  }

  List<RoomSearchItem> _mergeRoomResults(Iterable<RoomSearchItem> rooms) {
    final byRoomId = <String, RoomSearchItem>{};
    final windowsByRoomId = <String, Map<String, MatchingWindow>>{};

    for (final room in rooms) {
      final key = room.roomId.isNotEmpty
          ? room.roomId
          : '${room.buildingCode}-${room.roomNumber}';
      final existing = byRoomId[key];

      if (existing == null || room.reliability > existing.reliability) {
        byRoomId[key] = room;
      }

      final windows = windowsByRoomId.putIfAbsent(key, () => {});
      for (final window in room.matchingWindows) {
        windows['${window.start}-${window.end}'] = window;
      }
    }

    return byRoomId.entries.map((entry) {
      final room = entry.value;
      final windows = windowsByRoomId[entry.key]!.values.toList()
        ..sort((a, b) => a.start.compareTo(b.start));

      return RoomSearchItem(
        roomId: room.roomId,
        buildingCode: room.buildingCode,
        buildingName: room.buildingName,
        roomNumber: room.roomNumber,
        capacity: room.capacity,
        reliability: room.reliability,
        utilities: room.utilities,
        distanceSeconds: room.distanceSeconds,
        matchingWindows: windows,
      );
    }).toList()..sort((a, b) {
      final reliability = b.reliability.compareTo(a.reliability);
      if (reliability != 0) return reliability;
      return a.roomId.compareTo(b.roomId);
    });
  }

  List<MatchingWindow> _mergeTimeFilterOptions(
    Iterable<FreeSlotSelection> selections,
  ) {
    final windows = <String, MatchingWindow>{};

    for (final slot in selections) {
      final key = timeRangeKey(slot.startTime, slot.endTime);
      windows[key] = MatchingWindow(start: slot.startTime, end: slot.endTime);
    }

    return windows.values.toList()..sort((a, b) => a.start.compareTo(b.start));
  }
}
