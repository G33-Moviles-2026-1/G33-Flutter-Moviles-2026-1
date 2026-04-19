import 'package:andespace/core/di/core_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/navigation_api.dart';
import '../../data/repositories/navigation_repository_impl.dart';
import '../../domain/repositories/navigation_repository.dart';
import '../../domain/usecases/get_navigation_path.dart';
import '../../domain/usecases/get_nearest_node.dart';

final navigationApiProvider = Provider<NavigationApi>((ref) {
  return NavigationApi(ref.watch(dioProvider));
});

final navigationRepositoryProvider = Provider<NavigationRepository>((ref) {
  return NavigationRepositoryImpl(
    navigationApi: ref.watch(navigationApiProvider),
  );
});

final getNearestNodeUseCaseProvider = Provider<GetNearestNode>((ref) {
  return GetNearestNode(ref.watch(navigationRepositoryProvider));
});

final getNavigationPathUseCaseProvider = Provider<GetNavigationPath>((ref) {
  return GetNavigationPath(ref.watch(navigationRepositoryProvider));
});