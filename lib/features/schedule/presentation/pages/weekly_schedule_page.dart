import 'package:andespace/core/navigation/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';

import '../controllers/schedule_state.dart';
import '../providers/schedule_providers.dart';
import '../widgets/empty_schedule_state.dart';
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
    return '${start.day} de ${_monthName(start.month)} - '
        '${end.day} de ${_monthName(end.month)}';
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
              content: const Text(
                'Do you want to delete this class occurrence?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
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
              content: const Text(
                'This will remove your entire schedule. Continue?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
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

          if (state.status == ScheduleStatus.empty ||
              state.weeklySchedule == null) {
            return EmptyScheduleState(
              onLoadSchedule: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ScheduleLoadPage(),
                  ),
                );
              },
              onAddClassManually: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddClassPage(),
                  ),
                );
              },
            );
          }

          final schedule = state.weeklySchedule!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: controller.goToPreviousWeek,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          _formatWeekRange(
                            schedule.weekStart,
                            schedule.weekEnd,
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: controller.goToNextWeek,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 8,
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
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ScheduleLoadPage(),
                        ),
                      ),
                      child: const Text('Filter from Schedule'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddClassPage(),
                          ),
                        );
                      },
                      child: const Text('Add Class Manually'),
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