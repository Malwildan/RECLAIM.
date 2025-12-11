import 'package:hive/hive.dart';

part 'relapse_entry.g.dart';

/// Relapse entry model for tracking relapse events.
/// Cached locally with Hive for offline-first access.
@HiveType(typeId: 2)
class RelapseEntry extends HiveObject {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String triggerSource;

  @HiveField(3)
  final String location;

  @HiveField(4)
  final String notes;

  @HiveField(5)
  final DateTime occurredAt;

  @HiveField(6)
  final bool isSynced;

  RelapseEntry({
    this.id,
    required this.userId,
    required this.triggerSource,
    required this.location,
    required this.notes,
    required this.occurredAt,
    this.isSynced = false,
  });

  /// Create from Supabase response map.
  factory RelapseEntry.fromMap(Map<String, dynamic> map) {
    return RelapseEntry(
      id: map['id']?.toString(),
      userId: map['user_id'] as String,
      triggerSource: map['trigger_source'] as String? ?? 'Unknown',
      location: map['location'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      occurredAt: DateTime.parse(map['occurred_at'] as String),
      isSynced: true,
    );
  }

  /// Convert to map for Supabase insert.
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'trigger_source': triggerSource,
      'location': location,
      'notes': notes,
      'occurred_at': occurredAt.toIso8601String(),
    };
  }

  /// Mark as synced.
  RelapseEntry copyWithSynced() {
    return RelapseEntry(
      id: id,
      userId: userId,
      triggerSource: triggerSource,
      location: location,
      notes: notes,
      occurredAt: occurredAt,
      isSynced: true,
    );
  }
}
