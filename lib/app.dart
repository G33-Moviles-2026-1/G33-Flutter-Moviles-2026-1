import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/analytics/screen_time_route_observer.dart';
import 'core/connectivity/pending_action_event.dart';
import 'core/di/core_provider.dart';
import 'core/navigation/app_routes.dart';
import 'shared/theme/theme.dart';
import 'core/di/theme_mode_provider.dart';

final appNavigatorKey = GlobalKey<NavigatorState>();

class AndespaceApp extends ConsumerStatefulWidget {
  const AndespaceApp({super.key});

  @override
  ConsumerState<AndespaceApp> createState() => _AndespaceAppState();
}

class _AndespaceAppState extends ConsumerState<AndespaceApp> {
  late final ScreenTimeRouteObserver _screenTimeRouteObserver;

  @override
  void initState() {
    super.initState();
    _screenTimeRouteObserver = ScreenTimeRouteObserver(ref);
    ref.read(connectivityQueueServiceProvider);
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeModeProvider);

    ref.listen<AsyncValue<List<PendingActionEvent>>>(
      connectivitySyncBatchEventsProvider,
      (_, next) {
        next.whenData((events) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final ctx = appNavigatorKey.currentContext;
            if (ctx == null || !ctx.mounted || events.isEmpty) return;
            _showSyncDialog(ctx, events);
          });
        });
      },
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeState.effectiveMode,
      initialRoute: AppRoutes.authGate,
      routes: AppRoutes.routes,
      navigatorObservers: [_screenTimeRouteObserver],
    );
  }

  void _showSyncDialog(BuildContext context, List<PendingActionEvent> events) {
    final failures = events.whereType<PendingActionFailed>().toList();
    final successes = events.whereType<PendingActionSucceeded>().toList();
    final (title, message) = _syncDialogCopy(
      successes: successes,
      failures: failures,
    );

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  (String, String) _syncDialogCopy({
    required List<PendingActionSucceeded> successes,
    required List<PendingActionFailed> failures,
  }) {
    if (failures.isEmpty) {
      final count = successes.length;
      return (
        'Done',
        count <= 1
            ? successes.first.action.successMessage
            : '$count pending changes synced successfully.',
      );
    }

    final failedMessages = failures
        .map((event) => event.action.failureMessage)
        .toSet()
        .join('\n');

    if (successes.isEmpty) {
      return ('Sync failed', failedMessages);
    }

    return (
      'Some changes synced',
      'These changes could not sync:\n$failedMessages',
    );
  }
}
