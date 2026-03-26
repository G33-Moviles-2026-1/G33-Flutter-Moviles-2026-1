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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month_outlined, size: 72),
            const SizedBox(height: 16),
            const Text(
              'No schedule loaded yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Import your schedule or add classes manually to get started.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 240,
              child: ElevatedButton(
                onPressed: onLoadSchedule,
                child: const Text('Load Schedule'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 240,
              child: OutlinedButton(
                onPressed: onAddClassManually,
                child: const Text('Add Class Manually'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}