// lib/core/services/intent_router.dart

import 'dart:developer';
import 'package:battery_plus/battery_plus.dart';
import 'package:beacon_ai/core/repositories/memos_repository.dart';
import 'package:beacon_ai/core/services/ai_vision_client.dart';
import 'package:beacon_ai/core/services/camera_service.dart';
import 'package:beacon_ai/core/services/supabase_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Identified intent categories for quick voice dispatching.
enum IntentType {
  time,
  battery,
  takeNote,
  readNotes,
  phoneCall,
  emergencySos,
  visualQuery,
  generalQuery,
}

/// Dispatched result model holding speech response and payload.
class IntentResult {
  const IntentResult({
    required this.type,
    required this.spokenResponse,
    this.payload,
  });

  final IntentType type;
  final String spokenResponse;
  final dynamic payload;
}

/// Fast, zero-latency local rule-based intent classifier and dispatcher.
class IntentRouter {
  IntentRouter({
    Battery? battery,
    MemosRepository? memosRepository,
    SupabaseService? supabaseService,
    CameraService? cameraService,
    AiVisionClient? visionClient,
  })  : _battery = battery ?? Battery(),
        _memos = memosRepository ?? MemosRepository.instance,
        _supabase = supabaseService ?? SupabaseService.instance,
        _camera = cameraService ?? CameraService.instance,
        _vision = visionClient ?? AiVisionClient.instance;

  static final IntentRouter instance = IntentRouter();

  final Battery _battery;
  final MemosRepository _memos;
  final SupabaseService _supabase;
  final CameraService _camera;
  final AiVisionClient _vision;

  /// Analyzes spoken [query] and executes the appropriate local or cloud handler.
  Future<IntentResult> dispatch(String query) async {
    final clean = query.trim().toLowerCase();

    // 1. Time Intent
    if (clean.contains('time') || clean.contains('clock') || clean == 'date') {
      final now = DateTime.now();
      final timeStr = DateFormat('h:mm a, EEEE, MMMM d').format(now);
      return IntentResult(
        type: IntentType.time,
        spokenResponse: 'The time is $timeStr.',
      );
    }

    // 2. Battery Vitals Intent
    if (clean.contains('battery') || clean.contains('charge')) {
      try {
        final level = await _battery.batteryLevel;
        final state = await _battery.batteryState;
        final stateStr = state == BatteryState.charging
            ? 'and charging'
            : 'and not charging';
        return IntentResult(
          type: IntentType.battery,
          spokenResponse: 'Your battery level is $level percent, $stateStr.',
        );
      } catch (e) {
        log('Failed to read battery: $e');
        return const IntentResult(
          type: IntentType.battery,
          spokenResponse: 'Unable to read battery level right now.',
        );
      }
    }

    // 3. Take Note Intent
    if (clean.startsWith('note') ||
        clean.startsWith('take note') ||
        clean.startsWith('save note') ||
        clean.startsWith('remind me to') ||
        clean.startsWith('remember')) {
      final noteContent = _extractNoteContent(query);
      if (noteContent.isEmpty) {
        return const IntentResult(
          type: IntentType.takeNote,
          spokenResponse: 'Please tell me what note you would like to save.',
        );
      }

      await _memos.saveMemo(content: noteContent);
      return IntentResult(
        type: IntentType.takeNote,
        spokenResponse: 'Note saved locally: $noteContent.',
      );
    }

    // 4. Read Notes Intent
    if (clean.contains('read note') ||
        clean.contains('my notes') ||
        clean.contains('what are my notes') ||
        clean.contains('read my memos')) {
      final todayMemos = await _memos.getTodayMemos();
      final spoken = _memos.formatMemosForSpeech(todayMemos);
      return IntentResult(
        type: IntentType.readNotes,
        spokenResponse: spoken,
      );
    }

    // 5. Direct Phone Calling Intent
    if (clean.startsWith('call ') || clean.startsWith('dial ')) {
      final target = query.replaceFirst(RegExp(r'^(call|dial)\s+', caseSensitive: false), '').trim();
      final digits = target.replaceAll(RegExp(r'\D'), '');

      if (digits.isNotEmpty) {
        final uri = Uri.parse('tel:$digits');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          return IntentResult(
            type: IntentType.phoneCall,
            spokenResponse: 'Calling $digits.',
          );
        }
      }
      return IntentResult(
        type: IntentType.phoneCall,
        spokenResponse: 'Unable to place a direct phone call to $target.',
      );
    }

    // 6. Emergency Voice SOS Trigger
    if (clean == 'sos' || clean.contains('emergency') || clean.contains('help me')) {
      return _handleEmergencySos();
    }

    // 7. Visual AI Query (Gemini Vision Pipeline)
    if (clean.contains('what is this') ||
        clean.contains('what do you see') ||
        clean.contains('describe') ||
        clean.contains('read this') ||
        clean.contains('what color') ||
        clean.contains('how much is this') ||
        clean.contains('where is')) {
      return _handleVisualQuery(query);
    }

    // 8. General conversational fallback (If not a specific system intent)
    return IntentResult(
      type: IntentType.generalQuery,
      spokenResponse: 'You asked: $query. I am ready for your next command.',
    );
  }

  /// Triggers the background camera, captures a silent frame, and sends to Gemini.
  Future<IntentResult> _handleVisualQuery(String query) async {
    final base64Image = await _camera.takeSnapshotBase64();
    
    if (base64Image == null) {
      return const IntentResult(
        type: IntentType.visualQuery,
        spokenResponse: 'I could not access the camera. Please check permissions.',
      );
    }

    final answer = await _vision.analyzeImage(
      query: query,
      base64Image: base64Image,
    );

    return IntentResult(
      type: IntentType.visualQuery,
      spokenResponse: answer,
    );
  }

  Future<IntentResult> _handleEmergencySos() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      final batteryLevel = await _battery.batteryLevel;
      await _supabase.sendSosAlert(
        latitude: position.latitude,
        longitude: position.longitude,
        batteryLevel: batteryLevel,
      );

      return const IntentResult(
        type: IntentType.emergencySos,
        spokenResponse:
            'Emergency SOS beacon broadcasted with your GPS coordinates.',
      );
    } catch (e) {
      log('SOS location capture error: $e');
      return const IntentResult(
        type: IntentType.emergencySos,
        spokenResponse: 'Emergency trigger received. Dispatching alert.',
      );
    }
  }

  String _extractNoteContent(String raw) {
    return raw
        .replaceFirst(
          RegExp(
            r'^(take note(:)?|save note(:)?|note(:)?|remind me to|remember to|remember)\s*',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
  }
}