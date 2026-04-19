import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/auth_providers.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/app_tab.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/auth_required_scaffold.dart';
import '../../../auth/presentation/controllers/auth_notifier.dart';
import '../controllers/favorites_state.dart';
import '../providers/favorites_providers.dart';
import '../widgets/favorite_room_card.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (!authState.hasActiveSession) {
      return AuthRequiredScaffold(
        currentTab: AppTab.favorites,
        onTabSelected: (tab) => AppRoutes.handleTabSelection(context, tab),
        title: 'Log in to view your favorites',
        message:
            'Sign in to save rooms and access your favorite spaces later.',
      );
    }

    final state = ref.watch(favoritesControllerProvider);
    final notifier = ref.read(favoritesControllerProvider.notifier);

    ref.listen<FavoritesState>(favoritesControllerProvider, (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;

      if (nextError != null && nextError != previousError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(nextError),
              duration: const Duration(seconds: 4),
            ),
          );
      }
    });

    return AppScaffold(
      currentTab: AppTab.favorites,
      onTabSelected: (tab) => AppRoutes.handleTabSelection(context, tab),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Favorites',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 32,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your saved rooms appear here.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state.isLoading && state.items.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.items.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'You have no favorite rooms yet.\nPress the heart icon in results or room detail to save one.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: notifier.load,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          final room = state.items[index];
                          final isPending =
                              state.pendingRoomIds.contains(room.roomId);

                          return FavoriteRoomCard(
                            room: room,
                            isPending: isPending,
                            onRemoveTap: () async {
                              await notifier.removeFromFavorites(room);
                            },
                            onTap: () async {
                              try {
                                final seed = await notifier.getDetailSeed(room);
                                if (!context.mounted) return;
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.roomDetail,
                                  arguments: seed,
                                );
                              } catch (error) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        error.toString().replaceFirst('Exception: ', ''),
                                      ),
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                              }
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}