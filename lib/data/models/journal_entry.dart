import 'package:hive/hive.dart';

part 'journal_entry.g.dart';

/// Journal entry model for daily check-ins.
/// Cached locally with Hive for offline-first access.
@HiveType(typeId: 1)
class JournalEntry extends HiveObject {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final int moodRating;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final String title;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final bool isSynced;

  JournalEntry({
    this.id,
    required this.userId,
    required this.moodRating,
    required this.content,
    required this.title,
    required this.createdAt,
    this.isSynced = false,
  });

  /// Create from Supabase response map.
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id']?.toString(),
      userId: map['user_id'] as String,
      moodRating: map['mood_rating'] as int,
      content: map['content'] as String? ?? '',
      title: map['title'] as String? ?? 'Daily Check-in',
      createdAt: DateTime.parse(map['created_at'] as String),
      isSynced: true,
    );
  }

  /// Convert to map for Supabase insert.
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'mood_rating': moodRating,
      'content': content,
      'title': title,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get mood label from rating.
  String get moodLabel {
    const moodMap = {
      1: 'Drained 💀',
      2: 'Meh 😐',
      3: 'Okay 🌊',
      4: 'Good 🔋',
      5: 'God Mode ⚡',
    };
    return moodMap[moodRating] ?? 'Mood: $moodRating';
  }

  /// Mark as synced.
  JournalEntry copyWithSynced() {
    return JournalEntry(
      id: id,
      userId: userId,
      moodRating: moodRating,
      content: content,
      title: title,
      createdAt: createdAt,
      isSynced: true,
    );
  }
}
