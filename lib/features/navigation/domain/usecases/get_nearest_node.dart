import '../entities/navigation.dart';
import '../repositories/navigation_repository.dart';

class GetNearestNode {
  const GetNearestNode(this._repository);

  final NavigationRepository _repository;

  Future<NavigationNode> call({required double lat, required double lon}) {
    return _repository.getNearestNode(lat: lat, lon: lon);
  }
}