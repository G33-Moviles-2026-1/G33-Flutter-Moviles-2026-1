import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/features/friendships/domain/entities/friend.dart';
import 'package:andespace/features/friendships/presentation/providers/friendships_providers.dart';
import 'package:andespace/features/friendships/presentation/widgets/friends_free_slots_content.dart';
import 'package:andespace/features/friendships/presentation/widgets/friends_free_slots_controls.dart';
import 'package:andespace/features/schedule/presentation/pages/recommended_rooms_page.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendsFreeSlotsPage extends ConsumerWidget {
  const FriendsFreeSlotsPage({super.key, required this.friends});

  final List<Friend> friends;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = friendsFreeSlotsControllerProvider(friends);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final theme = Theme.of(context);

    return AppScaffold(
      currentTab: AppTab.favorites,
      onTabSelected: (tab) => AppRoutes.handleTabSelection(context, tab),
      body: RefreshIndicator(
        onRefresh: notifier.loadFreeSlots,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Back',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        Expanded(
                          child: Text(
                            'Free Slots',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Refresh',
                          onPressed: state.isLoading
                              ? null
                              : notifier.loadFreeSlots,
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SelectedFriendsStrip(friends: friends),
                    const SizedBox(height: 12),
                    FriendsFreeSlotsWeekSelector(
                      label: state.weekRangeLabel,
                      onPreviousWeek: state.isLoading
                          ? null
                          : notifier.goToPreviousWeek,
                      onNextWeek: state.isLoading
                          ? null
                          : notifier.goToNextWeek,
                    ),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: FriendsFreeSlotsContent(
                    state: state,
                    onSlotToggled: notifier.toggleSlot,
                    onClearSelection: notifier.clearSelectedSlots,
                    onFindRooms: () => _findRooms(context, ref),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _findRooms(BuildContext context, WidgetRef ref) async {
    final provider = friendsFreeSlotsControllerProvider(friends);
    final notifier = ref.read(provider.notifier);
    final result = await notifier.findRoomsForSelectedSlots();
    if (!context.mounted) return;

    if (result == null) {
      final message = ref.read(provider).findRoomsErrorMessage;
      if (message == null) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: 'friends_free_slots_rooms'),
        builder: (_) => RecommendedRoomsPage(
          items: result.rooms,
          description: result.description,
          emptyMessage: 'No rooms were found for the selected free slots.',
          timeFilterOptions: result.timeFilterOptions,
        ),
      ),
    );
  }
}
