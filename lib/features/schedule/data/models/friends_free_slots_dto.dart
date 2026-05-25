import '../../domain/entities/friends_free_slot.dart';

class FriendFreeSlotModel {
  const FriendFreeSlotModel({
    required this.startTime,
    required this.endTime,
    required this.freeCount,
    this.date,
    this.weekday,
    this.availableFriends = const [],
  });

  final DateTime? date;
  final String? weekday;
  final String startTime;
  final String endTime;
  final int freeCount;
  final List<String> availableFriends;

  factory FriendFreeSlotModel.fromJson(
    Map<String, dynamic> json, {
    required int selectedFriendCount,
  }) {
    return FriendFreeSlotModel(
      date: _parseDate(_firstValue(json, const ['date', 'day_date', 'day'])),
      weekday: _firstString(json, const ['weekday', 'day', 'week_day']),
      startTime: _firstString(json, const [
        'start_time',
        'slot_start',
        'start',
        'startTime',
      ]),
      endTime: _firstString(json, const [
        'end_time',
        'slot_end',
        'end',
        'endTime',
      ]),
      freeCount: _readFreeCount(json, selectedFriendCount),
      availableFriends: _readStringList(json, const [
        'available_friends',
        'free_friends',
        'friend_emails',
        'friends',
        'users',
        'available_participants',
      ]),
    );
  }

  FriendFreeSlot toEntity() {
    return FriendFreeSlot(
      date: date,
      weekday: weekday,
      startTime: startTime,
      endTime: endTime,
      freeCount: freeCount,
      availableFriends: availableFriends,
    );
  }
}

class FriendsFreeSlotsModel {
  const FriendsFreeSlotsModel({
    required this.totalFriends,
    required this.slots,
  });

  final int totalFriends;
  final List<FriendFreeSlotModel> slots;

  factory FriendsFreeSlotsModel.fromJson(
    Object? json, {
    required int selectedFriendCount,
  }) {
    final totalFriends = _readTotalFriends(json, selectedFriendCount);
    final slotMaps = _extractSlotMaps(json);

    return FriendsFreeSlotsModel(
      totalFriends: totalFriends,
      slots: slotMaps
          .map(
            (slot) => FriendFreeSlotModel.fromJson(
              slot,
              selectedFriendCount: totalFriends,
            ),
          )
          .where((slot) => slot.startTime.isNotEmpty && slot.endTime.isNotEmpty)
          .toList(),
    );
  }

  FriendsFreeSlots toEntity() {
    return FriendsFreeSlots(
      totalFriends: totalFriends,
      slots: slots.map((slot) => slot.toEntity()).toList(),
    );
  }
}

int _readTotalFriends(Object? json, int fallback) {
  if (json is! Map) return fallback;

  final map = Map<String, dynamic>.from(json);
  final value = _firstValue(map, const [
    'total_friends',
    'selected_friends',
    'selected_count',
    'friend_count',
    'participant_count',
    'max_available_count',
    'requested_friends_count',
  ]);

  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;

  return fallback;
}

List<Map<String, dynamic>> _extractSlotMaps(
  Object? data, {
  Map<String, dynamic> inherited = const {},
}) {
  if (data is List) return _extractFromList(data, inherited: inherited);
  if (data is! Map) return const [];

  final map = Map<String, dynamic>.from(data);
  final nextInherited = {
    ...inherited,
    if (map.containsKey('date')) 'date': map['date'],
    if (map.containsKey('day_date')) 'day_date': map['day_date'],
    if (map.containsKey('weekday')) 'weekday': map['weekday'],
    if (map.containsKey('day')) 'day': map['day'],
    if (map.containsKey('week_day')) 'week_day': map['week_day'],
  };

  if (_hasTimeFields(map)) {
    return [
      {...inherited, ...map},
    ];
  }

  final slots = <Map<String, dynamic>>[];

  for (final key in const ['days', 'week', 'day_slots']) {
    final value = map[key];
    if (value is List) {
      slots.addAll(_extractFromList(value, inherited: nextInherited));
    }
  }

  for (final key in const ['free_slots', 'slots', 'items', 'results', 'data']) {
    final value = map[key];
    if (value is List) {
      slots.addAll(_extractFromList(value, inherited: nextInherited));
    } else if (value is Map) {
      slots.addAll(_extractSlotMaps(value, inherited: nextInherited));
    }
  }

  return slots;
}

List<Map<String, dynamic>> _extractFromList(
  List<dynamic> raw, {
  Map<String, dynamic> inherited = const {},
}) {
  final slots = <Map<String, dynamic>>[];

  for (final item in raw) {
    if (item is! Map) continue;

    final map = Map<String, dynamic>.from(item);
    final nextInherited = {
      ...inherited,
      if (map.containsKey('date')) 'date': map['date'],
      if (map.containsKey('day_date')) 'day_date': map['day_date'],
      if (map.containsKey('weekday')) 'weekday': map['weekday'],
      if (map.containsKey('day')) 'day': map['day'],
      if (map.containsKey('week_day')) 'week_day': map['week_day'],
    };

    if (_hasTimeFields(map)) {
      slots.add({...inherited, ...map});
      continue;
    }

    for (final key in const ['free_slots', 'slots', 'items']) {
      final value = map[key];
      if (value is List) {
        slots.addAll(_extractFromList(value, inherited: nextInherited));
      }
    }
  }

  return slots;
}

bool _hasTimeFields(Map<String, dynamic> json) {
  return _firstString(json, const [
        'start_time',
        'slot_start',
        'start',
        'startTime',
      ]).isNotEmpty &&
      _firstString(json, const [
        'end_time',
        'slot_end',
        'end',
        'endTime',
      ]).isNotEmpty;
}

int _readFreeCount(Map<String, dynamic> json, int selectedFriendCount) {
  final value = _firstValue(json, const [
    'free_count',
    'available_count',
    'friends_free',
    'count',
    'overlap_count',
  ]);

  final parsed = switch (value) {
    num n => n.toInt(),
    String s => int.tryParse(s),
    _ => null,
  };

  if (parsed != null) {
    return parsed.clamp(0, selectedFriendCount).toInt();
  }

  final availableFriends = _readStringList(json, const [
    'available_friends',
    'free_friends',
    'friend_emails',
    'friends',
    'users',
    'available_participants',
  ]);

  if (availableFriends.isNotEmpty) {
    return availableFriends.length.clamp(0, selectedFriendCount).toInt();
  }

  return selectedFriendCount;
}

List<String> _readStringList(Map<String, dynamic> json, List<String> keys) {
  final value = _firstValue(json, keys);
  if (value is! List) return const [];

  return value
      .map((item) {
        if (item is Map) {
          final email = item['email'] ?? item['correo'] ?? item['username'];
          return email?.toString() ?? '';
        }

        return item.toString();
      })
      .where((item) => item.trim().isNotEmpty)
      .toList();
}

String _firstString(Map<String, dynamic> json, List<String> keys) {
  final value = _firstValue(json, keys);
  return value?.toString() ?? '';
}

Object? _firstValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key) && json[key] != null) return json[key];
  }

  return null;
}

DateTime? _parseDate(Object? value) {
  if (value == null) return null;

  final raw = value.toString().trim();
  if (raw.isEmpty) return null;

  final isoDate = DateTime.tryParse(raw);
  if (isoDate != null) {
    return DateTime(isoDate.year, isoDate.month, isoDate.day);
  }

  final match = RegExp(r'^(\d{1,2})-(\d{1,2})-(\d{4})$').firstMatch(raw);
  if (match == null) return null;

  final day = int.tryParse(match.group(1)!);
  final month = int.tryParse(match.group(2)!);
  final year = int.tryParse(match.group(3)!);

  if (day == null || month == null || year == null) return null;

  return DateTime(year, month, day);
}
