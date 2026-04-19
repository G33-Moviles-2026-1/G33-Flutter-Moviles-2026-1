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
  TextColumn get operation => text()(); // add | remove
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {opId};
}

@DriftDatabase(
  tables: [
    MyBookingsTable,
    FavoriteRoomsTable,
    FavoriteMutationsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'andespace_db'));

  @override
  int get schemaVersion => 2;

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
          ..orderBy([
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .get();
  }

  Future<List<FavoriteRoomsTableData>> getAllFavorites() =>
      select(favoriteRoomsTable).get();

  Future<FavoriteRoomsTableData?> getFavoriteById(String roomId) {
    return (select(favoriteRoomsTable)..where((t) => t.roomId.equals(roomId)))
        .getSingleOrNull();
  }

  Future<void> upsertFavorite(FavoriteRoomsTableCompanion row) =>
      into(favoriteRoomsTable).insertOnConflictUpdate(row);

  Future<void> deleteFavoriteById(String roomId) =>
      (delete(favoriteRoomsTable)..where((t) => t.roomId.equals(roomId))).go();

  Future<void> deleteCleanFavoritesNotIn(Set<String> roomIds) async {
    if (roomIds.isEmpty) {
      await (delete(favoriteRoomsTable)..where((t) => t.syncState.equals('clean')))
          .go();
      return;
    }

    await (delete(favoriteRoomsTable)
          ..where(
            (t) =>
                t.syncState.equals('clean') &
                t.roomId.isNotIn(roomIds.toList()),
          ))
        .go();
  }

  Future<List<FavoriteMutationsTableData>> getPendingFavoriteMutations() {
    return (select(favoriteMutationsTable)
          ..orderBy([
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .get();
  }

  Future<List<FavoriteMutationsTableData>> getFavoriteMutationsForRoom(
    String roomId,
  ) {
    return (select(favoriteMutationsTable)
          ..where((t) => t.roomId.equals(roomId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .get();
  }

  Future<void> upsertFavoriteMutation(FavoriteMutationsTableCompanion row) =>
      into(favoriteMutationsTable).insertOnConflictUpdate(row);

  Future<void> deleteFavoriteMutationById(String opId) =>
      (delete(favoriteMutationsTable)..where((t) => t.opId.equals(opId))).go();

  Future<void> deleteFavoriteMutationsForRoom(String roomId) =>
      (delete(favoriteMutationsTable)..where((t) => t.roomId.equals(roomId))).go();

  Future<void> clearAllLocalUserData() => transaction(() async {
        await delete(myBookingsTable).go();
        await delete(favoriteMutationsTable).go();
        await delete(favoriteRoomsTable).go();
      });
}