import 'time_range.dart';

enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

class RoomDetail {
  final String id;
  final String buildingName;
  final int capacity;

  final double reliability;
  final bool isCurrentlyAvailable;

  final Map<Weekday, List<TimeRange>> weeklyAvailability;

  final List<String> utilities;

  const RoomDetail({
    required this.id,
    required this.buildingName,
    required this.capacity,
    required this.reliability,
    required this.isCurrentlyAvailable,
    required this.weeklyAvailability,
    required this.utilities,
  });

  List<TimeRange> gapsFor(Weekday weekday) {
    return weeklyAvailability[weekday] ?? [];
  }
}