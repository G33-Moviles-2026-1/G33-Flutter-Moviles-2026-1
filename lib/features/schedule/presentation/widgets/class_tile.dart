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
    final displayHour = hour > 12 ? hour - 12 : hour;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      '${_formatDisplayTime(occurrence.startTime)} - ${_formatDisplayTime(occurrence.endTime)}',
      if ((occurrence.roomId ?? '').trim().isNotEmpty) 'Room: ${occurrence.roomId}',
    ].join('\n');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        title: Text(
          occurrence.title ?? 'Class',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: onDelete == null
            ? null
            : IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
      ),
    );
  }
}