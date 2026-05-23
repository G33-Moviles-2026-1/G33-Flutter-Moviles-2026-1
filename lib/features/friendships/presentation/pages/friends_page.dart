import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/features/auth/domain/entities/user_status.dart';
import 'package:andespace/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:andespace/features/friendships/domain/entities/friend.dart';
import 'package:andespace/features/friendships/presentation/controllers/friendships_notifier.dart';
import 'package:andespace/features/friendships/presentation/controllers/friendships_state.dart';
import 'package:andespace/features/friendships/presentation/pages/add_friends_page.dart';
import 'package:andespace/features/friendships/presentation/providers/friendships_providers.dart';
import 'package:andespace/shared/theme/app_theme_extension.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';
import 'package:andespace/shared/widgets/auth_required_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      body: Container(
        color: _pageBackground(context),
        child: RefreshIndicator(
          onRefresh: notifier.refreshAll,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
            children: [
              Center(
                child: Text(
                  'My Friends',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 34,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _TopActionButton(
                      label: 'My status:',
                      assetPath: _statusAssetPath(state.myStatus),
                      onTap: () =>
                          _showStatusDialog(context, state.myStatus, notifier),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TopActionButton(
                      label: 'Add friends',
                      assetPath: 'assets/icons/addfriend.svg',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddFriendsPage(),
                          ),
                        );
                      },
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
                    childAspectRatio: 0.91,
                  ),
                  itemBuilder: (context, index) {
                    final friend = state.friends[index];
                    final isPending = state.pendingFriendUsernames.contains(
                      friend.username,
                    );

                    return _FriendCard(
                      friend: friend,
                      isPending: isPending,
                      onDelete: () =>
                          _confirmRemoveFriend(context, notifier, friend),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusDialog(
    BuildContext context,
    UserStatus current,
    FriendshipsNotifier notifier,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: isDark ? 0.68 : 0.48),
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
      barrierColor: Colors.black.withValues(alpha: 0.48),
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
              style: _compactElevatedButtonStyle(
                dialogContext,
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
    required this.assetPath,
    required this.onTap,
  });

  final String label;
  final String assetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: _cardBackground(context),
      borderRadius: BorderRadius.circular(9),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: _borderColor(context)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _SvgIcon(
                assetPath: assetPath,
                size: 36,
                color: _primaryIconColor(context),
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

    return Material(
      color: _cardBackground(context),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _borderColor(context)),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 9,
              left: 9,
              child: _SvgIcon(
                assetPath: 'assets/icons/schedule.svg',
                size: 29,
                color: _primaryIconColor(context),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
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
                      constraints: const BoxConstraints.tightFor(
                        width: 42,
                        height: 42,
                      ),
                      icon: const Icon(Icons.delete_outline, size: 31),
                      color: _primaryIconColor(context),
                      onPressed: onDelete,
                    ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 34, 10, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SvgIcon(
                      assetPath: _statusAssetPath(friend.status),
                      size: 74,
                      color: _primaryIconColor(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      friend.username,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 25,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      friend.status.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        height: 1.05,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.78,
                        ),
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

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 38),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: _cardBackground(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _borderColor(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'My status:',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SvgIcon(
                    assetPath: _statusAssetPath(status),
                    size: 116,
                    color: _primaryIconColor(context),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _move(-1),
                        icon: const Icon(Icons.chevron_left, size: 44),
                        color: _primaryIconColor(context),
                      ),
                      Expanded(
                        child: Text(
                          status.label,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _move(1),
                        icon: const Icon(Icons.chevron_right, size: 44),
                        color: _primaryIconColor(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: _compactElevatedButtonStyle(
                        context,
                        minimumHeight: 50,
                        borderRadius: 9,
                      ),
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
              top: 4,
              right: 4,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 24),
                color: _primaryIconColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SvgIcon extends StatelessWidget {
  const _SvgIcon({
    required this.assetPath,
    required this.size,
    required this.color,
  });

  final String assetPath;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

String _statusAssetPath(UserStatus status) {
  return switch (status) {
    UserStatus.incognito => 'assets/icons/incognito.svg',
    UserStatus.busy => 'assets/icons/busy.svg',
    UserStatus.exercising => 'assets/icons/exercising.svg',
    UserStatus.free => 'assets/icons/free.svg',
    UserStatus.hangingOut => 'assets/icons/hangingout.svg',
    UserStatus.atHome => 'assets/icons/athome.svg',
    UserStatus.lunching => 'assets/icons/lunching.svg',
  };
}

Color _pageBackground(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return isDark ? theme.scaffoldBackgroundColor : Colors.white;
}

Color _cardBackground(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return isDark ? const Color(0xFF1A1D22) : Colors.white;
}

Color _primaryIconColor(BuildContext context) {
  final theme = Theme.of(context);
  final brand = theme.extension<BrandColors>()!;
  final isDark = theme.brightness == Brightness.dark;

  return isDark ? brand.accentYellow : Colors.black;
}

Color _borderColor(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return isDark
      ? Colors.white.withValues(alpha: 0.10)
      : Colors.black.withValues(alpha: 0.08);
}

ButtonStyle _compactElevatedButtonStyle(
  BuildContext context, {
  Color? backgroundColor,
  Color? foregroundColor,
  double minimumHeight = 40,
  double borderRadius = 8,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return ElevatedButton.styleFrom(
    backgroundColor: backgroundColor ?? colorScheme.secondary,
    foregroundColor: foregroundColor ?? colorScheme.onSecondary,
    minimumSize: Size(0, minimumHeight),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
  );
}