import 'package:flutter/material.dart';

class ScheduleDialogActions extends StatelessWidget {
  const ScheduleDialogActions({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    required this.confirmLabel,
    this.confirmChild,
  });

  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final String confirmLabel;
  final Widget? confirmChild;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cancelBackground = theme.brightness == Brightness.dark
        ? const Color(0xFFE8EAED)
        : const Color(0xFFFFF2C2);
    final cancelForeground = theme.brightness == Brightness.dark
        ? const Color(0xFF202124)
        : const Color(0xFF5D4300);

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onCancel,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: cancelBackground,
                foregroundColor: cancelForeground,
                disabledBackgroundColor: cancelBackground.withValues(
                  alpha: 0.45,
                ),
                disabledForegroundColor: cancelForeground.withValues(
                  alpha: 0.45,
                ),
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: confirmChild ?? Text(confirmLabel),
            ),
          ),
        ],
      ),
    );
  }
}
