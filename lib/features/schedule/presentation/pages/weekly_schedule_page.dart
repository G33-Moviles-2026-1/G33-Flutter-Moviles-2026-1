import 'package:andespace/core/di/core_provider.dart';
import 'package:andespace/features/schedule/domain/entities/schedule_occurrence.dart';
import 'package:andespace/features/schedule/presentation/pages/recommended_rooms_page.dart';
import 'package:andespace/features/schedule/presentation/widgets/delete_occurrence_scope_dialog.dart';
import 'package:andespace/features/schedule/presentation/widgets/schedule_confirm_dialog.dart';
import 'package:andespace/features/schedule/presentation/widgets/schedule_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uuid/uuid.dart';

import '../notifiers/schedule_state.dart';
import '../notifiers/schedule_notifier.dart';
import '../widgets/weekly_calendar_view.dart';
import 'add_class_page.dart';

class WeeklySchedulePage extends ConsumerStatefulWidget {
  const WeeklySchedulePage({super.key});

  @override
  ConsumerState<WeeklySchedulePage> createState() => _WeeklySchedulePageState();
}

class _WeeklySchedulePageState extends ConsumerState<WeeklySchedulePage> {
  @override
  void initState() {
    super.initState();

    final state = ref.read(scheduleControllerProvider);
    if (state.weeklySchedule == null) {
      Future.microtask(() {
        ref.read(scheduleControllerProvider.notifier).loadWeek();
      });
    }
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _formatWeekRange(DateTime start, DateTime end) {
    return '${start.day} of ${_monthName(start.month)} - ${end.day} of ${_monthName(end.month)}';
  }

  Future<void> _confirmDeleteOccurrence(ScheduleOccurrence occurrence) async {
    final scope = await showDeleteOccurrenceScopeDialog(context: context);

    if (scope == null) return;

    await ref
        .read(scheduleControllerProvider.notifier)
        .removeOccurrence(
          classId: occurrence.classId,
          date: occurrence.date,
          scope: scope,
        );
  }

  Future<void> _confirmDeleteFullSchedule() async {
    final confirmed = await showScheduleConfirmDialog(
      context: context,
      title: 'Delete full schedule',
      message: 'This will remove your entire schedule. Continue?',
    );

    if (!confirmed) return;

    await ref.read(scheduleControllerProvider.notifier).removeFullSchedule();
  }

  Future<void> _filterFromSchedule() async {
    final state = ref.read(scheduleControllerProvider);
    final controller = ref.read(scheduleControllerProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final maxDate = today.add(const Duration(days: 7));

    final selected = DateTime(
      state.selectedDate.year,
      state.selectedDate.month,
      state.selectedDate.day,
    );

    if (selected.isBefore(today) || selected.isAfter(maxDate)) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'You can only filter schedule from today up to 7 days ahead.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final session = ref.read(sessionControllerProvider.notifier);
    final currentSearch = session.currentSearch;

    session.updateSearchSelection(
      date: state.selectedDate,
      startTime: currentSearch?.startTime,
      endTime: currentSearch?.endTime,
    );

    final result = await controller.loadRecommendedRoomsForSelectedDay();

    final currentState = ref.read(scheduleControllerProvider);
    final items = result.$1;
    final lastUpdated = result.$2;

    if (!mounted) return;

    navigator.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'recommended_rooms'),
        builder: (_) => RecommendedRoomsPage(
          items: items,
          lastUpdated: lastUpdated,
          isOffline: !currentState.hasInternetConnection,
        ),
      ),
    );
  }

  Future<void> _openManualClassPage() async {
    final controller = ref.read(scheduleControllerProvider.notifier);
    final importSessionId = const Uuid().v4();

    await controller.trackManualImportStarted(
      importSessionId: importSessionId,
      sourceScreen: 'weekly_schedule',
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: 'add_schedule_class'),
        builder: (_) => AddClassPage(importSessionId: importSessionId),
      ),
    );
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

      if (next.infoMessage != null && next.infoMessage!.trim().isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next.infoMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );

        ref.read(scheduleControllerProvider.notifier).clearInfoMessage();
      }
    });

    final state = ref.watch(scheduleControllerProvider);
    final controller = ref.read(scheduleControllerProvider.notifier);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SchedulePageScaffold(
      body: Builder(
        builder: (context) {
          if (state.weeklySchedule == null) {
            return const SizedBox.shrink();
          }

          final schedule = state.weeklySchedule!;
          final isFilteringFromSchedule = state.isLoadingRecommendations;

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: controller.goToPreviousWeek,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text('Week', style: textTheme.bodySmall),
                            const SizedBox(height: 2),
                            Text(
                              _formatWeekRange(
                                schedule.weekStart,
                                schedule.weekEnd,
                              ),
                              textAlign: TextAlign.center,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: controller.goToNextWeek,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: 'Reload',
                      onPressed: controller.refresh,
                      icon: const Icon(Icons.refresh),
                    ),
                    IconButton(
                      tooltip: 'Delete schedule',
                      onPressed: _confirmDeleteFullSchedule,
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: WeeklyCalendarView(
                    schedule: schedule,
                    selectedDate: state.selectedDate,
                    onDaySelected: (day) {
                      controller.selectDay(day);
                    },
                    onDeleteOccurrence: (occurrence) {
                      _confirmDeleteOccurrence(occurrence);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: isFilteringFromSchedule
                              ? null
                              : _filterFromSchedule,
                          icon: isFilteringFromSchedule
                              ? const Padding(
                                  padding: EdgeInsets.only(right: 16),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.filter_alt_outlined),
                          label: Text(
                            isFilteringFromSchedule
                                ? 'Filtering...'
                                : 'Filter from Schedule',
                            textAlign: TextAlign.center,
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _openManualClassPage,
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text(
                            'Add Class Manually',
                            textAlign: TextAlign.center,
                          ),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (state.status == ScheduleStatus.deleting ||
                    state.status == ScheduleStatus.loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
