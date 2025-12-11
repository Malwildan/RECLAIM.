import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/constants.dart';

/// Analytics teaser card widget for navigating to stats screen.
class AnalyticsTeaserCard extends StatelessWidget {
  final VoidCallback onTap;

  const AnalyticsTeaserCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF111111)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBackgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.insights,
                color: AppColors.accentGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.dataAnalytics,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  AppStrings.viewTriggerPatterns,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            // Mini chart visual
            SizedBox(
              width: 40,
              height: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniBar(10),
                  _buildMiniBar(20),
                  _buildMiniBar(15),
                  _buildMiniBar(25),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.2, end: 0, delay: 300.ms),
    );
  }

  Widget _buildMiniBar(double height) {
    return Container(
      width: 6,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withOpacity(0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
