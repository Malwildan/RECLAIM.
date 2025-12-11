import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/journal_entry.dart';

/// Repository for managing journal entries.
/// Implements offline-first caching with Supabase sync.
class JournalRepository {
  final SupabaseClient _supabase;
  final Box<JournalEntry> _cache;

  JournalRepository({
    required SupabaseClient supabase,
    required Box<JournalEntry> cache,
  }) : _supabase = supabase,
       _cache = cache;

  /// Get the current user ID.
  String? get _userId => _supabase.auth.currentUser?.id;

  /// Log a daily check-in.
  Future<void> logDailyCheckIn(int moodRating, String content) async {
    if (_userId == null) return;

    final entry = JournalEntry(
      userId: _userId!,
      moodRating: moodRating,
      content: content,
      title: 'Daily Check-in',
      createdAt: DateTime.now(),
      isSynced: false,
    );

    // Save to Supabase
    await _supabase.from('journals').insert(entry.toMap());

    // Cache locally
    await _cache.add(entry.copyWithSynced());
  }

  /// Check if user has logged today.
  Future<bool> hasLoggedToday() async {
    if (_userId == null) return false;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
    ).toIso8601String();

    final response = await _supabase
        .from('journals')
        .select('id')
        .eq('user_id', _userId!)
        .gte('created_at', startOfDay)
        .lte('created_at', endOfDay)
        .limit(1);

    return (response as List).isNotEmpty;
  }

  /// Get the last log text (mood rating as label).
  Future<String> getLastLogText() async {
    if (_userId == null) return 'No logs yet';

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();

    // Fetch latest journal entry BEFORE today
    final List<dynamic> journals = await _supabase
        .from('journals')
        .select('mood_rating, created_at')
        .eq('user_id', _userId!)
        .lt('created_at', startOfDay)
        .order('created_at', ascending: false)
        .limit(1);

    if (journals.isNotEmpty) {
      final mood =
          (journals.first as Map<String, dynamic>)['mood_rating'] as int?;
      if (mood != null) {
        const moodMap = {
          1: 'Drained 💀',
          2: 'Meh 😐',
          3: 'Okay 🌊',
          4: 'Good 🔋',
          5: 'God Mode ⚡',
        };
        return moodMap[mood] ?? 'Mood: $mood/10';
      }
    }

    return 'No logs yet';
  }

  /// Get journal history.
  Future<List<JournalEntry>> getJournalHistory() async {
    if (_userId == null) return [];

    final List<dynamic> response = await _supabase
        .from('journals')
        .select('*')
        .eq('user_id', _userId!)
        .order('created_at', ascending: false);

    return response
        .map((e) => JournalEntry.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
