import '../entities/navigation.dart';

abstract class NavigationRepository {
  Future<NavigationNode> getNearestNode({
    required double lat,
    required double lon,
  });

  Future<NavigationPath> getNavigationPath({
    required String fromRoom,
    required String toRoom,
  });
}