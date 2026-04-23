import 'dart:convert';

import 'package:andespace/core/local/app_database.dart';

import '../../domain/entities/navigation.dart';

class CachedPathEntry {
  const CachedPathEntry({
    required this.key,
    required this.originText,
    required this.destText,
    required this.path,
  });

  final String key;
  final String originText;
  final String destText;
  final NavigationPath path;
}

class PathLocalDataSource {
  const PathLocalDataSource(this._db);

  final AppDatabase _db;

  Future<List<CachedPathEntry>> loadAll() async {
    final rows = await _db.getCachedPaths();
    return rows
        .map(
          (r) => CachedPathEntry(
            key: r.cacheKey,
            originText: r.originText,
            destText: r.destText,
            path: NavigationPath(
              fromRoom: r.originText,
              toRoom: r.destText,
              steps: List<String>.from(jsonDecode(r.stepsJson) as List),
              totalTimeSeconds: r.totalTimeSeconds,
            ),
          ),
        )
        .toList();
  }

  
  Future<void> persist(List<MapEntry<String, NavigationPath>> lruEntries) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rows = lruEntries.asMap().entries.map((e) {
      final idx = e.key;
      final entry = e.value;
      final t = now - (lruEntries.length - idx) * 1000;
      return CachedPathsTableCompanion.insert(
        cacheKey: entry.key,
        originText: entry.value.fromRoom,
        destText: entry.value.toRoom,
        stepsJson: jsonEncode(entry.value.steps),
        totalTimeSeconds: entry.value.totalTimeSeconds,
        accessedAt: t,
      );
    }).toList();
    await _db.replaceCachedPaths(rows);
  }
}
