import 'dart:async';

import 'package:andespace/core/di/core_provider.dart';
import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/features/schedule/presentation/mappers/google_calendar_import_error_message_mapper.dart';
import 'package:andespace/features/schedule/presentation/notifiers/schedule_notifier.dart';
import 'package:andespace/features/schedule/presentation/notifiers/schedule_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';

import '../widgets/google_calendar_connection_dialog.dart';
import '../widgets/google_calendar_selection_dialog.dart';
import '../widgets/schedule_import_option_card.dart';
import '../widgets/schedule_load_header_card.dart';
import '../widgets/schedule_upload_status_card.dart';
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

  void _showImportOfflineMessage(String importName) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$importName import is disabled because you do not have an internet connection.',
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
      _showImportOfflineMessage('ICS');
      return;
    }

    setState(() {
      _isOnline = true;
    });

    await _pickAndUploadIcs();
  }

  Future<void> _handleGoogleCalendarTap() async {
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
      _showImportOfflineMessage('Google Calendar');
      return;
    }

    setState(() {
      _isOnline = true;
    });

    await _connectAndImportGoogleCalendar();
  }

  Future<void> _connectAndImportGoogleCalendar() async {
    final controller = ref.read(scheduleControllerProvider.notifier);
    final importSessionId = const Uuid().v4();

    await controller.trackGoogleImportStarted(
      importSessionId: importSessionId,
      sourceScreen: 'schedule_load',
    );

    try {
      final auth = await controller.startGoogleCalendarConnection();
      final launched = await launchUrl(
        Uri.parse(auth.authUrl),
        mode: LaunchMode.externalApplication,
      );

      if (!mounted) return;

      if (!launched) {
        _showSnackBar('Could not open Google Calendar sign-in.');
        return;
      }

      await controller.trackGoogleAuthInitiated(
        importSessionId: importSessionId,
        sourceScreen: 'schedule_load',
      );

      if (!mounted) return;

      final calendars = await showGoogleCalendarConnectionDialog(
        context: context,
        state: auth.state,
      );

      if (!mounted || calendars == null || calendars.isEmpty) return;

      await controller.trackGoogleAuthGranted(
        importSessionId: importSessionId,
        sourceScreen: 'schedule_load',
      );

      if (!mounted) return;

      final selected = await showGoogleCalendarSelectionDialog(
        context: context,
        calendars: calendars,
      );

      if (!mounted || selected == null || selected.isEmpty) return;

      await controller.trackGoogleCalendarsSelected(
        importSessionId: importSessionId,
        sourceScreen: 'schedule_load',
        selectedCount: selected.length,
      );

      await controller.importGoogleCalendars(
        oauthState: auth.state,
        calendarIds: selected.map((calendar) => calendar.id).toList(),
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
    } catch (error, stackTrace) {
      debugPrint('Google Calendar import error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      _showSnackBar(mapGoogleCalendarImportErrorMessage(error));
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
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
    final isUploading = state.status == ScheduleStatus.uploading;
    final canUseRemoteImport = _isOnline && !isUploading;

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
                const ScheduleLoadHeaderCard(),
                const SizedBox(height: 24),

                AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: canUseRemoteImport ? 1 : 0.45,
                  child: ColorFiltered(
                    colorFilter: canUseRemoteImport
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
                  opacity: canUseRemoteImport ? 1 : 0.45,
                  child: ColorFiltered(
                    colorFilter: canUseRemoteImport
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
                  const ScheduleUploadStatusCard(
                    message: 'Uploading and processing schedule...',
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
