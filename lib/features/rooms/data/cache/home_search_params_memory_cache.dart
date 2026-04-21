import 'package:flutter/material.dart';

class HomeSearchParamsSnapshot {
  const HomeSearchParamsSnapshot({
    required this.rawRoomInput,
    required this.selectedUtilities,
    required this.selectedDate,
    required this.since,
    required this.until,
    required this.nearMe,
  });

  final String rawRoomInput;
  final Set<String> selectedUtilities;
  final DateTime? selectedDate;
  final TimeOfDay? since;
  final TimeOfDay? until;
  final bool nearMe;

  HomeSearchParamsSnapshot copyWith({
    String? rawRoomInput,
    Set<String>? selectedUtilities,
    DateTime? selectedDate,
    TimeOfDay? since,
    TimeOfDay? until,
    bool? nearMe,
  }) {
    return HomeSearchParamsSnapshot(
      rawRoomInput: rawRoomInput ?? this.rawRoomInput,
      selectedUtilities: selectedUtilities ?? this.selectedUtilities,
      selectedDate: selectedDate ?? this.selectedDate,
      since: since ?? this.since,
      until: until ?? this.until,
      nearMe: nearMe ?? this.nearMe,
    );
  }
}

class HomeSearchParamsMemoryCache {
  HomeSearchParamsSnapshot? _snapshot;

  HomeSearchParamsSnapshot? get snapshot => _snapshot;

  bool get hasSnapshot => _snapshot != null;

  void save(HomeSearchParamsSnapshot snapshot) {
    _snapshot = HomeSearchParamsSnapshot(
      rawRoomInput: snapshot.rawRoomInput,
      selectedUtilities: Set<String>.from(snapshot.selectedUtilities),
      selectedDate: snapshot.selectedDate == null
          ? null
          : DateTime(
              snapshot.selectedDate!.year,
              snapshot.selectedDate!.month,
              snapshot.selectedDate!.day,
            ),
      since: snapshot.since == null
          ? null
          : TimeOfDay(
              hour: snapshot.since!.hour,
              minute: snapshot.since!.minute,
            ),
      until: snapshot.until == null
          ? null
          : TimeOfDay(
              hour: snapshot.until!.hour,
              minute: snapshot.until!.minute,
            ),
      nearMe: snapshot.nearMe,
    );
  }

  void clear() {
    _snapshot = null;
  }
}