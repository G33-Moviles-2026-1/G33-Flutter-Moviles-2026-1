import 'package:andespace/features/schedule/domain/entities/google_calendar_source.dart';
import 'package:andespace/features/schedule/presentation/widgets/schedule_dialog_actions.dart';
import 'package:flutter/material.dart';

Future<List<GoogleCalendarSource>?> showGoogleCalendarSelectionDialog({
  required BuildContext context,
  required List<GoogleCalendarSource> calendars,
}) {
  return showDialog<List<GoogleCalendarSource>>(
    context: context,
    builder: (context) => GoogleCalendarSelectionDialog(calendars: calendars),
  );
}

class GoogleCalendarSelectionDialog extends StatefulWidget {
  const GoogleCalendarSelectionDialog({super.key, required this.calendars});

  final List<GoogleCalendarSource> calendars;

  @override
  State<GoogleCalendarSelectionDialog> createState() =>
      _GoogleCalendarSelectionDialogState();
}

class _GoogleCalendarSelectionDialogState
    extends State<GoogleCalendarSelectionDialog> {
  late final Set<String> _selectedIds = {
    for (final calendar in widget.calendars)
      if (calendar.primary) calendar.id,
  };

  @override
  void initState() {
    super.initState();

    if (_selectedIds.isEmpty && widget.calendars.isNotEmpty) {
      _selectedIds.add(widget.calendars.first.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose calendars'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: widget.calendars.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final calendar = widget.calendars[index];

            return CheckboxListTile(
              value: _selectedIds.contains(calendar.id),
              onChanged: (selected) {
                setState(() {
                  if (selected ?? false) {
                    _selectedIds.add(calendar.id);
                  } else {
                    _selectedIds.remove(calendar.id);
                  }
                });
              },
              title: Text(calendar.summary),
              subtitle: calendar.primary ? const Text('Primary') : null,
              controlAffinity: ListTileControlAffinity.leading,
            );
          },
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        ScheduleDialogActions(
          onCancel: () => Navigator.pop(context),
          onConfirm: _selectedIds.isEmpty
              ? null
              : () {
                  final selected = widget.calendars
                      .where((calendar) => _selectedIds.contains(calendar.id))
                      .toList();
                  Navigator.pop(context, selected);
                },
          confirmLabel: 'Import',
        ),
      ],
    );
  }
}
