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

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      '${occurrence.startTime} - ${occurrence.endTime}',
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