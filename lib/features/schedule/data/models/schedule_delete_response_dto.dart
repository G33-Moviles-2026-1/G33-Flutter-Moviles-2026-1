class ScheduleDeleteResponseModel {
  final bool ok;
  final bool deleted;
  final bool? split;

  const ScheduleDeleteResponseModel({
    required this.ok,
    required this.deleted,
    this.split,
  });

  factory ScheduleDeleteResponseModel.fromJson(Map<String, dynamic> json) {
    return ScheduleDeleteResponseModel(
      ok: json['ok'] as bool? ?? false,
      deleted: json['deleted'] as bool? ?? false,
      split: json['split'] as bool?,
    );
  }
}
