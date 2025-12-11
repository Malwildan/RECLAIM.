import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';

/// Check-in viewmodel for handling daily mood logging.
class CheckInViewmodel extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  CheckInViewmodel(this._ref) : super(const AsyncValue.data(null));

  /// Log a daily check-in.
  Future<void> logCheckIn(int moodRating, String content) async {
    state = const AsyncValue.loading();

    try {
      final journalRepo = _ref.read(journalRepositoryProvider);
      await journalRepo.logDailyCheckIn(moodRating, content);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for the check-in viewmodel.
final checkInViewmodelProvider =
    StateNotifierProvider<CheckInViewmodel, AsyncValue<void>>((ref) {
      return CheckInViewmodel(ref);
    });
