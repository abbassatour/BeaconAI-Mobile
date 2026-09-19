// lib/core/services/briefing_service.dart

import 'dart:developer';
import 'package:beacon_ai/core/repositories/memos_repository.dart';
import 'package:beacon_ai/core/services/tts_service.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// Service orchestrating scheduled morning audio briefings for engagement.
class MorningBriefingService {
  MorningBriefingService._();
  static final MorningBriefingService instance = MorningBriefingService._();

  final MemosRepository _memos = MemosRepository.instance;
  final TtsService _tts = TtsService.instance;

  /// Compiles today's memos into a natural acoustic briefing and recites it.
  Future<String> playMorningBriefing() async {
    final todayMemos = await _memos.getTodayMemos();

    String speechText;
    if (todayMemos.isEmpty) {
      speechText =
          'Good morning! You have no notes or reminders scheduled for today. Have a productive day!';
    } else {
      final buffer = StringBuffer(
        'Good morning! Here is your daily briefing. You have ${todayMemos.length} reminder${todayMemos.length > 1 ? 's' : ''} for today. ',
      );
      for (var i = 0; i < todayMemos.length; i++) {
        buffer.write('Number ${i + 1}: ${todayMemos[i].content}. ');
      }
      speechText = buffer.toString().trim();
    }

    log('MorningBriefingService: Playing daily briefing: $speechText');
    await _tts.speak(speechText);
    return speechText;
  }

  /// Configures user tags in OneSignal to segment morning briefing notifications.
  Future<void> registerBriefingSchedule({int targetHour = 8}) async {
    try {
      await OneSignal.User.addTags({
        'morning_briefing_enabled': 'true',
        'preferred_briefing_hour': targetHour.toString(),
      });
      log('MorningBriefingService: OneSignal briefing tags registered.');
    } catch (e, st) {
      log('MorningBriefingService: Tag registration error: $e', stackTrace: st);
    }
  }
}