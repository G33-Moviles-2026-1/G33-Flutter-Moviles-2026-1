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

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 56,
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
                          'Import your schedule or add classes manually to unlock the weekly calendar and recommendations.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: onLoadSchedule,
                            child: const Text(
                              'Load Schedule',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: onAddClassManually,
                            child: const Text(
                              'Add Class Manually',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}