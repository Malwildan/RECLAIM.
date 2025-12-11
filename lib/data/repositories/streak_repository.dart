import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

/// Repository for managing streak data.
/// Implements offline-first caching with Supabase sync.
class StreakRepository {
  final SupabaseClient _supabase;
  final Box<UserProfile> _cache;

  StreakRepository({
    required SupabaseClient supabase,
    required Box<UserProfile> cache,
  }) : _supabase = supabase,
       _cache = cache;

  /// Get the current user ID.
  String? get _userId => _supabase.auth.currentUser?.id;

  /// Get streak start time.
  /// Tries cache first, then fetches from Supabase.
  Future<DateTime> getStreakStart() async {
    if (_userId == null) return DateTime.now();

    // Try cache first
    final cached = _cache.get(_userId);
    if (cached != null) {
      // Refresh in background
      _refreshFromRemote();
      return cached.currentStreakStart;
    }

    // Fetch from Supabase
    return await _fetchFromRemote();
  }

  /// Fetch streak data from Supabase and cache it.
  Future<DateTime> _fetchFromRemote() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('current_streak_start')
          .eq('id', _userId!)
          .single();

      if (response['current_streak_start'] != null) {
        final raw = response['current_streak_start'];
        final parsed = DateTime.parse(raw).toUtc();

        // Cache the result
        await _cache.put(
          _userId,
          UserProfile(
            id: _userId!,
            currentStreakStart: parsed,
            lastUpdated: DateTime.now(),
          ),
        );

        return parsed;
      }
    } catch (e) {
      // Fall through to return now
    }
    return DateTime.now();
  }

  /// Refresh cache from remote in background.
  Future<void> _refreshFromRemote() async {
    try {
      await _fetchFromRemote();
    } catch (_) {
      // Ignore background refresh errors
    }
  }

  /// Reset streak to now.
  Future<void> resetStreak() async {
    if (_userId == null) return;

    final now = DateTime.now().toUtc();

    // Update Supabase
    await _supabase.from('profiles').upsert({
      'id': _userId,
      'current_streak_start': now.toIso8601String(),
    });

    // Update cache
    await _cache.put(
      _userId,
      UserProfile(
        id: _userId!,
        currentStreakStart: now,
        lastUpdated: DateTime.now(),
      ),
    );
  }

  /// Calculate current streak duration.
  Duration getCurrentStreakDuration() {
    final cached = _cache.get(_userId);
    if (cached == null) return Duration.zero;

    final now = DateTime.now().toUtc();
    final diff = now.difference(cached.currentStreakStart.toUtc());
    return diff.isNegative ? Duration.zero : diff;
  }
}
