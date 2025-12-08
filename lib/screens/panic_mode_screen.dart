import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math';
import '../reclaim_service.dart';

enum PanicMode { breathing, flashcard, audio, journal }

class PanicModeScreen extends StatefulWidget {
  const PanicModeScreen({super.key});

  @override
  State<PanicModeScreen> createState() => _PanicModeScreenState();
}

class _PanicModeScreenState extends State<PanicModeScreen> {
  // State: Mode selection (starts null to show menu)
  PanicMode? _currentMode;
  final ReclaimService _service = ReclaimService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    // 1. HAPTIC SHOCK: Immediate physical feedback upon opening
    HapticFeedback.heavyImpact();
  }

  Future<void> _setupAudio() async {
     // Ensure you have added 'assets/audio/meditation_1.mp3' to pubspec
     await _audioPlayer.setSource(AssetSource('audio/meditation_1.mp3'));
     _audioPlayer.onPlayerStateChanged.listen((state) {
       if (mounted) {
         setState(() => _isPlayingAudio = state == PlayerState.playing);
       }
     });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _finishUrgeSurfing() {
    // Vibrate to signal success
    HapticFeedback.mediumImpact();
    // Log success to Supabase
    _service.logPanic(wasSuccessful: true);
    // Close screen
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFFB4F8C8),
        content: Text("You won this round. Good job.", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
      )
    );
  }


  @override
  Widget build(BuildContext context) {
    // Full screen, pitch black, no distractions
    return Scaffold(
      backgroundColor: Colors.black, 
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => Navigator.pop(context), // Exit if they give up
        ),
        title: Text("URGE SURFING MODE", style: GoogleFonts.spaceGrotesk(color: Colors.red, fontWeight: FontWeight.w900, letterSpacing: 1)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _currentMode == null 
            ? _buildSelectionMenu() 
            : Column(
            children: [
              // The main content area changes based on randomized mode
              Expanded(
                child: _buildModeContent(),
              ),
              
              // The "Exit Strategy" Button
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                   style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB4F8C8), // Success Green
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _finishUrgeSurfing,
                  child: Text("I'M OKAY NOW. URGE PASSED.", 
                    style: GoogleFonts.spaceGrotesk(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              ).animate(onPlay: (c) => c.repeat())
               .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.5)), // Subtle attention grabber
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("CHOOSE YOUR WEAPON", 
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        const Text("Select an intervention to break the loop.", 
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 40),
        
        _buildModeButton("BREATHING", "4-7-8 Technique", Icons.air, PanicMode.breathing),
        const SizedBox(height: 16),
        _buildModeButton("FLASHCARDS", "Reality check quotes", Icons.style, PanicMode.flashcard),
        const SizedBox(height: 16),
        _buildModeButton("AUDIO RESET", "Guided meditation", Icons.headphones, PanicMode.audio),
        const SizedBox(height: 16),
        _buildModeButton("VENT JOURNAL", "Write it out", Icons.edit, PanicMode.journal),
      ],
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildModeButton(String title, String subtitle, IconData icon, PanicMode mode) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() {
          _currentMode = mode;
        });
        if (mode == PanicMode.audio) {
          _setupAudio();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildModeContent() {
    switch (_currentMode!) {
      case PanicMode.breathing: return const BreathingExerciseWidget();
      case PanicMode.flashcard: return const FlashcardWidget();
      case PanicMode.audio: return _buildAudioPlayerWidget();
      case PanicMode.journal: return const PanicJournalWidget();
    }
  }

  // --- MODE 3: AUDIO PLAYER WIDGET ---
  Widget _buildAudioPlayerWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.headphones, size: 80, color: Colors.red),
        const SizedBox(height: 30),
        Text("2-Minute Reset", style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const Text("Listen. Don't act.", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 50),
        
        GestureDetector(
          onTap: () async {
            HapticFeedback.selectionClick();
            if (_isPlayingAudio) {
              await _audioPlayer.pause();
            } else {
              // Ensure asset exists or this will throw error
              await _audioPlayer.resume(); 
            }
          },
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red, width: 4),
              color: _isPlayingAudio ? Colors.red.withOpacity(0.2) : Colors.transparent
            ),
            child: Icon(_isPlayingAudio ? Icons.pause : Icons.play_arrow, size: 60, color: Colors.white),
          ),
        ).animate(target: _isPlayingAudio ? 1 : 0)
         .scaleXY(end: 1.1, duration: 500.ms, curve: Curves.easeInOut) // Pulse while playing
      ],
    ).animate().fadeIn();
  }
}


// --- MODE 1: BREATHING WIDGET (4-7-8 Technique) ---
class BreathingExerciseWidget extends StatefulWidget {
  const BreathingExerciseWidget({super.key});

  @override
  State<BreathingExerciseWidget> createState() => _BreathingExerciseWidgetState();
}

class _BreathingExerciseWidgetState extends State<BreathingExerciseWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _instruction = "INHALE (4s)";

  @override
  void initState() {
    super.initState();
    // Total cycle: 4 + 7 + 8 = 19 seconds
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 19));
    _runBreathingCycle();
  }

  void _runBreathingCycle() async {
     if (!mounted) return;
    setState(() => _instruction = "INHALE (4s)");
    await _controller.animateTo(0.4, duration: const Duration(seconds: 4)); // Inhale to 40% size
    HapticFeedback.lightImpact();

     if (!mounted) return;
    setState(() => _instruction = "HOLD (7s)");
    await Future.delayed(const Duration(seconds: 7)); // Hold state
    HapticFeedback.lightImpact();

     if (!mounted) return;
    setState(() => _instruction = "EXHALE (8s)");
    await _controller.animateTo(0.0, duration: const Duration(seconds: 8)); // Exhale back to 0
    HapticFeedback.heavyImpact();

     if (!mounted) return;
    _runBreathingCycle(); // Loop
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_instruction, 
          style: GoogleFonts.spaceGrotesk(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white))
          .animate(target: _controller.value).fadeIn(), // Slight fade effect on text change
        const SizedBox(height: 50),
        
        // The Visual Breather Circle
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
             // Calculate size based on controller value (0.0 to 0.4)
            double size = 150 + (_controller.value * 300); 
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Gradient that shifts from blue (calm) to red (intense) based on breath phase
                gradient: RadialGradient(
                   colors: [
                    Color.lerp(Colors.blue, Colors.red, _controller.value * 2.5)!.withOpacity(0.5),
                    Colors.black
                   ]
                ),
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2)
              ),
            );
          }
        ),
        const SizedBox(height: 50),
         const Text("Match the circle size.", style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}

// --- MODE 2: FLASHCARD WIDGET ---
class FlashcardWidget extends StatelessWidget {
  const FlashcardWidget({super.key});

  final List<String> quotes = const [
    "A moment of discomfort is better than a day of regret.",
    "You are not your urges. You are the observer of them.",
    "Resetting now means going through this exact same feeling again later.",
    "Dopamine is lying to you right now.",
    "Visualize your future self thanking you for stopping here.",
  ];

  @override
  Widget build(BuildContext context) {
    String randomQuote = quotes[Random().nextInt(quotes.length)];

    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.red.withOpacity(0.5), width: 2)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             const Icon(Icons.format_quote_rounded, color: Colors.red, size: 40),
             const SizedBox(height: 20),
            Text(
              randomQuote.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22, 
                fontWeight: FontWeight.w900, 
                color: Colors.white,
                height: 1.2
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).fadeIn();
  }
}


// --- MODE 4: JOURNAL WIDGET ---
class PanicJournalWidget extends StatefulWidget {
  const PanicJournalWidget({super.key});

  @override
  State<PanicJournalWidget> createState() => _PanicJournalWidgetState();
}

class _PanicJournalWidgetState extends State<PanicJournalWidget> {
  final TextEditingController _controller = TextEditingController();
  // We don't save this to DB here, we just let them vent.
  // Saving happens when they click "I'm Okay Now"

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("VENT IT OUT.", style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.red)),
        const SizedBox(height: 10),
        const Text("Write exactly what you are feeling right now instead of acting on it. Don't filter.", 
           style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 30),
        Expanded(
          child: Container(
             padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withOpacity(0.3))
              ),
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              maxLines: null, // Infinite lines
              decoration: const InputDecoration(
                hintText: "I feel...",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none
              ),
               onChanged: (val) {
                 // Subtle haptic feedback while typing during panic mode
                 if (val.length % 5 == 0) HapticFeedback.selectionClick();
               },
            ),
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}