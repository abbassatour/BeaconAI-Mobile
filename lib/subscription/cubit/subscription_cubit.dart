// lib/subscription/cubit/subscription_cubit.dart

import 'package:beacon_ai/core/services/revenuecat_service.dart';
import 'package:beacon_ai/subscription/cubit/subscription_state.dart';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the user's subscription status and enforces freemium limitations.
class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit({RevenueCatService? rcService})
      : _rc = rcService ?? RevenueCatService.instance,
        super(const SubscriptionState()) {
    checkSubscriptionStatus();
  }

  final RevenueCatService _rc;

  /// Verifies with RevenueCat if the user has an active 'pro' entitlement.
  Future<void> checkSubscriptionStatus() async {
    emit(state.copyWith(status: SubscriptionStatus.loading));
    try {
      final isPro = await _rc.isProUser();
      
      // Load free queries count from local storage
      final prefs = await SharedPreferences.getInstance();
      final queriesLeft = prefs.getInt('free_queries_left') ?? 5;

      emit(state.copyWith(
        status: isPro ? SubscriptionStatus.pro : SubscriptionStatus.free,
        freeQueriesRemaining: queriesLeft,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionStatus.error,
        errorMessage: 'Failed to verify subscription status.',
      ));
    }
  }

  /// Deducts a visual query from the daily free limit.
  Future<void> decrementFreeQuery() async {
    if (state.isPro) return; // Pro users have unlimited queries

    final newCount = (state.freeQueriesRemaining - 1).clamp(0, 5);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('free_queries_left', newCount);

    emit(state.copyWith(freeQueriesRemaining: newCount));
  }

  /// Triggers the RevenueCat purchase flow.
  Future<bool> purchasePro() async {
    emit(state.copyWith(status: SubscriptionStatus.loading));
    final success = await _rc.purchasePro();
    
    if (success) {
      emit(state.copyWith(status: SubscriptionStatus.pro));
    } else {
      emit(state.copyWith(
        status: SubscriptionStatus.free,
        errorMessage: 'Purchase was cancelled or failed.',
      ));
    }
    return success;
  }
}