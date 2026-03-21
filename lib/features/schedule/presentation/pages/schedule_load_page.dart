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

    if (!context.mounted) return;

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

    final newState = controller.state;
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
        if (next.status == ScheduleStatus.error && next.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.errorMessage!)),
          );
        }
      },
    );

    final state = ref.watch(scheduleControllerProvider);

    return AppScaffold(
      title: 'AndeSpace',
      currentTab: AppTab.schedule,
      onTabSelected: (tab) => _onTabSelected(context, tab),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Load Schedule',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
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
                  onTap: state.status == ScheduleStatus.uploading
                      ? () {}
                      : () => _pickAndUploadIcs(context, ref),
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
                        builder: (_) => AddClassPage(importSessionId: importSessionId),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                if (state.status == ScheduleStatus.uploading)
                  const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}