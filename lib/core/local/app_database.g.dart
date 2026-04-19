// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MyBookingsTableTable extends MyBookingsTable
    with TableInfo<$MyBookingsTableTable, MyBookingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MyBookingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    roomId,
    date,
    createdAt,
    startTime,
    endTime,
    purpose,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'my_bookings';
  @override
  VerificationContext validateIntegrity(
    Insertable<MyBookingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    } else if (isInserting) {
      context.missing(_purposeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MyBookingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MyBookingsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_time'],
      )!,
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $MyBookingsTableTable createAlias(String alias) {
    return $MyBookingsTableTable(attachedDatabase, alias);
  }
}

class MyBookingsTableData extends DataClass
    implements Insertable<MyBookingsTableData> {
  final String id;
  final String roomId;
  final DateTime date;
  final DateTime createdAt;
  final String startTime;
  final String endTime;
  final String purpose;
  final String status;
  const MyBookingsTableData({
    required this.id,
    required this.roomId,
    required this.date,
    required this.createdAt,
    required this.startTime,
    required this.endTime,
    required this.purpose,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['room_id'] = Variable<String>(roomId);
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['start_time'] = Variable<String>(startTime);
    map['end_time'] = Variable<String>(endTime);
    map['purpose'] = Variable<String>(purpose);
    map['status'] = Variable<String>(status);
    return map;
  }

  MyBookingsTableCompanion toCompanion(bool nullToAbsent) {
    return MyBookingsTableCompanion(
      id: Value(id),
      roomId: Value(roomId),
      date: Value(date),
      createdAt: Value(createdAt),
      startTime: Value(startTime),
      endTime: Value(endTime),
      purpose: Value(purpose),
      status: Value(status),
    );
  }

  factory MyBookingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MyBookingsTableData(
      id: serializer.fromJson<String>(json['id']),
      roomId: serializer.fromJson<String>(json['roomId']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
      purpose: serializer.fromJson<String>(json['purpose']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'roomId': serializer.toJson<String>(roomId),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
      'purpose': serializer.toJson<String>(purpose),
      'status': serializer.toJson<String>(status),
    };
  }

  MyBookingsTableData copyWith({
    String? id,
    String? roomId,
    DateTime? date,
    DateTime? createdAt,
    String? startTime,
    String? endTime,
    String? purpose,
    String? status,
  }) => MyBookingsTableData(
    id: id ?? this.id,
    roomId: roomId ?? this.roomId,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    purpose: purpose ?? this.purpose,
    status: status ?? this.status,
  );
  MyBookingsTableData copyWithCompanion(MyBookingsTableCompanion data) {
    return MyBookingsTableData(
      id: data.id.present ? data.id.value : this.id,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MyBookingsTableData(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('purpose: $purpose, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    roomId,
    date,
    createdAt,
    startTime,
    endTime,
    purpose,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MyBookingsTableData &&
          other.id == this.id &&
          other.roomId == this.roomId &&
          other.date == this.date &&
          other.createdAt == this.createdAt &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.purpose == this.purpose &&
          other.status == this.status);
}

class MyBookingsTableCompanion extends UpdateCompanion<MyBookingsTableData> {
  final Value<String> id;
  final Value<String> roomId;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<String> purpose;
  final Value<String> status;
  final Value<int> rowid;
  const MyBookingsTableCompanion({
    this.id = const Value.absent(),
    this.roomId = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.purpose = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MyBookingsTableCompanion.insert({
    required String id,
    required String roomId,
    required DateTime date,
    required DateTime createdAt,
    required String startTime,
    required String endTime,
    required String purpose,
    required String status,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       roomId = Value(roomId),
       date = Value(date),
       createdAt = Value(createdAt),
       startTime = Value(startTime),
       endTime = Value(endTime),
       purpose = Value(purpose),
       status = Value(status);
  static Insertable<MyBookingsTableData> custom({
    Expression<String>? id,
    Expression<String>? roomId,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<String>? purpose,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomId != null) 'room_id': roomId,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (purpose != null) 'purpose': purpose,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MyBookingsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? roomId,
    Value<DateTime>? date,
    Value<DateTime>? createdAt,
    Value<String>? startTime,
    Value<String>? endTime,
    Value<String>? purpose,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return MyBookingsTableCompanion(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MyBookingsTableCompanion(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('purpose: $purpose, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MyBookingsTableTable myBookingsTable = $MyBookingsTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [myBookingsTable];
}

typedef $$MyBookingsTableTableCreateCompanionBuilder =
    MyBookingsTableCompanion Function({
      required String id,
      required String roomId,
      required DateTime date,
      required DateTime createdAt,
      required String startTime,
      required String endTime,
      required String purpose,
      required String status,
      Value<int> rowid,
    });
typedef $$MyBookingsTableTableUpdateCompanionBuilder =
    MyBookingsTableCompanion Function({
      Value<String> id,
      Value<String> roomId,
      Value<DateTime> date,
      Value<DateTime> createdAt,
      Value<String> startTime,
      Value<String> endTime,
      Value<String> purpose,
      Value<String> status,
      Value<int> rowid,
    });

class $$MyBookingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $MyBookingsTableTable> {
  $$MyBookingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MyBookingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MyBookingsTableTable> {
  $$MyBookingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MyBookingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MyBookingsTableTable> {
  $$MyBookingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$MyBookingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MyBookingsTableTable,
          MyBookingsTableData,
          $$MyBookingsTableTableFilterComposer,
          $$MyBookingsTableTableOrderingComposer,
          $$MyBookingsTableTableAnnotationComposer,
          $$MyBookingsTableTableCreateCompanionBuilder,
          $$MyBookingsTableTableUpdateCompanionBuilder,
          (
            MyBookingsTableData,
            BaseReferences<
              _$AppDatabase,
              $MyBookingsTableTable,
              MyBookingsTableData
            >,
          ),
          MyBookingsTableData,
          PrefetchHooks Function()
        > {
  $$MyBookingsTableTableTableManager(
    _$AppDatabase db,
    $MyBookingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MyBookingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MyBookingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MyBookingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> roomId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> startTime = const Value.absent(),
                Value<String> endTime = const Value.absent(),
                Value<String> purpose = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MyBookingsTableCompanion(
                id: id,
                roomId: roomId,
                date: date,
                createdAt: createdAt,
                startTime: startTime,
                endTime: endTime,
                purpose: purpose,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String roomId,
                required DateTime date,
                required DateTime createdAt,
                required String startTime,
                required String endTime,
                required String purpose,
                required String status,
                Value<int> rowid = const Value.absent(),
              }) => MyBookingsTableCompanion.insert(
                id: id,
                roomId: roomId,
                date: date,
                createdAt: createdAt,
                startTime: startTime,
                endTime: endTime,
                purpose: purpose,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MyBookingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MyBookingsTableTable,
      MyBookingsTableData,
      $$MyBookingsTableTableFilterComposer,
      $$MyBookingsTableTableOrderingComposer,
      $$MyBookingsTableTableAnnotationComposer,
      $$MyBookingsTableTableCreateCompanionBuilder,
      $$MyBookingsTableTableUpdateCompanionBuilder,
      (
        MyBookingsTableData,
        BaseReferences<
          _$AppDatabase,
          $MyBookingsTableTable,
          MyBookingsTableData
        >,
      ),
      MyBookingsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MyBookingsTableTableTableManager get myBookingsTable =>
      $$MyBookingsTableTableTableManager(_db, _db.myBookingsTable);
}
