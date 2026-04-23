import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/connectivity/pending_action_event.dart';
import 'core/di/core_provider.dart';
import 'core/navigation/app_routes.dart';
import 'features/bookings/presentation/providers/bookings_providers.dart';
import 'shared/theme/theme.dart';
import 'core/di/theme_mode_provider.dart';

final appNavigatorKey = GlobalKey<NavigatorState>();

class AndespaceApp extends ConsumerStatefulWidget {
  const AndespaceApp({super.key});

  @override
  ConsumerState<AndespaceApp> createState() => _AndespaceAppState();
}

class _AndespaceAppState extends ConsumerState<AndespaceApp> {
  @override
  void initState() {
    super.initState();
    ref.read(connectivityQueueServiceProvider);
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeModeProvider);

    ref.listen<AsyncValue<PendingActionEvent>>(
      connectivitySyncEventsProvider,
      (_, next) {
        next.whenData((event) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final ctx = appNavigatorKey.currentContext;
            if (ctx == null || !ctx.mounted) return;
            _showSyncDialog(ctx, event);
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
    );
  }

  void _showSyncDialog(BuildContext context, PendingActionEvent event) {
    final (title, message) = switch (event) {
      PendingActionSucceeded(:final action) => (
          'Done',
          action.successMessage,
        ),
      PendingActionFailed(:final action, :final error) => (
          'Sync failed',
          '${action.failureMessage}\n$error',
        ),
    };

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
}
