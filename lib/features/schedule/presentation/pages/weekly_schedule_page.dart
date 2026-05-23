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

    final controller = ref.read(scheduleControllerProvider.notifier);
    final weekRange = ref.watch(
      scheduleControllerProvider.select((state) {
        final schedule = state.weeklySchedule;

        return (start: schedule?.weekStart, end: schedule?.weekEnd);
      }),
    );

    return SchedulePageScaffold(
      body: Builder(
        builder: (context) {
          final weekStart = weekRange.start;
          final weekEnd = weekRange.end;

          if (weekStart == null || weekEnd == null) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              children: [
                _WeekHeader(
                  label: _formatWeekRange(weekStart, weekEnd),
                  onPreviousWeek: controller.goToPreviousWeek,
                  onNextWeek: controller.goToNextWeek,
                ),
                const SizedBox(height: 12),
                _ScheduleToolbar(
                  onRefresh: controller.refresh,
                  onDeleteSchedule: _confirmDeleteFullSchedule,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: WeeklyCalendarView(
                    onDaySelected: (day) {
                      controller.selectDay(day);
                    },
                    onDeleteOccurrence: (occurrence) {
                      _confirmDeleteOccurrence(occurrence);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _ScheduleActions(
                  onFilterFromSchedule: _filterFromSchedule,
                  onAddManualClass: _openManualClassPage,
                ),
                const _ScheduleProgressIndicator(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  final String label;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  const _WeekHeader({
    required this.label,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPreviousWeek,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Column(
              children: [
                Text('Week', style: textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onNextWeek,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _ScheduleToolbar extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback onDeleteSchedule;

  const _ScheduleToolbar({
    required this.onRefresh,
    required this.onDeleteSchedule,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          tooltip: 'Reload',
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
        ),
        IconButton(
          tooltip: 'Delete schedule',
          onPressed: onDeleteSchedule,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}

class _ScheduleActions extends ConsumerWidget {
  final VoidCallback onFilterFromSchedule;
  final VoidCallback onAddManualClass;

  const _ScheduleActions({
    required this.onFilterFromSchedule,
    required this.onAddManualClass,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFilteringFromSchedule = ref.watch(
      scheduleControllerProvider.select(
        (state) => state.isLoadingRecommendations,
      ),
    );

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: isFilteringFromSchedule ? null : onFilterFromSchedule,
              icon: isFilteringFromSchedule
                  ? const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
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
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(999)),
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
              onPressed: onAddManualClass,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text(
                'Add Class Manually',
                textAlign: TextAlign.center,
              ),
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(999)),
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
    );
  }
}

class _ScheduleProgressIndicator extends ConsumerWidget {
  const _ScheduleProgressIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
      scheduleControllerProvider.select((state) => state.status),
    );

    if (status != ScheduleStatus.deleting && status != ScheduleStatus.loading) {
      return const SizedBox.shrink();
    }

    return const Padding(
      padding: EdgeInsets.only(top: 16),
      child: LinearProgressIndicator(),
    );
  }
}
