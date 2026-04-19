class NavigationNode {
  const NavigationNode({
    required this.buildingCode,
    required this.floor,
  });

  final String buildingCode;
  final int floor;

  String get buildingHint => '$buildingCode ';
}

class NavigationPath {
  const NavigationPath({
    required this.fromRoom,
    required this.toRoom,
    required this.steps,
    required this.totalTimeSeconds,
  });

  final String fromRoom;
  final String toRoom;
  final List<String> steps;
  final int totalTimeSeconds;

  String get formattedDuration {
    if (totalTimeSeconds < 60) return '${totalTimeSeconds}s';
    final minutes = totalTimeSeconds ~/ 60;
    final seconds = totalTimeSeconds % 60;
    return seconds == 0 ? '${minutes}min' : '${minutes}min ${seconds}s';
  }
}
