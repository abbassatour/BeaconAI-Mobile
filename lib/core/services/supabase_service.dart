// lib/core/services/supabase_service.dart

import 'dart:developer';
import 'package:beacon_ai/core/constants/api_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service managing cloud synchronization, emergency SOS broadcasts,
/// and remote data operations with Supabase Postgres & Realtime.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  /// Initializes the Supabase client safely during app bootstrap.
  static Future<void> initialize() async {
    final url = ApiConstants.supabaseUrl;
    final anonKey = ApiConstants.supabaseAnonKey;

    if (url.contains('YOUR_SUPABASE') || anonKey.contains('YOUR_SUPABASE')) {
      log('SupabaseService: Credentials not set. Running in local fallback mode.');
      return;
    }

    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        debug: false,
      );
      log('SupabaseService: Connected successfully to cloud backend.');
    } catch (e, st) {
      log('SupabaseService: Initialization error: $e', stackTrace: st);
    }
  }

  /// Dispatches an emergency beacon ping to the cloud.
  /// Automatically triggers the Realtime channel for caregivers.
  Future<bool> sendSosAlert({
    required double latitude,
    required double longitude,
    int? batteryLevel,
    String? userId,
  }) async {
    try {
      final googleMapsUrl = 'https://maps.google.com/?q=$latitude,$longitude';

      await client.from('sos_alerts').insert({
        'user_id': userId ?? 'anonymous_user',
        'latitude': latitude,
        'longitude': longitude,
        'battery_level': batteryLevel ?? 100,
        'status': 'active',
        'google_maps_url': googleMapsUrl,
      });

      log('SupabaseService: SOS Alert dispatched successfully to cloud.');
      return true;
    } catch (e, st) {
      log('SupabaseService: Failed to dispatch SOS: $e', stackTrace: st);
      return false;
    }
  }

  /// Subscribes to real-time updates on active SOS alerts (for family/caregiver radar).
  Stream<List<Map<String, dynamic>>> subscribeToSosRealtime() {
    return client
        .from('sos_alerts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(10);
  }

  /// Backs up a local voice memo to the cloud.
  Future<void> backupMemo({
    required String title,
    required String content,
    String category = 'general',
  }) async {
    try {
      await client.from('voice_memos').insert({
        'title': title,
        'content': content,
        'category': category,
      });
      log('SupabaseService: Memo backed up to cloud.');
    } catch (e, st) {
      log('SupabaseService: Failed to backup memo: $e', stackTrace: st);
    }
  }
}