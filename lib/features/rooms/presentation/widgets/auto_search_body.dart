import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/features/bookings/presentation/widgets/quick_booking_dialog.dart';
import 'package:andespace/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:andespace/features/favorites/presentation/providers/favorites_providers.dart';
import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:andespace/features/rooms/presentation/controllers/auto_search_notifier.dart';
import 'package:andespace/features/rooms/presentation/controllers/auto_search_state.dart';
import 'package:andespace/shared/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AutoSearchBody extends ConsumerStatefulWidget {
  const AutoSearchBody({super.key});

  @override
  ConsumerState<AutoSearchBody> createState() => _AutoSearchBodyState();
}

class _AutoSearchBodyState extends ConsumerState<AutoSearchBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(autoSearchControllerProvider.notifier).load();
    });
  }

  Future<void> _toggleFavorite(RoomSearchItem room) async {
    final authState = ref.read(authControllerProvider);
    if (!authState.hasActiveSession) {
      Navigator.pushNamed(context, AppRoutes.favorites);
      return;
    }

    final favoritesState = ref.read(favoritesControllerProvider);
    final wasFavorite = favoritesState.isFavorite(room.roomId);

    await ref.read(favoritesControllerProvider.notifier).toggleFromSearch(room);

    if (wasFavorite) {
      ref.read(autoSearchControllerProvider.notifier).undoFavoriteForCurrent();
      return;
    }

    await ref.read(autoSearchControllerProvider.notifier).recordFavorite();
  }

  Future<void> _book(RoomSearchItem room) async {
    final authState = ref.read(authControllerProvider);
    if (!authState.hasActiveSession) {
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    final result = await showQuickBookingDialog(context: context, room: room);
    if (!mounted || result == null) return;

    await ref.read(autoSearchControllerProvider.notifier).recordBook();
    if (!mounted) return;

    final message = result == QuickBookingResult.created
        ? 'Booking created successfully.'
        : 'Booking queued and will sync when connection returns.';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(autoSearchControllerProvider);
    final theme = Theme.of(context);
    final room = state.currentRoom;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
              ),
              Expanded(
                child: Text(
                  'Auto Search',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _buildContent(context, state, room),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AutoSearchState state,
    RoomSearchItem? room,
  ) {
    switch (state.status) {
      case AutoSearchStatus.initial:
      case AutoSearchStatus.loading:
        return const Center(
          key: ValueKey('loading'),
          child: CircularProgressIndicator(),
        );
      case AutoSearchStatus.empty:
        return _AutoSearchMessage(
          key: const ValueKey('empty'),
          icon: Icons.search_off_rounded,
          title: 'No rooms found',
          message: 'Try again later when more rooms are available.',
          onRetry: () => ref.read(autoSearchControllerProvider.notifier).load(),
        );
      case AutoSearchStatus.failure:
        return _AutoSearchMessage(
          key: const ValueKey('failure'),
          icon: Icons.cloud_off_rounded,
          title: 'Auto Search unavailable',
          message: state.errorMessage ?? 'Please try again.',
          onRetry: () => ref.read(autoSearchControllerProvider.notifier).load(),
        );
      case AutoSearchStatus.success:
        if (room == null) {
          return _AutoSearchMessage(
            key: const ValueKey('missing-room'),
            icon: Icons.search_off_rounded,
            title: 'No rooms found',
            message: 'Try again later when more rooms are available.',
            onRetry: () =>
                ref.read(autoSearchControllerProvider.notifier).load(),
          );
        }

        return _AutoSearchRecommendation(
          key: ValueKey(room.roomId),
          room: room,
          isSubmitting: state.isSubmittingInteraction,
          onSkip: () =>
              ref.read(autoSearchControllerProvider.notifier).skipCurrent(),
          onDone: () =>
              ref.read(autoSearchControllerProvider.notifier).advanceCurrent(),
          onFavorite: () => _toggleFavorite(room),
          onBook: () => _book(room),
        );
    }
  }
}

class _AutoSearchRecommendation extends ConsumerWidget {
  const _AutoSearchRecommendation({
    super.key,
    required this.room,
    required this.isSubmitting,
    required this.onSkip,
    required this.onDone,
    required this.onFavorite,
    required this.onBook,
  });

  final RoomSearchItem room;
  final bool isSubmitting;
  final VoidCallback onSkip;
  final VoidCallback onDone;
  final Future<void> Function() onFavorite;
  final Future<void> Function() onBook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>()!;
    final favoritesState = ref.watch(favoritesControllerProvider);
    final isFavorite = favoritesState.isFavorite(room.roomId);
    final isFavoritePending = favoritesState.pendingRoomIds.contains(
      room.roomId,
    );

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 420, minHeight: 320),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: theme.brightness == Brightness.dark ? 0.24 : 0.08,
                    ),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Recommended for you',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: brand.accentYellow,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 22),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      room.roomId,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.72,
                        ),
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    room.buildingName ?? room.buildingCode,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Capacity: ${room.capacity} people',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _RoundActionButton(
              tooltip: isFavorite ? 'Done' : 'Skip',
              icon: isFavorite ? Icons.check_rounded : Icons.close_rounded,
              backgroundColor: isFavorite
                  ? (theme.brightness == Brightness.dark
                        ? brand.accentYellow
                        : const Color(0xFFFFFBA9))
                  : (theme.brightness == Brightness.dark
                        ? const Color(0xFF3B2228)
                        : const Color(0xFFFFDDE2)),
              foregroundColor: isFavorite
                  ? Colors.black
                  : (theme.brightness == Brightness.dark
                        ? const Color(0xFFFFB5C0)
                        : const Color(0xFF5B1722)),
              onPressed: isSubmitting
                  ? null
                  : isFavorite
                  ? onDone
                  : onSkip,
            ),
            const SizedBox(width: 12),
            _RoundActionButton(
              tooltip: isFavorite ? 'Saved' : 'Save favorite',
              icon: isFavorite ? null : Icons.favorite_border,
              backgroundColor: theme.brightness == Brightness.dark
                  ? const Color(0xFF312742)
                  : const Color(0xFFE9DDFC),
              foregroundColor: isFavorite
                  ? brand.accentYellow
                  : theme.colorScheme.onSurface,
              isLoading: isFavoritePending,
              onPressed: isSubmitting || isFavoritePending
                  ? null
                  : () {
                      onFavorite();
                    },
              child: isFavorite
                  ? _FavoriteActionIcon(
                      color: brand.accentYellow,
                      showBlackBorder: theme.brightness == Brightness.light,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isSubmitting
                    ? null
                    : () {
                        onBook();
                      },
                icon: const Icon(Icons.calendar_month_outlined, size: 22),
                label: const Text('Book Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: brand.accentYellow,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: brand.accentYellow.withValues(
                    alpha: 0.65,
                  ),
                  disabledForegroundColor: Colors.black.withValues(alpha: 0.55),
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: 0.18),
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: theme.brightness == Brightness.light
                        ? const BorderSide(color: Colors.black, width: 1.4)
                        : BorderSide.none,
                  ),
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.tooltip,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.icon,
    this.child,
    this.isLoading = false,
  });

  final String tooltip;
  final IconData? icon;
  final Widget? child;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: isEnabled
            ? backgroundColor
            : Theme.of(context).disabledColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        elevation: isEnabled ? 6 : 0,
        shadowColor: Colors.black.withValues(alpha: 0.14),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 62,
            height: 58,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : child ??
                        Icon(
                          icon,
                          color: isEnabled
                              ? foregroundColor
                              : Theme.of(context).disabledColor,
                          size: 26,
                        ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteActionIcon extends StatelessWidget {
  const _FavoriteActionIcon({
    required this.color,
    required this.showBlackBorder,
  });

  final Color color;
  final bool showBlackBorder;

  @override
  Widget build(BuildContext context) {
    if (!showBlackBorder) {
      return Icon(Icons.favorite, color: color, size: 26);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(Icons.favorite, color: Colors.black, size: 28),
        Icon(Icons.favorite, color: color, size: 23),
      ],
    );
  }
}

class _AutoSearchMessage extends StatelessWidget {
  const _AutoSearchMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>()!;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.dividerColor.withValues(alpha: .18)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 50, color: brand.accentYellow),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            FilledButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}
