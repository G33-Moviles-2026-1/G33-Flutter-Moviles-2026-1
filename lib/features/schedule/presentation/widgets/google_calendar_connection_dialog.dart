import 'package:andespace/features/schedule/domain/entities/google_calendar_source.dart';
import 'package:andespace/features/schedule/presentation/notifiers/schedule_notifier.dart';
import 'package:andespace/features/schedule/presentation/widgets/schedule_dialog_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<List<GoogleCalendarSource>?> showGoogleCalendarConnectionDialog({
  required BuildContext context,
  required String state,
}) {
  return showDialog<List<GoogleCalendarSource>>(
    context: context,
    barrierDismissible: false,
    builder: (context) => GoogleCalendarConnectionDialog(state: state),
  );
}

class GoogleCalendarConnectionDialog extends ConsumerStatefulWidget {
  const GoogleCalendarConnectionDialog({super.key, required this.state});

  final String state;

  @override
  ConsumerState<GoogleCalendarConnectionDialog> createState() =>
      _GoogleCalendarConnectionDialogState();
}

class _GoogleCalendarConnectionDialogState
    extends ConsumerState<GoogleCalendarConnectionDialog> {
  bool _isChecking = false;
  String? _message;

  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
      _message = null;
    });

    try {
      final calendars = await ref
          .read(scheduleControllerProvider.notifier)
          .loadGoogleCalendars(state: widget.state);

      if (!mounted) return;
      Navigator.pop(context, calendars);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message =
            'Google is not connected yet. Finish sign-in in the browser and try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Connect Google Calendar'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complete Google sign-in in the browser, then return here.',
            style: theme.textTheme.bodyMedium,
          ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(
              _message!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        ScheduleDialogActions(
          onCancel: _isChecking ? null : () => Navigator.pop(context),
          onConfirm: _isChecking ? null : _checkConnection,
          confirmLabel: 'Ready',
          confirmChild: _isChecking
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
        ),
      ],
    );
  }
}
