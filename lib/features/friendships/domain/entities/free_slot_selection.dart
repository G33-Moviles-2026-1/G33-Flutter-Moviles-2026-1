class FreeSlotSelection {
  const FreeSlotSelection({
    required this.date,
    required this.weekday,
    required this.startTime,
    required this.endTime,
  });

  final DateTime date;
  final int weekday;
  final String startTime;
  final String endTime;

  String get key => selectionKey(date, startTime, endTime);

  String get label {
    return '${weekdayShortLabel(weekday)} ${date.day}/${date.month} '
        '${formatSelectionTime(startTime)}-${formatSelectionTime(endTime)}';
  }
}

String selectionKey(DateTime date, String startTime, String endTime) {
  return '${date.year}-${date.month}-${date.day}|'
      '${timeRangeKey(startTime, endTime)}';
}

String timeRangeKey(String startTime, String endTime) {
  return '${normalizeSelectionTime(startTime)}-'
      '${normalizeSelectionTime(endTime)}';
}

String weekdayShortLabel(int weekday) {
  return switch (weekday) {
    DateTime.monday => 'Mon',
    DateTime.tuesday => 'Tue',
    DateTime.wednesday => 'Wed',
    DateTime.thursday => 'Thu',
    DateTime.friday => 'Fri',
    DateTime.saturday => 'Sat',
    DateTime.sunday => 'Sun',
    _ => '',
  };
}

String formatSelectionTime(String raw) {
  final normalized = normalizeSelectionTime(raw);
  if (normalized.length < 5) return raw;

  return normalized.substring(0, 5);
}

String normalizeSelectionTime(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return value;

  final parts = value.split(':');
  if (parts.length < 2) return value;

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return value;

  return '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';
}

int minutesFromSelectionTime(String raw) {
  final normalized = normalizeSelectionTime(raw);
  final parts = normalized.split(':');
  if (parts.length < 2) return 0;

  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = int.tryParse(parts[1]) ?? 0;

  return hour * 60 + minute;
}

String selectionTimeFromMinutes(int minutes) {
  final hour = (minutes ~/ 60).clamp(0, 23);
  final minute = (minutes % 60).clamp(0, 59);

  return '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';
}
