import '../../domain/entities/manual_class.dart';
import '../models/manual_class_dto.dart';

class ManualClassMapper {
  const ManualClassMapper._();

  static ManualClassModel toModel(ManualClass entity) {
    return ManualClassModel(
      title: entity.title,
      locationText: entity.locationText,
      roomId: entity.roomId,
      startDate: entity.startDate,
      endDate: entity.endDate,
      startTime: entity.startTime,
      endTime: entity.endTime,
      weekdays: entity.weekdays,
    );
  }

  static List<ManualClassModel> toModelList(List<ManualClass> entities) {
    return entities.map(toModel).toList();
  }
}