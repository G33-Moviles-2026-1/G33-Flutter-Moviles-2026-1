import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_provider.dart';
import '../../data/local/friendships_local_datasource.dart';
import '../../data/remote/friendships_api.dart';
import '../../data/repositories/friendships_repository_impl.dart';
import '../../domain/repositories/friendships_repository.dart';
import '../controllers/friendships_notifier.dart';
import '../controllers/friendships_state.dart';

final friendshipsLocalDataSourceProvider =
    Provider<FriendshipsLocalDataSource>((ref) {
  throw UnimplementedError(
    'friendshipsLocalDataSourceProvider must be overridden in main.dart',
  );
});

final friendshipsApiProvider = Provider<FriendshipsApi>((ref) {
  return FriendshipsApi(ref.watch(dioProvider));
});

final friendshipsRepositoryProvider = Provider<FriendshipsRepository>((ref) {
  return FriendshipsRepositoryImpl(
    api: ref.watch(friendshipsApiProvider),
    localDataSource: ref.watch(friendshipsLocalDataSourceProvider),
  );
});

final friendshipsControllerProvider =
    NotifierProvider<FriendshipsNotifier, FriendshipsState>(
  FriendshipsNotifier.new,
);