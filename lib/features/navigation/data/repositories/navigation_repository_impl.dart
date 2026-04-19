import '../../domain/entities/navigation.dart';
import '../../domain/repositories/navigation_repository.dart';
import '../models/navigation_dto.dart';
import '../remote/navigation_api.dart';

class NavigationRepositoryImpl implements NavigationRepository {
  const NavigationRepositoryImpl({required this.navigationApi});

  final NavigationApi navigationApi;

  @override
  Future<NavigationNode> getNearestNode({
    required double lat,
    required double lon,
  }) async {
    final raw = await navigationApi.getNearestNode(lat: lat, lon: lon);
    return NavigationNodeDto.fromJson(raw).toDomain();
  }

  @override
  Future<NavigationPath> getNavigationPath({
    required String fromRoom,
    required String toRoom,
  }) async {
    final raw = await navigationApi.getNavigationPath(
      fromRoom: fromRoom,
      toRoom: toRoom,
    );
    return NavigationPathDto.fromJson(raw).toDomain();
  }
}
