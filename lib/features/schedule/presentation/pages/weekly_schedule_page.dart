import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/features/schedule/presentation/pages/recommended_rooms_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';
import 'package:uuid/uuid.dart';

import '../controllers/schedule_state.dart';
import '../providers/schedule_providers.dart';
import '../widgets/weekly_calendar_view.dart';
import 'add_class_page.dart';
import 'schedule_load_page.dart';

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

  void _onTabSelected(BuildContext context, AppTab tab) {
    AppRoutes.handleTabSelection(context, tab);
  }

  String _monthName(int month) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return months[month - 1];
  }

  String _formatWeekRange(DateTime start, DateTime end) {
    return '${start.day} de ${_monthName(start.month)} - ${end.day} de ${_monthName(end.month)}';
  }

  Future<void> _confirmDeleteOccurrence({
    required String classId,
    required DateTime date,
  }) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete occurrence'),
              content: const Text('Do you want to delete this class occurrence?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;

    await ref.read(scheduleControllerProvider.notifier).removeOccurrence(
          classId: classId,
          date: date,
        );
  }

  Future<void> _confirmDeleteFullSchedule() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete full schedule'),
              content: const Text('This will remove your entire schedule. Continue?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;

    await ref.read(scheduleControllerProvider.notifier).removeFullSchedule();
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
    final controller = ref.read(scheduleControllerProvider.notifier);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return AppScaffold(
      title: 'My Schedule',
      currentTab: AppTab.schedule,
      onTabSelected: (tab) => _onTabSelected(context, tab),
      body: Builder(
        builder: (context) {
          if (state.status == ScheduleStatus.loading &&
              state.weeklySchedule == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.weeklySchedule == null) {
            return const ScheduleLoadPage();
          }

          final schedule = state.weeklySchedule!;

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
                            Text(
                              'Week',
                              style: textTheme.bodySmall,
                            ),
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
                    onDeleteOccurrence: (occurrence) {
                      _confirmDeleteOccurrence(
                        classId: occurrence.classId,
                        date: occurrence.date,
                      );
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
                          onPressed: () async {
                            final items = await controller.loadRecommendedRoomsForSelectedDay();

                            if (!mounted) return;

                            Navigator.push(
                              // ignore: use_build_context_synchronously
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecommendedRoomsPage(items: items),
                              ),
                            );
                          },
                          icon: const Icon(Icons.filter_alt_outlined),
                          label: const Text('Filter from Schedule'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700
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
                          onPressed: () async {
                            final analytics = ref.read(analyticsServiceProvider);
                            final userEmail = await controller.resolveUserEmail();
                            final importSessionId = const Uuid().v4();

                            await analytics.trackScheduleImportStep(
                              sessionId: importSessionId,
                              deviceId: 'mobile',
                              userEmail: userEmail,
                              method: 'manual',
                              step: 'started',
                              stepNumber: 1,
                              propsJson: {
                                'source_screen': 'schedule_load',
                              },
                            );

                            if (!context.mounted) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddClassPage(
                                  importSessionId: importSessionId,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Add Class Manually'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700
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