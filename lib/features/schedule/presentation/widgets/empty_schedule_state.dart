import 'package:flutter/material.dart';

class EmptyScheduleState extends StatelessWidget {
  final VoidCallback onLoadSchedule;
  final VoidCallback onAddClassManually;

  const EmptyScheduleState({
    super.key,
    required this.onLoadSchedule,
    required this.onAddClassManually,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: .18),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 58,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(height: 18),
                Text(
                  'No schedule loaded yet',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Import your schedule or add classes manually to unlock the weekly calendar and room recommendations.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: onLoadSchedule,
                    icon: const Icon(Icons.upload_file_outlined),
                    label: const Text('Load Schedule'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: onAddClassManually,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add Class Manually'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}