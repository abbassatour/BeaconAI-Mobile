// lib/zero_ui/widgets/camera_viewport.dart

import 'package:beacon_ai/core/services/camera_service.dart';
import 'package:beacon_ai/core/theme/app_theme.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// A stylized viewport showing the live camera feed for the Visual HUD.
class CameraViewport extends StatefulWidget {
  const CameraViewport({super.key});

  @override
  State<CameraViewport> createState() => _CameraViewportState();
}

class _CameraViewportState extends State<CameraViewport> {
  bool _isInitializing = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final service = CameraService.instance;
    if (!service.isReady) {
      final success = await service.initialize();
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = !success;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.subtleGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.pureWhite.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.beaconYellow),
      );
    }

    if (_hasError || CameraService.instance.controller == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off_rounded, color: Colors.white38, size: 40),
            SizedBox(height: 8),
            Text('Camera Unavailable', style: TextStyle(color: Colors.white38)),
          ],
        ),
      );
    }

    // Display the live camera feed cropped cleanly within the container
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: CameraService.instance.controller!.value.previewSize?.height ?? 1,
          height: CameraService.instance.controller!.value.previewSize?.width ?? 1,
          child: CameraPreview(CameraService.instance.controller!),
        ),
      ),
    );
  }
}