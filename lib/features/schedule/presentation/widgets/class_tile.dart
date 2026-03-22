import 'package:flutter/material.dart';
import '../../domain/entities/schedule_occurrence.dart';

class ClassTile extends StatelessWidget {
  final ScheduleOccurrence occurrence;
  final VoidCallback? onDelete;

  const ClassTile({
    super.key,
    required this.occurrence,
    this.onDelete,
  });

  String _formatDisplayTime(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return value;

    final parts = value.split(':');
    if (parts.length < 2) return value;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return value;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final normalizedHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$normalizedHour:${minute.toString().padLeft(2, '0')} $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final room = (occurrence.roomId ?? '').trim();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 6,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    occurrence.title ?? 'Class',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_formatDisplayTime(occurrence.startTime)} - ${_formatDisplayTime(occurrence.endTime)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (room.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Room: $room',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete occurrence',
              ),
          ],
        ),
      ),
    );
  }
}