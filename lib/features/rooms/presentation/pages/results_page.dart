import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/homepage_providers.dart';
import '../../domain/entities/room_search.dart';
import '../../../../shared/theme/app_theme_extension.dart';

class ResultsPage extends ConsumerWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeSearchControllerProvider);
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>()!;
    final items = state.response?.items ?? [];

    return AppScaffold(
      currentTab: AppTab.rooms,
      onTabSelected: (_) {
      },
      body: ListView.separated(
        padding: const EdgeInsets.all(18),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final room = items[index];
          return _RoomCard(room: room, brand: brand);
        },
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomSearchItem room;
  final BrandColors brand;

  const _RoomCard({required this.room, required this.brand});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context, 
        AppRoutes.roomDetail, 
        arguments: room,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 1.4),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(room.roomId, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                if (room.distanceMeters != null)
                  Text('${room.distanceMeters!.toStringAsFixed(0)}m away', style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            Text('${room.buildingName ?? room.buildingCode} - Room ${room.roomNumber}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _Badge(label: 'Cap: ${room.capacity}', color: brand.softYellow),
                ...room.utilities.take(2).map((u) => _Badge(label: u, color: Colors.grey[200]!)),
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
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}