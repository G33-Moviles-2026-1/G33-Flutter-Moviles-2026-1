import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme_extension.dart';
import '../../../../shared/widgets/room_card_bits.dart';
import '../../domain/entities/favorite_room.dart';

class FavoriteRoomCard extends StatelessWidget {
  const FavoriteRoomCard({
    super.key,
    required this.room,
    required this.isPending,
    required this.onTap,
    required this.onRemoveTap,
  });

  final FavoriteRoom room;
  final bool isPending;
  final VoidCallback onTap;
  final VoidCallback onRemoveTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brand = theme.extension<BrandColors>()!;

return RoomCardContainer(
  onTap: isPending ? null : onTap,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RoomCardHeaderRow(
        roomId: room.roomId,
        trailing: [
          if (isPending)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              onPressed: onRemoveTap,
              icon: OutlinedHeartIcon(
                isFilled: true,
                fillColor: brand.accentYellow,
              ),
              color: null,
              tooltip: 'Remove favorite',
            ),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        '${room.buildingName ?? room.buildingCode} • Room ${room.roomNumber}',
        style: theme.textTheme.bodyMedium,
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
            foregroundColor: theme.colorScheme.onSurface,
            borderColor: theme.dividerColor.withValues(alpha: .18),
          ),
          ...room.utilities.take(2).map(
            (u) => RoomCardBadge(
              label: _toTitleCase(u),
              backgroundColor: theme.brightness == Brightness.dark
                  ? theme.cardColor
                  : theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
              borderColor: theme.dividerColor.withValues(alpha: .18),
            ),
          ),
        ],
      ),
    ],
  ),
);
  }

  static String _toTitleCase(String value) {
    return value
        .split('_')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}