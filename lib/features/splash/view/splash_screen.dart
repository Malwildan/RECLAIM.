import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/constants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildGlitchText(const Color(0xFFFF0000))
                    .animate()
                    .hide()
                    .then(delay: 1500.ms)
                    .show()
                    .move(
                      begin: const Offset(-3, 0),
                      end: const Offset(-6, 0),
                      duration: 100.ms,
                    )
                    .fadeOut(duration: 50.ms)
                    .then(delay: 50.ms)
                    .fadeIn(duration: 50.ms)
                    .then(delay: 100.ms)
                    .fadeOut(duration: 50.ms),
                _buildGlitchText(const Color(0xFF00FFFF))
                    .animate()
                    .hide()
                    .then(delay: 1550.ms)
                    .show()
                    .move(
                      begin: const Offset(3, 0),
                      end: const Offset(6, 0),
                      duration: 100.ms,
                    )
                    .fadeOut(duration: 50.ms)
                    .then(delay: 50.ms)
                    .fadeIn(duration: 50.ms)
                    .then(delay: 100.ms)
                    .fadeOut(duration: 50.ms),
                Text(
                      "RECLAIM.",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -2,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                    .then(delay: 700.ms)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(15, 15),
                      duration: 500.ms,
                      curve: Curves.easeInExpo,
                    )
                    .shake(hz: 4, rotation: 0.05, duration: 500.ms)
                    .fadeOut(duration: 300.ms, curve: Curves.easeIn),
              ],
            ),
          ),
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
