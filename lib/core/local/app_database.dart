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

@DriftDatabase(tables: [MyBookingsTable])
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
}
