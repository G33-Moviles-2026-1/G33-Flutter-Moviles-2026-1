class ManualClass {
  final String title;
  final String? locationText;
  final String? roomId;
  final DateTime startDate;
  final DateTime endDate;
  final String startTime;
  final String endTime;
  final List<String> weekdays;

  const ManualClass({
    required this.title,
    this.locationText,
    this.roomId,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.weekdays,
  });
}