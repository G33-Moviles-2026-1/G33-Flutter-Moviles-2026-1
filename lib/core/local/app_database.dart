import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
part 'app_database.g.dart';

class MyBookingsTable extends Table {
  @override
  String get tableName => 'my_bookings';

  TextColumn get id => text()();
  TextColumn get roomId => text()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get startTime => text()();
  TextColumn get endTime => text()();
  TextColumn get purpose => text()();
  TextColumn get status => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class FavoriteRoomsTable extends Table {
  @override
  String get tableName => 'favorite_rooms';

  TextColumn get roomId => text()();
  TextColumn get buildingCode => text()();
  TextColumn get buildingName => text().nullable()();
  TextColumn get roomNumber => text()();
  IntColumn get capacity => integer()();
  RealColumn get reliability => real()();
  TextColumn get utilitiesJson => text().withDefault(const Constant('[]'))();
  TextColumn get syncState => text().withDefault(const Constant('clean'))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get savedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {roomId};
}

class FavoriteMutationsTable extends Table {
  @override
  String get tableName => 'favorite_mutations';

  TextColumn get opId => text()();
  TextColumn get roomId => text()();
  TextColumn get operation => text()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {opId};
}

class CachedPathsTable extends Table {
  @override
  String get tableName => 'cached_paths';

  TextColumn get cacheKey => text()();
  TextColumn get originText => text()();
  TextColumn get destText => text()();
  TextColumn get stepsJson => text()();
  IntColumn get totalTimeSeconds => integer()();
  IntColumn get accessedAt => integer()();

  @override
  Set<Column> get primaryKey => {cacheKey};
}

class ScheduleClassesTable extends Table {
  @override
  String get tableName => 'schedule_classes';

  TextColumn get classId => text()();
  TextColumn get title => text().nullable()();
  TextColumn get locationText => text().nullable()();
  TextColumn get roomId => text().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get startTime => text()();
  TextColumn get endTime => text()();
  TextColumn get weekdaysJson => text()();
  TextColumn get syncState => text().withDefault(const Constant('synced'))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {classId};
}

@DriftDatabase(
  tables: [
    MyBookingsTable,
    FavoriteRoomsTable,
    ScheduleClassesTable,
    FavoriteMutationsTable,
    CachedPathsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'andespace_db'));

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      for (final table in allTables) {
        await m.deleteTable(table.actualTableName);
        await m.createTable(table);
      }
    },
  );

  Future<List<MyBookingsTableData>> getAllBookings() =>
      select(myBookingsTable).get();

  Future<void> replaceAllBookings(List<MyBookingsTableCompanion> rows) =>
      transaction(() async {
        await delete(myBookingsTable).go();
        await batch((b) => b.insertAll(myBookingsTable, rows));
      });

  Future<void> deleteBookingById(String id) =>
      (delete(myBookingsTable)..where((t) => t.id.equals(id))).go();

  Future<List<FavoriteRoomsTableData>> getVisibleFavorites() {
    return (select(favoriteRoomsTable)
          ..where((t) => t.syncState.isNotValue('pending_remove'))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  Future<List<FavoriteRoomsTableData>> getAllFavorites() =>
      select(favoriteRoomsTable).get();

  Future<FavoriteRoomsTableData?> getFavoriteById(String roomId) {
    return (select(
      favoriteRoomsTable,
    )..where((t) => t.roomId.equals(roomId))).getSingleOrNull();
  }

  Future<void> upsertFavorite(FavoriteRoomsTableCompanion row) =>
      into(favoriteRoomsTable).insertOnConflictUpdate(row);

  Future<void> deleteFavoriteById(String roomId) =>
      (delete(favoriteRoomsTable)..where((t) => t.roomId.equals(roomId))).go();

  Future<void> deleteCleanFavoritesNotIn(Set<String> roomIds) async {
    if (roomIds.isEmpty) {
      await (delete(
        favoriteRoomsTable,
      )..where((t) => t.syncState.equals('clean'))).go();
      return;
    }

    await (delete(favoriteRoomsTable)..where(
          (t) =>
              t.syncState.equals('clean') & t.roomId.isNotIn(roomIds.toList()),
        ))
        .go();
  }

  Future<List<FavoriteMutationsTableData>> getPendingFavoriteMutations() {
    return (select(
      favoriteMutationsTable,
    )..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
  }

  Future<List<FavoriteMutationsTableData>> getFavoriteMutationsForRoom(
    String roomId,
  ) {
    return (select(favoriteMutationsTable)
          ..where((t) => t.roomId.equals(roomId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<void> upsertFavoriteMutation(FavoriteMutationsTableCompanion row) =>
      into(favoriteMutationsTable).insertOnConflictUpdate(row);

  Future<void> deleteFavoriteMutationById(String opId) =>
      (delete(favoriteMutationsTable)..where((t) => t.opId.equals(opId))).go();

  Future<void> deleteFavoriteMutationsForRoom(String roomId) => (delete(
    favoriteMutationsTable,
  )..where((t) => t.roomId.equals(roomId))).go();

  Future<List<CachedPathsTableData>> getCachedPaths() => (select(
    cachedPathsTable,
  )..orderBy([(t) => OrderingTerm.asc(t.accessedAt)])).get();

  Future<void> replaceCachedPaths(List<CachedPathsTableCompanion> rows) =>
      transaction(() async {
        await delete(cachedPathsTable).go();
        if (rows.isNotEmpty) {
          await batch((b) => b.insertAll(cachedPathsTable, rows));
        }
      });

  Future<void> clearAllLocalUserData() => transaction(() async {
    await delete(myBookingsTable).go();
    await delete(favoriteMutationsTable).go();
    await delete(favoriteRoomsTable).go();
    await delete(scheduleClassesTable).go();
  });

  Future<List<ScheduleClassesTableData>> getScheduleClasses() {
    return (select(scheduleClassesTable)).get();
  }

  Future<void> replaceScheduleClasses(
    List<ScheduleClassesTableCompanion> rows,
  ) {
    return transaction(() async {
      await delete(scheduleClassesTable).go();

      if (rows.isNotEmpty) {
        await batch((b) => b.insertAll(scheduleClassesTable, rows));
      }
    });
  }

  Future<void> upsertScheduleClasses(
    List<ScheduleClassesTableCompanion> rows,
  ) async {
    if (rows.isEmpty) {
      return;
    }

    await batch((b) {
      b.insertAllOnConflictUpdate(scheduleClassesTable, rows);
    });
  }

  Future<void> clearSchedule() async {
    await delete(scheduleClassesTable).go();
  }
}
