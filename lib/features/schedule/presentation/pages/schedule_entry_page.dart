import 'package:andespace/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/features/schedule/presentation/widgets/schedule_page_scaffold.dart';
import 'package:andespace/features/schedule/presentation/widgets/schedule_status_card.dart';
import 'package:andespace/shared/widgets/auth_required_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifiers/schedule_state.dart';
import '../notifiers/schedule_notifier.dart';
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
      await ref.read(scheduleControllerProvider.notifier).loadWeek(refreshFromRemote: true,);
    });
  }

  void _onTabSelected(BuildContext context, AppTab tab) {
    AppRoutes.handleTabSelection(context, tab);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    if (authState.isAuthenticated && !_requestedInitialLoad) {
      _tryInitialLoad();
    }

    if (!authState.hasActiveSession) {
      return AuthRequiredScaffold(
        currentTab: AppTab.schedule,
        onTabSelected: (tab) => _onTabSelected(context, tab),
        title: 'Log in to view your schedule',
        message:
            'Sign in to load, manage, and use your weekly schedule for recommendations.',
      );
    }

    final state = ref.watch(scheduleControllerProvider);

    if (state.status == ScheduleStatus.uploading) {
      return const SchedulePageScaffold(
        body: ScheduleStatusCard(
          leading: CircularProgressIndicator(),
          title: 'Loading your schedule...',
          message: 'Please wait while we prepare your weekly view.',
        ),
      );
    }

    final shouldShowWeeklySchedule =
        state.weeklySchedule != null &&
        (state.status == ScheduleStatus.loaded ||
            state.status == ScheduleStatus.loading ||
            state.status == ScheduleStatus.deleting ||
            state.status == ScheduleStatus.savingManualClass);

    if (shouldShowWeeklySchedule) {
      return const WeeklySchedulePage();
    }

    if (!_requestedInitialLoad ||
        state.status == ScheduleStatus.initial ||
        state.status == ScheduleStatus.loading) {
      return const SchedulePageScaffold(
        body: ScheduleStatusCard(
          leading: CircularProgressIndicator(),
          title: 'Loading your schedule...',
          message: 'Please wait while we prepare your weekly view.',
        ),
      );
    }

    if (state.status == ScheduleStatus.error) {
      return SchedulePageScaffold(
        body: ScheduleStatusCard(
          leading: Icon(
            Icons.error_outline_rounded,
            size: 56,
            color: theme.colorScheme.error,
          ),
          title: 'Something went wrong',
          message:
              'We could not load your schedule right now. Please check your connection and try again.',
          footer: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(scheduleControllerProvider.notifier).loadWeek(refreshFromRemote: true,);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ),
        ),
      );
    }

    return const ScheduleLoadPage();
  }
}
