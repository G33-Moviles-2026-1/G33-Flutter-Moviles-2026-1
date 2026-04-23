import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:andespace/features/rooms/presentation/controllers/home_search_state.dart';
import 'package:andespace/features/rooms/presentation/controllers/home_search_notifier.dart';
import 'package:andespace/shared/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andespace/features/favorites/presentation/providers/favorites_providers.dart';
import 'package:andespace/shared/widgets/room_card_bits.dart';

class ResultsBody extends ConsumerStatefulWidget {
  final HomeSearchState state;
  const ResultsBody({super.key, required this.state});

  @override
  ConsumerState<ResultsBody> createState() => _ResultsBodyState();
}

class _ResultsBodyState extends ConsumerState<ResultsBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<HomeSearchState>(homeSearchControllerProvider, (previous, next) {
      if (previous?.response?.query.offset != next.response?.query.offset) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      }

      final previousNavigate = previous?.navigateToNoInternetPage ?? false;
      final nextNavigate = next.navigateToNoInternetPage;

      if (nextNavigate && !previousNavigate) {
        ref.read(homeSearchControllerProvider.notifier).clearNoInternetNavigation();
        Navigator.pushNamed(context, AppRoutes.noInternet);
        return;
      }

      final previousMessage = previous?.feedbackMessage;
      final nextMessage = next.feedbackMessage;

      if (nextMessage != null && nextMessage != previousMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(nextMessage),
              duration: const Duration(seconds: 4),
            ),
          );
      }
    });

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final brand = theme.extension<BrandColors>()!;
    final response = widget.state.response;
    final items = response?.items ?? [];

    final int limit = response?.query.limit ?? 20;
    final int offset = response?.query.offset ?? 0;
    final int total = response?.total ?? 0;
    final int currentPage = (offset / limit).floor() + 1;
    final int totalPages = (total / limit).ceil();

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              if (items.isEmpty && !widget.state.isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: .18),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 52,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'No rooms found',
                            textAlign: TextAlign.center,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try changing the filters or search time.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => _RoomCard(
                    room: items[index],
                    brand: brand,
                    searchTime: response?.query.since,
                  ),
                ),
              if (widget.state.isLoading)
                Container(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: .65),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: .18),
                        ),
                      ),
                      child: const CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (totalPages > 1)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                top: BorderSide(
                  color: theme.dividerColor.withValues(alpha: .25),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.25 : 0.08,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PageBtn(
                  label: 'Prev',
                  onTap: currentPage > 1
                      ? () => ref
                            .read(homeSearchControllerProvider.notifier)
                            .goToPage(currentPage - 1)
                      : null,
                ),
                Text(
                  'Page $currentPage of $totalPages',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                _PageBtn(
                  label: 'Next',
                  onTap: currentPage < totalPages
                      ? () => ref
                            .read(homeSearchControllerProvider.notifier)
                            .goToPage(currentPage + 1)
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RoomCard extends ConsumerWidget {
  final RoomSearchItem room;
  final BrandColors brand;
  final String? searchTime;

  const _RoomCard({required this.room, required this.brand, this.searchTime});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authControllerProvider);
    final favoritesState = ref.watch(favoritesControllerProvider);
    final favoritesNotifier = ref.read(favoritesControllerProvider.notifier);

    final isFavorite = favoritesState.isFavorite(room.roomId);
    final isFavoritePending = favoritesState.pendingRoomIds.contains(
      room.roomId,
    );

    final String referenceTime =
        searchTime ??
        '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    final bool isAvailableInQuery = room.isAvailableAt(referenceTime);

    final Color statusColor = isAvailableInQuery
        ? const Color(0xFF2E7D32)
        : const Color(0xFFE68A00);

    final bool isDark = theme.brightness == Brightness.dark;

    final Color statusBg;
    if (isAvailableInQuery) {
      statusBg = isDark ? const Color(0xFF132218) : const Color(0xFFE8F5E9);
    } else {
      statusBg = isDark ? const Color(0xFF2A1D0B) : const Color(0xFFFFF3E0);
    }

    final String statusLabel = isAvailableInQuery
        ? 'FREE IN YOUR TIME'
        : 'AVAILABLE LATER';

    return RoomCardContainer(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.roomDetail, arguments: room);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoomCardHeaderRow(
            roomId: room.roomId,
            trailing: [
              if (isFavoritePending)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  onPressed: () async {
                    if (!authState.hasActiveSession) {
                      Navigator.pushNamed(context, AppRoutes.favorites);
                      return;
                    }

                    await favoritesNotifier.toggleFromSearch(room);
                  },
                  icon: OutlinedHeartIcon(
                    isFilled: isFavorite,
                    fillColor: isFavorite
                        ? brand.accentYellow
                        : colorScheme.onSurface,
                  ),
                  color: null,
                  tooltip: isFavorite ? 'Remove favorite' : 'Save favorite',
                ),
              if (room.distanceSeconds != null)
                RoomCardBadge(
                  label: '${room.distanceSeconds!.toStringAsFixed(0)} sec',
                  backgroundColor: theme.brightness == Brightness.dark
                      ? const Color(0xFF2D220C)
                      : brand.softYellow,
                  foregroundColor: colorScheme.onSurface,
                  borderColor: theme.dividerColor.withValues(alpha: .18),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${room.buildingName ?? room.buildingCode} • Room ${room.roomNumber}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: .18),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isAvailableInQuery
                      ? Icons.check_circle_outline
                      : Icons.schedule_outlined,
                  size: 18,
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        room.availabilityStatusText(referenceTime),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              RoomCardBadge(
                label: 'Cap: ${room.capacity}',
                backgroundColor: theme.brightness == Brightness.dark
                    ? const Color(0xFF2D220C)
                    : brand.softYellow,
                foregroundColor: colorScheme.onSurface,
                borderColor: theme.dividerColor.withValues(alpha: .18),
              ),
              ...room.utilities.take(2).map(
                (u) => RoomCardBadge(
                  label: u.toTitleCase(),
                  backgroundColor: theme.brightness == Brightness.dark
                      ? theme.cardColor
                      : colorScheme.surface,
                  foregroundColor: colorScheme.onSurface,
                  borderColor: theme.dividerColor.withValues(alpha: .18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _PageBtn({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isEnabled
              ? theme.colorScheme.secondary
              : theme.disabledColor.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: theme.dividerColor.withValues(alpha: .18)),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: isEnabled
                ? theme.colorScheme.onSecondary
                : theme.disabledColor,
          ),
        ),
      ),
    );
  }
}

extension StringFormatting on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split('_')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}

extension RoomAvailabilityX on RoomSearchItem {
  bool isAvailableAt(String referenceTime) {
    return matchingWindows.any(
      (w) =>
          referenceTime.compareTo(w.start) >= 0 &&
          referenceTime.compareTo(w.end) <= 0,
    );
  }

  String availabilityStatusText(String referenceTime) {
    final current = matchingWindows
        .where(
          (w) =>
              referenceTime.compareTo(w.start) >= 0 &&
              referenceTime.compareTo(w.end) <= 0,
        )
        .firstOrNull;

    if (current != null) {
      return 'From ${current.start} to ${current.end}';
    }

    final nextWindows =
        matchingWindows
            .where((w) => w.start.compareTo(referenceTime) > 0)
            .toList()
          ..sort((a, b) => a.start.compareTo(b.start));

    if (nextWindows.isNotEmpty) {
      final next = nextWindows.first;
      return 'From ${next.start} to ${next.end}';
    }

    return 'No availability for this time';
  }
}
