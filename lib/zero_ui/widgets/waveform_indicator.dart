// lib/zero_ui/widgets/waveform_indicator.dart

import 'package:beacon_ai/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Dynamic reactive visualizer reacting to incoming microphone decibel levels.
class WaveformIndicator extends StatelessWidget {
  const WaveformIndicator({
    required this.soundLevel,
    required this.isListening,
    super.key,
  });

  final double soundLevel;
  final bool isListening;

  @override
  Widget build(BuildContext context) {
    if (!isListening) return const SizedBox(height: 80);

    // Normalize soundLevel for visual expansion
    final scale = (1.0 + (soundLevel.clamp(0, 10) / 5)).clamp(1.0, 2.2);

    return SizedBox(
      height: 100,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 70 * scale,
          height: 70 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.beaconYellow.withValues(alpha: 0.15),
            border: Border.all(
              color: AppTheme.beaconYellow,
              width: 3 * scale,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.beaconYellow.withValues(alpha: 0.3),
                blurRadius: 20 * scale,
                spreadRadius: 4 * scale,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.mic_rounded,
              color: AppTheme.beaconYellow,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}