// lib/zero_ui/widgets/live_transcript_card.dart

import 'package:beacon_ai/core/theme/app_theme.dart';
import 'package:beacon_ai/zero_ui/cubit/zero_ui_state.dart';
import 'package:flutter/material.dart';

/// High-contrast card displaying user transcription and assistant reply.
class LiveTranscriptCard extends StatelessWidget {
  const LiveTranscriptCard({
    required this.state,
    super.key,
  });

  final ZeroUiState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isListening = state.status == ZeroUiStatus.listening;
    final isProcessing = state.status == ZeroUiStatus.processing;
    final isSpeaking = state.status == ZeroUiStatus.speaking;

    String header = 'READY';
    Color headerColor = AppTheme.subtleGray;

    if (isListening) {
      header = 'LISTENING...';
      headerColor = AppTheme.beaconYellow;
    } else if (isProcessing) {
      header = 'PROCESSING...';
      headerColor = Colors.orangeAccent;
    } else if (isSpeaking) {
      header = 'BEACON AI';
      headerColor = AppTheme.pureWhite;
    }

    final displayText = isListening
        ? (state.recognizedText.isEmpty
            ? 'Speak now, holding anywhere...'
            : state.recognizedText)
        : (state.responseText.isEmpty
            ? 'Long press anywhere to speak.\nSwipe up to replay.'
            : state.responseText);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: headerColor.withValues(alpha: 0.6),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: headerColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                header,
                style: textTheme.labelLarge?.copyWith(color: headerColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            displayText,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: isListening ? FontWeight.bold : FontWeight.normal,
              color: isListening ? AppTheme.beaconYellow : AppTheme.pureWhite,
            ),
          ),
        ],
      ),
    );
  }
}