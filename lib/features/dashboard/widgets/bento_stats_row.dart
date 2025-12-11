import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils/level_system.dart';

/// Bento stats row with last log and next level cards.
class BentoStatsRow extends StatelessWidget {
  final String lastLogText;
  final Duration currentStreak;
  final VoidCallback onLastLogTap;
  final VoidCallback onNextLevelTap;

  const BentoStatsRow({
    super.key,
    required this.lastLogText,
    required this.currentStreak,
    required this.onLastLogTap,
    required this.onNextLevelTap,
  });

  @override
  Widget build(BuildContext context) {
    final days = currentStreak.inDays;
    final nextLvl = LevelSystem.getNextLevel(days);
    final progress = LevelSystem.getProgressToNextLevelPrecise(currentStreak);

    return Row(
      children: [
        // Last Log Card
        Expanded(
          child: GestureDetector(
            onTap: onLastLogTap,
            child: _buildBentoCard(
              title: AppStrings.lastLog,
              content: lastLogText.isEmpty ? AppStrings.noLogsYet : lastLogText,
              icon: Icons.bubble_chart,
              color: AppColors.cardBackground,
              textColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Next Level Card
        Expanded(
          child: GestureDetector(
            onTap: onNextLevelTap,
            child: _buildNextLevelCard(nextLvl, days, progress),
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.2, end: 0, delay: 100.ms);
  }

  Widget _buildBentoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: textColor.withOpacity(0.9), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    content,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextLevelCard(
    Map<String, dynamic> nextLvl,
    int days,
    double progress,
  ) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.shield_outlined, color: Colors.grey, size: 20),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.nextLevel,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        nextLvl['title'],
                        style: TextStyle(
                          color: nextLvl['color'],
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              color: (nextLvl['color'] as Color).withOpacity(
                                0.5,
                              ),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Circular Progress
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 5,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: (1.0 - progress).clamp(0.0, 1.0),
                  strokeWidth: 5,
                  backgroundColor: Colors.transparent,
                  color: AppColors.accentGreen,
                  strokeCap: StrokeCap.round,
                ),
              ),
              SizedBox(
                width: 36,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(nextLvl['days'] as int) - days}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'DAYS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 6,
                          color: Colors.grey,
                        ),
                      ),
                      const Text(
                        'LEFT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 6,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
