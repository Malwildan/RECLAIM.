import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/relapse_entry.dart';
import 'streak_repository.dart';

/// Repository for managing relapse entries.
/// Implements offline-first caching with Supabase sync.
class RelapseRepository {
  final SupabaseClient _supabase;
  final Box<RelapseEntry> _cache;
  final StreakRepository _streakRepository;

  RelapseRepository({
    required SupabaseClient supabase,
    required Box<RelapseEntry> cache,
    required StreakRepository streakRepository,
  }) : _supabase = supabase,
       _cache = cache,
       _streakRepository = streakRepository;

  /// Get the current user ID.
  String? get _userId => _supabase.auth.currentUser?.id;

  /// Log a detailed relapse entry.
  Future<void> logRelapseDetailed({
    required String trigger,
    required String location,
    required String notes,
  }) async {
    if (_userId == null) return;

    final now = DateTime.now().toUtc();

    final entry = RelapseEntry(
      userId: _userId!,
      triggerSource: trigger,
      location: location,
      notes: notes,
      occurredAt: now,
      isSynced: false,
    );

    // Log the detailed relapse to Supabase
    await _supabase.from('relapses').insert(entry.toMap());

    // Reset the streak
    await _streakRepository.resetStreak();

    // Cache locally
    await _cache.add(entry.copyWithSynced());
  }

  /// Get relapse history.
  Future<List<RelapseEntry>> getRelapseHistory() async {
    if (_userId == null) return [];

    final List<dynamic> response = await _supabase
        .from('relapses')
        .select('*')
        .eq('user_id', _userId!)
        .order('occurred_at', ascending: false);

    return response
        .map((e) => RelapseEntry.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Get last relapse trigger (for dashboard display).
  Future<String?> getLastRelapseTrigger() async {
    if (_userId == null) return null;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();

    final List<dynamic> relapses = await _supabase
        .from('relapses')
        .select('trigger_source, occurred_at')
        .eq('user_id', _userId!)
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

    return null;
  }
}
