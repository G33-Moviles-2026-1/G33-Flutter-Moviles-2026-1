import 'package:andespace/features/rooms/presentation/pages/room_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:andespace/features/rooms/domain/entities/room_search.dart';

class RecommendedRoomsPage extends ConsumerWidget {
  const RecommendedRoomsPage({
    super.key,
    required this.items,
    this.lastUpdated,
    this.isOffline = false,
  });

  final List<RoomSearchItem> items;
  final DateTime? lastUpdated;
  final bool isOffline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recommended Rooms')),
      body: Column(
        children: [
          if (isOffline && lastUpdated != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _CachedRecommendationsBanner(lastUpdated: lastUpdated!),
            ),
          Expanded(
            child: items.isEmpty
                ? _EmptyRecommendationsView(isOffline: isOffline)
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final room = items[index];
                      return _RecommendedRoomCard(room: room);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CachedRecommendationsBanner extends StatelessWidget {
  const _CachedRecommendationsBanner({required this.lastUpdated});

  final DateTime lastUpdated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing last available recommendations. Last updated: ${_formatTimeAgo(lastUpdated)}. Availability may have changed.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${diff.inDays} days ago';
  }
}

class _EmptyRecommendationsView extends StatelessWidget {
  const _EmptyRecommendationsView({required this.isOffline});

  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOffline ? Icons.wifi_off_rounded : Icons.meeting_room_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              isOffline ? 'Internet required' : 'No recommendations found',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isOffline
                  ? 'Connect to the internet to find room recommendations for your schedule.'
                  : 'No recommended rooms were found for this day.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedRoomCard extends StatelessWidget {
  const _RecommendedRoomCard({required this.room});

  final RoomSearchItem room;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = room.roomId.isNotEmpty
        ? room.roomId
        : '${room.buildingCode} ${room.roomNumber}'.trim();

    final subtitle = room.buildingName ?? room.buildingCode;
    final slotLabel = _buildSlotLabel(room);
    final distanceLabel = _buildDistanceLabel(room.distanceSeconds);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RoomDetailPage(room: room)),
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.18),
            ),
            borderRadius: BorderRadius.circular(18),
            color: theme.cardColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(
                        alpha: 0.16,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.meeting_room_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 10),
              Text(subtitle, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (slotLabel != null)
                    _InfoChip(label: slotLabel, icon: Icons.schedule_outlined),
                  _InfoChip(
                    label: 'Capacity ${room.capacity}',
                    icon: Icons.people_outline,
                  ),
                  if (distanceLabel != null)
                    _InfoChip(
                      label: distanceLabel,
                      icon: Icons.directions_walk_outlined,
                    ),
                ],
              ),
              if (room.utilities.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: room.utilities
                      .map((utility) => _TagChip(label: utility))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String? _buildSlotLabel(RoomSearchItem room) {
    if (room.matchingWindows.isEmpty) return null;

    final first = room.matchingWindows.first;
    final start = _formatHour(first.start);
    final end = _formatHour(first.end);

    if (start == null || end == null) return null;
    return '$start - $end';
  }

  String? _buildDistanceLabel(double? secondsOrDistance) {
    if (secondsOrDistance == null) return null;

    final minutes = (secondsOrDistance / 60).round();
    if (minutes <= 0) return 'Very close';
    if (minutes == 1) return '1 min away';
    return '$minutes min away';
  }

  String? _formatHour(String? raw) {
    if (raw == null || raw.isEmpty) return null;

    final parts = raw.split(':');
    if (parts.length < 2) return raw;

    final hh = parts[0].padLeft(2, '0');
    final mm = parts[1].padLeft(2, '0');
    return '$hh:$mm';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor: theme.cardColor,
      side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.18)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}
