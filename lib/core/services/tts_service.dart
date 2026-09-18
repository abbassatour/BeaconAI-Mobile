// lib/core/services/tts_service.dart

import 'dart:developer';
import 'package:flutter_tts/flutter_tts.dart';

/// Current operational status of the TTS engine.
enum TtsStatus { idle, playing, paused, stopped }

/// Service managing Text-to-Speech audio synthesis exclusively in English
/// with Markdown sanitization for fluid acoustic delivery.
class TtsService {
  TtsService._() {
    _initTts();
  }

  static final TtsService instance = TtsService._();

  late final FlutterTts _flutterTts;
  TtsStatus _status = TtsStatus.idle;

  TtsStatus get status => _status;
  bool get isSpeaking => _status == TtsStatus.playing;

  /// Optional callback invoked when speech utterance finishes naturally.
  void Function()? onCompletion;

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();

    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1);
    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setStartHandler(() {
      _status = TtsStatus.playing;
    });

    _flutterTts.setCompletionHandler(() {
      _status = TtsStatus.idle;
      onCompletion?.call();
    });

    _flutterTts.setCancelHandler(() {
      _status = TtsStatus.stopped;
    });

    _flutterTts.setErrorHandler((dynamic msg) {
      _status = TtsStatus.idle;
      log('TTS Engine Error: $msg');
    });
  }

  /// Converts [text] into spoken English audio.
  Future<void> speak(String text) async {
    await stop();

    final sanitized = _sanitizeTextForSpeech(text);
    if (sanitized.isEmpty) return;

    try {
      _status = TtsStatus.playing;
      await _flutterTts.speak(sanitized);
    } catch (e, st) {
      _status = TtsStatus.idle;
      log('Failed to synthesize speech: $e', stackTrace: st);
    }
  }

  /// Silences any active voice recitation immediately.
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _status = TtsStatus.stopped;
    } catch (e) {
      log('Error stopping TTS: $e');
    }
  }

  /// Adjusts speech playback rate (0.0 to 1.0).
  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate.clamp(0.0, 1.0));
  }

  /// Strips Markdown tags, links, and bullets to produce clean spoken prose.
  String _sanitizeTextForSpeech(String raw) {
    return raw
        .replaceAll(RegExp(r'\*\*|\*|__|_|`|#+'), '') // Bold/Italic/Headers
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1') // Links
        .replaceAll(RegExp(r'https?:\/\/\S+'), 'link') // Raw URLs
        .replaceAll(RegExp(r'[-*•]\s+'), '') // Bullet points
        .trim();
  }

  void dispose() {
    _flutterTts.stop();
  }
}