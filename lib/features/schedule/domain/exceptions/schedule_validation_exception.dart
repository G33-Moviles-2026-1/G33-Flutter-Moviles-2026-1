class ScheduleValidationException implements Exception {
  final String message;

  const ScheduleValidationException(this.message);

  @override
  String toString() => message;
}