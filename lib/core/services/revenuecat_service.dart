// lib/core/services/revenuecat_service.dart

import 'dart:developer';
import 'dart:io';
import 'package:beacon_ai/core/constants/api_constants.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Service managing freemium limitations and Pro subscriptions via RevenueCat.
class RevenueCatService {
  RevenueCatService._();
  static final RevenueCatService instance = RevenueCatService._();

  bool _isInitialized = false;

  /// Initializes the RevenueCat SDK safely.
  static Future<void> initialize() async {
    final apiKey = ApiConstants.revenueCatApiKey;
    
    if (apiKey.isEmpty || apiKey.contains('YOUR_REVENUECAT')) {
      log('RevenueCatService: API Key missing. Running in offline/free fallback mode.');
      return;
    }

    try {
      await Purchases.setLogLevel(LogLevel.warn);

      late PurchasesConfiguration configuration;
      // Note: For a real cross-platform app, you'd have an iOS key and an Android key.
      // We use the same env variable here for hackathon simplicity.
      configuration = PurchasesConfiguration(apiKey);
      
      await Purchases.configure(configuration);
      instance._isInitialized = true;
      log('RevenueCatService: Connected to RevenueCat successfully.');
    } catch (e, st) {
      log('RevenueCatService: Init error: $e', stackTrace: st);
    }
  }

  /// Checks if the current user has the active "pro" entitlement.
  Future<bool> isProUser() async {
    if (!_isInitialized) return false;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      // "pro" is the standard entitlement identifier we will set in the RevenueCat dashboard
      return customerInfo.entitlements.all['pro']?.isActive == true;
    } catch (e) {
      log('RevenueCatService: Failed to fetch customer info: $e');
      return false;
    }
  }

  /// Attempts to purchase the primary Pro package.
  Future<bool> purchasePro() async {
    if (!_isInitialized) return false;
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        // Purchase the first available package (e.g., Monthly Pro)
        final purchaseResult = await Purchases.purchasePackage(offerings.current!.availablePackages.first);
        
        // In v10+, we access customerInfo through the purchaseResult object
        return purchaseResult.customerInfo.entitlements.all['pro']?.isActive == true;
      }
      return false;
    } catch (e) {
      log('RevenueCatService: Purchase failed or cancelled: $e');
      return false;
    }
  }
}