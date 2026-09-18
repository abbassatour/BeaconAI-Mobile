// lib/core/audio/sound_controller.dart

import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';

/// Central controller for audio feedback cues and sound prioritization.
class SoundController {
  SoundController._() {
    _initPlayer();
  }

  static final SoundController instance = SoundController._();

  late final AudioPlayer _player;

  void _initPlayer() {
    _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  }

  /// Plays the wake sound when the user starts speaking (hold starts).
  Future<void> playListeningCue() async {
    await _safePlay('audio/wake.mp3', volume: 0.6);
  }

  /// Plays the thinking/processing tone while AI is inferring.
  Future<void> playProcessingCue() async {
    await _safePlay('audio/processing.mp3', volume: 0.5);
  }

  /// Plays the success tone when an action completes successfully.
  Future<void> playSuccessCue() async {
    await _safePlay('audio/success.mp3', volume: 0.7);
  }

  /// Plays the warning/error tone when an action fails.
  Future<void> playErrorCue() async {
    await _safePlay('audio/error.mp3', volume: 0.8);
  }

  /// Plays the loud repeating alarm during emergency SOS trigger.
  Future<void> playSosAlarm() async {
    await _player.stop();
    await _player.setReleaseMode(ReleaseMode.loop);
    await _safePlay('audio/sos.mp3', volume: 1);
  }

  /// Immediately cuts off any active playback (e.g. when user touches canvas).
  Future<void> stop() async {
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.stop();
    } catch (e, stack) {
      log('Error stopping audio: $e', stackTrace: stack);
    }
  }

  Future<void> _safePlay(String assetPath, {double volume = 1.0}) async {
    try {
      await _player.stop();
      await _player.setVolume(volume);
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      // Gracefully handle missing asset files during development
      log('Sound cue bypassed or asset missing: $assetPath ($e)');
    }
  }

  void dispose() {
    _player.dispose();
  }
} 