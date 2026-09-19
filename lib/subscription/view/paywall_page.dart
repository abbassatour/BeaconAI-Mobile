// lib/subscription/view/paywall_page.dart

import 'package:beacon_ai/core/theme/app_theme.dart';
import 'package:beacon_ai/subscription/cubit/subscription_cubit.dart';
import 'package:beacon_ai/subscription/cubit/subscription_state.dart';
import 'package:beacon_ai/subscription/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const PaywallPage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SubscriptionCubit(),
      child: const _PaywallView(),
    );
  }
}

class _PaywallView extends StatelessWidget {
  const _PaywallView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.pureBlack,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.beaconYellow),
      ),
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        listener: (context, state) {
          if (state.status == SubscriptionStatus.pro) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Welcome to BeaconAI Pro! Unlimited vision unlocked.'),
                backgroundColor: AppTheme.beaconYellow,
              ),
            );
            Navigator.of(context).pop();
          } else if (state.status == SubscriptionStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred.'),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == SubscriptionStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.beaconYellow),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LIMITLESS\nVISION',
                  style: TextStyle(
                    color: AppTheme.pureWhite,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your daily free queries are running low. Upgrade to Pro for unlimited spatial AI assistance, offline priority, and more.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                
                HighContrastPlanCard(
                  title: 'Pro',
                  price: '\$9.99 / mo',
                  description: 'Unlimited Gemini AI queries, priority processing, and 24/7 emergency radar.',
                  onTap: () => context.read<SubscriptionCubit>().purchasePro(),
                ),
                
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    '— OR —',
                    style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                
                SponsorBlindTile(
                  onTap: () => context.read<SubscriptionCubit>().purchasePro(),
                ),
                
                const SizedBox(height: 40),
                const Text(
                  'Subscription auto-renews. Cancel anytime in your device settings. Powered securely by RevenueCat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}