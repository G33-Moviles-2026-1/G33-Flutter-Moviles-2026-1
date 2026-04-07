import 'package:andespace/core/di/core_provider.dart';
import 'package:andespace/core/navigation/app_routes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:andespace/core/navigation/app_tab.dart';
import 'package:andespace/shared/widgets/app_scaffold.dart';
import 'package:uuid/uuid.dart';

import '../controllers/schedule_state.dart';
import '../providers/schedule_providers.dart';
import '../widgets/schedule_import_option_card.dart';
import 'add_class_page.dart';
import 'weekly_schedule_page.dart';

class ScheduleLoadPage extends ConsumerWidget {
  const ScheduleLoadPage({super.key});

  Future<void> _pickAndUploadIcs(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final analytics = ref.read(analyticsServiceProvider);
    final controller = ref.read(scheduleControllerProvider.notifier);
    final importSessionId = const Uuid().v4();

    final userEmail = await controller.resolveUserEmail();

    await analytics.trackScheduleImportStep(
      sessionId: importSessionId,
      deviceId: 'mobile',
      userEmail: userEmail,
      method: 'ics',
      step: 'started',
      stepNumber: 1,
      propsJson: {
        'source_screen': 'schedule_load',
      },
    );

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ics'],
    );

    final path = result?.files.single.path;
    if (path == null) return;

    await analytics.trackScheduleImportStep(
      sessionId: importSessionId,
      deviceId: 'mobile',
      userEmail: userEmail,
      method: 'ics',
      step: 'file_selected',
      stepNumber: 2,
      propsJson: {
        'source_screen': 'schedule_load',
      },
    );

    await analytics.trackScheduleImportStep(
      sessionId: importSessionId,
      deviceId: 'mobile',
      userEmail: userEmail,
      method: 'ics',
      step: 'parsed',
      stepNumber: 3,
      propsJson: {
        'source_screen': 'schedule_load',
      },
    );

    await controller.importIcs(
      filePath: path,
      importSessionId: importSessionId,
    );

    await analytics.trackScheduleImportStep(
      sessionId: importSessionId,
      deviceId: 'mobile',
      userEmail: userEmail,
      method: 'ics',
      step: 'confirmed',
      stepNumber: 4,
      propsJson: {
        'source_screen': 'schedule_load',
      },
    );
    if (!context.mounted) return;
    final newState = ref.read(scheduleControllerProvider);
    if (newState.status == ScheduleStatus.loaded) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WeeklySchedulePage(),
        ),
      );
    }
  }

  void _onTabSelected(BuildContext context, AppTab tab) {
    AppRoutes.handleTabSelection(context, tab);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ScheduleState>(
      scheduleControllerProvider,
      (_, next) {
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
      },
    );

    final state = ref.watch(scheduleControllerProvider);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isUploading = state.status == ScheduleStatus.uploading;

    return AppScaffold(
      //title: 'My Schedule',
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
                ScheduleImportOptionCard(
                  title: 'Google Calendar',
                  icon: Icons.calendar_today_outlined,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Google Calendar flow coming soon.'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                ScheduleImportOptionCard(
                  title: 'Load ICS',
                  icon: Icons.upload_file_outlined,
                  onTap: isUploading ? () {} : () => _pickAndUploadIcs(context, ref),
                ),
                const SizedBox(height: 14),
                ScheduleImportOptionCard(
                  title: 'Load Manually',
                  icon: Icons.edit_calendar_outlined,
                  onTap: () async {
                    final analytics = ref.read(analyticsServiceProvider);
                    final controller = ref.read(scheduleControllerProvider.notifier);
                    final userEmail = await controller.resolveUserEmail();
                    final importSessionId = const Uuid().v4();

                    await analytics.trackScheduleImportStep(
                      sessionId: importSessionId,
                      deviceId: 'mobile',
                      userEmail: userEmail,
                      method: 'manual',
                      step: 'started',
                      stepNumber: 1,
                      propsJson: {
                        'source_screen': 'schedule_load',
                      },
                    );

                    if (!context.mounted) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddClassPage(
                          importSessionId: importSessionId,
                        ),
                      ),
                    );
                  },
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
                    child: Column(
                      children: const [
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