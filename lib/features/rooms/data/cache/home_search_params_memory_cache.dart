import 'package:flutter/material.dart';

enum HomeSearchParamKey {
  rawRoomInput,
  selectedUtilities,
  selectedDate,
  since,
  until,
  nearMe,
}

class HomeSearchParamsArrayMap {
  const HomeSearchParamsArrayMap._(this._values);

  factory HomeSearchParamsArrayMap.empty() {
    return const HomeSearchParamsArrayMap._({});
  }

  final Map<HomeSearchParamKey, Object?> _values;

  T? getValue<T>(HomeSearchParamKey key) {
    final value = _values[key];
    if (value is T) return value;
    return null;
  }

  HomeSearchParamsArrayMap put(HomeSearchParamKey key, Object? value) {
    final next = Map<HomeSearchParamKey, Object?>.from(_values);
    next[key] = value;
    return HomeSearchParamsArrayMap._(next);
  }
}

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

  factory HomeSearchParamsSnapshot.fromArrayMap(HomeSearchParamsArrayMap map) {
    return HomeSearchParamsSnapshot(
      rawRoomInput:
          map.getValue<String>(HomeSearchParamKey.rawRoomInput) ?? '',
      selectedUtilities:
          map.getValue<Set<String>>(HomeSearchParamKey.selectedUtilities) ??
              <String>{},
      selectedDate: map.getValue<DateTime>(HomeSearchParamKey.selectedDate),
      since: map.getValue<TimeOfDay>(HomeSearchParamKey.since),
      until: map.getValue<TimeOfDay>(HomeSearchParamKey.until),
      nearMe: map.getValue<bool>(HomeSearchParamKey.nearMe) ?? false,
    );
  }

  HomeSearchParamsArrayMap toArrayMap() {
    return HomeSearchParamsArrayMap.empty()
        .put(HomeSearchParamKey.rawRoomInput, rawRoomInput)
        .put(
          HomeSearchParamKey.selectedUtilities,
          Set<String>.from(selectedUtilities),
        )
        .put(
          HomeSearchParamKey.selectedDate,
          selectedDate == null
              ? null
              : DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                ),
        )
        .put(
          HomeSearchParamKey.since,
          since == null
              ? null
              : TimeOfDay(hour: since!.hour, minute: since!.minute),
        )
        .put(
          HomeSearchParamKey.until,
          until == null
              ? null
              : TimeOfDay(hour: until!.hour, minute: until!.minute),
        )
        .put(HomeSearchParamKey.nearMe, nearMe);
  }

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
  HomeSearchParamsArrayMap _arrayMap = HomeSearchParamsArrayMap.empty();

  HomeSearchParamsSnapshot? get snapshot {
    final hasAnyValue = _arrayMap.getValue<String>(HomeSearchParamKey.rawRoomInput) != null ||
        _arrayMap.getValue<Set<String>>(HomeSearchParamKey.selectedUtilities) != null ||
        _arrayMap.getValue<DateTime>(HomeSearchParamKey.selectedDate) != null ||
        _arrayMap.getValue<TimeOfDay>(HomeSearchParamKey.since) != null ||
        _arrayMap.getValue<TimeOfDay>(HomeSearchParamKey.until) != null ||
        _arrayMap.getValue<bool>(HomeSearchParamKey.nearMe) != null;

    if (!hasAnyValue) return null;

    return HomeSearchParamsSnapshot.fromArrayMap(_arrayMap);
  }

  bool get hasSnapshot => snapshot != null;

  void save(HomeSearchParamsSnapshot snapshot) {
    _arrayMap = snapshot.toArrayMap();
  }

  void clear() {
    _arrayMap = HomeSearchParamsArrayMap.empty();
  }
}