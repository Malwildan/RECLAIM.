import 'package:supabase_flutter/supabase_flutter.dart';

/// Wrapper service for Supabase client access.
/// Provides centralized access to the Supabase instance.
class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get the Supabase client instance.
  SupabaseClient get client => _client;

  /// Get the current authenticated user.
  User? get currentUser => _client.auth.currentUser;

  /// Check if a user is logged in.
  bool get isLoggedIn => currentUser != null;

  /// Sign in anonymously if not already logged in.
  Future<void> ensureLoggedIn() async {
    if (!isLoggedIn) {
      await _client.auth.signInAnonymously();
    }
  }

  /// Get the current user ID or throw if not logged in.
  String get userId {
    final user = currentUser;
    if (user == null) {
      throw StateError('User is not logged in');
    }
    return user.id;
  }
}
