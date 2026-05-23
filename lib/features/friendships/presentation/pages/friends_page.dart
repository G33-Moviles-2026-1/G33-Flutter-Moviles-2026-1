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
    final theme = Theme.of(context);

    ref.listen<FriendshipsState>(friendshipsControllerProvider, (
      previous,
      next,
    ) {
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
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
          children: [
            Text(
              'My Friends',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _TopActionButton(
                    label: 'My status:',
                    icon: _statusIcon(state.myStatus),
                    onTap: () =>
                        _showStatusDialog(context, state.myStatus, notifier),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TopActionButton(
                    label: 'Add friends',
                    icon: Icons.group_add,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.addFriends),
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
                  style: theme.textTheme.bodyLarge,
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
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.92,
                ),
                itemBuilder: (context, index) {
                  final friend = state.friends[index];
                  final isPending = state.pendingFriendUsernames.contains(
                    friend.username,
                  );

                  return _FriendCard(
                    friend: friend,
                    isPending: isPending,
                    onDelete: () => _confirmRemoveFriend(context, notifier, friend),
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

  Future<void> _confirmRemoveFriend(
    BuildContext context,
    FriendshipsNotifier notifier,
    Friend friend,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          title: const Text('Remove friend?'),
          content: Text(
            'Are you sure you want to remove ${friend.username} from your friends?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await notifier.removeFriend(friend);
    }
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
    final colorScheme = theme.colorScheme;

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(8),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: colorScheme.secondary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
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
    final colorScheme = theme.colorScheme;

    return Material(
      color: theme.cardColor,
      elevation: 0,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.18)),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 8,
              child: Icon(
                Icons.calendar_month_outlined,
                size: 22,
                color: colorScheme.secondary,
              ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: isPending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Remove friend',
                      icon: const Icon(Icons.delete_outline),
                      color: colorScheme.onSurface.withValues(alpha: 0.72),
                      onPressed: onDelete,
                    ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 34, 10, 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _statusIcon(friend.status),
                        size: 30,
                        color: colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      friend.username,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      friend.status.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.66),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'My status:',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _statusIcon(status),
                    size: 48,
                    color: colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _move(-1),
                      icon: const Icon(Icons.chevron_left, size: 42),
                      color: colorScheme.onSurface,
                    ),
                    Expanded(
                      child: Text(
                        status.label,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _move(1),
                      icon: const Icon(Icons.chevron_right, size: 42),
                      color: colorScheme.onSurface,
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
              icon: const Icon(Icons.close),
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
