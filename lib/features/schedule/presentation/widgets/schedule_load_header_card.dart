import 'package:flutter/material.dart';

class ScheduleLoadHeaderCard extends StatelessWidget {
  const ScheduleLoadHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 48,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Load your schedule',
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Import an ICS file or add classes manually to unlock weekly views and room recommendations.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
