import 'package:andespace/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';

import '../../domain/entities/manual_class.dart';
import '../controllers/schedule_state.dart';
import '../providers/schedule_providers.dart';

class AddClassPage extends ConsumerStatefulWidget {
  const AddClassPage({
    super.key,
    required this.importSessionId,
  });

  final String importSessionId;

  @override
  ConsumerState<AddClassPage> createState() => _AddClassPageState();
}

class _AddClassPageState extends ConsumerState<AddClassPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
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
    _locationController.dispose();
    _roomIdController.dispose();
    super.dispose();
  }

  void _onTabSelected(BuildContext context, AppTab tab) {
    AppRoutes.handleTabSelection(context, tab);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 7, minute: 0),
    );

    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 8, minute: 0),
    );

    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
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
      setState(() {
        _startDate = picked;
      });
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
      setState(() {
        _endDate = picked;
      });
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
    final analytics = ref.read(analyticsServiceProvider);
    final userEmail = await ref.read(scheduleControllerProvider.notifier).resolveUserEmail();

    await analytics.trackScheduleImportStep(
      sessionId: widget.importSessionId,
      deviceId: 'mobile',
      userEmail: userEmail,
      method: 'manual',
      step: 'first_class_added',
      stepNumber: 2,
      propsJson: {
        'source_screen': 'add_class',
      },
    );
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null ||
        _endDate == null ||
        _startTime == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select start/end dates and times.'),
        ),
      );
      return;
    }

    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start date must be earlier than or equal to end date.'),
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
        const SnackBar(
          content: Text('Select at least one weekday.'),
        ),
      );
      return;
    }

    final existingClasses = await ref
    .read(scheduleControllerProvider.notifier)
    .getExistingClassesForValidation();

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
          int.parse(existingStartParts[0]) * 60 + int.parse(existingStartParts[1]);
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
      
      await analytics.trackScheduleImportStep(
        sessionId: widget.importSessionId,
        deviceId: 'mobile',
        userEmail: userEmail,
        method: 'manual',
        step: 'confirmed',
        stepNumber: 3,
        propsJson: {
          'source_screen': 'add_class',
        },
      );
    }

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

    await ref.read(scheduleControllerProvider.notifier).saveManualClass(
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
    ref.listen<ScheduleState>(
      scheduleControllerProvider,
      (_, next) {
        if (next.status == ScheduleStatus.error && next.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.errorMessage!)),
          );
        }
      },
    );

    final state = ref.watch(scheduleControllerProvider);
    final isSaving = state.status == ScheduleStatus.savingManualClass;

    return AppScaffold(
        title: 'Add Class',
        currentTab: AppTab.schedule,
        onTabSelected: (tab) => _onTabSelected(context, tab),
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
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  TextFormField(
                    controller: _titleController,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(60),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Class Title',
                      border: OutlineInputBorder(),
                      counterText: '',
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
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(30),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Room (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _pickStartDate,
                          child: Text(
                            _startDate == null
                                ? 'Start Date'
                                : _formatDate(_startDate!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _pickEndDate,
                          child: Text(
                            _endDate == null
                                ? 'End Date'
                                : _formatDate(_endDate!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _pickStartTime,
                          child: Text(
                            _startTime == null
                                ? 'Start Time'
                                : _startTime!.format(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _pickEndTime,
                          child: Text(
                            _endTime == null
                                ? 'End Time'
                                : _endTime!.format(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Days of the Week',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _weekdays.keys.map((day) {
                      final selected = _weekdays[day] ?? false;

                      return FilterChip(
                        label: Text(_weekdayLabel(day)),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            _weekdays[day] = value;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _submit,
                      child: Text(
                        isSaving ? 'Saving...' : 'Add',
                      ),
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