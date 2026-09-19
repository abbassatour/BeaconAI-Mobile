// lib/core/services/onesignal_service.dart

import 'dart:developer';
import 'package:beacon_ai/core/constants/api_constants.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// Service managing OneSignal push notifications and daily audio briefings.
class OneSignalService {
  OneSignalService._();
  static final OneSignalService instance = OneSignalService._();

  /// Initializes the OneSignal SDK and requests notification permissions.
  static Future<void> initialize() async {
    final appId = ApiConstants.oneSignalAppId;

    if (appId.isEmpty || appId.contains('YOUR_ONESIGNAL')) {
      log('OneSignalService: App ID missing. Running without push notifications.');
      return;
    }

    try {
      // Remove this method to stop OneSignal Debugging in production
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

      OneSignal.initialize(appId);

      // Prompt the user for push notification permission.
      // In a real app, you might want to call this at a specific UI moment, 
      // but for the hackathon, doing it at boot is acceptable.
      await OneSignal.Notifications.requestPermission(true);

      log('OneSignalService: Initialized successfully.');
    } catch (e, st) {
      log('OneSignalService: Initialization error: $e', stackTrace: st);
    }
  }
}