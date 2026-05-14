import 'dart:async';

import 'package:andespace/core/di/core_provider.dart';
import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/features/schedule/presentation/notifiers/schedule_notifier.dart';
import 'package:andespace/features/schedule/presentation/notifiers/schedule_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';

import '../widgets/schedule_import_option_card.dart';
import 'add_class_page.dart';
import 'weekly_schedule_page.dart';

class ScheduleLoadPage extends ConsumerStatefulWidget {
  const ScheduleLoadPage({super.key});

  @override
  ConsumerState<ScheduleLoadPage> createState() => _ScheduleLoadPageState();
}

class _ScheduleLoadPageState extends ConsumerState<ScheduleLoadPage> {
  Timer? _connectivityTimer;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();

    _connectivityTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkInternetConnection(),
    );
  }

  @override
  void dispose() {
    _connectivityTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkInternetConnection() async {
    final online = await _hasInternetConnection();

    if (!mounted) return;

    if (_isOnline != online) {
      setState(() {
        _isOnline = online;
      });
    }
  }

  Future<bool> _hasInternetConnection() async {
    final service = ref.read(connectivityStatusServiceProvider);
    return service.hasInternetConnection();
  }

  void _showIcsOfflineMessage() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'ICS import is disabled because you do not have an internet connection.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _handleIcsTap() async {
    final state = ref.read(scheduleControllerProvider);

    if (state.status == ScheduleStatus.uploading) {
      return;
    }

    final online = await _hasInternetConnection();

    if (!mounted) return;

    if (!online) {
      setState(() {
        _isOnline = false;
      });
      _showIcsOfflineMessage();
      return;
    }

    setState(() {
      _isOnline = true;
    });

    await _pickAndUploadIcs();
  }

  Future<void> _handleGoogleCalendarTap() async {
    final online = await _hasInternetConnection();

    if (!mounted) return;

    if (!online) {
      setState(() {
        _isOnline = false;
      });
      _showGoogleCalendarOfflineMessage();
      return;
    }

    setState(() {
      _isOnline = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Calendar flow coming soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showGoogleCalendarOfflineMessage() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Google Calendar import is disabled because you do not have an internet connection.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _pickAndUploadIcs() async {
    final controller = ref.read(scheduleControllerProvider.notifier);
    final importSessionId = const Uuid().v4();

    await controller.trackIcsImportStarted(
      importSessionId: importSessionId,
      sourceScreen: 'schedule_load',
    );

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ics'],
    );

    final path = result?.files.single.path;
    if (path == null) return;

    await controller.trackIcsFileSelected(
      importSessionId: importSessionId,
      sourceScreen: 'schedule_load',
    );

    await controller.importIcs(
      filePath: path,
      importSessionId: importSessionId,
    );

    if (!mounted) return;

    final newState = ref.read(scheduleControllerProvider);

    if (newState.status == ScheduleStatus.loaded) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WeeklySchedulePage()),
      );
    }
  }

  Future<void> _openManualClassPage() async {
    final importSessionId = const Uuid().v4();
    final controller = ref.read(scheduleControllerProvider.notifier);

    unawaited(
      controller.trackManualImportStarted(
        importSessionId: importSessionId,
        sourceScreen: 'schedule_load',
      ),
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddClassPage(importSessionId: importSessionId),
      ),
    );
  }

  void _onTabSelected(BuildContext context, AppTab tab) {
    AppRoutes.handleTabSelection(context, tab);
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isUploading = state.status == ScheduleStatus.uploading;
    final canUseIcs = _isOnline && !isUploading;

    return AppScaffold(
      currentTab: AppTab.schedule,
      onTabSelected: (tab) => _onTabSelected(context, tab),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 48,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Load your schedule',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Import an ICS file or add classes manually to unlock weekly views and room recommendations.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: canUseIcs ? 1 : 0.45,
                  child: ColorFiltered(
                    colorFilter: canUseIcs
                        ? const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.multiply,
                          )
                        : ColorFilter.mode(
                            theme.disabledColor.withValues(alpha: 0.35),
                            BlendMode.srcATop,
                          ),
                    child: ScheduleImportOptionCard(
                      title: 'Google Calendar',
                      icon: Icons.calendar_today_outlined,
                      onTap: _handleGoogleCalendarTap,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: canUseIcs ? 1 : 0.45,
                  child: ColorFiltered(
                    colorFilter: canUseIcs
                        ? const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.multiply,
                          )
                        : ColorFilter.mode(
                            theme.disabledColor.withValues(alpha: 0.35),
                            BlendMode.srcATop,
                          ),
                    child: ScheduleImportOptionCard(
                      title: isUploading ? 'Uploading ICS...' : 'Load ICS',
                      icon: Icons.upload_file_outlined,
                      onTap: _handleIcsTap,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                ScheduleImportOptionCard(
                  title: 'Load Manually',
                  icon: Icons.edit_calendar_outlined,
                  onTap: _openManualClassPage,
                ),

                if (isUploading) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.18),
                      ),
                    ),
                    child: const Column(
                      children: [
                        LinearProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Uploading and processing ICS file...'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
