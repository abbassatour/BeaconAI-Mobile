// lib/core/repositories/memos_repository.dart

import 'dart:developer';
import 'package:beacon_ai/core/database/app_database.dart';
import 'package:beacon_ai/core/services/supabase_service.dart';
import 'package:drift/drift.dart';

/// Repository managing offline-first voice memo persistence (Drift/SQLite)
/// and opportunistic background cloud backup (Supabase).
class MemosRepository {
  MemosRepository({
    AppDatabase? database,
    SupabaseService? supabaseService,
  })  : _db = database ?? AppDatabase.instance,
        _supabase = supabaseService ?? SupabaseService.instance;

  static final MemosRepository instance = MemosRepository();

  final AppDatabase _db;
  final SupabaseService _supabase;

  /// Saves a voice memo locally first, then attempts background cloud backup.
  Future<int> saveMemo({
    required String content,
    String? title,
    String category = 'general',
  }) async {
    final derivedTitle = title ?? _generateTitleFromContent(content);

    final companion = VoiceMemosCompanion.insert(
      title: derivedTitle,
      content: content.trim(),
      category: Value(category),
    );

    final insertedId = await _db.insertMemo(companion);
    log('MemosRepository: Stored memo locally with ID: $insertedId');

    // Opportunistic cloud backup without blocking local UX
    _supabase.backupMemo(
      title: derivedTitle,
      content: content.trim(),
      category: category,
    ).catchError((Object error) {
      log('MemosRepository: Cloud backup bypassed (offline mode): $error');
    });

    return insertedId;
  }

  /// Watches a reactive stream of all stored memos.
  Stream<List<VoiceMemo>> watchMemos() => _db.watchAllMemos();

  /// Fetches memos recorded today.
  Future<List<VoiceMemo>> getTodayMemos() => _db.getTodayMemos();

  /// Fetches all stored memos.
  Future<List<VoiceMemo>> getAllMemos() => _db.getAllMemos();

  /// Deletes a memo by ID.
  Future<int> deleteMemo(int id) => _db.deleteMemoById(id);

  /// Synthesizes stored memos into natural spoken prose for eyes-free TTS playback.
  String formatMemosForSpeech(List<VoiceMemo> memos) {
    if (memos.isEmpty) {
      return 'You have no voice notes recorded for today.';
    }

    if (memos.length == 1) {
      return 'You have one note recorded: ${memos.first.content}';
    }

    final buffer = StringBuffer('You have ${memos.length} notes for today. ');
    for (var i = 0; i < memos.length; i++) {
      buffer.write('Note ${i + 1}: ${memos[i].content}. ');
    }
    return buffer.toString().trim();
  }

  String _generateTitleFromContent(String text) {
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length <= 4) {
      return text.trim();
    }
    return '${words.take(4).join(' ')}...';
  }
}