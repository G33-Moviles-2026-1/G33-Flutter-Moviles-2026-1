import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/manual_class.dart';
import '../../domain/entities/schedule_weekday.dart';
import '../notifiers/schedule_notifier.dart';
import '../notifiers/schedule_state.dart';

class AddClassPage extends ConsumerStatefulWidget {
  const AddClassPage({super.key, required this.importSessionId});

  final String importSessionId;

  @override
  ConsumerState<AddClassPage> createState() => _AddClassPageState();
}

class _AddClassPageState extends ConsumerState<AddClassPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _roomIdController = TextEditingController();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _startDate;
  DateTime? _endDate;

  final Map<String, bool> _weekdays = {
    ScheduleWeekday.monday: false,
    ScheduleWeekday.tuesday: false,
    ScheduleWeekday.wednesday: false,
    ScheduleWeekday.thursday: false,
    ScheduleWeekday.friday: false,
    ScheduleWeekday.saturday: false,
  };

  @override
  void dispose() {
    _titleController.dispose();
    _roomIdController.dispose();
    super.dispose();
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 7, minute: 0),
    );

    if (picked == null) return;

    setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 8, minute: 0),
    );

    if (picked == null) return;

    setState(() => _endTime = picked);
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );

    if (picked == null) return;

    setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );

    if (picked == null) return;

    setState(() => _endDate = picked);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm:00';
  }

  String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$dd/$mm/$yyyy';
  }

  List<String> _selectedWeekdays() {
    return _weekdays.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null ||
        _endDate == null ||
        _startTime == null ||
        _endTime == null) {
      _showSnackBar('Select start and end dates and times.');
      return;
    }

    final roomText = _roomIdController.text.trim();

    final manualClass = ManualClass(
      title: _titleController.text.trim(),
      roomId: roomText.isEmpty ? null : roomText,
      locationText: roomText.isEmpty ? null : roomText,
      startDate: _startDate!,
      endDate: _endDate!,
      startTime: _formatTimeOfDay(_startTime!),
      endTime: _formatTimeOfDay(_endTime!),
      weekdays: _selectedWeekdays(),
    );

    final controller = ref.read(scheduleControllerProvider.notifier);

    await controller.saveManualClass(
      manualClass: manualClass,
      importSessionId: widget.importSessionId,
    );

    if (!mounted) return;

    final state = ref.read(scheduleControllerProvider);

    if (state.status == ScheduleStatus.loaded) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ScheduleState>(scheduleControllerProvider, (_, next) {
      final message = next.errorMessage;

      if (next.status == ScheduleStatus.error &&
          message != null &&
          message.trim().isNotEmpty) {
        _showSnackBar(message);
      }
    });

    final state = ref.watch(scheduleControllerProvider);
    final isSaving = state.status == ScheduleStatus.savingManualClass;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Class'),
        leading: const BackButton(),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AbsorbPointer(
          absorbing: isSaving,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create a class block',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add the subject, date range, time range, and weekdays.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                _ClassInfoCard(
                  titleController: _titleController,
                  roomIdController: _roomIdController,
                ),
                const SizedBox(height: 16),
                _DateTimeCard(
                  startDate: _startDate,
                  endDate: _endDate,
                  startTime: _startTime,
                  endTime: _endTime,
                  onPickStartDate: _pickStartDate,
                  onPickEndDate: _pickEndDate,
                  onPickStartTime: _pickStartTime,
                  onPickEndTime: _pickEndTime,
                  formatDate: _formatDate,
                ),
                const SizedBox(height: 16),
                _WeekdaysCard(
                  weekdays: _weekdays,
                  onChanged: (day, value) {
                    setState(() {
                      _weekdays[day] = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: isSaving ? null : _submit,
                    icon: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        : const Icon(Icons.add_circle_outline),
                    label: Text(isSaving ? 'Saving...' : 'Add Class'),
                  ),
                ),
                if (isSaving) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClassInfoCard extends StatelessWidget {
  const _ClassInfoCard({
    required this.titleController,
    required this.roomIdController,
  });

  final TextEditingController titleController;
  final TextEditingController roomIdController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(theme),
      child: Column(
        children: [
          TextFormField(
            controller: titleController,
            inputFormatters: [LengthLimitingTextInputFormatter(60)],
            decoration: InputDecoration(
              hintText: 'Class Title',
              counterText: '',
              enabledBorder: _inputBorder(theme),
            ),
            validator: (value) {
              final text = (value ?? '').trim();

              if (text.isEmpty) {
                return 'Enter a class title';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: roomIdController,
            inputFormatters: [LengthLimitingTextInputFormatter(30)],
            decoration: InputDecoration(
              hintText: 'Room (Optional)',
              enabledBorder: _inputBorder(theme),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateTimeCard extends StatelessWidget {
  const _DateTimeCard({
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.onPickStartDate,
    required this.onPickEndDate,
    required this.onPickStartTime,
    required this.onPickEndTime,
    required this.formatDate,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndTime;
  final String Function(DateTime date) formatDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dates',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: onPickStartDate,
                    icon: const Icon(Icons.event_outlined),
                    label: Text(
                      startDate == null ? 'Start Date' : formatDate(startDate!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: onPickEndDate,
                    icon: const Icon(Icons.event_available_outlined),
                    label: Text(
                      endDate == null ? 'End Date' : formatDate(endDate!),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Time',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: onPickStartTime,
                    icon: const Icon(Icons.schedule_outlined),
                    label: Text(
                      startTime == null ? 'Start Time' : startTime!.format(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: onPickEndTime,
                    icon: const Icon(Icons.schedule),
                    label: Text(
                      endTime == null ? 'End Time' : endTime!.format(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekdaysCard extends StatelessWidget {
  const _WeekdaysCard({
    required this.weekdays,
    required this.onChanged,
  });

  final Map<String, bool> weekdays;
  final void Function(String day, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Days of the Week',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weekdays.keys.map((day) {
              final selected = weekdays[day] ?? false;

              return FilterChip(
                label: Text(
                  ScheduleWeekday.shortLabel(day),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: selected,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                onSelected: (value) => onChanged(day, value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration(ThemeData theme) {
  return BoxDecoration(
    color: theme.cardColor,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.18)),
  );
}

InputBorder _inputBorder(ThemeData theme) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(
      color: theme.brightness == Brightness.light
          ? Colors.black54
          : Colors.transparent,
    ),
  );
}
