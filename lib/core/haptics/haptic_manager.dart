// lib/core/haptics/haptic_manager.dart

import 'dart:async';
import 'package:flutter/services.dart';

/// Manages tactile sensory feedback (haptics) for eyes-free navigation.
class HapticManager {
  HapticManager._();
  static final HapticManager instance = HapticManager._();

  Timer? _listeningHeartbeat;

  /// Starts a subtle, periodic pulse while the user is holding the screen.
  /// This assures visually impaired users that the microphone is active.
  void startListeningPulse() {
    _listeningHeartbeat?.cancel();
    HapticFeedback.mediumImpact();
    _listeningHeartbeat = Timer.periodic(
      const Duration(milliseconds: 350),
      (_) => HapticFeedback.selectionClick(),
    );
  }

  /// Stops the ongoing listening pulse when touch is released.
  void stopListeningPulse() {
    _listeningHeartbeat?.cancel();
    _listeningHeartbeat = null;
  }

  /// Double tap confirmation vibration on action success.
  Future<void> successNotification() async {
    stopListeningPulse();
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// Heavy alert vibration for errors or cancelled actions.
  Future<void> errorAlert() async {
    stopListeningPulse();
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.heavyImpact();
  }

  /// Distinct escalating pulse sequence triggered during SOS emergency mode.
  Future<void> emergencyAlarmPulse() async {
    stopListeningPulse();
    for (var i = 0; i < 3; i++) {
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }
  }

  void dispose() {
    stopListeningPulse();
  }
}