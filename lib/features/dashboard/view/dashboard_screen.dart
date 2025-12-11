import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import '../widgets/widgets.dart';
import '../../check_in/view/check_in_sheet.dart';
import '../../relapse/view/relapse_sheet.dart';
import '../../stats/view/stats_screen.dart';
import '../../panic/view/panic_screen.dart';
import '../../milestones/view/milestones_screen.dart';
import '../../journal_history/view/journal_history_screen.dart';
import '../../about/view/about_screen.dart';
import '../../splash/view/splash_screen.dart';
import '../../../shared/widgets/brain_fact_card.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils/top_snack_bar.dart';

/// Dashboard screen - main home view of the app.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardViewmodelProvider);

    if (state.isLoading) {
      return const SplashScreen();
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable content
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100), // Space for button
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(context, ref),
                    const SizedBox(height: 30),

                    // Streak Counter
                    StreakCounterCard(currentStreak: state.currentStreak),
                    const SizedBox(height: 16),

                    // Bento Stats Row
                    BentoStatsRow(
                      lastLogText: state.lastLogText,
                      currentStreak: state.currentStreak,
                      onLastLogTap: () => _navigateToJournalHistory(context),
                      onNextLevelTap: () => _navigateToMilestones(
                        context,
                        state.currentStreak.inDays,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Brain Fact Card
                    const BrainFactCard(),
                    const SizedBox(height: 16),

                    // Analytics Teaser
                    AnalyticsTeaserCard(onTap: () => _navigateToStats(context)),
                    const SizedBox(height: 16),

                    // Check-in Card
                    CheckInCard(
                      hasCheckedInToday: state.hasCheckedInToday,
                      onTap: () => _showCheckInSheet(context, ref),
                    ),
                  ],
                ),
              ),
            ),

            // Floating Panic Button at bottom (no background)
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: PanicButton(onTap: () => _navigateToPanicMode(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => _navigateToAbout(context),
          child: Text(
            AppStrings.appTitle,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _showRelapseSheet(context, ref),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardBackgroundLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.dangerRed.withOpacity(0.3)),
            ),
            child: Text(
              AppStrings.iRelapsed,
              style: const TextStyle(
                color: AppColors.dangerRed,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCheckInSheet(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CheckInSheet(),
    );

    if (result == true) {
      ref.read(dashboardViewmodelProvider.notifier).refreshData();
    }
  }

  void _showRelapseSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RelapseSheet(
        onRelapseComplete: () async {
          await Future.delayed(const Duration(milliseconds: 800));
          ref.read(dashboardViewmodelProvider.notifier).refreshData();
          if (context.mounted) {
            showTopSnackBar(
              context,
              'Counter reset. Starting fresh now.',
              backgroundColor: AppColors.dangerRed,
              icon: Icons.refresh,
            );
          }
        },
      ),
    );
  }

  void _navigateToStats(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StatsScreen()),
    );
  }

  void _navigateToJournalHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JournalHistoryScreen()),
    );
  }

  void _navigateToMilestones(BuildContext context, int currentStreakDays) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MilestonesScreen(currentStreakDays: currentStreakDays),
      ),
    );
  }

  void _navigateToPanicMode(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const PanicScreen(),
      ),
    );
  }

  void _navigateToAbout(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AboutScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
