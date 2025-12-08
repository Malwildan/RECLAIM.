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
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .move(begin: const Offset(-3, 0), end: const Offset(-6, 0), duration: 100.ms)
                    .fadeIn(duration: 50.ms)
                    .then(delay: 2000.ms) // Wait
                    .fadeOut(duration: 50.ms) // Glitch out
                    .then(delay: 50.ms)
                    .fadeIn(duration: 50.ms) // Glitch in
                    .then(delay: 100.ms)
                    .fadeOut(duration: 50.ms)
                    .then(delay: 50.ms)
                    .fadeIn(duration: 50.ms)
                    .then(delay: 200.ms)
                    .fadeOut(duration: 50.ms),

                // Glitch Layer 2 (Cyan - Right Offset)
                _buildGlitchText(const Color(0xFF00FFFF))
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .move(begin: const Offset(3, 0), end: const Offset(6, 0), duration: 100.ms)
                    .fadeIn(duration: 50.ms)
                    .then(delay: 2100.ms) // Slightly desynced
                    .fadeOut(duration: 50.ms)
                    .then(delay: 50.ms)
                    .fadeIn(duration: 50.ms)
                    .then(delay: 100.ms)
                    .fadeOut(duration: 50.ms)
                    .then(delay: 50.ms)
                    .fadeIn(duration: 50.ms)
                    .then(delay: 200.ms)
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
                ).animate(onPlay: (c) => c.repeat())
                 .shimmer(duration: 2500.ms, color: const Color(0xFFB4F8C8).withOpacity(0.5))
                 .shake(hz: 0.2, rotation: 0.03) // Slower shake, slightly more rotation
              ],
            ).animate() // Entrance Impact
             .scale(begin: const Offset(3, 3), end: const Offset(1, 1), duration: 400.ms, curve: Curves.easeOutExpo)
             .fadeIn(duration: 50.ms)
             .shake(hz: 4, curve: Curves.easeInOut, duration: 400.ms, rotation: 0.05),
          ),

          // Flash Overlay
          IgnorePointer(
            child: Container(color: Colors.white.withOpacity(0.1))
                .animate()
                .fadeOut(duration: 500.ms, curve: Curves.easeOut),
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
