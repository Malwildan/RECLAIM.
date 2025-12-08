import 'package:flutter/material.dart';

class LevelSystem {
  // The thresholds for leveling up
  static final List<Map<String, dynamic>> levels = [
    {'days': 0, 'title': 'CLOWN', 'color': Color(0xFFFF2659)},      // Red
    {'days': 1, 'title': 'NOOB', 'color': Color(0xFF9E9E9E)},       // Grey
    {'days': 3, 'title': 'BEGINNER', 'color': Color(0xFFFFFFFF)},   // White
    {'days': 7, 'title': 'MID', 'color': Color(0xFFB4F8C8)},        // Mint
    {'days': 14, 'title': 'ADVANCED', 'color': Color(0xFF64FFDA)},  // Teal
    {'days': 30, 'title': 'SIGMA', 'color': Color(0xFF448AFF)},     // Blue
    {'days': 45, 'title': 'CHAD', 'color': Color(0xFF7C4DFF)},      // Indigo
    {'days': 60, 'title': 'ABSOLUTE CHAD', 'color': Color(0xFFAA00FF)}, // Purple
    {'days': 120, 'title': 'ALPHA', 'color': Color(0xFFFF4081)},    // Pink
    {'days': 365, 'title': 'GOD MODE', 'color': Color(0xFFFFD700)}, // Gold
  ];

  static Map<String, dynamic> getCurrentLevel(int streakDays) {
    // Find the highest level the user has achieved
    return levels.lastWhere((lvl) => streakDays >= lvl['days'], 
        orElse: () => levels[0]);
  }

  static Map<String, dynamic> getNextLevel(int streakDays) {
    // Find the first level that is strictly greater than current days
    return levels.firstWhere((lvl) => lvl['days'] > streakDays, 
        orElse: () => {'days': 9999, 'title': 'MAXED OUT'});
  }

  static double getProgressToNextLevel(int streakDays) {
    final current = getCurrentLevel(streakDays);
    final next = getNextLevel(streakDays);
    
    if (next['days'] == 9999) return 1.0; // Max level

    // Math: (Current Streak - Level Start) / (Next Level Start - Level Start)
    int daysIntoLevel = streakDays - (current['days'] as int);
    int levelDuration = (next['days'] as int) - (current['days'] as int);
    
    return daysIntoLevel / levelDuration;
  }

  static double getProgressToNextLevelPrecise(Duration streak) {
    final int streakDays = streak.inDays;
    final current = getCurrentLevel(streakDays);
    final next = getNextLevel(streakDays);
    
    if (next['days'] == 9999) return 1.0; // Max level

    // Convert streak to precise days (e.g. 1.5 days)
    double streakDaysPrecise = streak.inMilliseconds / (24 * 60 * 60 * 1000);
    
    // Math: (Current Streak - Level Start) / (Next Level Start - Level Start)
    double daysIntoLevel = streakDaysPrecise - (current['days'] as int);
    int levelDuration = (next['days'] as int) - (current['days'] as int);
    
    return daysIntoLevel / levelDuration;
  }
}
