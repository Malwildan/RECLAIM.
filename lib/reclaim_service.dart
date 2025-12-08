import 'package:supabase_flutter/supabase_flutter.dart';

class ReclaimService {
  final _supabase = Supabase.instance.client;

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
      return DateTime.parse(response['current_streak_start']);
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
      'was_successful': wasSuccessful 
    });
  }

  // 4. LOG DAILY MOOD
  Future<void> logDailyCheckIn(int moodRating, String content) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('journals').insert({
      'user_id': user.id,
      'mood_rating': moodRating, // 1 to 5 scale
      'content': content,        // Optional note
      'title': 'Daily Check-in',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // 5. LOG RELAPSE WITH ANALYSIS
  Future<void> logRelapseDetailed({
    required String trigger,
    required String location,
    required String notes,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Log the detailed relapse
    await _supabase.from('relapses').insert({
      'user_id': user.id,
      'trigger_source': trigger,
      'location': location,
      'notes': notes,
      'occurred_at': DateTime.now().toIso8601String(),
    });

    // Note: The Database Trigger (PostgreSQL) automatically resets 
    // the 'current_streak_start' in the profiles table when this runs.
  }
}