import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/features/rooms/presentation/widgets/home_body.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';
import 'package:andespace/shared/widgets/utilities_string.dart';
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
    
    final response = state.response;
    final items = response?.items ?? [];

    // Lógica de paginación
    final int limit = response?.query.limit ?? 20;
    final int offset = response?.query.offset ?? 0;
    final int total = response?.total ?? 0;
    final int currentPage = (offset / limit).floor() + 1;
    final int totalPages = (total / limit).ceil();

    return AppScaffold(
      currentTab: AppTab.rooms,
      onTabSelected: (_) {},
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CompactSearchForm(
              roomCtrl: TextEditingController(text: response?.query.roomPrefixes.join(', ')),
              isLoading: state.isLoading,
              onOpenFilters: () {},
              onSearch: () {},
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => _RoomCard(room: items[index], brand: brand),
                ),
                if (state.isLoading)
                  const Center(child: CircularProgressIndicator(color: Colors.black)),
              ],
            ),
          ),

          if (totalPages > 1)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.black, width: 2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PageBtn(
                    label: "Prev", 
                    onTap: currentPage > 1 ? () => ref.read(homeSearchControllerProvider.notifier).goToPage(currentPage - 1) : null
                  ),
                  Text("Page $currentPage of $totalPages", style: const TextStyle(fontWeight: FontWeight.bold)),
                  _PageBtn(
                    label: "Next", 
                    onTap: currentPage < totalPages ? () => ref.read(homeSearchControllerProvider.notifier).goToPage(currentPage + 1) : null
                  ),
                ],
              ),
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
    final isEnabled = onTap != null;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : Colors.grey[200],
          border: Border.all(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isEnabled ? [const BoxShadow(color: Colors.black, offset: Offset(2, 2))] : null,
        ),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isEnabled ? Colors.black : Colors.grey)),
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
                ...room.utilities.take(2).map((u) => _Badge(label: u.toTitleCase(), color: Colors.grey[200]!)),
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