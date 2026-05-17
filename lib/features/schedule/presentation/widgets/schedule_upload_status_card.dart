import 'package:flutter/material.dart';

class ScheduleUploadStatusCard extends StatelessWidget {
  const ScheduleUploadStatusCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          const LinearProgressIndicator(),
          const SizedBox(height: 12),
          Text(message),
        ],
      ),
    );
  }
}
