import 'package:Reclaim/actions_sheets.dart';
import 'package:Reclaim/screens/panic_mode_screen.dart';
import 'package:Reclaim/screens/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import 'reclaim_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ljvfxaexorrcsblnzyjp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxqdmZ4YWV4b3JyY3NibG56eWpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUwOTA3OTQsImV4cCI6MjA4MDY2Njc5NH0.yvGlZV2DdN_TSHiJZaUXxq0AIxlnpsF1767oZdk3fTg',
  );

  runApp(const ReclaimApp());
}

class ReclaimApp extends StatelessWidget {
  const ReclaimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reclaim',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050505), // Pitch black
        useMaterial3: true,
        textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}



class _DashboardScreenState extends State<DashboardScreen> {
  final ReclaimService _service = ReclaimService();
  
  // Default to 0 until data loads
  Duration currentStreak = Duration.zero; 
  DateTime? streakStartTime;
  Timer? _timer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    // 1. Log them in (Anonymously for now)
    await _service.ensureLoggedIn();
    
    // 2. Get the real start time from Supabase
    streakStartTime = await _service.getStreakStart();
    
    setState(() {
      isLoading = false;
      _updateStreakDuration(); // Calculate initial duration
    });

    // 3. Start the ticker to update UI every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (streakStartTime != null) {
        setState(() {
          _updateStreakDuration();
        });
      }
    });
  }

  // Helper to do the math
  void _updateStreakDuration() {
    final now = DateTime.now();
    if (streakStartTime != null) {
      final start = streakStartTime!.toLocal();
      final diff = now.difference(start);
      currentStreak = diff.isNegative ? Duration.zero : diff;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildBentoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: textColor.withOpacity(0.9), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      )),
                  const SizedBox(height: 4),
                  Text(content,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFB4F8C8))),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("RECLAIM.",
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -1)),
                      
                  // THE RELAPSE BUTTON
                  GestureDetector(
                    onTap: () {
                      // Show the Relapse Analysis Sheet
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true, // Allows keyboard to push sheet up
                        backgroundColor: Colors.transparent,
                        builder: (context) => RelapseAnalysisSheet(
                          onRelapseComplete: () {
                            // Refresh the dashboard data after reset
                            _initData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Counter reset. Learn from this."))
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF222222),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.withOpacity(0.3))
                      ),
                      child: const Text("I Relapsed", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),

              // STREAK COUNTER (Same design, real data)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFB4F8C8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("CURRENT STREAK",
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "${currentStreak.inDays}",
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 60,
                              height: 1,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 5),
                        const Text("DAYS",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    // Monospace Timer for precision
                    Text(
                      "${(currentStreak.inHours % 24).toString().padLeft(2, '0')} : "
                      "${(currentStreak.inMinutes % 60).toString().padLeft(2, '0')} : "
                      "${(currentStreak.inSeconds % 60).toString().padLeft(2, '0')}",
                      style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Courier',
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),

              const SizedBox(height: 16),
              
              // 3. The Bento Grid (Mood & Leveling System)
              Row(
                children: [
                  // LEFT CARD: MOOD (Keep as is, or simplify)
                  Expanded(
                    child: _buildBentoCard(
                      title: "LAST LOG",
                      content: "Anxious", // In a real app, fetch this from DB
                      icon: Icons.bubble_chart,
                      color: const Color(0xFF1A1A1A),
                      textColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // RIGHT CARD: LEVEL SYSTEM (Dynamic)
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final int days = currentStreak.inDays;
                        final currentLvl = LevelSystem.getCurrentLevel(days);
                        final nextLvl = LevelSystem.getNextLevel(days);
                        final double progress = LevelSystem.getProgressToNextLevel(days);

                        return Container(
                          height: 100,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.05))
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Text Info
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(Icons.shield_outlined, color: Colors.grey, size: 20),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("LEVEL", 
                                        style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold)),
                                      Text(currentLvl['title'], 
                                        style: TextStyle(
                                          color: currentLvl['color'], 
                                          fontSize: 16, 
                                          fontWeight: FontWeight.w900,
                                          shadows: [Shadow(color: (currentLvl['color'] as Color).withOpacity(0.5), blurRadius: 10)]
                                        )),
                                    ],
                                  )
                                ],
                              ),
                              
                              // Circular XP Bar
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Background Circle
                                  SizedBox(
                                    width: 50, height: 50,
                                    child: CircularProgressIndicator(
                                      value: 1.0,
                                      strokeWidth: 5,
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  // Progress Circle
                                  SizedBox(
                                    width: 50, height: 50,
                                    child: CircularProgressIndicator(
                                      value: progress,
                                      strokeWidth: 5,
                                      backgroundColor: Colors.transparent,
                                      color: currentLvl['color'],
                                      strokeCap: StrokeCap.round,
                                    ),
                                  ),
                                  // Days left text in center
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("${(nextLvl['days'] as int) - days}", 
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                                      const Text("LEFT", 
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 6, color: Colors.grey)),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      }
                    ),
                  ),
                ],
              ).animate().fadeIn().slideY(begin: 0.2, end: 0, delay: 100.ms),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StatsScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    // A subtle gradient to make it distinct from the check-in card
                    gradient: LinearGradient(
                      colors: [const Color(0xFF1A1A1A), const Color(0xFF111111)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      // Left: Icon + Text
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF222222),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.insights, color: Color(0xFFB4F8C8), size: 24),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("DATA ANALYTICS", 
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14, 
                              fontWeight: FontWeight.bold, 
                              color: Colors.white,
                              letterSpacing: 1
                            )),
                          Text("View your trigger patterns", 
                            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                      
                      const Spacer(),

                      // Right: A mini "Fake Chart" visual for aesthetic
                      SizedBox(
                        width: 40,
                        height: 20,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniBar(10),
                            _buildMiniBar(20),
                            _buildMiniBar(15),
                            _buildMiniBar(25),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.2, end: 0, delay: 300.ms),
              ),

              const SizedBox(height: 16),
              // THE CHECK-IN CARD (Clickable)
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const DailyCheckInSheet(),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF333333)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Daily Check-in",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("Log your mood & triggers.",
                              style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, color: Colors.black, size: 16),
                      )
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.2, end: 0, delay: 200.ms),
              ),

              // ... [Your Daily Check-in Card is above here] ...

              const SizedBox(height: 16),

              // NEW: ANALYTICS TEASER CARD
              
              // ... [The Spacer() and Panic Button are below here] ...

              const Spacer(),

              // PANIC BUTTON (Real Logic Added)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (context) => PanicModeScreen()));
                },
                child: Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4B4B),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4B4B).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bolt, color: Colors.white, size: 30),
                      const SizedBox(width: 10),
                      Text("PANIC BUTTON",
                          style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1)),
                    ],
                  ),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .scaleXY(begin: 1.0, end: 1.02, duration: 1000.ms),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for the mini chart visual
  Widget _buildMiniBar(double height) {
    return Container(
      width: 6,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

}

class LevelSystem {
  // The thresholds for leveling up
  static final List<Map<String, dynamic>> levels = [
    {'days': 0, 'title': 'GLITCH', 'color': Color(0xFF666666)},      // Grey
    {'days': 3, 'title': 'NOVICE', 'color': Color(0xFFFFFFFF)},      // White
    {'days': 7, 'title': 'APPRENTICE', 'color': Color(0xFFB4F8C8)},  // Mint
    {'days': 14, 'title': 'ADEPT', 'color': Color(0xFF64FFDA)},      // Teal
    {'days': 30, 'title': 'VANGUARD', 'color': Color(0xFF448AFF)},   // Blue
    {'days': 60, 'title': 'TITAN', 'color': Color(0xFFAA00FF)},      // Purple
    {'days': 90, 'title': 'GOD MODE', 'color': Color(0xFFFFD700)},   // Gold
  ];

  static Map<String, dynamic> getCurrentLevel(int streakDays) {
    // Find the highest level the user has achieved
    return levels.lastWhere((lvl) => streakDays >= lvl['days'], 
        orElse: () => levels[0]);
  }

  static Map<String, dynamic> getNextLevel(int streakDays) {
    // Find the first level that is strictly greater than current days
    return levels.firstWhere((lvl) => lvl['days'] > streakDays, 
        orElse: () => {'days': 9999, 'title': 'MAXED OUT'});
  }

  static double getProgressToNextLevel(int streakDays) {
    final current = getCurrentLevel(streakDays);
    final next = getNextLevel(streakDays);
    
    if (next['days'] == 9999) return 1.0; // Max level

    // Math: (Current Streak - Level Start) / (Next Level Start - Level Start)
    int daysIntoLevel = streakDays - (current['days'] as int);
    int levelDuration = (next['days'] as int) - (current['days'] as int);
    
    return daysIntoLevel / levelDuration;
  }
}