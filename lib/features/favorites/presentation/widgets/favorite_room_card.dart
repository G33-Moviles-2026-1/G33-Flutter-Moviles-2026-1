import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme_extension.dart';
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: isPending ? null : onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: .18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      room.roomId,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (isPending)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      onPressed: onRemoveTap,
                      icon: _OutlinedHeartIcon(
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
                  _Badge(
                    label: 'Cap: ${room.capacity}',
                    backgroundColor: theme.brightness == Brightness.dark
                        ? const Color(0xFF2D220C)
                        : brand.softYellow,
                    foregroundColor: theme.colorScheme.onSurface,
                    borderColor: theme.dividerColor.withValues(alpha: .18),
                  ),
                  ...room.utilities
                      .take(2)
                      .map(
                        (u) => _Badge(
                          label: _toTitleCase(u),
                          backgroundColor: theme.brightness == Brightness.dark
                              ? theme.cardColor
                              : theme.colorScheme.surface,
                          foregroundColor: theme.colorScheme.onSurface,
                          borderColor: theme.dividerColor.withValues(
                            alpha: .18,
                          ),
                        ),
                      ),
                ],
              ),
            ],
          ),
        ),
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

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: foregroundColor,
        ),
      ),
    );
  }
}

class _OutlinedHeartIcon extends StatelessWidget {
  const _OutlinedHeartIcon({required this.isFilled, required this.fillColor});

  final bool isFilled;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            isFilled ? Icons.favorite : Icons.favorite_border,
            size: 23,
            color: Colors.black,
          ),
          Icon(
            isFilled ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color:fillColor,
          ),
        ],
      ),
    );
  }
}
