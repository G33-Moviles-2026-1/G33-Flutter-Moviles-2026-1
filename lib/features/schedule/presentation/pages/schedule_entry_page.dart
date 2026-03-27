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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    if (authState.isAuthenticated && !_requestedInitialLoad) {
      _tryInitialLoad();
    }

    if (!authState.isAuthenticated) {
      return AppScaffold(
        //title: 'My Schedule',
        currentTab: AppTab.schedule,
        onTabSelected: (tab) => _onTabSelected(context, tab),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 56,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Log in to view your schedule',
                              textAlign: TextAlign.center,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Sign in to load, manage, and use your weekly schedule for recommendations.',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.login,
                                  );
                                },
                                icon: const Icon(Icons.login),
                                label: const Text('Log In'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
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
        //title: 'My Schedule',
        currentTab: AppTab.schedule,
        onTabSelected: (tab) => _onTabSelected(context, tab),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 18),
                    Text(
                      'Loading your schedule...',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please wait while we prepare your weekly view.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (state.weeklySchedule != null) {
      return const WeeklySchedulePage();
    }

    if (state.status == ScheduleStatus.error) {
      return AppScaffold(
        //title: 'My Schedule',
        currentTab: AppTab.schedule,
        onTabSelected: (tab) => _onTabSelected(context, tab),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 56,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Something went wrong',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.errorMessage ??
                          'We could not load your schedule right now.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ref.read(scheduleControllerProvider.notifier).loadWeek();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return const ScheduleLoadPage();
  }
}