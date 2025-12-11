import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/services.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

// ============================================================================
// Service Providers
// ============================================================================

/// Provides the Supabase service instance.
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

/// Provides the Gemini service instance.
final geminiServiceProvider = Provider<GeminiService>((ref) {
  final service = GeminiService();
  service.initialize();
  return service;
});

/// Provides direct access to Supabase client.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// ============================================================================
// Hive Box Providers
// ============================================================================

/// Provides the user profile Hive box.
final userProfileBoxProvider = Provider<Box<UserProfile>>((ref) {
  return Hive.box<UserProfile>('profiles');
});

/// Provides the journal entry Hive box.
final journalBoxProvider = Provider<Box<JournalEntry>>((ref) {
  return Hive.box<JournalEntry>('journals');
});

/// Provides the relapse entry Hive box.
final relapseBoxProvider = Provider<Box<RelapseEntry>>((ref) {
  return Hive.box<RelapseEntry>('relapses');
});

// ============================================================================
// Repository Providers
// ============================================================================

/// Provides the streak repository.
final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepository(
    supabase: ref.watch(supabaseClientProvider),
    cache: ref.watch(userProfileBoxProvider),
  );
});

/// Provides the journal repository.
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository(
    supabase: ref.watch(supabaseClientProvider),
    cache: ref.watch(journalBoxProvider),
  );
});

/// Provides the relapse repository.
final relapseRepositoryProvider = Provider<RelapseRepository>((ref) {
  return RelapseRepository(
    supabase: ref.watch(supabaseClientProvider),
    cache: ref.watch(relapseBoxProvider),
    streakRepository: ref.watch(streakRepositoryProvider),
  );
});
