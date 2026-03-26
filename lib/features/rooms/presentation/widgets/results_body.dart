import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/features/rooms/domain/entities/room_search.dart';
import 'package:andespace/features/rooms/presentation/controllers/home_search_state.dart';
import 'package:andespace/features/rooms/presentation/providers/rooms_providers.dart';
import 'package:andespace/shared/theme/app_theme_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

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
    });

    final theme = Theme.of(context);
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
              ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) => _RoomCard(
                  room: items[index],
                  brand: brand,
                  searchTime:
                      response?.query.since,
                ),
              ),
              if (widget.state.isLoading)
                Container(
                  color: Colors.white.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                ),
            ],
          ),
        ),

        if (totalPages > 1)
          Container(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              32,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(
                top: BorderSide(color: Colors.black, width: 2),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _PageBtn(
                  label: "Prev",
                  onTap: currentPage > 1
                      ? () => ref
                            .read(homeSearchControllerProvider.notifier)
                            .goToPage(currentPage - 1)
                      : null,
                ),
                Text(
                  "Página $currentPage de $totalPages",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                _PageBtn(
                  label: "Next",
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

class _RoomCard extends StatelessWidget {
  final RoomSearchItem room;
  final BrandColors brand;
  final String? searchTime;

  const _RoomCard({required this.room, required this.brand, this.searchTime});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String referenceTime =
        searchTime ??
        "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}";

    final bool isAvailableInQuery = room.isAvailableAt(referenceTime);

    final Color statusColor = isAvailableInQuery
        ? const Color(0xFF4CAF50)
        : const Color(0xFFFF9800);
    final Color statusBg = isAvailableInQuery
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFF3E0);
    final String statusLabel = isAvailableInQuery
        ? "LIBRE EN TU HORARIO"
        : "DISPONIBLE DESPUÉS";

    return InkWell(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.roomDetail, arguments: room),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 1.5),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  room.roomId,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (room.distanceSeconds != null)
                  _Badge(
                    label: '${room.distanceSeconds!.toStringAsFixed(0)} Seconds',
                    color: Colors.white,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${room.buildingName ?? room.buildingCode} • Salón ${room.roomNumber}',
              style: TextStyle(color: Colors.grey[800], fontSize: 14),
            ),

            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 1.2),
              ),
              child: Row(
                children: [
                  Icon(
                    isAvailableInQuery ? Icons.check_circle : Icons.schedule,
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
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: statusColor.withOpacity(0.9),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          room.availabilityStatusText(referenceTime),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black,
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
                _Badge(label: 'Cap: ${room.capacity}', color: brand.softYellow),
                ...room.utilities
                    .take(2)
                    .map(
                      (u) => _Badge(
                        label: u.toTitleCase(),
                        color: Colors.grey[200]!,
                      ),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
    final isEnabled = onTap != null;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : Colors.grey[200],
          border: Border.all(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isEnabled
              ? [const BoxShadow(color: Colors.black, offset: Offset(2, 2))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isEnabled ? Colors.black : Colors.grey,
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
      return 'De ${current.start} a ${current.end}';
    }
    final nextWindows =
        matchingWindows
            .where((w) => w.start.compareTo(referenceTime) > 0)
            .toList()
          ..sort((a, b) => a.start.compareTo(b.start));

    if (nextWindows.isNotEmpty) {
      final next = nextWindows.first;
      return 'De ${next.start} a ${next.end}';
    }

    return 'Sin disponibilidad para esta fecha';
  }
}
