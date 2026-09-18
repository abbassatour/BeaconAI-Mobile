// lib/zero_ui/cubit/zero_ui_state.dart

import 'package:equatable/equatable.dart';

/// High-level operational statuses for the Zero-UI system.
enum ZeroUiStatus { idle, listening, processing, speaking, sosTriggered, error }

/// Display mode toggle: Pure black eyes-free canvas vs Live Visual HUD.
enum DisplayMode { eyesFree, visualHud }

class ZeroUiState extends Equatable {
  const ZeroUiState({
    this.status = ZeroUiStatus.idle,
    this.displayMode = DisplayMode.visualHud,
    this.recognizedText = '',
    this.responseText = '',
    this.soundLevel = 0.0,
    this.errorMessage,
  });

  final ZeroUiStatus status;
  final DisplayMode displayMode;
  final String recognizedText;
  final String responseText;
  final double soundLevel;
  final String? errorMessage;

  ZeroUiState copyWith({
    ZeroUiStatus? status,
    DisplayMode? displayMode,
    String? recognizedText,
    String? responseText,
    double? soundLevel,
    String? errorMessage,
  }) {
    return ZeroUiState(
      status: status ?? this.status,
      displayMode: displayMode ?? this.displayMode,
      recognizedText: recognizedText ?? this.recognizedText,
      responseText: responseText ?? this.responseText,
      soundLevel: soundLevel ?? this.soundLevel,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        displayMode,
        recognizedText,
        responseText,
        soundLevel,
        errorMessage,
      ];
}