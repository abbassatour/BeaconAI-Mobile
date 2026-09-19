// lib/core/services/speech_service.dart

import 'dart:developer';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Service managing real-time speech recognition (Speech-to-Text) in English.
class SpeechService {
  SpeechService._() {
    _speech = SpeechToText();
  }

  static final SpeechService instance = SpeechService._();

  late final SpeechToText _speech;
  bool _isInitialized = false;

  bool get isListening => _speech.isListening;
  bool get isAvailable => _isInitialized && _speech.isAvailable;

  Future<bool> initialize({
    void Function(String status)? onStatus,
    void Function(SpeechRecognitionError error)? onError,
  }) async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speech.initialize(
        onStatus: onStatus ?? (status) => log('Speech status: $status'),
        onError: onError ?? (error) => log('Speech error: ${error.errorMsg}'),
        debugLogging: false,
      );
      return _isInitialized;
    } catch (e, stack) {
      log('Speech engine init failed: $e', stackTrace: stack);
      _isInitialized = false;
      return false;
    }
  }

  Future<void> startListening({
    required void Function(String recognizedWords, bool isFinal) onResult,
    void Function(double level)? onSoundLevelChange,
  }) async {
    if (!_isInitialized) {
      if (!(await initialize())) return;
    }
    if (_speech.isListening) await _speech.stop();
    try {
      await _speech.listen(
        onResult: (result) => onResult(result.recognizedWords, result.finalResult),
        onSoundLevelChange: onSoundLevelChange,
        localeId: 'en_US',
        listenMode: ListenMode.dictation,
        cancelOnError: false,
        partialResults: true,
      );
    } catch (e, stack) {
      log('Error while listening: $e', stackTrace: stack);
    }
  }

  Future<void> stopListening() async {
    if (_speech.isListening) await _speech.stop();
  }

  void dispose() {
    _speech.stop();
  }
}