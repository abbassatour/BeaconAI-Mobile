// lib/zero_ui/view/zero_ui_view.dart

import 'package:beacon_ai/core/theme/app_theme.dart';
import 'package:beacon_ai/zero_ui/cubit/zero_ui_cubit.dart';
import 'package:beacon_ai/zero_ui/cubit/zero_ui_state.dart';
import 'package:beacon_ai/zero_ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ZeroUiView extends StatelessWidget {
  const ZeroUiView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ZeroUiCubit>();

    return BlocBuilder<ZeroUiCubit, ZeroUiState>(
      builder: (context, state) {
        final isEyesFree = state.displayMode == DisplayMode.eyesFree;

        return Scaffold(
          backgroundColor: AppTheme.pureBlack,
          body: HapticCanvas(
            onLongPressStart: cubit.onTouchStarted,
            onLongPressEnd: cubit.onTouchReleased,
            onSwipeUp: cubit.replayLastResponse,
            onSwipeDown: cubit.toggleDisplayMode,
            onTripleTap: cubit.triggerEmergencySos,
            child: SafeArea(
              child: isEyesFree
                  ? _buildEyesFreeMode(context, state)
                  : _buildVisualHudMode(context, state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEyesFreeMode(BuildContext context, ZeroUiState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            state.status == ZeroUiStatus.listening
                ? Icons.mic_rounded
                : Icons.touch_app_rounded,
            color: AppTheme.beaconYellow,
            size: 80,
          ),
          const SizedBox(height: 24),
          const Text(
            'EYES-FREE MODE',
            style: TextStyle(
              color: AppTheme.beaconYellow,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Swipe down for visual HUD',
            style: TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualHudMode(BuildContext context, ZeroUiState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BEACON AI',
                style: TextStyle(
                  color: AppTheme.beaconYellow,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: 1.5,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.visibility_off_rounded,
                  color: AppTheme.beaconYellow,
                ),
                tooltip: 'Switch to Eyes-Free mode',
                onPressed: context.read<ZeroUiCubit>().toggleDisplayMode,
              ),
            ],
          ),
          const Spacer(),
          WaveformIndicator(
            soundLevel: state.soundLevel,
            isListening: state.status == ZeroUiStatus.listening,
          ),
          const SizedBox(height: 20),
          LiveTranscriptCard(state: state),
          const Spacer(),
          const Text(
            'Press & hold anywhere to speak • Swipe down to dim',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white30, fontSize: 13),
          ),
        ],
      ),
    );
  }
}