import '../entities/navigation.dart';
import '../repositories/navigation_repository.dart';

class GetNavigationPath {
  const GetNavigationPath(this._repository);

  final NavigationRepository _repository;

  Future<NavigationPath> call({
    required String fromRoom,
    required String toRoom,
  }) {
    return _repository.getNavigationPath(
      fromRoom: fromRoom,
      toRoom: toRoom,
    );
  }
}