import 'package:andespace/features/rooms/presentation/pages/room_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:andespace/features/rooms/domain/entities/room_search.dart';

class RecommendedRoomsPage extends ConsumerWidget {
  const RecommendedRoomsPage({
    super.key,
    required this.items,
  });

  final List<RoomSearchItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended Rooms'),
      ),
      body: items.isEmpty
          ? const _EmptyRecommendationsView()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final room = items[index];
                return _RecommendedRoomCard(room: room);
              },
            ),
    );
  }
}

class _EmptyRecommendationsView extends StatelessWidget {
  const _EmptyRecommendationsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No recommended rooms were found for this day.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class _RecommendedRoomCard extends StatelessWidget {
  const _RecommendedRoomCard({
    required this.room,
  });

  final RoomSearchItem room;

  @override
  Widget build(BuildContext context) {
    final title = room.roomId.isNotEmpty
        ? room.roomId
        : '${room.buildingCode} ${room.roomNumber}'.trim();

    final subtitle = room.buildingName ?? room.buildingCode;
    final slotLabel = _buildSlotLabel(room);
    final distanceLabel = _buildDistanceLabel(room.distanceMeters);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomDetailPage(room: room),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (slotLabel != null)
                  _InfoChip(
                    label: slotLabel,
                    icon: Icons.schedule_outlined,
                  ),
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
              const SizedBox(height: 12),
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
  const _InfoChip({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}