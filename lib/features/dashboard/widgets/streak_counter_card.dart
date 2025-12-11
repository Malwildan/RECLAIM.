import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils/level_system.dart';

/// Streak counter card widget displaying current streak with level.
class StreakCounterCard extends StatelessWidget {
  final Duration currentStreak;

  const StreakCounterCard({super.key, required this.currentStreak});

  @override
  Widget build(BuildContext context) {
    final currentLvl = LevelSystem.getCurrentLevel(currentStreak.inDays);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.accentGreen,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.currentStreak,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${currentStreak.inDays}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 60,
                          height: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'DAYS',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Monospace Timer
                Text(
                  '${(currentStreak.inHours % 24).toString().padLeft(2, '0')} : '
                  '${(currentStreak.inMinutes % 60).toString().padLeft(2, '0')} : '
                  '${(currentStreak.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Courier',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Level Emoji
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.myLevel,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentLvl['emoji'] ?? '🤡',
                  style: const TextStyle(fontSize: 50),
                ),
                Text(
                  currentLvl['title'] ?? 'CLOWN',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }
}
