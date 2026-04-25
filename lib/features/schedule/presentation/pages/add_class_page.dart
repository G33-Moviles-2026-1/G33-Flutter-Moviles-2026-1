import 'package:andespace/core/di/core_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/manual_class.dart';
import '../notifiers/schedule_state.dart';
import '../notifiers/schedule_notifier.dart';

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
    'monday': false,
    'tuesday': false,
    'wednesday': false,
    'thursday': false,
    'friday': false,
    'saturday': false,
  };

  String _weekdayLabel(String value) {
    switch (value) {
      case 'monday':
        return 'MO';
      case 'tuesday':
        return 'TU';
      case 'wednesday':
        return 'WE';
      case 'thursday':
        return 'TH';
      case 'friday':
        return 'FR';
      case 'saturday':
        return 'SA';
      default:
        return value;
    }
  }

  bool _dateRangesOverlap({
    required DateTime startA,
    required DateTime endA,
    required DateTime startB,
    required DateTime endB,
  }) {
    return !startA.isAfter(endB) && !startB.isAfter(endA);
  }

  bool _timeRangesOverlap({
    required int startMinutesA,
    required int endMinutesA,
    required int startMinutesB,
    required int endMinutesB,
  }) {
    return startMinutesA < endMinutesB && startMinutesB < endMinutesA;
  }

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

    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 8, minute: 0),
    );

    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() => _endDate = picked);
    }
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null ||
        _endDate == null ||
        _startTime == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select start and end dates and times.')),
      );
      return;
    }

    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Start date must be earlier than or equal to end date.',
          ),
        ),
      );
      return;
    }

    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

    if (startMinutes >= endMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start time must be earlier than end time.'),
        ),
      );
      return;
    }

    final selectedWeekdays = _weekdays.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one weekday.')),
      );
      return;
    }

    final controller = ref.read(scheduleControllerProvider.notifier);
    final analytics = ref.read(analyticsServiceProvider);

    try {
      await analytics.trackScheduleImportStep(
        sessionId: widget.importSessionId,
        deviceId: 'mobile',
        userEmail: 'current_user',
        method: 'manual',
        step: 'first_class_added',
        stepNumber: 2,
        propsJson: {'source_screen': 'add_class'},
      );
    } catch (_) {}

    final existingClasses = await controller.getExistingClassesForValidation();

    if (!mounted) return;

    for (final existing in existingClasses) {
      final sameWeekday = existing.weekdays.any(
        (day) => selectedWeekdays.contains(day),
      );

      if (!sameWeekday) continue;

      final datesOverlap = _dateRangesOverlap(
        startA: _startDate!,
        endA: _endDate!,
        startB: existing.startDate,
        endB: existing.endDate,
      );

      if (!datesOverlap) continue;

      final existingStartParts = existing.startTime.split(':');
      final existingEndParts = existing.endTime.split(':');

      final existingStartMinutes =
          int.parse(existingStartParts[0]) * 60 +
          int.parse(existingStartParts[1]);
      final existingEndMinutes =
          int.parse(existingEndParts[0]) * 60 + int.parse(existingEndParts[1]);

      final overlaps = _timeRangesOverlap(
        startMinutesA: startMinutes,
        endMinutesA: endMinutes,
        startMinutesB: existingStartMinutes,
        endMinutesB: existingEndMinutes,
      );

      if (overlaps) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'This class overlaps with "${existing.title ?? 'another class'}".',
            ),
          ),
        );
        return;
      }
    }
    try {
      await analytics.trackScheduleImportStep(
        sessionId: widget.importSessionId,
        deviceId: 'mobile',
        userEmail: 'current_user',
        method: 'manual',
        step: 'confirmed',
        stepNumber: 3,
        propsJson: {'source_screen': 'add_class'},
      );
    } catch (_) {}

    final manualClass = ManualClass(
      title: _titleController.text.trim(),
      roomId: _roomIdController.text.trim().isEmpty
          ? null
          : _roomIdController.text.trim(),
      locationText: _roomIdController.text.trim().isEmpty
          ? null
          : _roomIdController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      startTime: _formatTimeOfDay(_startTime!),
      endTime: _formatTimeOfDay(_endTime!),
      weekdays: selectedWeekdays,
    );

    await controller.saveManualClass(
      manualClass: manualClass,
      importSessionId: widget.importSessionId,
    );

    final state = ref.read(scheduleControllerProvider);

    if (!mounted) return;

    if (state.status == ScheduleStatus.loaded ||
        state.status == ScheduleStatus.empty) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ScheduleState>(scheduleControllerProvider, (_, next) {
      if (next.status == ScheduleStatus.error &&
          next.errorMessage != null &&
          next.errorMessage!.trim().isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
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

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        inputFormatters: [LengthLimitingTextInputFormatter(60)],
                        decoration: InputDecoration(
                          hintText: 'Class Title',
                          counterText: '',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: theme.brightness == Brightness.light
                                  ? Colors.black54
                                  : Colors.transparent,
                            ),
                          ),
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
                        controller: _roomIdController,
                        inputFormatters: [LengthLimitingTextInputFormatter(30)],
                        decoration: InputDecoration(
                          hintText: 'Room (Optional)',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: theme.brightness == Brightness.light
                                  ? Colors.black54
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dates',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 54,
                              child: OutlinedButton.icon(
                                onPressed: _pickStartDate,
                                icon: const Icon(Icons.event_outlined),
                                label: Text(
                                  _startDate == null
                                      ? 'Start Date'
                                      : _formatDate(_startDate!),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 54,
                              child: OutlinedButton.icon(
                                onPressed: _pickEndDate,
                                icon: const Icon(
                                  Icons.event_available_outlined,
                                ),
                                label: Text(
                                  _endDate == null
                                      ? 'End Date'
                                      : _formatDate(_endDate!),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Time',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 54,
                              child: OutlinedButton.icon(
                                onPressed: _pickStartTime,
                                icon: const Icon(Icons.schedule_outlined),
                                label: Text(
                                  _startTime == null
                                      ? 'Start Time'
                                      : _startTime!.format(context),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 54,
                              child: OutlinedButton.icon(
                                onPressed: _pickEndTime,
                                icon: const Icon(Icons.schedule),
                                label: Text(
                                  _endTime == null
                                      ? 'End Time'
                                      : _endTime!.format(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Days of the Week',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _weekdays.keys.map((day) {
                          final selected = _weekdays[day] ?? false;

                          return FilterChip(
                            label: Text(
                              _weekdayLabel(day),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            selected: selected,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: const VisualDensity(
                              horizontal: -2,
                              vertical: -2,
                            ),
                            labelPadding: const EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            onSelected: (value) {
                              setState(() {
                                _weekdays[day] = value;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
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
