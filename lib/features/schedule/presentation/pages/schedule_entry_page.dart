import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/schedule_state.dart';
import '../providers/schedule_providers.dart';
import 'schedule_load_page.dart';
import 'weekly_schedule_page.dart';

class ScheduleEntryPage extends ConsumerStatefulWidget {
  const ScheduleEntryPage({super.key});

  @override
  ConsumerState<ScheduleEntryPage> createState() => _ScheduleEntryPageState();
}

class _ScheduleEntryPageState extends ConsumerState<ScheduleEntryPage> {
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (_hasLoaded) return;
      _hasLoaded = true;
      await ref.read(scheduleControllerProvider.notifier).loadWeek();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduleControllerProvider);

    if (state.status == ScheduleStatus.initial ||
        state.status == ScheduleStatus.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.status == ScheduleStatus.loaded &&
        state.weeklySchedule != null) {
      return const WeeklySchedulePage();
    }

    return const ScheduleLoadPage();
  }
}