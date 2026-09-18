// lib/zero_ui/cubit/zero_ui_cubit.dart

import 'dart:async';
import 'package:beacon_ai/core/audio/sound_controller.dart';
import 'package:beacon_ai/core/haptics/haptic_manager.dart';
import 'package:beacon_ai/core/services/speech_service.dart';
import 'package:beacon_ai/core/services/tts_service.dart';
import 'package:beacon_ai/zero_ui/cubit/zero_ui_state.dart';
import 'package:bloc/bloc.dart';

class ZeroUiCubit extends Cubit<ZeroUiState> {
  ZeroUiCubit({
    HapticManager? hapticManager,
    SoundController? soundController,
    TtsService? ttsService,
    SpeechService? speechService,
  })  : _haptics = hapticManager ?? HapticManager.instance,
        _sound = soundController ?? SoundController.instance,
        _tts = ttsService ?? TtsService.instance,
        _speech = speechService ?? SpeechService.instance,
        super(const ZeroUiState()) {
    _initTtsListener();
  }

  final HapticManager _haptics;
  final SoundController _sound;
  final TtsService _tts;
  final SpeechService _speech;

  void _initTtsListener() {
    _tts.onCompletion = () {
      if (state.status == ZeroUiStatus.speaking) {
        emit(state.copyWith(status: ZeroUiStatus.idle));
      }
    };
  }

  /// Triggered as soon as the user presses anywhere on the screen.
  Future<void> onTouchStarted() async {
    // Immediate audio cutoff for instant responsiveness
    await _sound.stop();
    await _tts.stop();

    _haptics.startListeningPulse();
    await _sound.playListeningCue();

    emit(
      state.copyWith(
        status: ZeroUiStatus.listening,
        recognizedText: '',
        soundLevel: 0,
      ),
    );

    await _speech.startListening(
      onResult: (words, isFinal) {
        emit(state.copyWith(recognizedText: words));
      },
      onSoundLevelChange: (level) {
        emit(state.copyWith(soundLevel: level));
      },
    );
  }

  /// Triggered as soon as the user lifts their finger off the screen.
  Future<void> onTouchReleased() async {
    _haptics.stopListeningPulse();
    await _speech.stopListening();

    final query = state.recognizedText.trim();
    if (query.isEmpty) {
      await _sound.playErrorCue();
      await _haptics.errorAlert();
      emit(state.copyWith(status: ZeroUiStatus.idle));
      return;
    }

    emit(state.copyWith(status: ZeroUiStatus.processing));
    await _sound.playProcessingCue();

    // Simulating initial local intent execution before vision/cloud connection
    await _handleCommand(query);
  }

  Future<void> _handleCommand(String query) async {
    // Temporary response mock to verify end-to-end loop
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final reply = 'You said: $query. Beacon AI system is listening.';
    await _haptics.successNotification();
    await _sound.playSuccessCue();

    emit(
      state.copyWith(
        status: ZeroUiStatus.speaking,
        responseText: reply,
      ),
    );

    await _tts.speak(reply);
  }

  /// Swiping up repeats the last assistant answer.
  Future<void> replayLastResponse() async {
    if (state.responseText.isNotEmpty) {
      await _haptics.successNotification();
      emit(state.copyWith(status: ZeroUiStatus.speaking));
      await _tts.speak(state.responseText);
    }
  }

  /// Swiping down toggles between pure Eyes-Free canvas and Visual HUD.
  void toggleDisplayMode() {
    final nextMode = state.displayMode == DisplayMode.visualHud
        ? DisplayMode.eyesFree
        : DisplayMode.visualHud;
    _haptics.successNotification();
    emit(state.copyWith(displayMode: nextMode));
  }

  /// Triple-tap activates Emergency SOS alarm.
  Future<void> triggerEmergencySos() async {
    emit(state.copyWith(status: ZeroUiStatus.sosTriggered));
    await _haptics.emergencyAlarmPulse();
    await _sound.playSosAlarm();
    await _tts.speak('Emergency SOS triggered. Help beacon activated.');
  }

  @override
  Future<void> close() {
    _haptics.dispose();
    _sound.dispose();
    _speech.dispose();
    _tts.dispose();
    return super.close();
  }
}