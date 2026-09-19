// lib/core/services/camera_service.dart

import 'dart:convert';
import 'dart:developer';
import 'package:camera/camera.dart';

/// Service managing silent background camera operations for AI vision processing.
class CameraService {
  CameraService._();
  static final CameraService instance = CameraService._();

  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;

  bool get isReady => _isInitialized && _controller != null;
  CameraController? get controller => _controller;

  /// Initializes the background camera (prefers back camera, medium resolution for speed).
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        log('CameraService: No cameras found on device.');
        return false;
      }

      // Find the first back camera, fallback to the first available one
      final backCamera = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      // Medium resolution provides a great balance between AI clarity and fast payload size
      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      _isInitialized = true;
      log('CameraService: Initialized successfully.');
      return true;
    } catch (e, st) {
      log('CameraService: Initialization failed: $e', stackTrace: st);
      _isInitialized = false;
      return false;
    }
  }

  /// Silently captures a frame and returns it as a Base64 encoded JPEG string.
  Future<String?> takeSnapshotBase64() async {
    if (!_isInitialized || _controller == null) {
      final initSuccess = await initialize();
      if (!initSuccess) return null;
    }

    try {
      final XFile imageFile = await _controller!.takePicture();
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      log('CameraService: Snapshot captured. Base64 length: ${base64Image.length}');
      return base64Image;
    } catch (e, st) {
      log('CameraService: Failed to capture snapshot: $e', stackTrace: st);
      return null;
    }
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _isInitialized = false;
  }
}