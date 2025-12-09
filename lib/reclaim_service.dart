import 'package:supabase_flutter/supabase_flutter.dart';

class ReclaimService {
  final _supabase = Supabase.instance.client;

  // --- NEW: FETCH RANDOM VIDEO ---
  Future<String?> getRandomVideoId() async {
    // 1. Fetch all video IDs (Assuming list is small < 100)
    final response = await _supabase
        .from('motivational_videos')
        .select('youtube_id');
    
    final List<dynamic> data = response;
    if (data.isEmpty) return null;

    // 2. Pick a random one locally
    final randomIndex = DateTime.now().microsecondsSinceEpoch % data.length;
    return data[randomIndex]['youtube_id'] as String;
  }

  // --- NEW: FETCH RELAPSE HISTORY ---
  Future<List<Map<String, dynamic>>> getRelapseHistory() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    // Fetch all relapses, ordered by newest first
    final List<dynamic> response = await _supabase
        .from('relapses')
        .select('trigger_source, occurred_at')
        .eq('user_id', user.id)
        .order('occurred_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // --- NEW: FETCH LAST LOG TEXT (Journal or Relapse) ---
  Future<String> getLastLogText() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return "No logs yet";

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();

    // Fetch latest journal entry BEFORE today
    final List<dynamic> journals = await _supabase
        .from('journals')
        .select('mood_rating, created_at')
        .eq('user_id', user.id)
        .lt('created_at', startOfDay)
        .order('created_at', ascending: false)
        .limit(1);

    if (journals.isNotEmpty) {
      final mood =
          (journals.first as Map<String, dynamic>)['mood_rating'] as int?;
      if (mood != null) {
        // Map integer mood to label + emoji
        const moodMap = {
          1: 'Drained 💀',
          2: 'Meh 😐',
          3: 'Okay 🌊',
          4: 'Good 🔋',
          5: 'God Mode ⚡',
        };
        return moodMap[mood] ?? "Mood: $mood/10";
      }
    }

    // Fallback to latest relapse trigger BEFORE today
    final List<dynamic> relapses = await _supabase
        .from('relapses')
        .select('trigger_source, occurred_at')
        .eq('user_id', user.id)
        .lt('occurred_at', startOfDay)
        .order('occurred_at', ascending: false)
        .limit(1);

    if (relapses.isNotEmpty) {
      final trigger =
          (relapses.first as Map<String, dynamic>)['trigger_source'] as String?;
      if (trigger != null && trigger.trim().isNotEmpty) {
        return trigger.trim();
      }
    }

    return "No logs yet";
  }

  // 1. ANONYMOUS LOGIN
  Future<void> ensureLoggedIn() async {
    if (_supabase.auth.currentUser == null) {
      await _supabase.auth.signInAnonymously();
    }
  }

  // 2. FETCH START DATE
  Future<DateTime> getStreakStart() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return DateTime.now();

    final response = await _supabase
        .from('profiles')
        .select('current_streak_start')
        .eq('id', user.id)
        .single();

    if (response['current_streak_start'] != null) {
      final raw = response['current_streak_start'];
      final parsed = DateTime.parse(raw);
      // Return UTC to compare against UTC 'now' consistently
      return parsed.toUtc();
    }

    return DateTime.now();
  }

  // 3. LOG PANIC BUTTON (Restored & Updated)
  // Now accepts 'wasSuccessful' to track if the user survived the urge
  Future<void> logPanic({bool wasSuccessful = false}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('panic_logs').insert({
      'user_id': user.id,
      'triggered_at': DateTime.now().toIso8601String(),
      'was_successful': wasSuccessful,
    });
  }

  // 4. LOG DAILY MOOD
  Future<void> logDailyCheckIn(int moodRating, String content) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('journals').insert({
      'user_id': user.id,
      'mood_rating': moodRating, // 1 to 5 scale
      'content': content, // Optional note
      'title': 'Daily Check-in',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // --- NEW: CHECK IF ALREADY LOGGED TODAY ---
  Future<bool> hasLoggedToday() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final response = await _supabase
        .from('journals')
        .select('id')
        .eq('user_id', user.id)
        .gte('created_at', startOfDay)
        .lte('created_at', endOfDay)
        .limit(1);

    return (response as List).isNotEmpty;
  }

  // 5. LOG RELAPSE WITH ANALYSIS
  Future<void> logRelapseDetailed({
    required String trigger,
    required String location,
    required String notes,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final now = DateTime.now().toUtc();

    // Log the detailed relapse
    await _supabase.from('relapses').insert({
      'user_id': user.id,
      'trigger_source': trigger,
      'location': location,
      'notes': notes,
      'occurred_at': now.toIso8601String(),
    });

    // CRITICAL FIX: Explicitly reset the streak start time
    // Don't rely on database triggers that might not exist
    await _supabase.from('profiles').upsert({
      'id': user.id,
      'current_streak_start': now.toIso8601String(),
    });
  }

  // 6. MANUAL STREAK RESET (Emergency fix if timer gets stuck)
  Future<void> resetStreak() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final now = DateTime.now().toUtc();
    await _supabase.from('profiles').upsert({
      'id': user.id,
      'current_streak_start': now.toIso8601String(),
    });
  }

  // 7. FETCH JOURNAL HISTORY
  Future<List<Map<String, dynamic>>> getJournalHistory() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final List<dynamic> response = await _supabase
        .from('journals')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
