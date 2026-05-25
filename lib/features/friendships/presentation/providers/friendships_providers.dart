import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_provider.dart';
import '../../../rooms/presentation/providers/rooms_providers.dart';
import '../../../schedule/presentation/providers/schedule_providers.dart';
import '../../data/local/friendships_local_datasource.dart';
import '../../data/remote/friendships_api.dart';
import '../../data/repositories/friendships_repository_impl.dart';
import '../../domain/entities/friend.dart';
import '../../domain/repositories/friendships_repository.dart';
import '../../domain/usecases/find_rooms_for_free_slots_usecase.dart';
import '../../domain/usecases/load_friends_free_slots_for_week_usecase.dart';
import '../notifiers/friends_free_slots_notifier.dart';
import '../notifiers/friends_free_slots_state.dart';
import '../notifiers/friendships_notifier.dart';
import '../notifiers/friendships_state.dart';

final friendshipsLocalDataSourceProvider = Provider<FriendshipsLocalDataSource>(
  (ref) {
    throw UnimplementedError(
      'friendshipsLocalDataSourceProvider must be overridden in main.dart',
    );
  },
);

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

final loadFriendsFreeSlotsForWeekUseCaseProvider =
    Provider<LoadFriendsFreeSlotsForWeekUseCase>((ref) {
      return LoadFriendsFreeSlotsForWeekUseCase(
        scheduleRepository: ref.watch(scheduleRepositoryProvider),
      );
    });

final findRoomsForFreeSlotsUseCaseProvider =
    Provider<FindRoomsForFreeSlotsUseCase>((ref) {
      return FindRoomsForFreeSlotsUseCase(
        roomRepository: ref.watch(roomRepositoryProvider),
      );
    });

final friendsFreeSlotsControllerProvider = NotifierProvider.autoDispose
    .family<FriendsFreeSlotsNotifier, FriendsFreeSlotsState, List<Friend>>(
      FriendsFreeSlotsNotifier.new,
    );
