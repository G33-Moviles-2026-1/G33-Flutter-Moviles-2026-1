import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:andespace/core/di/auth_providers.dart';
import 'package:andespace/core/di/core_provider.dart';

import '../../data/datasources/schedule_remote_data_source.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../domain/usecases/delete_full_schedule.dart';
import '../../domain/usecases/delete_schedule_class.dart';
import '../../domain/usecases/delete_schedule_occurrence.dart';
import '../../domain/usecases/get_schedule_classes.dart';
import '../../domain/usecases/get_weekly_schedule.dart';
import '../../domain/usecases/upload_ics_schedule.dart';
import '../../domain/usecases/upload_manual_schedule.dart';
import '../controllers/schedule_controller.dart';
import '../controllers/schedule_state.dart';

final scheduleRemoteDataSourceProvider = Provider<ScheduleRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);

  return ScheduleRemoteDataSourceImpl(dio: dio);
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final remoteDataSource = ref.watch(scheduleRemoteDataSourceProvider);

  return ScheduleRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

final uploadIcsScheduleProvider = Provider<UploadIcsSchedule>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return UploadIcsSchedule(repository);
});

final uploadManualScheduleProvider = Provider<UploadManualSchedule>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return UploadManualSchedule(repository);
});

final getWeeklyScheduleProvider = Provider<GetWeeklySchedule>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return GetWeeklySchedule(repository);
});

final getScheduleClassesProvider = Provider<GetScheduleClasses>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return GetScheduleClasses(repository);
});

final deleteFullScheduleProvider = Provider<DeleteFullSchedule>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return DeleteFullSchedule(repository);
});

final deleteScheduleClassProvider = Provider<DeleteScheduleClass>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return DeleteScheduleClass(repository);
});

final deleteScheduleOccurrenceProvider = Provider<DeleteScheduleOccurrence>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return DeleteScheduleOccurrence(repository);
});

final scheduleControllerProvider =
    StateNotifierProvider<ScheduleController, ScheduleState>((ref) {
  return ScheduleController(
    getWeeklySchedule: ref.watch(getWeeklyScheduleProvider),
    uploadIcsSchedule: ref.watch(uploadIcsScheduleProvider),
    uploadManualSchedule: ref.watch(uploadManualScheduleProvider),
    getScheduleClasses: ref.watch(getScheduleClassesProvider),
    deleteFullSchedule: ref.watch(deleteFullScheduleProvider),
    deleteScheduleClass: ref.watch(deleteScheduleClassProvider),
    deleteScheduleOccurrence: ref.watch(deleteScheduleOccurrenceProvider),
    resolveUserEmail: () async {
      final getCurrentUser = ref.read(getCurrentUserUseCaseProvider);
      final currentUser = await getCurrentUser();
      return currentUser!.email;
    },
  );
});