import 'dart:async';

import 'package:andespace/core/di/core_provider.dart';
import 'package:andespace/core/navigation/app_routes.dart';
import 'package:andespace/features/schedule/domain/entities/google_calendar_source.dart';
import 'package:andespace/features/schedule/presentation/notifiers/schedule_notifier.dart';
import 'package:andespace/features/schedule/presentation/notifiers/schedule_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
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
      _showGoogleCalendarOfflineMessage();
      return;
    }

    setState(() {
      _isOnline = true;
    });

    await _connectAndImportGoogleCalendar();
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

      final calendars = await _waitForGoogleCalendarConnection(auth.state);

      if (!mounted || calendars == null || calendars.isEmpty) return;

      final selected = await _showGoogleCalendarSelectionDialog(calendars);

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
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('Could not import Google Calendar. Please try again.');
    }
  }

  Future<List<GoogleCalendarSource>?> _waitForGoogleCalendarConnection(
    String state,
  ) {
    return showDialog<List<GoogleCalendarSource>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _GoogleConnectionDialog(state: state),
    );
  }

  Future<List<GoogleCalendarSource>?> _showGoogleCalendarSelectionDialog(
    List<GoogleCalendarSource> calendars,
  ) {
    return showDialog<List<GoogleCalendarSource>>(
      context: context,
      builder: (context) =>
          _GoogleCalendarSelectionDialog(calendars: calendars),
    );
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

class _GoogleConnectionDialog extends ConsumerStatefulWidget {
  const _GoogleConnectionDialog({required this.state});

  final String state;

  @override
  ConsumerState<_GoogleConnectionDialog> createState() =>
      _GoogleConnectionDialogState();
}

class _GoogleConnectionDialogState
    extends ConsumerState<_GoogleConnectionDialog> {
  bool _isChecking = false;
  String? _message;

  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
      _message = null;
    });

    try {
      final calendars = await ref
          .read(scheduleControllerProvider.notifier)
          .loadGoogleCalendars(state: widget.state);

      if (!mounted) return;
      Navigator.pop(context, calendars);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message =
            'Google is not connected yet. Finish sign-in in the browser and try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Connect Google Calendar'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complete Google sign-in in the browser, then return here.',
            style: theme.textTheme.bodyMedium,
          ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(
              _message!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isChecking ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isChecking ? null : _checkConnection,
          child: _isChecking
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('I connected'),
        ),
      ],
    );
  }
}

class _GoogleCalendarSelectionDialog extends StatefulWidget {
  const _GoogleCalendarSelectionDialog({required this.calendars});

  final List<GoogleCalendarSource> calendars;

  @override
  State<_GoogleCalendarSelectionDialog> createState() =>
      _GoogleCalendarSelectionDialogState();
}

class _GoogleCalendarSelectionDialogState
    extends State<_GoogleCalendarSelectionDialog> {
  late final Set<String> _selectedIds = {
    for (final calendar in widget.calendars)
      if (calendar.primary) calendar.id,
  };

  @override
  void initState() {
    super.initState();

    if (_selectedIds.isEmpty && widget.calendars.isNotEmpty) {
      _selectedIds.add(widget.calendars.first.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose calendars'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: widget.calendars.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final calendar = widget.calendars[index];

            return CheckboxListTile(
              value: _selectedIds.contains(calendar.id),
              onChanged: (selected) {
                setState(() {
                  if (selected ?? false) {
                    _selectedIds.add(calendar.id);
                  } else {
                    _selectedIds.remove(calendar.id);
                  }
                });
              },
              title: Text(calendar.summary),
              subtitle: calendar.primary ? const Text('Primary') : null,
              controlAffinity: ListTileControlAffinity.leading,
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedIds.isEmpty
              ? null
              : () {
                  final selected = widget.calendars
                      .where((calendar) => _selectedIds.contains(calendar.id))
                      .toList();
                  Navigator.pop(context, selected);
                },
          child: const Text('Import'),
        ),
      ],
    );
  }
}
