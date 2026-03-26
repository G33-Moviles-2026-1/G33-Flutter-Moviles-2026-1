class ScheduleUploadResponseModel {
  final bool ok;
  final String scheduleId;
  final int classesCount;
  final List<String> warnings;

  const ScheduleUploadResponseModel({
    required this.ok,
    required this.scheduleId,
    required this.classesCount,
    required this.warnings,
  });

  factory ScheduleUploadResponseModel.fromJson(Map<String, dynamic> json) {
    return ScheduleUploadResponseModel(
      ok: json['ok'] as bool? ?? false,
      scheduleId: json['schedule_id']?.toString() ?? '',
      classesCount: json['classes_count'] as int? ?? 0,
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}