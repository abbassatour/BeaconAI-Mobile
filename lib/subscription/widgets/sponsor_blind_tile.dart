// lib/subscription/widgets/sponsor_blind_tile.dart

import 'package:beacon_ai/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SponsorBlindTile extends StatelessWidget {
  const SponsorBlindTile({
    required this.onTap,
    super.key,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.beaconYellow.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.volunteer_activism_rounded, color: AppTheme.beaconYellow, size: 40),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sponsor a User',
                    style: TextStyle(
                      color: AppTheme.beaconYellow,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pay it forward. Gift unlimited AI vision to someone in need.',
                    style: TextStyle(
                      color: AppTheme.pureWhite,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}