import 'package:andespace/core/di/auth_providers.dart';
import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';
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
  bool _requestedInitialLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tryInitialLoad();
  }

  void _tryInitialLoad() {
    final authState = ref.read(authControllerProvider);

    if (!authState.isAuthenticated) return;
    if (_requestedInitialLoad) return;

    _requestedInitialLoad = true;

    Future.microtask(() async {
      await ref.read(scheduleControllerProvider.notifier).loadWeek();
    });
  }

  void _onTabSelected(BuildContext context, AppTab tab) {
    AppRoutes.handleTabSelection(context, tab);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    if (authState.isAuthenticated && !_requestedInitialLoad) {
      _tryInitialLoad();
    }

    if (!authState.isAuthenticated) {
      return AppScaffold(
        title: 'My Schedule',
        currentTab: AppTab.schedule,
        onTabSelected: (tab) => _onTabSelected(context, tab),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 72),
                  const SizedBox(height: 20),
                  const Text(
                    'You need to log in to use this feature.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Log in to load and manage your schedule.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.login,
                        );
                      },
                      child: const Text('Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final state = ref.watch(scheduleControllerProvider);

    if (!_requestedInitialLoad ||
        state.status == ScheduleStatus.initial ||
        (state.status == ScheduleStatus.loading &&
            state.weeklySchedule == null)) {
      return AppScaffold(
        title: 'My Schedule',
        currentTab: AppTab.schedule,
        onTabSelected: (tab) => _onTabSelected(context, tab),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.weeklySchedule != null) {
      return const WeeklySchedulePage();
    }

    if (state.status == ScheduleStatus.empty) {
      return const ScheduleLoadPage();
    }

    if (state.status == ScheduleStatus.error) {
      return AppScaffold(
        title: 'My Schedule',
        currentTab: AppTab.schedule,
        onTabSelected: (tab) => _onTabSelected(context, tab),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage ?? 'Something went wrong loading your schedule.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.read(scheduleControllerProvider.notifier).loadWeek();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const ScheduleLoadPage();
  }
}