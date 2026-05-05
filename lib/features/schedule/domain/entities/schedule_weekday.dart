class ScheduleWeekday {
  const ScheduleWeekday._();

  static const monday = 'monday';
  static const tuesday = 'tuesday';
  static const wednesday = 'wednesday';
  static const thursday = 'thursday';
  static const friday = 'friday';
  static const saturday = 'saturday';
  static const sunday = 'sunday';

  static const values = <String>[
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
    sunday,
  ];

  static bool isValid(String value) {
    return values.contains(value);
  }

  static String shortLabel(String value) {
    switch (value) {
      case monday:
        return 'MO';
      case tuesday:
        return 'TU';
      case wednesday:
        return 'WE';
      case thursday:
        return 'TH';
      case friday:
        return 'FR';
      case saturday:
        return 'SA';
      case sunday:
        return 'SU';
      default:
        return value;
    }
  }
}