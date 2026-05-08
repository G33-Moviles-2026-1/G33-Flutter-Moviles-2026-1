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

  static int index(String value) {
    switch (value) {
      case monday:
        return DateTime.monday;
      case tuesday:
        return DateTime.tuesday;
      case wednesday:
        return DateTime.wednesday;
      case thursday:
        return DateTime.thursday;
      case friday:
        return DateTime.friday;
      case saturday:
        return DateTime.saturday;
      case sunday:
        return DateTime.sunday;
      default:
        return 99;
    }
  }

  static String? fromDateTimeWeekday(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return monday;
      case DateTime.tuesday:
        return tuesday;
      case DateTime.wednesday:
        return wednesday;
      case DateTime.thursday:
        return thursday;
      case DateTime.friday:
        return friday;
      case DateTime.saturday:
        return saturday;
      case DateTime.sunday:
        return sunday;
      default:
        return null;
    }
  }
}
