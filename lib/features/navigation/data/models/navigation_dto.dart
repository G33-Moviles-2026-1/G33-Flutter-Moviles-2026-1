import '../../domain/entities/navigation.dart';

class NavigationNodeDto {
  const NavigationNodeDto({
    required this.buildingCode,
    required this.floor,
  });

  final String buildingCode;
  final int floor;

  factory NavigationNodeDto.fromJson(Map<String, dynamic> json) {
    return NavigationNodeDto(
      buildingCode: json['building_code'] as String,
      floor: json['floor'] as int,
    );
  }

  NavigationNode toDomain() => NavigationNode(
        buildingCode: buildingCode,
        floor: floor,
      );
}

class NavigationPathDto {
  const NavigationPathDto({
    required this.fromRoom,
    required this.toRoom,
    required this.steps,
    required this.totalTimeSeconds,
  });

  final String fromRoom;
  final String toRoom;
  final List<String> steps;
  final int totalTimeSeconds;

  factory NavigationPathDto.fromJson(Map<String, dynamic> json) {
    return NavigationPathDto(
      fromRoom: json['from_room'] as String,
      toRoom: json['to_room'] as String,
      totalTimeSeconds: (json['total_time_seconds'] as num).toInt(),
      steps: List<String>.from(json['steps'] as List),
    );
  }

  NavigationPath toDomain() => NavigationPath(
        fromRoom: fromRoom,
        toRoom: toRoom,
        steps: steps,
        totalTimeSeconds: totalTimeSeconds,
      );
}