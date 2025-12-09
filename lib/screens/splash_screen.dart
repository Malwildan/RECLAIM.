import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glitch Layer 1 (Red - Left Offset)
                _buildGlitchText(const Color(0xFFFF0000))
                    .animate()
                    .hide()
                    .then(delay: 1500.ms)
                    .show()
                    .move(begin: const Offset(-3, 0), end: const Offset(-6, 0), duration: 100.ms)
                    .fadeOut(duration: 50.ms)
                    .then(delay: 50.ms)
                    .fadeIn(duration: 50.ms)
                    .then(delay: 100.ms)
                    .fadeOut(duration: 50.ms),

                // Glitch Layer 2 (Cyan - Right Offset)
                _buildGlitchText(const Color(0xFF00FFFF))
                    .animate()
                    .hide()
                    .then(delay: 1550.ms)
                    .show()
                    .move(begin: const Offset(3, 0), end: const Offset(6, 0), duration: 100.ms)
                    .fadeOut(duration: 50.ms)
                    .then(delay: 50.ms)
                    .fadeIn(duration: 50.ms)
                    .then(delay: 100.ms)
                    .fadeOut(duration: 50.ms),

                // Main Text
                Text(
                  "RECLAIM.",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -2,
                  ),
                ).animate()
                 .fadeIn(duration: 800.ms, curve: Curves.easeOut) // Gentle Entry
                 .then(delay: 700.ms) // Wait
                 // IMPACT EXIT: Zoom in violently + Shake
                 .scale(begin: const Offset(1, 1), end: const Offset(15, 15), duration: 500.ms, curve: Curves.easeInExpo)
                 .shake(hz: 4, rotation: 0.05, duration: 500.ms)
                 .fadeOut(duration: 300.ms, curve: Curves.easeIn),
              ],
            ),
          ),

          // Flash Overlay (At the end)
          IgnorePointer(
            child: Container(color: Colors.white)
                .animate(delay: 1800.ms)
                .fadeIn(duration: 50.ms)
                .fadeOut(duration: 200.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildGlitchText(Color color) {
    return Text(
      "RECLAIM.",
      style: GoogleFonts.spaceGrotesk(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: color.withOpacity(0.7),
        letterSpacing: -2,
      ),
    );
  }
}
