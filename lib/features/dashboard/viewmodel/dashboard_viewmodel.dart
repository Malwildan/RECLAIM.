import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';

/// State class for the dashboard.
class DashboardState {
  final DateTime? streakStartTime;
  final Duration currentStreak;
  final String lastLogText;
  final bool hasCheckedInToday;
  final bool isLoading;

  const DashboardState({
    this.streakStartTime,
    this.currentStreak = Duration.zero,
    this.lastLogText = '',
    this.hasCheckedInToday = false,
    this.isLoading = true,
  });

  DashboardState copyWith({
    DateTime? streakStartTime,
    Duration? currentStreak,
    String? lastLogText,
    bool? hasCheckedInToday,
    bool? isLoading,
  }) {
    return DashboardState(
      streakStartTime: streakStartTime ?? this.streakStartTime,
      currentStreak: currentStreak ?? this.currentStreak,
      lastLogText: lastLogText ?? this.lastLogText,
      hasCheckedInToday: hasCheckedInToday ?? this.hasCheckedInToday,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Dashboard ViewModel using Riverpod StateNotifier.
class DashboardViewmodel extends StateNotifier<DashboardState> {
  final Ref _ref;
  Timer? _timer;

  DashboardViewmodel(this._ref) : super(const DashboardState()) {
    _initData();
  }

  /// Initialize dashboard data.
  Future<void> _initData() async {
    final supabaseService = _ref.read(supabaseServiceProvider);
    final streakRepo = _ref.read(streakRepositoryProvider);
    final journalRepo = _ref.read(journalRepositoryProvider);

    // Ensure logged in
    await supabaseService.ensureLoggedIn();

    // Get data
    final streakStart = await streakRepo.getStreakStart();
    final lastLog = await journalRepo.getLastLogText();
    final hasCheckedIn = await journalRepo.hasLoggedToday();

    // Update state
    state = state.copyWith(
      streakStartTime: streakStart,
      lastLogText: lastLog,
      hasCheckedInToday: hasCheckedIn,
      isLoading: false,
    );

    _updateStreakDuration();
    _startTimer();
  }

  /// Start the timer to update streak every second.
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateStreakDuration();
    });
  }

  /// Update the current streak duration.
  void _updateStreakDuration() {
    final streakStart = state.streakStartTime;
    if (streakStart == null) return;

    final now = DateTime.now().toUtc();
    final startUtc = streakStart.toUtc();
    final diff = now.difference(startUtc);

    state = state.copyWith(
      currentStreak: diff.isNegative ? Duration.zero : diff,
    );
  }

  /// Refresh all dashboard data.
  Future<void> refreshData() async {
    state = state.copyWith(isLoading: true);
    await _initData();
  }

  /// Mark that a check-in was completed.
  void markCheckInComplete() {
    state = state.copyWith(hasCheckedInToday: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Provider for the dashboard viewmodel.
final dashboardViewmodelProvider =
    StateNotifierProvider<DashboardViewmodel, DashboardState>((ref) {
      return DashboardViewmodel(ref);
    });
