import 'package:andespace/core/di/core_provider.dart';
import 'package:andespace/features/schedule/data/local/schedule_local_data_source.dart';
import 'package:andespace/features/schedule/data/remote/schedule_remote_data_source.dart';
import 'package:andespace/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:andespace/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:andespace/features/schedule/domain/usecases/delete_full_schedule_for_current_user_usecase.dart';
import 'package:andespace/features/schedule/domain/usecases/delete_schedule_class_for_current_user_usecase.dart';
import 'package:andespace/features/schedule/domain/usecases/delete_schedule_occurrence_for_current_user_usecase.dart';
import 'package:andespace/features/schedule/domain/usecases/get_recommended_rooms_for_current_user_usecase.dart';
import 'package:andespace/features/schedule/domain/usecases/get_schedule_classes_for_current_user_usecase.dart';
import 'package:andespace/features/schedule/domain/usecases/import_ics_for_current_user_usecase.dart';
import 'package:andespace/features/schedule/domain/usecases/load_week_for_current_user_usecase.dart';
import 'package:andespace/features/schedule/domain/usecases/save_manual_class_for_current_user_usecase.dart';
import 'package:andespace/features/schedule/domain/usecases/validate_schedule_class_requirements_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scheduleRemoteDataSourceProvider =
    Provider<ScheduleRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);

  return ScheduleRemoteDataSourceImpl(dio: dio);
});

final scheduleLocalDataSourceProvider = Provider<ScheduleLocalDataSource>((ref) {
  final db = ref.watch(appDatabaseProvider);

  return ScheduleLocalDataSourceImpl(db: db);
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final remoteDataSource = ref.watch(scheduleRemoteDataSourceProvider);
  final localDataSource = ref.watch(scheduleLocalDataSourceProvider);
  final connectivityQueueService = ref.watch(connectivityQueueServiceProvider);

  return ScheduleRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    connectivityQueueService: connectivityQueueService,
  );
});

final validateScheduleClassRequirementsProvider =
    Provider<ValidateScheduleClassRequirementsUseCase>((ref) {
  return const ValidateScheduleClassRequirementsUseCase();
});

final loadWeekForCurrentUserProvider =
    Provider<LoadWeekForCurrentUserUseCase>((ref) {
  return LoadWeekForCurrentUserUseCase(
    repository: ref.watch(scheduleRepositoryProvider),
  );
});

final importIcsForCurrentUserProvider =
    Provider<ImportIcsForCurrentUserUseCase>((ref) {
  return ImportIcsForCurrentUserUseCase(
    repository: ref.watch(scheduleRepositoryProvider),
  );
});

final getScheduleClassesForCurrentUserProvider =
    Provider<GetScheduleClassesForCurrentUserUseCase>((ref) {
  return GetScheduleClassesForCurrentUserUseCase(
    repository: ref.watch(scheduleRepositoryProvider),
  );
});

final saveManualClassForCurrentUserProvider =
    Provider<SaveManualClassForCurrentUserUseCase>((ref) {
  return SaveManualClassForCurrentUserUseCase(
    repository: ref.watch(scheduleRepositoryProvider),
    getScheduleClassesForCurrentUser: ref.watch(
      getScheduleClassesForCurrentUserProvider,
    ),
    validateScheduleClassRequirements: ref.watch(
      validateScheduleClassRequirementsProvider,
    ),
  );
});

final deleteFullScheduleForCurrentUserProvider =
    Provider<DeleteFullScheduleForCurrentUserUseCase>((ref) {
  return DeleteFullScheduleForCurrentUserUseCase(
    repository: ref.watch(scheduleRepositoryProvider),
  );
});

final deleteScheduleClassForCurrentUserProvider =
    Provider<DeleteScheduleClassForCurrentUserUseCase>((ref) {
  return DeleteScheduleClassForCurrentUserUseCase(
    repository: ref.watch(scheduleRepositoryProvider),
  );
});

final deleteScheduleOccurrenceForCurrentUserProvider =
    Provider<DeleteScheduleOccurrenceForCurrentUserUseCase>((ref) {
  return DeleteScheduleOccurrenceForCurrentUserUseCase(
    repository: ref.watch(scheduleRepositoryProvider),
  );
});

final getRecommendedRoomsForCurrentUserProvider =
    Provider<GetRecommendedRoomsForCurrentUserUseCase>((ref) {
  return GetRecommendedRoomsForCurrentUserUseCase(
    repository: ref.watch(scheduleRepositoryProvider),
  );
});