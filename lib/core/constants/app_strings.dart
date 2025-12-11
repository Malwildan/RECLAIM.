/// Static string constants used throughout the app.
abstract class AppStrings {
  // App info
  static const String appName = 'Reclaim';
  static const String appTitle = 'RECLAIM.';

  // Dashboard strings
  static const String currentStreak = 'CURRENT STREAK';
  static const String myLevel = 'MY LEVEL';
  static const String lastLog = 'LAST LOG';
  static const String nextLevel = 'NEXT LEVEL';
  static const String daysLeft = 'DAYS LEFT';
  static const String noLogsYet = 'No logs yet';

  // Check-in strings
  static const String vibeCheck = 'VIBE CHECK';
  static const String dailyCheckIn = 'Daily Check-in';
  static const String checkInComplete = 'Check-in Complete';
  static const String logMoodTriggers = 'Log your mood & triggers.';
  static const String seeYouTomorrow = 'See you tomorrow.';
  static const String logIt = 'LOG IT';
  static const String anythingOnMind = 'Anything on your mind?';

  // Relapse strings
  static const String iRelapsed = 'I Relapsed';
  static const String resetAnalysis = 'RESET ANALYSIS';
  static const String resetCounter = 'RESET COUNTER';
  static const String beHonest = 'Be honest. Data beats addiction.';
  static const String whatTriggered = 'What triggered it?';
  static const String whereWereYou = 'Where were you?';
  static const String whatHappened = 'What happened?';

  // Stats strings
  static const String forensics = 'FORENSICS';
  static const String dataAnalytics = 'DATA ANALYTICS';
  static const String viewTriggerPatterns = 'View your trigger patterns';
  static const String noDataCleanRecord = 'No data. Clean record.';

  // Panic button
  static const String panicButton = 'PANIC BUTTON';

  // Mood labels
  static const List<String> moodLabels = [
    'Drained',
    'Meh',
    'Okay',
    'Good',
    'God Mode',
  ];

  // Trigger options
  static const List<String> triggerOptions = [
    'Stress/Anxiety',
    'Boredom',
    'Social Media',
    'Loneliness',
    'Insomnia',
    'Accidental Exposure',
    'Other',
  ];
}
