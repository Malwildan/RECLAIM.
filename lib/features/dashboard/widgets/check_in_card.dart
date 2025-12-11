import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/constants.dart';

/// Daily check-in card widget.
class CheckInCard extends StatelessWidget {
  final bool hasCheckedInToday;
  final VoidCallback? onTap;

  const CheckInCard({super.key, required this.hasCheckedInToday, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasCheckedInToday ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasCheckedInToday
                ? AppColors.accentGreen.withOpacity(0.3)
                : AppColors.borderLight,
          ),
          borderRadius: BorderRadius.circular(24),
          color: hasCheckedInToday
              ? AppColors.accentGreen.withOpacity(0.05)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasCheckedInToday
                      ? AppStrings.checkInComplete
                      : AppStrings.dailyCheckIn,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: hasCheckedInToday
                        ? AppColors.accentGreen
                        : Colors.white,
                  ),
                ),
                Text(
                  hasCheckedInToday
                      ? AppStrings.seeYouTomorrow
                      : AppStrings.logMoodTriggers,
                  style: TextStyle(
                    color: hasCheckedInToday
                        ? AppColors.accentGreen.withOpacity(0.7)
                        : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: hasCheckedInToday ? AppColors.accentGreen : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasCheckedInToday ? Icons.check : Icons.edit,
                color: Colors.black,
                size: 16,
              ),
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.2, end: 0, delay: 200.ms),
    );
  }
}
