import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/features/auth/domain/entities/user_status.dart';
import 'package:andespace/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:andespace/features/friendships/domain/entities/friend.dart';
import 'package:andespace/features/friendships/presentation/controllers/friendships_state.dart';
import 'package:andespace/features/friendships/presentation/providers/friendships_providers.dart';
import 'package:andespace/features/friendships/presentation/controllers/friendships_notifier.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';
import 'package:andespace/shared/widgets/auth_required_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendsPage extends ConsumerWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (!authState.hasActiveSession) {
      return AuthRequiredScaffold(
        currentTab: AppTab.favorites,
        onTabSelected: (tab) => AppRoutes.handleTabSelection(context, tab),
        title: 'Log in to view your friends',
        message: 'Sign in to add friends and see their current status.',
      );
    }

    final state = ref.watch(friendshipsControllerProvider);
    final notifier = ref.read(friendshipsControllerProvider.notifier);

    ref.listen<FriendshipsState>(friendshipsControllerProvider, (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;

      if (nextError != null && nextError != previousError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(nextError)));
      }
    });

    return AppScaffold(
      currentTab: AppTab.favorites,
      onTabSelected: (tab) => AppRoutes.handleTabSelection(context, tab),
      body: RefreshIndicator(
        onRefresh: notifier.refreshAll,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          children: [
            Center(
              child: Text(
                'My Friends',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _TopActionButton(
                    label: 'My status:',
                    icon: _statusIcon(state.myStatus),
                    onTap: () => _showStatusDialog(context, state.myStatus, notifier),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TopActionButton(
                    label: 'Add friends',
                    icon: Icons.group_add,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.addFriends),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (state.isFriendsLoading && state.friends.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.friends.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Text(
                  'You have no friends yet.\nTap Add friends to send your first request.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.friends.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.84,
                ),
                itemBuilder: (context, index) {
                  final friend = state.friends[index];
                  final isPending =
                      state.pendingFriendUsernames.contains(friend.username);

                  return _FriendCard(
                    friend: friend,
                    isPending: isPending,
                    onDelete: () => notifier.removeFriend(friend),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showStatusDialog(
    BuildContext context,
    UserStatus current,
    FriendshipsNotifier notifier,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => _StatusCarouselDialog(
        initialStatus: current,
        onStatusSelected: notifier.updateMyStatus,
      ),
    );
  }
}

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: const Color(0xFFFFFBA9),
      borderRadius: BorderRadius.circular(8),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              Icon(icon, color: Colors.black, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  const _FriendCard({
    required this.friend,
    required this.isPending,
    required this.onDelete,
  });

  final Friend friend;
  final bool isPending;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          Positioned(
            top: 6,
            left: 6,
            child: Icon(Icons.calendar_month, size: 28, color: theme.colorScheme.onSurface),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: isPending
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    tooltip: 'Remove friend',
                    icon: const Icon(Icons.delete_outline),
                    color: theme.colorScheme.onSurface,
                    onPressed: onDelete,
                  ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 32, 8, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _statusIcon(friend.status),
                    size: 58,
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    friend.username,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    friend.status.label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCarouselDialog extends StatefulWidget {
  const _StatusCarouselDialog({
    required this.initialStatus,
    required this.onStatusSelected,
  });

  final UserStatus initialStatus;
  final ValueChanged<UserStatus> onStatusSelected;

  @override
  State<_StatusCarouselDialog> createState() => _StatusCarouselDialogState();
}

class _StatusCarouselDialogState extends State<_StatusCarouselDialog> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = UserStatus.values.indexOf(widget.initialStatus);
    if (_index < 0) _index = 0;
  }

  void _move(int delta) {
    setState(() {
      _index = (_index + delta) % UserStatus.values.length;
      if (_index < 0) _index = UserStatus.values.length - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = UserStatus.values[_index];

    return Dialog(
      backgroundColor: const Color(0xFFFFFBA9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'My status:',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                ),
                const SizedBox(height: 18),
                Icon(_statusIcon(status), size: 96, color: Colors.black),
                const SizedBox(height: 24),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _move(-1),
                      icon: const Icon(Icons.chevron_left, size: 42),
                      color: Colors.black,
                    ),
                    Expanded(
                      child: Text(
                        status.label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.black,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _move(1),
                      icon: const Icon(Icons.chevron_right, size: 42),
                      color: Colors.black,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onStatusSelected(status);
                      Navigator.pop(context);
                    },
                    child: const Text('Save status'),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _statusIcon(UserStatus status) {
  return switch (status) {
    UserStatus.incognito => Icons.visibility_off,
    UserStatus.busy => Icons.work,
    UserStatus.exercising => Icons.fitness_center,
    UserStatus.free => Icons.event_available,
    UserStatus.hangingOut => Icons.groups,
    UserStatus.atHome => Icons.home,
    UserStatus.lunching => Icons.restaurant,
  };
}