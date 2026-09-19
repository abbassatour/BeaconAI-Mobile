// lib/core/database/app_database.dart

import 'package:beacon_ai/core/database/connection.dart';
import 'package:beacon_ai/core/database/tables/voice_memos_table.dart';
import 'package:drift/drift.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [VoiceMemos])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? openConnection());

  static final AppDatabase instance = AppDatabase();

  @override
  int get schemaVersion => 1;

  /// Fetches all memos ordered by most recent first.
  Future<List<VoiceMemo>> getAllMemos() =>
      (select(voiceMemos)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  /// Reactive stream of voice memos for live UI updates.
  Stream<List<VoiceMemo>> watchAllMemos() =>
      (select(voiceMemos)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  /// Retrieves memos recorded today (for morning briefings and "read my notes").
  Future<List<VoiceMemo>> getTodayMemos() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return (select(voiceMemos)
          ..where((t) => t.createdAt.isBiggerOrEqualValue(startOfDay))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Inserts a new voice memo into the local vault.
  Future<int> insertMemo(VoiceMemosCompanion memo) =>
      into(voiceMemos).insert(memo);

  /// Updates an existing memo entry.
  Future<bool> updateMemo(VoiceMemo memo) =>
      update(voiceMemos).replace(memo);

  /// Deletes a memo by primary id.
  Future<int> deleteMemoById(int id) =>
      (delete(voiceMemos)..where((t) => t.id.equals(id))).go();
}