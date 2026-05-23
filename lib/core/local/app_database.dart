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

class FriendsTable extends Table {
  @override
  String get tableName => 'friends';

  TextColumn get email => text()();
  TextColumn get username => text()();
  TextColumn get status => text()();
  TextColumn get syncState => text().withDefault(const Constant('clean'))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {email};
}

class FriendMutationsTable extends Table {
  @override
  String get tableName => 'friend_mutations';

  TextColumn get opId => text()();
  TextColumn get operation => text()();
  TextColumn get identifier => text().nullable()();
  TextColumn get status => text().nullable()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {opId};
}

class MyStatusTable extends Table {
  @override
  String get tableName => 'my_status';

  TextColumn get id => text()();
  TextColumn get status => text()();
  TextColumn get syncState => text().withDefault(const Constant('clean'))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
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

class CachedRecommendedRoomsTable extends Table {
  @override
  String get tableName => 'cached_recommended_rooms';

  TextColumn get cacheKey => text()(); // yyyy-MM-dd
  TextColumn get dataJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {cacheKey};
}

@DriftDatabase(
  tables: [
    MyBookingsTable,
    FavoriteRoomsTable,
    ScheduleClassesTable,
    FavoriteMutationsTable,
    FriendsTable,
    FriendMutationsTable,
    MyStatusTable,
    CachedPathsTable,
    CachedRecommendedRoomsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'andespace_db'));

  @override
  int get schemaVersion => 7;

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
    await delete(friendsTable).go();
    await delete(friendMutationsTable).go();
    await delete(myStatusTable).go();
    await delete(scheduleClassesTable).go();
    await delete(cachedRecommendedRoomsTable).go();
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

  Future<void> deleteScheduleClass(String classId) async {
    await (delete(
      scheduleClassesTable,
    )..where((t) => t.classId.equals(classId))).go();
  }

  Future<void> upsertRecommendedRooms({
    required String key,
    required String json,
  }) {
    return into(cachedRecommendedRoomsTable).insertOnConflictUpdate(
      CachedRecommendedRoomsTableCompanion(
        cacheKey: Value(key),
        dataJson: Value(json),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<CachedRecommendedRoomsTableData?> getRecommendedRooms(String key) {
    return (select(
      cachedRecommendedRoomsTable,
    )..where((t) => t.cacheKey.equals(key))).getSingleOrNull();
  }

  Future<List<FriendsTableData>> getVisibleFriends() {
    return (select(friendsTable)
          ..where((t) => t.syncState.isNotValue('pending_remove'))
          ..orderBy([(t) => OrderingTerm.asc(t.username)]))
        .get();
  }

  Future<List<FriendsTableData>> getAllFriends() {
    return select(friendsTable).get();
  }

  Future<void> upsertFriend(FriendsTableCompanion row) {
    return into(friendsTable).insertOnConflictUpdate(row);
  }

  Future<void> replaceCleanFriends(List<FriendsTableCompanion> rows) {
    return transaction(() async {
      final existing = await getAllFriends();
      final pendingRemoveEmails = existing
          .where((f) => f.syncState == 'pending_remove')
          .map((f) => f.email)
          .toSet();

      for (final row in rows) {
        final email = row.email.value;
        if (pendingRemoveEmails.contains(email)) continue;
        await into(friendsTable).insertOnConflictUpdate(row);
      }
    });
  }

  Future<void> deleteCleanFriendsNotIn(Set<String> emails) async {
    if (emails.isEmpty) {
      await (delete(friendsTable)
            ..where((t) => t.syncState.equals('clean')))
          .go();
      return;
    }

    await (delete(friendsTable)
          ..where(
            (t) => t.syncState.equals('clean') & t.email.isNotIn(emails.toList()),
          ))
        .go();
  }

  Future<void> deleteFriendByEmail(String email) {
    return (delete(friendsTable)..where((t) => t.email.equals(email))).go();
  }

  Future<List<FriendMutationsTableData>> getPendingFriendMutations() {
    return (select(friendMutationsTable)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<void> upsertFriendMutation(FriendMutationsTableCompanion row) {
    return into(friendMutationsTable).insertOnConflictUpdate(row);
  }

  Future<void> deleteFriendMutationById(String opId) {
    return (delete(friendMutationsTable)..where((t) => t.opId.equals(opId))).go();
  }

  Future<void> deleteStatusUpdateMutations() {
    return (delete(friendMutationsTable)
          ..where((t) => t.operation.equals('update_status')))
        .go();
  }

  Future<MyStatusTableData?> getMyStatusRow() {
    return (select(myStatusTable)..where((t) => t.id.equals('me')))
        .getSingleOrNull();
  }

  Future<void> upsertMyStatus(MyStatusTableCompanion row) {
    return into(myStatusTable).insertOnConflictUpdate(row);
  }
}
