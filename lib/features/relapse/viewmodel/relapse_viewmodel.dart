import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';

/// Relapse viewmodel for handling relapse logging.
class RelapseViewmodel extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  RelapseViewmodel(this._ref) : super(const AsyncValue.data(null));

  /// Log a relapse with details.
  Future<void> logRelapse({
    required String trigger,
    required String location,
    required String notes,
  }) async {
    state = const AsyncValue.loading();

    try {
      final relapseRepo = _ref.read(relapseRepositoryProvider);
      await relapseRepo.logRelapseDetailed(
        trigger: trigger,
        location: location,
        notes: notes,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for the relapse viewmodel.
final relapseViewmodelProvider =
    StateNotifierProvider<RelapseViewmodel, AsyncValue<void>>((ref) {
      return RelapseViewmodel(ref);
    });
