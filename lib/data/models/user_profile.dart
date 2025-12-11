import 'package:hive/hive.dart';

part 'user_profile.g.dart';

/// User profile model with streak information.
/// Cached locally with Hive for offline-first access.
@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime currentStreakStart;

  @HiveField(2)
  final DateTime? lastUpdated;

  UserProfile({
    required this.id,
    required this.currentStreakStart,
    this.lastUpdated,
  });

  /// Create from Supabase response map.
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      currentStreakStart: DateTime.parse(map['current_streak_start'] as String),
      lastUpdated: DateTime.now(),
    );
  }

  /// Convert to map for Supabase upsert.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'current_streak_start': currentStreakStart.toIso8601String(),
    };
  }

  /// Copy with updated streak start time.
  UserProfile copyWith({
    String? id,
    DateTime? currentStreakStart,
    DateTime? lastUpdated,
  }) {
    return UserProfile(
      id: id ?? this.id,
      currentStreakStart: currentStreakStart ?? this.currentStreakStart,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
