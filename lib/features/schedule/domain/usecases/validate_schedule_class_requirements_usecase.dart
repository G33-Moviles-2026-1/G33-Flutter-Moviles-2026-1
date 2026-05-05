import '../entities/manual_class.dart';
import '../entities/schedule_class.dart';
import '../entities/schedule_weekday.dart';
import '../exceptions/schedule_validation_exception.dart';

class ValidateScheduleClassRequirementsUseCase {
  const ValidateScheduleClassRequirementsUseCase();

  void call({
    required List<ManualClass> newClasses,
    List<ScheduleClass> existingClasses = const [],
  }) {
    if (newClasses.isEmpty) {
      throw const ScheduleValidationException('There are no classes to save.');
    }

    for (final scheduleClass in newClasses) {
      _validateClassFields(scheduleClass);
    }

    _validateNewClassesDoNotOverlapEachOther(newClasses);
    _validateNewClassesDoNotOverlapExistingClasses(
      newClasses: newClasses,
      existingClasses: existingClasses,
    );
  }

  void _validateClassFields(ManualClass scheduleClass) {
    if (scheduleClass.title.trim().isEmpty) {
      throw const ScheduleValidationException('Enter a class title.');
    }

    if (scheduleClass.startDate.isAfter(scheduleClass.endDate)) {
      throw const ScheduleValidationException(
        'Start date must be earlier than or equal to end date.',
      );
    }

    if (scheduleClass.weekdays.isEmpty) {
      throw const ScheduleValidationException('Select at least one weekday.');
    }

    for (final weekday in scheduleClass.weekdays) {
      if (!ScheduleWeekday.isValid(weekday)) {
        throw ScheduleValidationException('Invalid weekday: $weekday.');
      }
    }

    final startMinutes = _timeToMinutes(scheduleClass.startTime);
    final endMinutes = _timeToMinutes(scheduleClass.endTime);

    if (startMinutes >= endMinutes) {
      throw const ScheduleValidationException(
        'Start time must be earlier than end time.',
      );
    }
  }

  void _validateNewClassesDoNotOverlapEachOther(List<ManualClass> newClasses) {
    for (var i = 0; i < newClasses.length; i++) {
      for (var j = i + 1; j < newClasses.length; j++) {
        final first = newClasses[i];
        final second = newClasses[j];

        if (_manualClassesOverlap(first, second)) {
          throw ScheduleValidationException(
            'The class "${first.title}" overlaps with "${second.title}".',
          );
        }
      }
    }
  }

  void _validateNewClassesDoNotOverlapExistingClasses({
    required List<ManualClass> newClasses,
    required List<ScheduleClass> existingClasses,
  }) {
    for (final newClass in newClasses) {
      for (final existingClass in existingClasses) {
        if (_manualClassOverlapsScheduleClass(newClass, existingClass)) {
          throw ScheduleValidationException(
            'This class overlaps with "${existingClass.title ?? 'another class'}".',
          );
        }
      }
    }
  }

  bool _manualClassesOverlap(ManualClass first, ManualClass second) {
    return _haveCommonWeekday(first.weekdays, second.weekdays) &&
        _dateRangesOverlap(
          startA: first.startDate,
          endA: first.endDate,
          startB: second.startDate,
          endB: second.endDate,
        ) &&
        _timeRangesOverlap(
          startMinutesA: _timeToMinutes(first.startTime),
          endMinutesA: _timeToMinutes(first.endTime),
          startMinutesB: _timeToMinutes(second.startTime),
          endMinutesB: _timeToMinutes(second.endTime),
        );
  }

  bool _manualClassOverlapsScheduleClass(
    ManualClass newClass,
    ScheduleClass existingClass,
  ) {
    return _haveCommonWeekday(newClass.weekdays, existingClass.weekdays) &&
        _dateRangesOverlap(
          startA: newClass.startDate,
          endA: newClass.endDate,
          startB: existingClass.startDate,
          endB: existingClass.endDate,
        ) &&
        _timeRangesOverlap(
          startMinutesA: _timeToMinutes(newClass.startTime),
          endMinutesA: _timeToMinutes(newClass.endTime),
          startMinutesB: _timeToMinutes(existingClass.startTime),
          endMinutesB: _timeToMinutes(existingClass.endTime),
        );
  }

  bool _haveCommonWeekday(List<String> firstWeekdays, List<String> secondWeekdays) {
    final firstSet = firstWeekdays.toSet();
    return secondWeekdays.any(firstSet.contains);
  }

  bool _dateRangesOverlap({
    required DateTime startA,
    required DateTime endA,
    required DateTime startB,
    required DateTime endB,
  }) {
    return !startA.isAfter(endB) && !startB.isAfter(endA);
  }

  bool _timeRangesOverlap({
    required int startMinutesA,
    required int endMinutesA,
    required int startMinutesB,
    required int endMinutesB,
  }) {
    return startMinutesA < endMinutesB && startMinutesB < endMinutesA;
  }

  int _timeToMinutes(String value) {
    final parts = value.split(':');

    if (parts.length < 2) {
      throw ScheduleValidationException('Invalid time format: $value.');
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      throw ScheduleValidationException('Invalid time format: $value.');
    }

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw ScheduleValidationException('Invalid time value: $value.');
    }

    return hour * 60 + minute;
  }
}
