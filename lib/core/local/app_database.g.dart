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

class $FavoriteRoomsTableTable extends FavoriteRoomsTable
    with TableInfo<$FavoriteRoomsTableTable, FavoriteRoomsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteRoomsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _buildingCodeMeta = const VerificationMeta(
    'buildingCode',
  );
  @override
  late final GeneratedColumn<String> buildingCode = GeneratedColumn<String>(
    'building_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _buildingNameMeta = const VerificationMeta(
    'buildingName',
  );
  @override
  late final GeneratedColumn<String> buildingName = GeneratedColumn<String>(
    'building_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roomNumberMeta = const VerificationMeta(
    'roomNumber',
  );
  @override
  late final GeneratedColumn<String> roomNumber = GeneratedColumn<String>(
    'room_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capacityMeta = const VerificationMeta(
    'capacity',
  );
  @override
  late final GeneratedColumn<int> capacity = GeneratedColumn<int>(
    'capacity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reliabilityMeta = const VerificationMeta(
    'reliability',
  );
  @override
  late final GeneratedColumn<double> reliability = GeneratedColumn<double>(
    'reliability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _utilitiesJsonMeta = const VerificationMeta(
    'utilitiesJson',
  );
  @override
  late final GeneratedColumn<String> utilitiesJson = GeneratedColumn<String>(
    'utilities_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('clean'),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    roomId,
    buildingCode,
    buildingName,
    roomNumber,
    capacity,
    reliability,
    utilitiesJson,
    syncState,
    lastError,
    savedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_rooms';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteRoomsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('building_code')) {
      context.handle(
        _buildingCodeMeta,
        buildingCode.isAcceptableOrUnknown(
          data['building_code']!,
          _buildingCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_buildingCodeMeta);
    }
    if (data.containsKey('building_name')) {
      context.handle(
        _buildingNameMeta,
        buildingName.isAcceptableOrUnknown(
          data['building_name']!,
          _buildingNameMeta,
        ),
      );
    }
    if (data.containsKey('room_number')) {
      context.handle(
        _roomNumberMeta,
        roomNumber.isAcceptableOrUnknown(data['room_number']!, _roomNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_roomNumberMeta);
    }
    if (data.containsKey('capacity')) {
      context.handle(
        _capacityMeta,
        capacity.isAcceptableOrUnknown(data['capacity']!, _capacityMeta),
      );
    } else if (isInserting) {
      context.missing(_capacityMeta);
    }
    if (data.containsKey('reliability')) {
      context.handle(
        _reliabilityMeta,
        reliability.isAcceptableOrUnknown(
          data['reliability']!,
          _reliabilityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reliabilityMeta);
    }
    if (data.containsKey('utilities_json')) {
      context.handle(
        _utilitiesJsonMeta,
        utilitiesJson.isAcceptableOrUnknown(
          data['utilities_json']!,
          _utilitiesJsonMeta,
        ),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {roomId};
  @override
  FavoriteRoomsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteRoomsTableData(
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      )!,
      buildingCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}building_code'],
      )!,
      buildingName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}building_name'],
      ),
      roomNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_number'],
      )!,
      capacity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capacity'],
      )!,
      reliability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reliability'],
      )!,
      utilitiesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}utilities_json'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FavoriteRoomsTableTable createAlias(String alias) {
    return $FavoriteRoomsTableTable(attachedDatabase, alias);
  }
}

class FavoriteRoomsTableData extends DataClass
    implements Insertable<FavoriteRoomsTableData> {
  final String roomId;
  final String buildingCode;
  final String? buildingName;
  final String roomNumber;
  final int capacity;
  final double reliability;
  final String utilitiesJson;
  final String syncState;
  final String? lastError;
  final DateTime savedAt;
  final DateTime updatedAt;
  const FavoriteRoomsTableData({
    required this.roomId,
    required this.buildingCode,
    this.buildingName,
    required this.roomNumber,
    required this.capacity,
    required this.reliability,
    required this.utilitiesJson,
    required this.syncState,
    this.lastError,
    required this.savedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['room_id'] = Variable<String>(roomId);
    map['building_code'] = Variable<String>(buildingCode);
    if (!nullToAbsent || buildingName != null) {
      map['building_name'] = Variable<String>(buildingName);
    }
    map['room_number'] = Variable<String>(roomNumber);
    map['capacity'] = Variable<int>(capacity);
    map['reliability'] = Variable<double>(reliability);
    map['utilities_json'] = Variable<String>(utilitiesJson);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['saved_at'] = Variable<DateTime>(savedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FavoriteRoomsTableCompanion toCompanion(bool nullToAbsent) {
    return FavoriteRoomsTableCompanion(
      roomId: Value(roomId),
      buildingCode: Value(buildingCode),
      buildingName: buildingName == null && nullToAbsent
          ? const Value.absent()
          : Value(buildingName),
      roomNumber: Value(roomNumber),
      capacity: Value(capacity),
      reliability: Value(reliability),
      utilitiesJson: Value(utilitiesJson),
      syncState: Value(syncState),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      savedAt: Value(savedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FavoriteRoomsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteRoomsTableData(
      roomId: serializer.fromJson<String>(json['roomId']),
      buildingCode: serializer.fromJson<String>(json['buildingCode']),
      buildingName: serializer.fromJson<String?>(json['buildingName']),
      roomNumber: serializer.fromJson<String>(json['roomNumber']),
      capacity: serializer.fromJson<int>(json['capacity']),
      reliability: serializer.fromJson<double>(json['reliability']),
      utilitiesJson: serializer.fromJson<String>(json['utilitiesJson']),
      syncState: serializer.fromJson<String>(json['syncState']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'roomId': serializer.toJson<String>(roomId),
      'buildingCode': serializer.toJson<String>(buildingCode),
      'buildingName': serializer.toJson<String?>(buildingName),
      'roomNumber': serializer.toJson<String>(roomNumber),
      'capacity': serializer.toJson<int>(capacity),
      'reliability': serializer.toJson<double>(reliability),
      'utilitiesJson': serializer.toJson<String>(utilitiesJson),
      'syncState': serializer.toJson<String>(syncState),
      'lastError': serializer.toJson<String?>(lastError),
      'savedAt': serializer.toJson<DateTime>(savedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FavoriteRoomsTableData copyWith({
    String? roomId,
    String? buildingCode,
    Value<String?> buildingName = const Value.absent(),
    String? roomNumber,
    int? capacity,
    double? reliability,
    String? utilitiesJson,
    String? syncState,
    Value<String?> lastError = const Value.absent(),
    DateTime? savedAt,
    DateTime? updatedAt,
  }) => FavoriteRoomsTableData(
    roomId: roomId ?? this.roomId,
    buildingCode: buildingCode ?? this.buildingCode,
    buildingName: buildingName.present ? buildingName.value : this.buildingName,
    roomNumber: roomNumber ?? this.roomNumber,
    capacity: capacity ?? this.capacity,
    reliability: reliability ?? this.reliability,
    utilitiesJson: utilitiesJson ?? this.utilitiesJson,
    syncState: syncState ?? this.syncState,
    lastError: lastError.present ? lastError.value : this.lastError,
    savedAt: savedAt ?? this.savedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FavoriteRoomsTableData copyWithCompanion(FavoriteRoomsTableCompanion data) {
    return FavoriteRoomsTableData(
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      buildingCode: data.buildingCode.present
          ? data.buildingCode.value
          : this.buildingCode,
      buildingName: data.buildingName.present
          ? data.buildingName.value
          : this.buildingName,
      roomNumber: data.roomNumber.present
          ? data.roomNumber.value
          : this.roomNumber,
      capacity: data.capacity.present ? data.capacity.value : this.capacity,
      reliability: data.reliability.present
          ? data.reliability.value
          : this.reliability,
      utilitiesJson: data.utilitiesJson.present
          ? data.utilitiesJson.value
          : this.utilitiesJson,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRoomsTableData(')
          ..write('roomId: $roomId, ')
          ..write('buildingCode: $buildingCode, ')
          ..write('buildingName: $buildingName, ')
          ..write('roomNumber: $roomNumber, ')
          ..write('capacity: $capacity, ')
          ..write('reliability: $reliability, ')
          ..write('utilitiesJson: $utilitiesJson, ')
          ..write('syncState: $syncState, ')
          ..write('lastError: $lastError, ')
          ..write('savedAt: $savedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    roomId,
    buildingCode,
    buildingName,
    roomNumber,
    capacity,
    reliability,
    utilitiesJson,
    syncState,
    lastError,
    savedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteRoomsTableData &&
          other.roomId == this.roomId &&
          other.buildingCode == this.buildingCode &&
          other.buildingName == this.buildingName &&
          other.roomNumber == this.roomNumber &&
          other.capacity == this.capacity &&
          other.reliability == this.reliability &&
          other.utilitiesJson == this.utilitiesJson &&
          other.syncState == this.syncState &&
          other.lastError == this.lastError &&
          other.savedAt == this.savedAt &&
          other.updatedAt == this.updatedAt);
}

class FavoriteRoomsTableCompanion
    extends UpdateCompanion<FavoriteRoomsTableData> {
  final Value<String> roomId;
  final Value<String> buildingCode;
  final Value<String?> buildingName;
  final Value<String> roomNumber;
  final Value<int> capacity;
  final Value<double> reliability;
  final Value<String> utilitiesJson;
  final Value<String> syncState;
  final Value<String?> lastError;
  final Value<DateTime> savedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FavoriteRoomsTableCompanion({
    this.roomId = const Value.absent(),
    this.buildingCode = const Value.absent(),
    this.buildingName = const Value.absent(),
    this.roomNumber = const Value.absent(),
    this.capacity = const Value.absent(),
    this.reliability = const Value.absent(),
    this.utilitiesJson = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastError = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoriteRoomsTableCompanion.insert({
    required String roomId,
    required String buildingCode,
    this.buildingName = const Value.absent(),
    required String roomNumber,
    required int capacity,
    required double reliability,
    this.utilitiesJson = const Value.absent(),
    this.syncState = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime savedAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : roomId = Value(roomId),
       buildingCode = Value(buildingCode),
       roomNumber = Value(roomNumber),
       capacity = Value(capacity),
       reliability = Value(reliability),
       savedAt = Value(savedAt),
       updatedAt = Value(updatedAt);
  static Insertable<FavoriteRoomsTableData> custom({
    Expression<String>? roomId,
    Expression<String>? buildingCode,
    Expression<String>? buildingName,
    Expression<String>? roomNumber,
    Expression<int>? capacity,
    Expression<double>? reliability,
    Expression<String>? utilitiesJson,
    Expression<String>? syncState,
    Expression<String>? lastError,
    Expression<DateTime>? savedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (roomId != null) 'room_id': roomId,
      if (buildingCode != null) 'building_code': buildingCode,
      if (buildingName != null) 'building_name': buildingName,
      if (roomNumber != null) 'room_number': roomNumber,
      if (capacity != null) 'capacity': capacity,
      if (reliability != null) 'reliability': reliability,
      if (utilitiesJson != null) 'utilities_json': utilitiesJson,
      if (syncState != null) 'sync_state': syncState,
      if (lastError != null) 'last_error': lastError,
      if (savedAt != null) 'saved_at': savedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoriteRoomsTableCompanion copyWith({
    Value<String>? roomId,
    Value<String>? buildingCode,
    Value<String?>? buildingName,
    Value<String>? roomNumber,
    Value<int>? capacity,
    Value<double>? reliability,
    Value<String>? utilitiesJson,
    Value<String>? syncState,
    Value<String?>? lastError,
    Value<DateTime>? savedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FavoriteRoomsTableCompanion(
      roomId: roomId ?? this.roomId,
      buildingCode: buildingCode ?? this.buildingCode,
      buildingName: buildingName ?? this.buildingName,
      roomNumber: roomNumber ?? this.roomNumber,
      capacity: capacity ?? this.capacity,
      reliability: reliability ?? this.reliability,
      utilitiesJson: utilitiesJson ?? this.utilitiesJson,
      syncState: syncState ?? this.syncState,
      lastError: lastError ?? this.lastError,
      savedAt: savedAt ?? this.savedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (buildingCode.present) {
      map['building_code'] = Variable<String>(buildingCode.value);
    }
    if (buildingName.present) {
      map['building_name'] = Variable<String>(buildingName.value);
    }
    if (roomNumber.present) {
      map['room_number'] = Variable<String>(roomNumber.value);
    }
    if (capacity.present) {
      map['capacity'] = Variable<int>(capacity.value);
    }
    if (reliability.present) {
      map['reliability'] = Variable<double>(reliability.value);
    }
    if (utilitiesJson.present) {
      map['utilities_json'] = Variable<String>(utilitiesJson.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRoomsTableCompanion(')
          ..write('roomId: $roomId, ')
          ..write('buildingCode: $buildingCode, ')
          ..write('buildingName: $buildingName, ')
          ..write('roomNumber: $roomNumber, ')
          ..write('capacity: $capacity, ')
          ..write('reliability: $reliability, ')
          ..write('utilitiesJson: $utilitiesJson, ')
          ..write('syncState: $syncState, ')
          ..write('lastError: $lastError, ')
          ..write('savedAt: $savedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduleClassesTableTable extends ScheduleClassesTable
    with TableInfo<$ScheduleClassesTableTable, ScheduleClassesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleClassesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<String> classId = GeneratedColumn<String>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userEmailMeta = const VerificationMeta(
    'userEmail',
  );
  @override
  late final GeneratedColumn<String> userEmail = GeneratedColumn<String>(
    'user_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationTextMeta = const VerificationMeta(
    'locationText',
  );
  @override
  late final GeneratedColumn<String> locationText = GeneratedColumn<String>(
    'location_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
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
  static const VerificationMeta _weekdaysJsonMeta = const VerificationMeta(
    'weekdaysJson',
  );
  @override
  late final GeneratedColumn<String> weekdaysJson = GeneratedColumn<String>(
    'weekdays_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    classId,
    userEmail,
    title,
    locationText,
    roomId,
    startDate,
    endDate,
    startTime,
    endTime,
    weekdaysJson,
    syncState,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_classes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleClassesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('user_email')) {
      context.handle(
        _userEmailMeta,
        userEmail.isAcceptableOrUnknown(data['user_email']!, _userEmailMeta),
      );
    } else if (isInserting) {
      context.missing(_userEmailMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('location_text')) {
      context.handle(
        _locationTextMeta,
        locationText.isAcceptableOrUnknown(
          data['location_text']!,
          _locationTextMeta,
        ),
      );
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    } else if (isInserting) {
      context.missing(_endDateMeta);
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
    if (data.containsKey('weekdays_json')) {
      context.handle(
        _weekdaysJsonMeta,
        weekdaysJson.isAcceptableOrUnknown(
          data['weekdays_json']!,
          _weekdaysJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weekdaysJsonMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {classId};
  @override
  ScheduleClassesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleClassesTableData(
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_id'],
      )!,
      userEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_email'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      locationText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_text'],
      ),
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_time'],
      )!,
      weekdaysJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weekdays_json'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ScheduleClassesTableTable createAlias(String alias) {
    return $ScheduleClassesTableTable(attachedDatabase, alias);
  }
}

class ScheduleClassesTableData extends DataClass
    implements Insertable<ScheduleClassesTableData> {
  final String classId;
  final String userEmail;
  final String? title;
  final String? locationText;
  final String? roomId;
  final DateTime startDate;
  final DateTime endDate;
  final String startTime;
  final String endTime;
  final String weekdaysJson;
  final String syncState;
  final DateTime updatedAt;
  const ScheduleClassesTableData({
    required this.classId,
    required this.userEmail,
    this.title,
    this.locationText,
    this.roomId,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.weekdaysJson,
    required this.syncState,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['class_id'] = Variable<String>(classId);
    map['user_email'] = Variable<String>(userEmail);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || locationText != null) {
      map['location_text'] = Variable<String>(locationText);
    }
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<String>(roomId);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['start_time'] = Variable<String>(startTime);
    map['end_time'] = Variable<String>(endTime);
    map['weekdays_json'] = Variable<String>(weekdaysJson);
    map['sync_state'] = Variable<String>(syncState);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ScheduleClassesTableCompanion toCompanion(bool nullToAbsent) {
    return ScheduleClassesTableCompanion(
      classId: Value(classId),
      userEmail: Value(userEmail),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      locationText: locationText == null && nullToAbsent
          ? const Value.absent()
          : Value(locationText),
      roomId: roomId == null && nullToAbsent
          ? const Value.absent()
          : Value(roomId),
      startDate: Value(startDate),
      endDate: Value(endDate),
      startTime: Value(startTime),
      endTime: Value(endTime),
      weekdaysJson: Value(weekdaysJson),
      syncState: Value(syncState),
      updatedAt: Value(updatedAt),
    );
  }

  factory ScheduleClassesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleClassesTableData(
      classId: serializer.fromJson<String>(json['classId']),
      userEmail: serializer.fromJson<String>(json['userEmail']),
      title: serializer.fromJson<String?>(json['title']),
      locationText: serializer.fromJson<String?>(json['locationText']),
      roomId: serializer.fromJson<String?>(json['roomId']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
      weekdaysJson: serializer.fromJson<String>(json['weekdaysJson']),
      syncState: serializer.fromJson<String>(json['syncState']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'classId': serializer.toJson<String>(classId),
      'userEmail': serializer.toJson<String>(userEmail),
      'title': serializer.toJson<String?>(title),
      'locationText': serializer.toJson<String?>(locationText),
      'roomId': serializer.toJson<String?>(roomId),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
      'weekdaysJson': serializer.toJson<String>(weekdaysJson),
      'syncState': serializer.toJson<String>(syncState),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ScheduleClassesTableData copyWith({
    String? classId,
    String? userEmail,
    Value<String?> title = const Value.absent(),
    Value<String?> locationText = const Value.absent(),
    Value<String?> roomId = const Value.absent(),
    DateTime? startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    String? weekdaysJson,
    String? syncState,
    DateTime? updatedAt,
  }) => ScheduleClassesTableData(
    classId: classId ?? this.classId,
    userEmail: userEmail ?? this.userEmail,
    title: title.present ? title.value : this.title,
    locationText: locationText.present ? locationText.value : this.locationText,
    roomId: roomId.present ? roomId.value : this.roomId,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    weekdaysJson: weekdaysJson ?? this.weekdaysJson,
    syncState: syncState ?? this.syncState,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ScheduleClassesTableData copyWithCompanion(
    ScheduleClassesTableCompanion data,
  ) {
    return ScheduleClassesTableData(
      classId: data.classId.present ? data.classId.value : this.classId,
      userEmail: data.userEmail.present ? data.userEmail.value : this.userEmail,
      title: data.title.present ? data.title.value : this.title,
      locationText: data.locationText.present
          ? data.locationText.value
          : this.locationText,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      weekdaysJson: data.weekdaysJson.present
          ? data.weekdaysJson.value
          : this.weekdaysJson,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleClassesTableData(')
          ..write('classId: $classId, ')
          ..write('userEmail: $userEmail, ')
          ..write('title: $title, ')
          ..write('locationText: $locationText, ')
          ..write('roomId: $roomId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('weekdaysJson: $weekdaysJson, ')
          ..write('syncState: $syncState, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    classId,
    userEmail,
    title,
    locationText,
    roomId,
    startDate,
    endDate,
    startTime,
    endTime,
    weekdaysJson,
    syncState,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleClassesTableData &&
          other.classId == this.classId &&
          other.userEmail == this.userEmail &&
          other.title == this.title &&
          other.locationText == this.locationText &&
          other.roomId == this.roomId &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.weekdaysJson == this.weekdaysJson &&
          other.syncState == this.syncState &&
          other.updatedAt == this.updatedAt);
}

class ScheduleClassesTableCompanion
    extends UpdateCompanion<ScheduleClassesTableData> {
  final Value<String> classId;
  final Value<String> userEmail;
  final Value<String?> title;
  final Value<String?> locationText;
  final Value<String?> roomId;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<String> weekdaysJson;
  final Value<String> syncState;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ScheduleClassesTableCompanion({
    this.classId = const Value.absent(),
    this.userEmail = const Value.absent(),
    this.title = const Value.absent(),
    this.locationText = const Value.absent(),
    this.roomId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.weekdaysJson = const Value.absent(),
    this.syncState = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduleClassesTableCompanion.insert({
    required String classId,
    required String userEmail,
    this.title = const Value.absent(),
    this.locationText = const Value.absent(),
    this.roomId = const Value.absent(),
    required DateTime startDate,
    required DateTime endDate,
    required String startTime,
    required String endTime,
    required String weekdaysJson,
    this.syncState = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : classId = Value(classId),
       userEmail = Value(userEmail),
       startDate = Value(startDate),
       endDate = Value(endDate),
       startTime = Value(startTime),
       endTime = Value(endTime),
       weekdaysJson = Value(weekdaysJson),
       updatedAt = Value(updatedAt);
  static Insertable<ScheduleClassesTableData> custom({
    Expression<String>? classId,
    Expression<String>? userEmail,
    Expression<String>? title,
    Expression<String>? locationText,
    Expression<String>? roomId,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<String>? weekdaysJson,
    Expression<String>? syncState,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (classId != null) 'class_id': classId,
      if (userEmail != null) 'user_email': userEmail,
      if (title != null) 'title': title,
      if (locationText != null) 'location_text': locationText,
      if (roomId != null) 'room_id': roomId,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (weekdaysJson != null) 'weekdays_json': weekdaysJson,
      if (syncState != null) 'sync_state': syncState,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduleClassesTableCompanion copyWith({
    Value<String>? classId,
    Value<String>? userEmail,
    Value<String?>? title,
    Value<String?>? locationText,
    Value<String?>? roomId,
    Value<DateTime>? startDate,
    Value<DateTime>? endDate,
    Value<String>? startTime,
    Value<String>? endTime,
    Value<String>? weekdaysJson,
    Value<String>? syncState,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ScheduleClassesTableCompanion(
      classId: classId ?? this.classId,
      userEmail: userEmail ?? this.userEmail,
      title: title ?? this.title,
      locationText: locationText ?? this.locationText,
      roomId: roomId ?? this.roomId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      weekdaysJson: weekdaysJson ?? this.weekdaysJson,
      syncState: syncState ?? this.syncState,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (classId.present) {
      map['class_id'] = Variable<String>(classId.value);
    }
    if (userEmail.present) {
      map['user_email'] = Variable<String>(userEmail.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (locationText.present) {
      map['location_text'] = Variable<String>(locationText.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (weekdaysJson.present) {
      map['weekdays_json'] = Variable<String>(weekdaysJson.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleClassesTableCompanion(')
          ..write('classId: $classId, ')
          ..write('userEmail: $userEmail, ')
          ..write('title: $title, ')
          ..write('locationText: $locationText, ')
          ..write('roomId: $roomId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('weekdaysJson: $weekdaysJson, ')
          ..write('syncState: $syncState, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoriteMutationsTableTable extends FavoriteMutationsTable
    with TableInfo<$FavoriteMutationsTableTable, FavoriteMutationsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteMutationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
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
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    roomId,
    operation,
    attemptCount,
    lastError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_mutations';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteMutationsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {opId};
  @override
  FavoriteMutationsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteMutationsTableData(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FavoriteMutationsTableTable createAlias(String alias) {
    return $FavoriteMutationsTableTable(attachedDatabase, alias);
  }
}

class FavoriteMutationsTableData extends DataClass
    implements Insertable<FavoriteMutationsTableData> {
  final String opId;
  final String roomId;
  final String operation;
  final int attemptCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FavoriteMutationsTableData({
    required this.opId,
    required this.roomId,
    required this.operation,
    required this.attemptCount,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['op_id'] = Variable<String>(opId);
    map['room_id'] = Variable<String>(roomId);
    map['operation'] = Variable<String>(operation);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FavoriteMutationsTableCompanion toCompanion(bool nullToAbsent) {
    return FavoriteMutationsTableCompanion(
      opId: Value(opId),
      roomId: Value(roomId),
      operation: Value(operation),
      attemptCount: Value(attemptCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FavoriteMutationsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteMutationsTableData(
      opId: serializer.fromJson<String>(json['opId']),
      roomId: serializer.fromJson<String>(json['roomId']),
      operation: serializer.fromJson<String>(json['operation']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String>(opId),
      'roomId': serializer.toJson<String>(roomId),
      'operation': serializer.toJson<String>(operation),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FavoriteMutationsTableData copyWith({
    String? opId,
    String? roomId,
    String? operation,
    int? attemptCount,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => FavoriteMutationsTableData(
    opId: opId ?? this.opId,
    roomId: roomId ?? this.roomId,
    operation: operation ?? this.operation,
    attemptCount: attemptCount ?? this.attemptCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FavoriteMutationsTableData copyWithCompanion(
    FavoriteMutationsTableCompanion data,
  ) {
    return FavoriteMutationsTableData(
      opId: data.opId.present ? data.opId.value : this.opId,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      operation: data.operation.present ? data.operation.value : this.operation,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteMutationsTableData(')
          ..write('opId: $opId, ')
          ..write('roomId: $roomId, ')
          ..write('operation: $operation, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    opId,
    roomId,
    operation,
    attemptCount,
    lastError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteMutationsTableData &&
          other.opId == this.opId &&
          other.roomId == this.roomId &&
          other.operation == this.operation &&
          other.attemptCount == this.attemptCount &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FavoriteMutationsTableCompanion
    extends UpdateCompanion<FavoriteMutationsTableData> {
  final Value<String> opId;
  final Value<String> roomId;
  final Value<String> operation;
  final Value<int> attemptCount;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FavoriteMutationsTableCompanion({
    this.opId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.operation = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoriteMutationsTableCompanion.insert({
    required String opId,
    required String roomId,
    required String operation,
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : opId = Value(opId),
       roomId = Value(roomId),
       operation = Value(operation),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FavoriteMutationsTableData> custom({
    Expression<String>? opId,
    Expression<String>? roomId,
    Expression<String>? operation,
    Expression<int>? attemptCount,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (roomId != null) 'room_id': roomId,
      if (operation != null) 'operation': operation,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoriteMutationsTableCompanion copyWith({
    Value<String>? opId,
    Value<String>? roomId,
    Value<String>? operation,
    Value<int>? attemptCount,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FavoriteMutationsTableCompanion(
      opId: opId ?? this.opId,
      roomId: roomId ?? this.roomId,
      operation: operation ?? this.operation,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteMutationsTableCompanion(')
          ..write('opId: $opId, ')
          ..write('roomId: $roomId, ')
          ..write('operation: $operation, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedPathsTableTable extends CachedPathsTable
    with TableInfo<$CachedPathsTableTable, CachedPathsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedPathsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originTextMeta = const VerificationMeta(
    'originText',
  );
  @override
  late final GeneratedColumn<String> originText = GeneratedColumn<String>(
    'origin_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destTextMeta = const VerificationMeta(
    'destText',
  );
  @override
  late final GeneratedColumn<String> destText = GeneratedColumn<String>(
    'dest_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepsJsonMeta = const VerificationMeta(
    'stepsJson',
  );
  @override
  late final GeneratedColumn<String> stepsJson = GeneratedColumn<String>(
    'steps_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalTimeSecondsMeta = const VerificationMeta(
    'totalTimeSeconds',
  );
  @override
  late final GeneratedColumn<int> totalTimeSeconds = GeneratedColumn<int>(
    'total_time_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accessedAtMeta = const VerificationMeta(
    'accessedAt',
  );
  @override
  late final GeneratedColumn<int> accessedAt = GeneratedColumn<int>(
    'accessed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    cacheKey,
    originText,
    destText,
    stepsJson,
    totalTimeSeconds,
    accessedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_paths';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedPathsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('origin_text')) {
      context.handle(
        _originTextMeta,
        originText.isAcceptableOrUnknown(data['origin_text']!, _originTextMeta),
      );
    } else if (isInserting) {
      context.missing(_originTextMeta);
    }
    if (data.containsKey('dest_text')) {
      context.handle(
        _destTextMeta,
        destText.isAcceptableOrUnknown(data['dest_text']!, _destTextMeta),
      );
    } else if (isInserting) {
      context.missing(_destTextMeta);
    }
    if (data.containsKey('steps_json')) {
      context.handle(
        _stepsJsonMeta,
        stepsJson.isAcceptableOrUnknown(data['steps_json']!, _stepsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_stepsJsonMeta);
    }
    if (data.containsKey('total_time_seconds')) {
      context.handle(
        _totalTimeSecondsMeta,
        totalTimeSeconds.isAcceptableOrUnknown(
          data['total_time_seconds']!,
          _totalTimeSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalTimeSecondsMeta);
    }
    if (data.containsKey('accessed_at')) {
      context.handle(
        _accessedAtMeta,
        accessedAt.isAcceptableOrUnknown(data['accessed_at']!, _accessedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_accessedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  CachedPathsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedPathsTableData(
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      originText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_text'],
      )!,
      destText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dest_text'],
      )!,
      stepsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}steps_json'],
      )!,
      totalTimeSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_time_seconds'],
      )!,
      accessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accessed_at'],
      )!,
    );
  }

  @override
  $CachedPathsTableTable createAlias(String alias) {
    return $CachedPathsTableTable(attachedDatabase, alias);
  }
}

class CachedPathsTableData extends DataClass
    implements Insertable<CachedPathsTableData> {
  final String cacheKey;
  final String originText;
  final String destText;
  final String stepsJson;
  final int totalTimeSeconds;
  final int accessedAt;
  const CachedPathsTableData({
    required this.cacheKey,
    required this.originText,
    required this.destText,
    required this.stepsJson,
    required this.totalTimeSeconds,
    required this.accessedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    map['origin_text'] = Variable<String>(originText);
    map['dest_text'] = Variable<String>(destText);
    map['steps_json'] = Variable<String>(stepsJson);
    map['total_time_seconds'] = Variable<int>(totalTimeSeconds);
    map['accessed_at'] = Variable<int>(accessedAt);
    return map;
  }

  CachedPathsTableCompanion toCompanion(bool nullToAbsent) {
    return CachedPathsTableCompanion(
      cacheKey: Value(cacheKey),
      originText: Value(originText),
      destText: Value(destText),
      stepsJson: Value(stepsJson),
      totalTimeSeconds: Value(totalTimeSeconds),
      accessedAt: Value(accessedAt),
    );
  }

  factory CachedPathsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedPathsTableData(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      originText: serializer.fromJson<String>(json['originText']),
      destText: serializer.fromJson<String>(json['destText']),
      stepsJson: serializer.fromJson<String>(json['stepsJson']),
      totalTimeSeconds: serializer.fromJson<int>(json['totalTimeSeconds']),
      accessedAt: serializer.fromJson<int>(json['accessedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'originText': serializer.toJson<String>(originText),
      'destText': serializer.toJson<String>(destText),
      'stepsJson': serializer.toJson<String>(stepsJson),
      'totalTimeSeconds': serializer.toJson<int>(totalTimeSeconds),
      'accessedAt': serializer.toJson<int>(accessedAt),
    };
  }

  CachedPathsTableData copyWith({
    String? cacheKey,
    String? originText,
    String? destText,
    String? stepsJson,
    int? totalTimeSeconds,
    int? accessedAt,
  }) => CachedPathsTableData(
    cacheKey: cacheKey ?? this.cacheKey,
    originText: originText ?? this.originText,
    destText: destText ?? this.destText,
    stepsJson: stepsJson ?? this.stepsJson,
    totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
    accessedAt: accessedAt ?? this.accessedAt,
  );
  CachedPathsTableData copyWithCompanion(CachedPathsTableCompanion data) {
    return CachedPathsTableData(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      originText: data.originText.present
          ? data.originText.value
          : this.originText,
      destText: data.destText.present ? data.destText.value : this.destText,
      stepsJson: data.stepsJson.present ? data.stepsJson.value : this.stepsJson,
      totalTimeSeconds: data.totalTimeSeconds.present
          ? data.totalTimeSeconds.value
          : this.totalTimeSeconds,
      accessedAt: data.accessedAt.present
          ? data.accessedAt.value
          : this.accessedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedPathsTableData(')
          ..write('cacheKey: $cacheKey, ')
          ..write('originText: $originText, ')
          ..write('destText: $destText, ')
          ..write('stepsJson: $stepsJson, ')
          ..write('totalTimeSeconds: $totalTimeSeconds, ')
          ..write('accessedAt: $accessedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    cacheKey,
    originText,
    destText,
    stepsJson,
    totalTimeSeconds,
    accessedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedPathsTableData &&
          other.cacheKey == this.cacheKey &&
          other.originText == this.originText &&
          other.destText == this.destText &&
          other.stepsJson == this.stepsJson &&
          other.totalTimeSeconds == this.totalTimeSeconds &&
          other.accessedAt == this.accessedAt);
}

class CachedPathsTableCompanion extends UpdateCompanion<CachedPathsTableData> {
  final Value<String> cacheKey;
  final Value<String> originText;
  final Value<String> destText;
  final Value<String> stepsJson;
  final Value<int> totalTimeSeconds;
  final Value<int> accessedAt;
  final Value<int> rowid;
  const CachedPathsTableCompanion({
    this.cacheKey = const Value.absent(),
    this.originText = const Value.absent(),
    this.destText = const Value.absent(),
    this.stepsJson = const Value.absent(),
    this.totalTimeSeconds = const Value.absent(),
    this.accessedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedPathsTableCompanion.insert({
    required String cacheKey,
    required String originText,
    required String destText,
    required String stepsJson,
    required int totalTimeSeconds,
    required int accessedAt,
    this.rowid = const Value.absent(),
  }) : cacheKey = Value(cacheKey),
       originText = Value(originText),
       destText = Value(destText),
       stepsJson = Value(stepsJson),
       totalTimeSeconds = Value(totalTimeSeconds),
       accessedAt = Value(accessedAt);
  static Insertable<CachedPathsTableData> custom({
    Expression<String>? cacheKey,
    Expression<String>? originText,
    Expression<String>? destText,
    Expression<String>? stepsJson,
    Expression<int>? totalTimeSeconds,
    Expression<int>? accessedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (originText != null) 'origin_text': originText,
      if (destText != null) 'dest_text': destText,
      if (stepsJson != null) 'steps_json': stepsJson,
      if (totalTimeSeconds != null) 'total_time_seconds': totalTimeSeconds,
      if (accessedAt != null) 'accessed_at': accessedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedPathsTableCompanion copyWith({
    Value<String>? cacheKey,
    Value<String>? originText,
    Value<String>? destText,
    Value<String>? stepsJson,
    Value<int>? totalTimeSeconds,
    Value<int>? accessedAt,
    Value<int>? rowid,
  }) {
    return CachedPathsTableCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      originText: originText ?? this.originText,
      destText: destText ?? this.destText,
      stepsJson: stepsJson ?? this.stepsJson,
      totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
      accessedAt: accessedAt ?? this.accessedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (originText.present) {
      map['origin_text'] = Variable<String>(originText.value);
    }
    if (destText.present) {
      map['dest_text'] = Variable<String>(destText.value);
    }
    if (stepsJson.present) {
      map['steps_json'] = Variable<String>(stepsJson.value);
    }
    if (totalTimeSeconds.present) {
      map['total_time_seconds'] = Variable<int>(totalTimeSeconds.value);
    }
    if (accessedAt.present) {
      map['accessed_at'] = Variable<int>(accessedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedPathsTableCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('originText: $originText, ')
          ..write('destText: $destText, ')
          ..write('stepsJson: $stepsJson, ')
          ..write('totalTimeSeconds: $totalTimeSeconds, ')
          ..write('accessedAt: $accessedAt, ')
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
  late final $FavoriteRoomsTableTable favoriteRoomsTable =
      $FavoriteRoomsTableTable(this);
  late final $ScheduleClassesTableTable scheduleClassesTable =
      $ScheduleClassesTableTable(this);
  late final $FavoriteMutationsTableTable favoriteMutationsTable =
      $FavoriteMutationsTableTable(this);
  late final $CachedPathsTableTable cachedPathsTable = $CachedPathsTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    myBookingsTable,
    favoriteRoomsTable,
    scheduleClassesTable,
    favoriteMutationsTable,
    cachedPathsTable,
  ];
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
typedef $$FavoriteRoomsTableTableCreateCompanionBuilder =
    FavoriteRoomsTableCompanion Function({
      required String roomId,
      required String buildingCode,
      Value<String?> buildingName,
      required String roomNumber,
      required int capacity,
      required double reliability,
      Value<String> utilitiesJson,
      Value<String> syncState,
      Value<String?> lastError,
      required DateTime savedAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$FavoriteRoomsTableTableUpdateCompanionBuilder =
    FavoriteRoomsTableCompanion Function({
      Value<String> roomId,
      Value<String> buildingCode,
      Value<String?> buildingName,
      Value<String> roomNumber,
      Value<int> capacity,
      Value<double> reliability,
      Value<String> utilitiesJson,
      Value<String> syncState,
      Value<String?> lastError,
      Value<DateTime> savedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$FavoriteRoomsTableTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteRoomsTableTable> {
  $$FavoriteRoomsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buildingCode => $composableBuilder(
    column: $table.buildingCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buildingName => $composableBuilder(
    column: $table.buildingName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomNumber => $composableBuilder(
    column: $table.roomNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get reliability => $composableBuilder(
    column: $table.reliability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get utilitiesJson => $composableBuilder(
    column: $table.utilitiesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteRoomsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteRoomsTableTable> {
  $$FavoriteRoomsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buildingCode => $composableBuilder(
    column: $table.buildingCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buildingName => $composableBuilder(
    column: $table.buildingName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomNumber => $composableBuilder(
    column: $table.roomNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get reliability => $composableBuilder(
    column: $table.reliability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get utilitiesJson => $composableBuilder(
    column: $table.utilitiesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteRoomsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteRoomsTableTable> {
  $$FavoriteRoomsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get buildingCode => $composableBuilder(
    column: $table.buildingCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get buildingName => $composableBuilder(
    column: $table.buildingName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get roomNumber => $composableBuilder(
    column: $table.roomNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get capacity =>
      $composableBuilder(column: $table.capacity, builder: (column) => column);

  GeneratedColumn<double> get reliability => $composableBuilder(
    column: $table.reliability,
    builder: (column) => column,
  );

  GeneratedColumn<String> get utilitiesJson => $composableBuilder(
    column: $table.utilitiesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FavoriteRoomsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoriteRoomsTableTable,
          FavoriteRoomsTableData,
          $$FavoriteRoomsTableTableFilterComposer,
          $$FavoriteRoomsTableTableOrderingComposer,
          $$FavoriteRoomsTableTableAnnotationComposer,
          $$FavoriteRoomsTableTableCreateCompanionBuilder,
          $$FavoriteRoomsTableTableUpdateCompanionBuilder,
          (
            FavoriteRoomsTableData,
            BaseReferences<
              _$AppDatabase,
              $FavoriteRoomsTableTable,
              FavoriteRoomsTableData
            >,
          ),
          FavoriteRoomsTableData,
          PrefetchHooks Function()
        > {
  $$FavoriteRoomsTableTableTableManager(
    _$AppDatabase db,
    $FavoriteRoomsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteRoomsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteRoomsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteRoomsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> roomId = const Value.absent(),
                Value<String> buildingCode = const Value.absent(),
                Value<String?> buildingName = const Value.absent(),
                Value<String> roomNumber = const Value.absent(),
                Value<int> capacity = const Value.absent(),
                Value<double> reliability = const Value.absent(),
                Value<String> utilitiesJson = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoriteRoomsTableCompanion(
                roomId: roomId,
                buildingCode: buildingCode,
                buildingName: buildingName,
                roomNumber: roomNumber,
                capacity: capacity,
                reliability: reliability,
                utilitiesJson: utilitiesJson,
                syncState: syncState,
                lastError: lastError,
                savedAt: savedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String roomId,
                required String buildingCode,
                Value<String?> buildingName = const Value.absent(),
                required String roomNumber,
                required int capacity,
                required double reliability,
                Value<String> utilitiesJson = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required DateTime savedAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FavoriteRoomsTableCompanion.insert(
                roomId: roomId,
                buildingCode: buildingCode,
                buildingName: buildingName,
                roomNumber: roomNumber,
                capacity: capacity,
                reliability: reliability,
                utilitiesJson: utilitiesJson,
                syncState: syncState,
                lastError: lastError,
                savedAt: savedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteRoomsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoriteRoomsTableTable,
      FavoriteRoomsTableData,
      $$FavoriteRoomsTableTableFilterComposer,
      $$FavoriteRoomsTableTableOrderingComposer,
      $$FavoriteRoomsTableTableAnnotationComposer,
      $$FavoriteRoomsTableTableCreateCompanionBuilder,
      $$FavoriteRoomsTableTableUpdateCompanionBuilder,
      (
        FavoriteRoomsTableData,
        BaseReferences<
          _$AppDatabase,
          $FavoriteRoomsTableTable,
          FavoriteRoomsTableData
        >,
      ),
      FavoriteRoomsTableData,
      PrefetchHooks Function()
    >;
typedef $$ScheduleClassesTableTableCreateCompanionBuilder =
    ScheduleClassesTableCompanion Function({
      required String classId,
      required String userEmail,
      Value<String?> title,
      Value<String?> locationText,
      Value<String?> roomId,
      required DateTime startDate,
      required DateTime endDate,
      required String startTime,
      required String endTime,
      required String weekdaysJson,
      Value<String> syncState,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ScheduleClassesTableTableUpdateCompanionBuilder =
    ScheduleClassesTableCompanion Function({
      Value<String> classId,
      Value<String> userEmail,
      Value<String?> title,
      Value<String?> locationText,
      Value<String?> roomId,
      Value<DateTime> startDate,
      Value<DateTime> endDate,
      Value<String> startTime,
      Value<String> endTime,
      Value<String> weekdaysJson,
      Value<String> syncState,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ScheduleClassesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduleClassesTableTable> {
  $$ScheduleClassesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userEmail => $composableBuilder(
    column: $table.userEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationText => $composableBuilder(
    column: $table.locationText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
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

  ColumnFilters<String> get weekdaysJson => $composableBuilder(
    column: $table.weekdaysJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScheduleClassesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduleClassesTableTable> {
  $$ScheduleClassesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userEmail => $composableBuilder(
    column: $table.userEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationText => $composableBuilder(
    column: $table.locationText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
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

  ColumnOrderings<String> get weekdaysJson => $composableBuilder(
    column: $table.weekdaysJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScheduleClassesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduleClassesTableTable> {
  $$ScheduleClassesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<String> get userEmail =>
      $composableBuilder(column: $table.userEmail, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get locationText => $composableBuilder(
    column: $table.locationText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get weekdaysJson => $composableBuilder(
    column: $table.weekdaysJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ScheduleClassesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduleClassesTableTable,
          ScheduleClassesTableData,
          $$ScheduleClassesTableTableFilterComposer,
          $$ScheduleClassesTableTableOrderingComposer,
          $$ScheduleClassesTableTableAnnotationComposer,
          $$ScheduleClassesTableTableCreateCompanionBuilder,
          $$ScheduleClassesTableTableUpdateCompanionBuilder,
          (
            ScheduleClassesTableData,
            BaseReferences<
              _$AppDatabase,
              $ScheduleClassesTableTable,
              ScheduleClassesTableData
            >,
          ),
          ScheduleClassesTableData,
          PrefetchHooks Function()
        > {
  $$ScheduleClassesTableTableTableManager(
    _$AppDatabase db,
    $ScheduleClassesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleClassesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleClassesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ScheduleClassesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> classId = const Value.absent(),
                Value<String> userEmail = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> locationText = const Value.absent(),
                Value<String?> roomId = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
                Value<String> startTime = const Value.absent(),
                Value<String> endTime = const Value.absent(),
                Value<String> weekdaysJson = const Value.absent(),
                Value<String> syncState = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleClassesTableCompanion(
                classId: classId,
                userEmail: userEmail,
                title: title,
                locationText: locationText,
                roomId: roomId,
                startDate: startDate,
                endDate: endDate,
                startTime: startTime,
                endTime: endTime,
                weekdaysJson: weekdaysJson,
                syncState: syncState,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String classId,
                required String userEmail,
                Value<String?> title = const Value.absent(),
                Value<String?> locationText = const Value.absent(),
                Value<String?> roomId = const Value.absent(),
                required DateTime startDate,
                required DateTime endDate,
                required String startTime,
                required String endTime,
                required String weekdaysJson,
                Value<String> syncState = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ScheduleClassesTableCompanion.insert(
                classId: classId,
                userEmail: userEmail,
                title: title,
                locationText: locationText,
                roomId: roomId,
                startDate: startDate,
                endDate: endDate,
                startTime: startTime,
                endTime: endTime,
                weekdaysJson: weekdaysJson,
                syncState: syncState,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScheduleClassesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduleClassesTableTable,
      ScheduleClassesTableData,
      $$ScheduleClassesTableTableFilterComposer,
      $$ScheduleClassesTableTableOrderingComposer,
      $$ScheduleClassesTableTableAnnotationComposer,
      $$ScheduleClassesTableTableCreateCompanionBuilder,
      $$ScheduleClassesTableTableUpdateCompanionBuilder,
      (
        ScheduleClassesTableData,
        BaseReferences<
          _$AppDatabase,
          $ScheduleClassesTableTable,
          ScheduleClassesTableData
        >,
      ),
      ScheduleClassesTableData,
      PrefetchHooks Function()
    >;
typedef $$FavoriteMutationsTableTableCreateCompanionBuilder =
    FavoriteMutationsTableCompanion Function({
      required String opId,
      required String roomId,
      required String operation,
      Value<int> attemptCount,
      Value<String?> lastError,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$FavoriteMutationsTableTableUpdateCompanionBuilder =
    FavoriteMutationsTableCompanion Function({
      Value<String> opId,
      Value<String> roomId,
      Value<String> operation,
      Value<int> attemptCount,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$FavoriteMutationsTableTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteMutationsTableTable> {
  $$FavoriteMutationsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteMutationsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteMutationsTableTable> {
  $$FavoriteMutationsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteMutationsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteMutationsTableTable> {
  $$FavoriteMutationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FavoriteMutationsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoriteMutationsTableTable,
          FavoriteMutationsTableData,
          $$FavoriteMutationsTableTableFilterComposer,
          $$FavoriteMutationsTableTableOrderingComposer,
          $$FavoriteMutationsTableTableAnnotationComposer,
          $$FavoriteMutationsTableTableCreateCompanionBuilder,
          $$FavoriteMutationsTableTableUpdateCompanionBuilder,
          (
            FavoriteMutationsTableData,
            BaseReferences<
              _$AppDatabase,
              $FavoriteMutationsTableTable,
              FavoriteMutationsTableData
            >,
          ),
          FavoriteMutationsTableData,
          PrefetchHooks Function()
        > {
  $$FavoriteMutationsTableTableTableManager(
    _$AppDatabase db,
    $FavoriteMutationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteMutationsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$FavoriteMutationsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FavoriteMutationsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> opId = const Value.absent(),
                Value<String> roomId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoriteMutationsTableCompanion(
                opId: opId,
                roomId: roomId,
                operation: operation,
                attemptCount: attemptCount,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String opId,
                required String roomId,
                required String operation,
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FavoriteMutationsTableCompanion.insert(
                opId: opId,
                roomId: roomId,
                operation: operation,
                attemptCount: attemptCount,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteMutationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoriteMutationsTableTable,
      FavoriteMutationsTableData,
      $$FavoriteMutationsTableTableFilterComposer,
      $$FavoriteMutationsTableTableOrderingComposer,
      $$FavoriteMutationsTableTableAnnotationComposer,
      $$FavoriteMutationsTableTableCreateCompanionBuilder,
      $$FavoriteMutationsTableTableUpdateCompanionBuilder,
      (
        FavoriteMutationsTableData,
        BaseReferences<
          _$AppDatabase,
          $FavoriteMutationsTableTable,
          FavoriteMutationsTableData
        >,
      ),
      FavoriteMutationsTableData,
      PrefetchHooks Function()
    >;
typedef $$CachedPathsTableTableCreateCompanionBuilder =
    CachedPathsTableCompanion Function({
      required String cacheKey,
      required String originText,
      required String destText,
      required String stepsJson,
      required int totalTimeSeconds,
      required int accessedAt,
      Value<int> rowid,
    });
typedef $$CachedPathsTableTableUpdateCompanionBuilder =
    CachedPathsTableCompanion Function({
      Value<String> cacheKey,
      Value<String> originText,
      Value<String> destText,
      Value<String> stepsJson,
      Value<int> totalTimeSeconds,
      Value<int> accessedAt,
      Value<int> rowid,
    });

class $$CachedPathsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CachedPathsTableTable> {
  $$CachedPathsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originText => $composableBuilder(
    column: $table.originText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destText => $composableBuilder(
    column: $table.destText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stepsJson => $composableBuilder(
    column: $table.stepsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalTimeSeconds => $composableBuilder(
    column: $table.totalTimeSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accessedAt => $composableBuilder(
    column: $table.accessedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedPathsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedPathsTableTable> {
  $$CachedPathsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originText => $composableBuilder(
    column: $table.originText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destText => $composableBuilder(
    column: $table.destText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stepsJson => $composableBuilder(
    column: $table.stepsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalTimeSeconds => $composableBuilder(
    column: $table.totalTimeSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accessedAt => $composableBuilder(
    column: $table.accessedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedPathsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedPathsTableTable> {
  $$CachedPathsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get originText => $composableBuilder(
    column: $table.originText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destText =>
      $composableBuilder(column: $table.destText, builder: (column) => column);

  GeneratedColumn<String> get stepsJson =>
      $composableBuilder(column: $table.stepsJson, builder: (column) => column);

  GeneratedColumn<int> get totalTimeSeconds => $composableBuilder(
    column: $table.totalTimeSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accessedAt => $composableBuilder(
    column: $table.accessedAt,
    builder: (column) => column,
  );
}

class $$CachedPathsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedPathsTableTable,
          CachedPathsTableData,
          $$CachedPathsTableTableFilterComposer,
          $$CachedPathsTableTableOrderingComposer,
          $$CachedPathsTableTableAnnotationComposer,
          $$CachedPathsTableTableCreateCompanionBuilder,
          $$CachedPathsTableTableUpdateCompanionBuilder,
          (
            CachedPathsTableData,
            BaseReferences<
              _$AppDatabase,
              $CachedPathsTableTable,
              CachedPathsTableData
            >,
          ),
          CachedPathsTableData,
          PrefetchHooks Function()
        > {
  $$CachedPathsTableTableTableManager(
    _$AppDatabase db,
    $CachedPathsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedPathsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedPathsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedPathsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cacheKey = const Value.absent(),
                Value<String> originText = const Value.absent(),
                Value<String> destText = const Value.absent(),
                Value<String> stepsJson = const Value.absent(),
                Value<int> totalTimeSeconds = const Value.absent(),
                Value<int> accessedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedPathsTableCompanion(
                cacheKey: cacheKey,
                originText: originText,
                destText: destText,
                stepsJson: stepsJson,
                totalTimeSeconds: totalTimeSeconds,
                accessedAt: accessedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cacheKey,
                required String originText,
                required String destText,
                required String stepsJson,
                required int totalTimeSeconds,
                required int accessedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedPathsTableCompanion.insert(
                cacheKey: cacheKey,
                originText: originText,
                destText: destText,
                stepsJson: stepsJson,
                totalTimeSeconds: totalTimeSeconds,
                accessedAt: accessedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedPathsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedPathsTableTable,
      CachedPathsTableData,
      $$CachedPathsTableTableFilterComposer,
      $$CachedPathsTableTableOrderingComposer,
      $$CachedPathsTableTableAnnotationComposer,
      $$CachedPathsTableTableCreateCompanionBuilder,
      $$CachedPathsTableTableUpdateCompanionBuilder,
      (
        CachedPathsTableData,
        BaseReferences<
          _$AppDatabase,
          $CachedPathsTableTable,
          CachedPathsTableData
        >,
      ),
      CachedPathsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MyBookingsTableTableTableManager get myBookingsTable =>
      $$MyBookingsTableTableTableManager(_db, _db.myBookingsTable);
  $$FavoriteRoomsTableTableTableManager get favoriteRoomsTable =>
      $$FavoriteRoomsTableTableTableManager(_db, _db.favoriteRoomsTable);
  $$ScheduleClassesTableTableTableManager get scheduleClassesTable =>
      $$ScheduleClassesTableTableTableManager(_db, _db.scheduleClassesTable);
  $$FavoriteMutationsTableTableTableManager get favoriteMutationsTable =>
      $$FavoriteMutationsTableTableTableManager(
        _db,
        _db.favoriteMutationsTable,
      );
  $$CachedPathsTableTableTableManager get cachedPathsTable =>
      $$CachedPathsTableTableTableManager(_db, _db.cachedPathsTable);
}
